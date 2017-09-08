#!/usr/bin/env rdmd

import std.stdio;
import seq;
import twobit;
import std.exception;


int main(string[] args) {

   auto fa = TwoBit();

   enforce(args.length > 1, "Must specify filename");
   fa.load(args[1]);

   Seq seq;
   while (fa.next_seq(seq)) {
        write(seq.as_fasta);
   }

   return 0;

}

