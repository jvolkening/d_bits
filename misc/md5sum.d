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

    bool vers;

    // parse command-line arguments
    auto opts = getopt( args,
        std.getopt.config.caseSensitive,
        std.getopt.config.bundling,
        "version", "output version information and exit", &vers,
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
Usage: md5sum [OPTION]... [FILE]...
Print or check MD5 (128-bit) checksums.
]");

    foreach (opt; opts) {
        writefln("%5s %-17s %s", opt.optShort, opt.optLong, opt.help);
    }


    writeln(q"[

Full documentation at: <http://foo.bar/md5sum>
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
