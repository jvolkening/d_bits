module fasta;

import std.stdio;
import std.array;
import std.string;
import std.regex;
import std.conv;
import std.format;
import std.file;
import std.math;
import seq;

struct Fasta {

    File foo;
    File f_idx;
    char[] seq;
    string id;
    string desc;
    ulong[][string] idx;


    void load(string fn) {
       
        foo = File(fn, "r");

    }

    void load_index(string fn) {

        string id;
        ulong a,b,c,d;

        string x = to!string( std.file.read(fn) );

        while (x.length > 0) {
            formattedRead(x, "%s\t%s\t%s\t%s\t%s\n", &id, &a, &b, &c, &d);
            idx[id] = [a, b, c, d];
        }

    }

    bool fetch_seq(out Seq ret, string id, long start = 1, long end = -1) {

        auto  len = idx[id][0];
        auto  off = idx[id][1];
        auto  bpl = idx[id][2];
        auto  eol = idx[id][3] - bpl;

        end = end >= 0 ? end : len;

        --start;

        foo.seek(off + start + start/bpl*eol, 0);
        len = end - start;
        auto rlen = len + len/bpl*eol;
        auto buf  = foo.rawRead(new char[rlen]);
        auto seq  = tr(buf," \t\n\r","","d");

        ret.id  = id;
        ret.seq = seq;

        return true;

    }
        
    bool next_seq(out Seq ret) {

        auto builder = appender!string;
        builder.reserve(4096); // can speed up, not much memory overhead

        if (foo.eof) return false;

        char[] ln;
        while (foo.readln(ln)) {
            if (ln[0] == '>') {
                bool first = id.length == 0;
                seq = builder.data.dup;
                ret.seq  = seq;
                ret.id   = id;
                ret.desc = desc;

                auto ws = indexOfAny(ln, " \t");
                if (ws >= 0) {
                    id = ln[1..ws].dup;
                    auto nws = indexOfNeither(ln, " \t", ws);
                    desc = ln[nws..$-1].dup;
                }
                assert(id.length > 0);
                if (! first) return true;
            }
            else {
                builder.put(ln.chomp);
            }
        }
        seq = builder.data.dup;
        ret.seq  = seq;
        ret.id   = id;
        ret.desc = desc;
        return true;

    }


}
