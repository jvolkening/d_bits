module seq;

import std.array : appender;
import std.algorithm : min;
import std.range : iota;

struct Seq {

    char[] seq;
    char[] qual;
    string id;
    string desc;

    static int ll = 50;

    // format as FASTA
    @property string as_fasta() const {

        auto builder = appender!string;
        builder.put(">" ~ this.id);
        if (this.desc.length > 0) {
            builder.put(" " ~ this.desc);
        }
        builder.put("\n");

        auto len = this.seq.length;
        foreach (start; iota(0, len, ll)) {
            auto end = min(start+ll, len);
            builder.put( this.seq[start..end] );
            builder.put("\n");
        }
        return builder.data;

    }

    // format as FASTQ
    @property string as_fastq() const {

        auto builder = appender!string;
        builder.put("@" ~ this.id);
        if (this.desc.length > 0) {
            builder.put(" " ~ this.desc);
        }
        builder.put("\n");
        builder.put(this.seq);
        builder.put("\n+\n");
        builder.put(this.qual);
        return builder.data;

    }

}

