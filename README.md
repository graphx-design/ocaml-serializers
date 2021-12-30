# OCaml Serializer Benchmarks

In order to get a rough idea of the cost of serialization and de-serialization in various formats implemented in OCaml, I created this quick benchmark.

## Formats Tested

### Bin_prot

* [OCaml-only] Jane Street's `Bin_prot` (a.k.a. `bin-io`) reference implementation;

### Google Protocol Buffers

* [Cross-platform] `ocaml-protoc` and `ocaml-protoc-plugin`, from a Protobuf IDL
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
│ binprot: rw              │  1_481.95ns │   384.00w │    0.25w │    0.25w │      7.42% │
│ capnp: rw                │  3_662.10ns │ 1_781.00w │  259.26w │    1.26w │     18.33% │
│ protobuf-bin: rw         │  3_888.80ns │ 1_981.00w │  259.77w │    1.77w │     19.47% │
│ protoplug: rw            │  5_310.84ns │ 5_568.00w │   11.05w │   11.05w │     26.59% │
│ deriving-protobuf: rw    │  4_673.54ns │ 2_498.00w │  262.38w │    4.38w │     23.40% │
│ atd-yojson: rw           │ 14_559.34ns │ 2_436.00w │  262.71w │    4.71w │     72.89% │
│ deriving-yojson: rw      │ 17_495.03ns │ 2_243.00w │  277.48w │    4.48w │     87.59% │
│ protobuf-json: rw        │ 19_973.95ns │ 2_043.00w │  285.42w │    3.42w │    100.00% │
│ yojson-no-marshal: rw    │ 17_084.04ns │ 1_638.00w │  276.07w │    3.07w │     85.53% │
│ binprot: read            │    624.95ns │   365.00w │          │          │      3.13% │
│ binprot: write           │    880.39ns │    19.00w │          │          │      4.41% │
│ capnp: read              │  1_051.50ns │   953.00w │    0.32w │    0.32w │      5.26% │
│ capnp: write             │  2_263.49ns │   793.00w │  258.45w │    0.45w │     11.33% │
│ protobuf-bin: read       │    994.11ns │   906.00w │    0.59w │    0.59w │      4.98% │
│ protobuf-bin: write      │  2_770.37ns │ 1_075.00w │  258.75w │    0.75w │     13.87% │
│ protoplug: read          │  3_327.79ns │ 3_957.00w │    7.16w │    7.16w │     16.66% │
│ protoplug: write         │  2_075.81ns │ 1_611.00w │    2.25w │    2.25w │     10.39% │
│ deriving-protobuf: read  │  1_556.34ns │ 1_435.00w │    2.01w │    2.01w │      7.79% │
│ deriving-protobuf: write │  2_712.19ns │ 1_063.00w │  258.64w │    0.64w │     13.58% │
│ atd-yojson: read         │  7_888.56ns │ 1_987.00w │    3.95w │    3.95w │     39.49% │
│ atd-yojson: write        │  5_874.75ns │   449.00w │  258.12w │    0.12w │     29.41% │
│ deriving-yojson: read    │  9_689.97ns │ 1_424.00w │   -0.30w │   -0.30w │     48.51% │
│ deriving-yojson: write   │  7_781.59ns │   819.00w │  273.63w │    0.63w │     38.96% │
│ protobuf-json: read      │ 10_259.82ns │ 1_223.00w │    2.52w │    2.52w │     51.37% │
│ protobuf-json: write     │  9_415.25ns │   820.00w │  282.71w │    0.71w │     47.14% │
└──────────────────────────┴─────────────┴───────────┴──────────┴──────────┴────────────┘
```

From this very simple test, we can derive a few tentative conclusions:

* Jane Street's `Bin_prot` (a.k.a. `bin-io`) is 3x as fast as binary Protobuf (keep in mind some of it is coded in C);

* The IDL based `ocaml-protoc` adds no cost on top of the underlying `ppx_deriving_protobuf`;

* The `ocaml-protoc-plugin` (as of 2021) is 3x slower at reading vs `ocaml-protoc` and allocates significantly more in both directions;

* `atd-yojson` is marginally more performant than the other JSON codecs, including bare `Yojson` strangely enough;

* The OCaml native `capnp` implementation performs exactly on par with Protobuf binary, since there needs to be conversion to native OCaml types;

## LICENSE AND COPYRIGHT

The contents of this repository is:

Copyright (c) 2019-2021 Graph X Design Inc. <https://www.gxd.ca/>

Distributed under the MIT (X11) License:
http://www.opensource.org/licenses/mit-license.php

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
