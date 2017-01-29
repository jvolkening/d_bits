#!/usr/bin/env rdmd

import std.stdio;
import seq;
import twobit;

int main(string[] args) {

   auto fa = TwoBit();

   fa.load(args[1]);

   Seq seq;
   while (fa.next_seq(seq)) {
        write(seq.as_fasta);
   }

   return 0;

}

