#!/usr/bin/env rdmd

import std.stdio;
import seq;
import fastq;

int main(string[] args) {

   auto fq = Fastq();

   fq.load(args[1]);

   Seq seq;
   while (fq.next_seq(seq)) {
        write(seq.as_fasta);
   }

   return 0;

}

