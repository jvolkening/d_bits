#!/usr/bin/env rdmd

import std.stdio;
import std.conv;
import seq;
import fasta;

int main(string[] args) {

    string fn_fa = args[1];
    string fn_ix = fn_fa ~ ".fai";

    auto id = args[2];
    
    // start and end are optional
    ulong start = 1;
    if (args.length > 3) {
        start = to!ulong(args[3]);
    }

    ulong end = -1;
    if (args.length > 4) {
        end = to!ulong(args[4]);
    }

    auto fa = Fasta();

    fa.load(fn_fa);
    fa.load_index(fn_ix);

    Seq seq;
    fa.fetch_seq(seq, id, start, end);
    write(seq.as_fasta);

    return 0;

}

