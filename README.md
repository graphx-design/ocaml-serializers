# OCaml Serializer Benchmarks

In order to get a rough idea of the cost of serialization and de-serialization in various formats implemented in OCaml, I created this quick benchmark.

## Formats

* Google Protocol Buffers with `ocaml-protoc`
* Type-safe JSON with `ocaml-protoc-yojson`
* Type-safe JSON with `atd` in front of `yojson`
* Raw JSON directly with `yojson`

## TODO

- [ ] Jane Street's `Bin_prot` could be better for OCaml-to-OCaml exchanges
- [ ] S-expressions worth a look?

## Results

These ran on my Intel® Core™ i7-8650U CPU @ 1.90GHz:

```text
┌────────────────────────────┬────────────┬───────────┬──────────┬──────────┬────────────┐
│ Name                       │   Time/Run │   mWd/Run │ mjWd/Run │ Prom/Run │ Percentage │
├────────────────────────────┼────────────┼───────────┼──────────┼──────────┼────────────┤
│ protobuf-bin: read-write   │ 1_953.29ns │ 1_504.04w │    0.60w │    0.60w │     21.72% │
│ protobuf-json: read-write  │ 8_994.22ns │ 1_322.07w │    1.19w │    1.19w │    100.00% │
│ atd-yojson: read-write     │ 5_689.96ns │ 1_000.02w │    0.47w │    0.47w │     63.26% │
│ yojson: read-write PARTIAL │ 7_880.50ns │   912.02w │    0.74w │    0.74w │     87.62% │
│ protobuf-bin: read         │   893.76ns │   830.02w │    0.36w │    0.36w │      9.94% │
│ protobuf-bin: write        │   912.72ns │   674.01w │    0.17w │    0.17w │     10.15% │
│ protobuf-json: read        │ 4_979.57ns │   709.02w │    0.74w │    0.74w │     55.36% │
│ protobuf-json: write       │ 3_851.10ns │   613.05w │    0.53w │    0.53w │     42.82% │
│ atd-yojson: read           │ 3_644.72ns │   734.00w │    0.37w │    0.37w │     40.52% │
│ atd-yojson: write          │ 1_913.99ns │   266.01w │          │          │     21.28% │
└────────────────────────────┴────────────┴───────────┴──────────┴──────────┴────────────┘
```

For this very simple test, it appears that `ocaml-protoc`'s binary codec outperforms the JSON variants by quite a bit: 4.5x `ocaml-protoc-yojson` and 3x `atd-yojson`.

### Note About Apache Thrift

My quick hack `thrift_buffer_transport.ml` is still included, in case anyone with OCaml 4.06 or lower wants to try it out.  On my laptop, it was roughly 15x slower than `ocaml-protoc` binary, so I lost interest.  (This was also consistent with Protobuf vs Thrift in Perl and JavaScript tests.)

## MIT License

MIT License

Copyright (c) 2019 Graph X Design

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

