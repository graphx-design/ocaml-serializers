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
│ binprot: rw              │    873.90ns │   384.00w │    0.20w │    0.20w │      4.96% │
│ capnp: rw                │  3_005.08ns │ 1_781.09w │  259.28w │    1.28w │     17.05% │
│ protobuf-bin: rw         │  2_713.29ns │ 1_997.04w │  260.28w │    2.28w │     15.39% │
│ deriving-protobuf: rw    │  3_244.36ns │ 2_513.06w │  262.26w │    4.26w │     18.40% │
│ atd-yojson: rw           │ 12_909.65ns │ 2_426.00w │  264.74w │    6.74w │     73.23% │
│ deriving-yojson: rw      │ 17_629.74ns │ 2_243.08w │  276.06w │    3.06w │    100.00% │
│ protobuf-json: rw        │ 17_138.44ns │ 2_043.10w │  285.62w │    3.62w │     97.21% │
│ yojson-no-marshal: rw    │ 15_267.60ns │ 1_638.04w │  276.74w │    3.74w │     86.60% │
│ binprot: read            │    419.65ns │   365.00w │          │          │      2.38% │
│ binprot: write           │    441.96ns │    19.00w │          │          │      2.51% │
│ capnp: read              │    847.07ns │   953.02w │    0.32w │    0.32w │      4.80% │
│ capnp: write             │  2_020.26ns │   793.04w │  258.46w │    0.46w │     11.46% │
│ protobuf-bin: read       │    773.75ns │   906.02w │    0.59w │    0.59w │      4.39% │
│ protobuf-bin: write      │  1_870.20ns │ 1_091.01w │  258.57w │    0.57w │     10.61% │
│ deriving-protobuf: read  │  1_108.85ns │ 1_435.06w │    1.96w │    1.96w │      6.29% │
│ deriving-protobuf: write │  1_961.03ns │ 1_078.01w │  258.37w │    0.37w │     11.12% │
│ atd-yojson: read         │  7_251.69ns │ 1_977.01w │    3.77w │    3.77w │     41.13% │
│ atd-yojson: write        │  4_831.84ns │   449.00w │  258.12w │    0.12w │     27.41% │
│ deriving-yojson: read    │  8_586.96ns │ 1_424.00w │   -0.45w │   -0.45w │     48.71% │
│ deriving-yojson: write   │  6_627.43ns │   819.03w │  273.77w │    0.77w │     37.59% │
│ protobuf-json: read      │  9_003.48ns │ 1_223.02w │    2.65w │    2.65w │     51.07% │
│ protobuf-json: write     │  7_240.96ns │   820.04w │  282.69w │    0.69w │     41.07% │
└──────────────────────────┴─────────────┴───────────┴──────────┴──────────┴────────────┘
```

From this very simple test, we can derive a few tentative conclusions:

* Jane Street's `Bin_prot` (a.k.a. `bin-io`) is 3x as fast as binary Protobuf (keep in mind some of it is coded in C);

* The IDL based `ocaml-protoc` adds no cost on top of the underlying `ppx_deriving_protobuf`;

* `atd-yojson` is marginally more performant than the other JSON codecs, including bare `Yojson` strangely enough;

* The OCaml native `capnp` implementation performs exactly on par with Protobuf binary, since there needs to be conversion to native OCaml types;

## LICENSE AND COPYRIGHT

The contents of this repository is:

Copyright (c) 2019 Graph X Design Inc. <https://www.gxd.ca/>

Distributed under the MIT (X11) License:
http://www.opensource.org/licenses/mit-license.php

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
