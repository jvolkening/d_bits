#!/usr/bin/env rdmd

import std.algorithm : reduce, splitter, max, map;
import std.conv      : to;
import std.getopt;
import std.stdio;
import std.digest.md;
import std.array;

enum PROGRAM = "md5sum";
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

    // could be re-written using std:algorithm ???
    auto files = fns.map!(a => File(a))().array();
    if (! files.length) files = [ stdin ];

    // iterate over filenames
    foreach (file; files) {

        auto hash = digest!MD5(file.byChunk(4096));
        auto name = file.name.length > 0
            ? file.name
            : "-";
        writeln( hash.toHexString!(LetterCase.lower) ~ "  " ~ name );

    }

    return 0;
}

void printOpts( Option[] opts ) {

    writeln(q"[
Usage: wc [OPTION]... [FILE]...
Print newline, word, and byte counts for each FILE, and a total line if
more than one FILE is specified.  With no FILE, or when FILE is -,
read standard input.  A word is a non-zero-length sequence of characters
delimited by white space.
The options below may be used to select which counts are printed, always in
the following order: newline, word, character, byte, maximum line length.
]");

    foreach (opt; opts) {
        writefln("%5s %-17s %s", opt.optShort, opt.optLong, opt.help);
    }


    writeln(q"[

Full documentation at: <http://foo.bar/wc>
]");

}

void printVersion() {

    writeln; // I like a little whitespace
    writeln( PROGRAM ~ " " ~ to!string(VERSION) );
    writeln(q"[
Copyright (C) 2017 Jeremy Volkening
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Written by Jeremy Volkening
]");

}
