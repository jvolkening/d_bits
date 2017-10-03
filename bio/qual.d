#!/usr/bin/env rdmd

import std.stdio;
import std.string    : format;
import std.array     : array;
import std.algorithm : map,sum,sort;
import std.conv      : to;
import seq;
import fastq;

int main(string[] args) {

    auto fq = Fastq();

    fq.load(args[1]);

    ubyte[][] quals;
    ulong max = 0;

    Seq seq;
    while (fq.next_seq(seq)) {
        if (max < seq.qual.length) {
            max = seq.qual.length;
        }
        quals ~= to!(ubyte[])(seq.qual.map!"a-33".array);
        //writeln(q);
        //quals ~= cast(ubyte[])q.map!(a => a-33).array;
        //writeln(quals);
    }
    writeln(max);

    for (ushort i = 0; i < max; ++i) {
        ubyte[] s;
        s.reserve(max);
        ulong l = 0;
        foreach (q; quals) {
            if (q.length <= i) {
                continue;
            }
            s ~= q[i];
            ++l;
        }
        //s.sort!("a < b");
        //ubyte m  = s[ s.length/2   ];
        //ubyte Q1 = s[ s.length/4   ];
        //ubyte Q3 = s[ s.length/4*3 ];
        //double mu = s.sum/l;
        //writeln(format("%s %s %s %s", mu, m, Q1, Q3));
    }


    return 0;

}

