module fastq;

import std.stdio;
import std.array;
import std.string;
import std.regex;
import std.conv;
import std.format;
import std.file;
import std.math;
import seq;

struct Fastq {

    File foo;
    File f_idx;
    char[] seq;
    string id;
    char[] qual;
    string desc;


    void load(string fn) {
       
        foo = File(fn, "r");

    }

    bool next_seq(out Seq ret) {

        if (foo.eof) {
            return false;
        }

        char[] ln;
        foo.readln(ln);
        if (foo.eof) {
            if (ln.chomp.length == 0) {
                return false;
            }
            else {
                throw new Exception("Unexpected EOF");
            }
        }
        if (ln[0] != '@') {
            throw new Exception("Bad FASTQ format (missing ID token");
        }
        auto ws = indexOfAny(ln, " \t");
        if (ws >= 0) {
            id = ln[1..ws].dup;
            auto nws = indexOfNeither(ln, " \t", ws);
            desc = ln[nws..$-1].dup;
        }
        else {
            id   = ln[1..$-1].dup;
            desc = "";
        }
        assert(id.length > 0);
        foo.readln(ln);
        seq = ln.chomp.dup;
        foo.readln(ln);
        foo.readln(ln);
        qual = ln.chomp.dup;

        ret.seq  = seq;
        ret.id   = id;
        ret.desc = desc;
        ret.qual = qual;
        return true;

    }

}
