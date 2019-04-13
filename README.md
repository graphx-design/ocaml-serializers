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
┌──────────────────────────┬────────────┬───────────┬──────────┬──────────┬────────────┐
│ Name                     │   Time/Run │   mWd/Run │ mjWd/Run │ Prom/Run │ Percentage │
├──────────────────────────┼────────────┼───────────┼──────────┼──────────┼────────────┤
│ binprot: rw              │   885.04ns │   213.01w │          │          │     10.01% │
│ protobuf-bin: rw         │ 1_904.30ns │ 1_504.04w │    0.60w │    0.60w │     21.54% │
│ deriving-protobuf: rw    │ 1_946.77ns │ 1_603.04w │    0.82w │    0.82w │     22.02% │
│ atd-yojson: rw           │ 5_682.97ns │ 1_000.02w │    0.45w │    0.45w │     64.29% │
│ deriving-yojson: rw      │ 8_291.21ns │ 1_747.64w │    1.45w │    1.45w │     93.79% │
│ protobuf-json: rw        │ 8_840.01ns │ 1_322.07w │    1.24w │    1.24w │    100.00% │
│ yojson-no-marshal: rw    │ 7_673.18ns │   912.02w │    0.73w │    0.73w │     86.80% │
│ binprot: read            │   447.28ns │   186.00w │          │          │      5.06% │
│ binprot: write           │   396.48ns │    27.00w │          │          │      4.49% │
│ protobuf-bin: read       │   893.94ns │   830.02w │    0.37w │    0.37w │     10.11% │
│ protobuf-bin: write      │   892.09ns │   674.01w │    0.17w │    0.17w │     10.09% │
│ deriving-protobuf: read  │   946.24ns │   929.05w │    0.59w │    0.59w │     10.70% │
│ deriving-protobuf: write │   904.83ns │   674.01w │    0.17w │    0.17w │     10.24% │
│ atd-yojson: read         │ 3_652.26ns │   734.00w │    0.37w │    0.37w │     41.32% │
│ atd-yojson: write        │ 1_873.87ns │   266.01w │          │          │     21.20% │
│ deriving-yojson: read    │ 4_669.77ns │ 1_147.04w │    1.19w │    1.19w │     52.83% │
│ deriving-yojson: write   │ 3_377.61ns │   600.03w │    0.50w │    0.50w │     38.21% │
│ protobuf-json: read      │ 4_957.74ns │   709.02w │    0.76w │    0.76w │     56.08% │
│ protobuf-json: write     │ 3_805.69ns │   613.06w │    0.55w │    0.55w │     43.05% │
└──────────────────────────┴────────────┴───────────┴──────────┴──────────┴────────────┘
```

From this very simple test, we can derive a few tentative conclusions:

* Jane Street's `Bin_prot` (a.k.a. `bin-io`) is 2x as fast as binary Protobuf (keep in mind some of it is coded in C);

* For binary Protobuf, `ocaml-protoc` and `ppx_deriving_protobuf` perform identically;

* `atd-yojson` is 1.5x more performant than other JSON codecs, including bare `Yojson`;

* Reading JSON is up to twice as expensive as writing, and JSON is generally 3-4x slower than binary formats;

## MIT License

MIT License

Copyright (c) 2019 Graph X Design

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

