#!/usr/bin/env rdmd

import std.algorithm;
import std.conv;
import std.file;
import std.getopt;
import std.stdio;

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
    bool print_L; // longest line

    // parse command-line arguments
    getopt( args,
        "l|lines",           &print_l,
        "w|words",           &print_w,
        "m|chars",           &print_c,
        "c|bytes",           &print_b,
        "L|max-line-length", &print_L,
    );

    // default is to pring word, line, and byte counts
    if ( !( print_b || print_c || print_l || print_w || print_L) ) {
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

        //foreach(wchar[] line; lines(file)) {
        foreach (line; file.byLine(KeepTerminator.yes)) {


            // count lines
            if (print_l && line[$-1] == '\n') {
                ++lLineCount;
            }

            // the conversion to dchar is slow, so skip if possible
            if (! (print_c || print_L || print_w) ) {
                continue;
            }

            // necessary to properly handle wide characters
            dchar[] dline = to!(dchar[])(line);

            // putting conditionals around the rest of these seems to make no
            // noticeable difference in speed, so they are left out

            // count characters
            lCharCount += dline.length;

            // track max line length
            if (dline.length > lMaxLine) {
                lMaxLine = dline.length;
                if (dline[$-1] == '\n') --lMaxLine;
            }

            // count words
            // splitter() is faster than split() !!!
            foreach(dchar[] word; splitter(dline)) {
                lWordCount += 1;
            }

        }

        ulong[] vals;
        if (print_l) vals ~= lLineCount;
        if (print_w) vals ~= lWordCount;
        if (print_c) vals ~= lCharCount;
        if (print_b) vals ~= lByteCount;
        if (print_L) vals ~= lMaxLine;

        // emulate coreutils - recalculate field length for single files
        if (fns.length < 2) {
            l_field = to!int( reduce!(max)( map!(a => (to!string(a).length))(vals) ) );
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
        if (print_L) vals ~= maxLine;

        foreach (val; vals) {
            writef("%*s ", l_field, val);
        }
        writeln("total");

    }

    return 0;
}
