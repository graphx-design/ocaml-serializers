# OCaml Serializer Benchmarks

In order to get a rough idea of the cost of serialization and de-serialization in various formats implemented in OCaml, I created this quick benchmark.

## Formats Tested

### Bin_prot

* [OCaml-only] Jane Street's `Bin_prot` (a.k.a. `bin-io`) reference implementation;

### Google Protocol Buffers

* [Cross-platform] `ocaml-protoc`, from a Protobuf IDL (front-end to `ppx_deriving_protobuf`)
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
│ binprot: rw              │  1_088.66ns │   409.01w │    0.27w │    0.27w │      6.52% │
│ protobuf-bin: rw         │  3_399.62ns │ 2_524.04w │  261.38w │    3.38w │     20.38% │
│ deriving-protobuf: rw    │  3_571.90ns │ 2_623.07w │  261.61w │    3.61w │     21.41% │
│ atd-yojson: rw           │ 13_329.77ns │ 2_429.01w │  261.99w │    3.99w │     79.89% │
│ deriving-yojson: rw      │ 16_129.85ns │ 2_501.10w │  276.84w │    3.84w │     96.67% │
│ protobuf-json: rw        │ 16_684.65ns │ 2_083.08w │  285.34w │    3.34w │    100.00% │
│ yojson-no-marshal: rw    │ 15_427.45ns │ 1_666.03w │  275.92w │    2.92w │     92.46% │
│ binprot: read            │    485.12ns │   372.00w │    0.21w │    0.21w │      2.91% │
│ binprot: write           │    571.75ns │    37.00w │          │          │      3.43% │
│ protobuf-bin: read       │  1_005.28ns │ 1_214.02w │    1.47w │    1.47w │      6.03% │
│ protobuf-bin: write      │  2_329.11ns │ 1_310.01w │  258.37w │    0.37w │     13.96% │
│ deriving-protobuf: read  │  1_038.44ns │ 1_313.03w │    1.84w │    1.84w │      6.22% │
│ deriving-protobuf: write │  2_200.85ns │ 1_310.02w │  258.61w │    0.61w │     13.19% │
│ atd-yojson: read         │  7_207.78ns │ 1_977.01w │    4.04w │    4.04w │     43.20% │
│ atd-yojson: write        │  5_275.34ns │   452.00w │  258.12w │    0.12w │     31.62% │
│ deriving-yojson: read    │  8_281.38ns │ 1_645.03w │    3.66w │    3.66w │     49.63% │
│ deriving-yojson: write   │  7_149.42ns │   856.02w │  273.42w │    0.42w │     42.85% │
│ protobuf-json: read      │  8_486.86ns │ 1_208.02w │    2.79w │    2.79w │     50.87% │
│ protobuf-json: write     │  7_642.53ns │   875.05w │  282.59w │    0.59w │     45.81% │
└──────────────────────────┴─────────────┴───────────┴──────────┴──────────┴────────────┘
```

From this very simple test, we can derive a few tentative conclusions:

* Jane Street's `Bin_prot` (a.k.a. `bin-io`) is 3x as fast as binary Protobuf (keep in mind some of it is coded in C);

* The IDL based `ocaml-protoc` adds no cost on top of the underlying `ppx_deriving_protobuf`;

* `atd-yojson` is marginally more performant than the other JSON codecs, including bare `Yojson` strangely enough;

## LICENSE AND COPYRIGHT

The contents of this repository is:

Copyright (c) 2019 Graph X Design Inc. <https://www.gxd.ca/>

Distributed under the MIT (X11) License:
http://www.opensource.org/licenses/mit-license.php

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
