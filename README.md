# OCaml Serializer Benchmarks

In order to get a rough idea of the cost of serialization and de-serialization in various formats implemented in OCaml, I created this quick benchmark.

## Formats Tested

### Bin_prot

* [OCaml-only] Jane Street's `Bin_prot` (a.k.a. `bin-io`) reference implementation;

### Google Protocol Buffers

* [Cross-platform] `ocaml-protoc`, from a Protobuf IDL (front-end to `ppx_deriving_protobuf`)
* [OCaml-centric] `ppx_deriving_protobuf`, from type definitions (can _generate_ a Protobuf IDL)

### Cap'n Proto

* [Cross-platform] the IDL and resulting binary data are identical across platforms

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
│ binprot: rw              │    856.28ns │   384.00w │    0.20w │    0.20w │      5.14% │
│ protobuf-bin: rw         │  2_792.29ns │ 1_997.03w │  260.14w │    2.14w │     16.76% │
│ deriving-protobuf: rw    │  3_128.10ns │ 2_513.06w │  262.24w │    4.24w │     18.77% │
│ atd-yojson: rw           │ 12_852.26ns │ 2_426.01w │  264.51w │    6.51w │     77.14% │
│ deriving-yojson: rw      │ 15_596.39ns │ 2_243.06w │  277.33w │    4.33w │     93.61% │
│ protobuf-json: rw        │ 16_661.85ns │ 2_043.07w │  285.06w │    3.06w │    100.00% │
│ yojson-no-marshal: rw    │ 14_826.40ns │ 1_638.04w │  277.43w │    4.43w │     88.98% │
│ binprot: read            │    404.71ns │   365.00w │          │          │      2.43% │
│ binprot: write           │    435.65ns │    19.00w │          │          │      2.61% │
│ capnp:write              │  1_894.60ns │   793.05w │  258.43w │    0.43w │     11.37% │
│ protobuf-bin: read       │    769.56ns │   906.02w │    0.58w │    0.58w │      4.62% │
│ protobuf-bin: write      │  1_854.72ns │ 1_091.01w │  258.57w │    0.57w │     11.13% │
│ deriving-protobuf: read  │  1_111.62ns │ 1_435.06w │    1.96w │    1.96w │      6.67% │
│ deriving-protobuf: write │  1_835.38ns │ 1_078.01w │  258.35w │    0.35w │     11.02% │
│ atd-yojson: read         │  7_147.99ns │ 1_977.01w │    3.72w │    3.72w │     42.90% │
│ atd-yojson: write        │  5_232.28ns │   449.00w │  258.10w │          │     31.40% │
│ deriving-yojson: read    │  8_653.08ns │ 1_424.00w │   -0.46w │   -0.46w │     51.93% │
│ deriving-yojson: write   │  6_855.80ns │   819.03w │  273.69w │    0.69w │     41.15% │
│ protobuf-json: read      │  8_869.98ns │ 1_223.02w │    2.56w │    2.56w │     53.24% │
│ protobuf-json: write     │  7_086.42ns │   820.08w │  282.58w │    0.58w │     42.53% │
└──────────────────────────┴─────────────┴───────────┴──────────┴──────────┴────────────┘
```

From this very simple test, we can derive a few tentative conclusions:

* Jane Street's `Bin_prot` (a.k.a. `bin-io`) is 3x as fast as binary Protobuf (keep in mind some of it is coded in C);

* The IDL based `ocaml-protoc` adds no cost on top of the underlying `ppx_deriving_protobuf`;

* `atd-yojson` is marginally more performant than the other JSON codecs, including bare `Yojson` strangely enough;

* The OCaml native `capnp` implementation seems to perform on par with Protobuf, from a preliminary write-only experiment;

## LICENSE AND COPYRIGHT

The contents of this repository is:

Copyright (c) 2019 Graph X Design Inc. <https://www.gxd.ca/>

Distributed under the MIT (X11) License:
http://www.opensource.org/licenses/mit-license.php

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
