module seq;

import std.array : appender;
import std.algorithm : min;
import std.range : iota;

struct Seq {

    string seq;
    string id;
    string desc;
    string qual;

    static int ll = 60;

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

}

