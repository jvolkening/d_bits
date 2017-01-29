module twobit;

import std.stdio;
import std.array;
import std.string;
import std.regex;
import std.conv;
import std.format;
import std.file;
import std.math;
import seq;
import std.bitmanip;
import std.system;

struct TwoBit {

    File file;

    uint[string] idx;
    string[] ids;
    uint seqCount;
    uint currSeq = 0;
    bool swap_bytes;

    enum uint le_magic = 0x1A412743;
    enum uint be_magic = 0x4327411A;

    enum bmap = "TCAG";

    enum headField {
        magic,
        vers,
        seqCount,
        empty
    };


    // called to initialize object

    void load(string fn) {
       
        file = File(fn, "rb");
        check_header();
        build_index();
        //write_seqs();

    }

    bool next_seq (out Seq ret) {

        if (currSeq == seqCount) return false;

        fetch_seq( ret, ids[currSeq++] );

        return true;

    }

    void fetch_seq(out Seq ret, string id) {

        // seek to start of record
        auto offset = idx[id];
        file.seek(offset, 0);

        // read sequence count
        ubyte[4] buffer;
        file.rawRead(buffer);
        uint seqLen = convert(buffer);

        // read masking blocks
        uint[] nStarts;
        uint[] nLens;

        uint[] maskStarts;
        uint[] maskLens;

        read_block( nStarts,    nLens    );
        read_block( maskStarts, maskLens );

        // empty field
        file.rawRead(buffer);
        assert(
            convert(buffer) == 0,
            "Reserved field must be 0"
        );

        // unpack sequence data
        ubyte[] raw_seq;
        raw_seq.length = (seqLen + 3)/4;

        char[] seq;
        seq.length = seqLen;

        file.rawRead(raw_seq);

        foreach (i; 0..seqLen) {
            
            seq[i] = bmap [
                ( raw_seq[i/4] >> 2*(3-i%4) ) & 0x3
            ];
            ++i;

        }
        foreach (t, s; nStarts) {
            seq[s..s+nLens[t]] = 'N';
        }
        foreach (t, s; maskStarts) {
            seq[s..s+maskLens[t]] += 32;
        }

        ret.id = id; 
        ret.seq = seq;
                
    }
            
    void read_block (ref uint[] starts, ref uint[] lens) {

        ubyte[] buffer;

        buffer.length = 4;
        file.rawRead(buffer);
        uint blocks = convert(buffer[0..4]);

        if (blocks > 0) {

            buffer.length = blocks * 4;
            file.rawRead(buffer);

            starts.length = blocks;

            for (int i = 0; i < blocks; ++i) {
                ubyte[4] start = buffer[ (i*4)..(i*4+4) ];
                starts[i] = convert(start);
            }

            file.rawRead(buffer);

            lens.length = blocks;

            for (int i = 0; i < blocks; ++i) {
                ubyte[4] start = buffer[ (i*4)..(i*4+4) ];
                lens[i] = convert(start);
            }

        }
    }
 

    void check_header() {

        uint[] head;
        head.length = 4;
        file.rawRead(head);

        // determine endianness by magic sequence
        uint magic = head[ headField.magic ];
        if (magic == be_magic) {
            swap_bytes = true;
        }
        else if (magic == le_magic) {
            swap_bytes = false;
        }
        else { throw new Exception("Bad magic byte"); }
     
        // read version number
        assert(
            head[ headField.vers ] == 0,
            "Format version must be zero"
        );

        // read sequence count
        seqCount = head[ headField.seqCount ];
        if (swap_bytes) { seqCount = swapEndian(seqCount); }
        ids.length = seqCount;

        // check reserved field
        assert(
            head[ headField.empty ] == 0,
            "Reserved field must be zero"
        );


    }

    void build_index() {

        ubyte[1] idLen;
        char[]   id;
        uint[1]  offset;

        for (uint i = 0; i < seqCount; ++i) {
            file.rawRead(idLen);
            id.length = idLen[0];
            file.rawRead(id);
            file.rawRead(offset);
            auto sid = id.idup;
            idx[sid] = offset[0];
            ids[i] = sid;
        }

    }

    uint convert(ubyte[4] a) {

        version(BigEndian) {
            if (swap_bytes) {
                return a.littleEndianToNative!uint();
            }
            else {
                return a.bigEndianToNative!uint();
            }
        }
        version(LittleEndian) {
            if (swap_bytes) {
                return bigEndianToNative!uint(a);
            }
            else {
                return littleEndianToNative!uint(a);
            }
        }

    }


}
