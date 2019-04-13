# OCaml Serializer Benchmarks

In order to get a rough idea of the cost of serialization and de-serialization in various formats implemented in OCaml, I created this quick benchmark.

## Formats Tested

### Bin_prot

* [OCaml-only] Jane Street's `Bin_prot` (a.k.a. `bin-io`) reference implementation;

### Google Protocol Buffers

* [Cross-platform] `ocaml-protoc`, from a Protobuf IDL
* [OCaml-centric] `ppx_deriving_protobuf`, from type definitions (can _generate_ a Protobuf IDL)

### JSON

* [Cross-platform] Type-safe with `ocaml-protoc-yojson`, from a Protobuf IDL
* [OCaml-centric] Type-safe with `atd` in front of `yojson`, from an ATD IDL
* [OCaml-centric] Type-safe with `ppx_deriving_yojson`
* [Cross-platform] Unsafe with `yojson` (would require manual marshalling, not tested here)

### Apache Thrift

My quick hack `thrift_buffer_transport.ml` is still included, in case anyone with OCaml 4.06 or lower wants to try it out.  On my laptop, Thrift Compact Binary was an order of magnitude slower than `ocaml-protoc` binary, so I lost interest.  (This was consistent with my Perl and JavaScript tests.)

## Results

These ran on my Intel® Core™ i7-8650U CPU @ 1.90GHz:

```text
┌──────────────────────────┬─────────────┬───────────┬──────────┬──────────┬────────────┐
│ Name                     │    Time/Run │   mWd/Run │ mjWd/Run │ Prom/Run │ Percentage │
├──────────────────────────┼─────────────┼───────────┼──────────┼──────────┼────────────┤
│ binprot: rw              │    964.66ns │   399.00w │    0.32w │    0.32w │      5.77% │
│ protobuf-bin: rw         │  3_474.85ns │ 2_524.04w │  261.37w │    3.37w │     20.77% │
│ deriving-protobuf: rw    │  3_652.92ns │ 2_623.07w │  261.62w │    3.62w │     21.83% │
│ atd-yojson: rw           │ 13_700.66ns │ 2_429.01w │  262.07w │    4.07w │     81.88% │
│ deriving-yojson: rw      │ 16_250.64ns │ 2_501.10w │  276.84w │    3.84w │     97.12% │
│ protobuf-json: rw        │ 16_732.08ns │ 2_083.08w │  285.34w │    3.34w │    100.00% │
│ yojson-no-marshal: rw    │ 15_445.61ns │ 1_666.03w │  275.92w │    2.92w │     92.31% │
│ binprot: read            │    479.05ns │   372.00w │    0.21w │    0.21w │      2.86% │
│ binprot: write           │    465.85ns │    27.00w │          │          │      2.78% │
│ protobuf-bin: read       │  1_018.48ns │ 1_214.02w │    1.47w │    1.47w │      6.09% │
│ protobuf-bin: write      │  2_359.66ns │ 1_310.01w │  258.37w │    0.37w │     14.10% │
│ deriving-protobuf: read  │  1_050.04ns │ 1_313.03w │    1.84w │    1.84w │      6.28% │
│ deriving-protobuf: write │  2_205.48ns │ 1_310.02w │  258.61w │    0.61w │     13.18% │
│ atd-yojson: read         │  7_212.93ns │ 1_977.01w │    4.04w │    4.04w │     43.11% │
│ atd-yojson: write        │  5_354.93ns │   452.01w │  258.13w │    0.13w │     32.00% │
│ deriving-yojson: read    │  8_175.88ns │ 1_645.03w │    3.66w │    3.66w │     48.86% │
│ deriving-yojson: write   │  7_227.02ns │   856.02w │  273.41w │    0.41w │     43.19% │
│ protobuf-json: read      │  8_397.90ns │ 1_208.02w │    2.78w │    2.78w │     50.19% │
│ protobuf-json: write     │  7_631.51ns │   875.05w │  282.59w │    0.59w │     45.61% │
└──────────────────────────┴─────────────┴───────────┴──────────┴──────────┴────────────┘
```

From this very simple test, we can derive a few tentative conclusions:

* Jane Street's `Bin_prot` (a.k.a. `bin-io`) is 3x as fast as binary Protobuf (keep in mind some of it is coded in C);

* For binary Protobuf, `ocaml-protoc` and `ppx_deriving_protobuf` perform identically;

* `atd-yojson` is marginally more performant than the other JSON codecs, including bare `Yojson` strangely enough;

## MIT License

MIT License

Copyright (c) 2019 Graph X Design

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

