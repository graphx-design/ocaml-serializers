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
┌──────────────────────────┬─────────────┬───────────┬───────────┬──────────┬────────────┐
│ Name                     │    Time/Run │   mWd/Run │  mjWd/Run │ Prom/Run │ Percentage │
├──────────────────────────┼─────────────┼───────────┼───────────┼──────────┼────────────┤
│ binprot: rw              │    862.89ns │   384.00w │     0.20w │    0.20w │      5.14% │
│ protobuf-bin: rw         │  2_868.17ns │ 1_997.03w │   260.17w │    2.17w │     17.10% │
│ deriving-protobuf: rw    │  3_285.59ns │ 2_513.06w │   262.22w │    4.22w │     19.59% │
│ atd-yojson: rw           │ 12_771.61ns │ 2_426.00w │   264.73w │    6.73w │     76.14% │
│ deriving-yojson: rw      │ 15_808.48ns │ 2_243.05w │   277.44w │    4.44w │     94.24% │
│ protobuf-json: rw        │ 16_774.18ns │ 2_043.08w │   285.30w │    3.30w │    100.00% │
│ yojson-no-marshal: rw    │ 14_897.95ns │ 1_638.04w │   277.43w │    4.43w │     88.81% │
│ binprot: read            │    411.00ns │   365.00w │           │          │      2.45% │
│ binprot: write           │    432.50ns │    19.00w │           │          │      2.58% │
│ capnp:write              │  3_108.78ns │   793.02w │ 1_026.30w │    0.30w │     18.53% │
│ protobuf-bin: read       │    777.05ns │   906.02w │     0.59w │    0.59w │      4.63% │
│ protobuf-bin: write      │  1_834.39ns │ 1_091.01w │   258.57w │    0.57w │     10.94% │
│ deriving-protobuf: read  │  1_123.37ns │ 1_435.06w │     1.96w │    1.96w │      6.70% │
│ deriving-protobuf: write │  1_900.74ns │ 1_078.01w │   258.38w │    0.38w │     11.33% │
│ atd-yojson: read         │  7_199.05ns │ 1_977.01w │     3.72w │    3.72w │     42.92% │
│ atd-yojson: write        │  5_201.74ns │   449.00w │   258.12w │    0.12w │     31.01% │
│ deriving-yojson: read    │  8_419.35ns │ 1_424.00w │    -0.47w │   -0.47w │     50.19% │
│ deriving-yojson: write   │  6_831.80ns │   819.03w │   273.67w │    0.67w │     40.73% │
│ protobuf-json: read      │  8_850.74ns │ 1_223.02w │     2.46w │    2.46w │     52.76% │
│ protobuf-json: write     │  7_054.40ns │   820.05w │   282.58w │    0.58w │     42.06% │
└──────────────────────────┴─────────────┴───────────┴───────────┴──────────┴────────────┘
```

From this very simple test, we can derive a few tentative conclusions:

* Jane Street's `Bin_prot` (a.k.a. `bin-io`) is 3x as fast as binary Protobuf (keep in mind some of it is coded in C);

* The IDL based `ocaml-protoc` adds no cost on top of the underlying `ppx_deriving_protobuf`;

* `atd-yojson` is marginally more performant than the other JSON codecs, including bare `Yojson` strangely enough;

* The OCaml native `capnp` implementation underperforms Protobuf;

## LICENSE AND COPYRIGHT

The contents of this repository is:

Copyright (c) 2019 Graph X Design Inc. <https://www.gxd.ca/>

Distributed under the MIT (X11) License:
http://www.opensource.org/licenses/mit-license.php

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
