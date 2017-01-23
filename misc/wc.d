#!/usr/bin/env rdmd

import std.algorithm : reduce, splitter, max, map;
import std.conv      : to;
import std.file      : getSize;
import std.getopt;
import std.stdio;

enum PROGRAM = "wc";
enum VERSION = 0.001;

int main(string[] args) {

    ulong lineCount;
    ulong wordCount;
    ulong charCount;
    ulong byteCount;
    ulong maxLine;

    bool print_l; // newlines
    bool print_w; // words
    bool print_c; // characters
    bool print_b; // bytes
    bool print_m; // longest line

    bool vers;

    // parse command-line arguments
    auto opts = getopt( args,
        std.getopt.config.caseSensitive,
        std.getopt.config.bundling,
        "l|lines",           "print the newline counts",             &print_l,
        "w|words",           "print the word counts",                &print_w,
        "m|chars",           "print the character counts",           &print_c,
        "c|bytes",           "print the byte counts",                &print_b,
        "L|max-line-length", "print the length of the longest line", &print_m,
        "version",           "output version information and exit",  &vers,
    );

    // print help message
    if (opts.helpWanted) {
        printOpts(opts.options);
        return(0);
    }

    // print version message
    if (vers) {
        printVersion();
        return(0);
    }

    // default is to pring word, line, and byte counts
    if ( !( print_b || print_c || print_l || print_w || print_m) ) {
        print_l = true;
        print_w = true;
        print_b = true;
    }

    // the rest of arguments should be filenames
    string[] fns = args[1..$];

    // field length is pre-calculated (always based on byte length, even if
    // byte length is not printed
    foreach (fn; fns) {
        byteCount += getSize(fn);
    }
    int l_field = to!int( to!string(byteCount).length );

    // iterate over filenames
    foreach (fn; fns) {

        ulong lLineCount;
        ulong lWordCount;
        ulong lCharCount;
        ulong lByteCount = getSize(fn);
        ulong lMaxLine;

        auto file = File(fn);


        // iterate over lines (might be faster to use byChunk, but that
        // complicates word counting quite a bit
        foreach (line; file.byLine(KeepTerminator.yes)) {

            // don't continue if we only want bytes. This could be implemented
            // as simple outer if() statement but would add another block
            // level, and this hack has virtually no cost
            if (! (print_c || print_m || print_w || print_l) ) {
                break;
            }

            bool has_nl = line[$-1] == '\n'
                ? true
                : false;

            // count newlines
            if (has_nl) {
                ++lLineCount;
            }

            // short circuit if possible
            if (! (print_c || print_m || print_w) ) {
                continue;
            }

            // find actual line length, accounting for wide chars
            // (see UTF-8 spec to understand inequality)
            size_t line_len = 0;
            foreach (b; line) {
                if ( (b >> 6) != 0b10 ) {
                    ++line_len;
                }
            }

            // count chars
            lCharCount += line_len;

            // track max line length
            if (has_nl) --line_len;
            if (line_len > lMaxLine) {
                lMaxLine = line_len;
            }

            // count words
            //splitter() is faster than split() !!!
            foreach(char[] word; splitter(line)) {
                lWordCount += 1;
            }

        }

        ulong[] vals;
        if (print_l) vals ~= lLineCount;
        if (print_w) vals ~= lWordCount;
        if (print_c) vals ~= lCharCount;
        if (print_b) vals ~= lByteCount;
        if (print_m) vals ~= lMaxLine;

        // emulate coreutils - recalculate field length for single files
        if (fns.length < 2) {
            l_field = to!int(
                reduce!(max)(
                map!(a => (to!string(a).length))
                (vals) )
            );
        }
       
        foreach (val; vals) {
            writef("%*s ", l_field, val);
        }
        writeln(fn);

        wordCount += lWordCount;
        lineCount += lLineCount;
        charCount += lCharCount;
        if (maxLine < lMaxLine) {
            maxLine = lMaxLine;
        }
            
    }

    if (fns.length > 1) {

        ulong[] vals;
        if (print_l) vals ~= lineCount;
        if (print_w) vals ~= wordCount;
        if (print_c) vals ~= charCount;
        if (print_b) vals ~= byteCount;
        if (print_m) vals ~= maxLine;

        foreach (val; vals) {
            writef("%*s ", l_field, val);
        }
        writeln("total");

    }

    return 0;
}

void printOpts( Option[] opts ) {

    writeln(q"HERE
Usage: wc [OPTION]... [FILE]...
Print newline, word, and byte counts for each FILE, and a total line if
more than one FILE is specified.  With no FILE, or when FILE is -,
read standard input.  A word is a non-zero-length sequence of characters
delimited by white space.
The options below may be used to select which counts are printed, always in
the following order: newline, word, character, byte, maximum line length.
HERE");

    foreach (opt; opts) {
        writefln("%5s %16s %s", opt.optShort, opt.optLong, opt.help);
    }


    writeln(q"HERE

Full documentation at: <http://foo.bar/wc>
HERE");

}

void printVersion() {

    writeln( PROGRAM ~ " " ~ to!string(VERSION) );
    writeln(q"HERE
Copyright (C) 2017 Jeremy Volkening
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Written by Jeremy Volkening
HERE");

}
