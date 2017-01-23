#!/usr/bin/env rdmd

import std.stdio;
import seq;
import fasta;

int main(string[] args) {

   auto fa = Fasta();

   fa.load(args[1]);

   Seq seq;
   while (fa.next_seq(seq)) {
        write(seq.as_fasta);
   }

   return 0;

}

