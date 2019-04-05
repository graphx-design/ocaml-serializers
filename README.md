# OCaml Serializer Benchmarks

In order to get a rough idea of the cost of serialization and de-serialization in various formats implemented in OCaml, I created this quick benchmark.

## Formats

* Google Protocol Buffers with `ocaml-protoc`
* Type-safe JSON with `ocaml-protoc-yojson`
* Type-safe JSON with `atd` in front of `yojson`
* Raw JSON directly with `yojson`
* Jane Street's `Bin_prot`

## TODO

- [ ] Jane Street's `Bin_prot` outperforms unfairly: we need to add shape validation
- [ ] S-expressions worth a look?

## Results

These ran on my Intel® Core™ i7-8650U CPU @ 1.90GHz:

```text
┌────────────────────────────┬────────────┬───────────┬──────────┬──────────┬────────────┐
│ Name                       │   Time/Run │   mWd/Run │ mjWd/Run │ Prom/Run │ Percentage │
├────────────────────────────┼────────────┼───────────┼──────────┼──────────┼────────────┤
│ binprot: read-write        │   891.51ns │   213.01w │          │          │     10.14% │
│ protobuf-bin: read-write   │ 1_920.27ns │ 1_504.04w │    0.60w │    0.60w │     21.84% │
│ protobuf-json: read-write  │ 8_791.32ns │ 1_322.08w │    1.17w │    1.17w │    100.00% │
│ atd-yojson: read-write     │ 5_615.56ns │ 1_000.02w │    0.47w │    0.47w │     63.88% │
│ yojson: read-write PARTIAL │ 7_647.18ns │   912.02w │    0.73w │    0.73w │     86.99% │
│ binprot: read              │   444.89ns │   186.00w │          │          │      5.06% │
│ binprot: write             │   408.83ns │    27.00w │          │          │      4.65% │
│ protobuf-bin: read         │   912.42ns │   830.02w │    0.37w │    0.37w │     10.38% │
│ protobuf-bin: write        │   915.58ns │   674.01w │    0.17w │    0.17w │     10.41% │
│ protobuf-json: read        │ 4_881.78ns │   709.02w │    0.75w │    0.75w │     55.53% │
│ protobuf-json: write       │ 3_832.54ns │   613.05w │    0.53w │    0.53w │     43.59% │
│ atd-yojson: read           │ 3_582.47ns │   734.00w │    0.37w │    0.37w │     40.75% │
│ atd-yojson: write          │ 1_906.43ns │   266.01w │          │          │     21.69% │
└────────────────────────────┴────────────┴───────────┴──────────┴──────────┴────────────┘
```

For this very simple test, it appears that `ocaml-protoc`'s binary codec outperforms the JSON variants by quite a bit: 4.5x `ocaml-protoc-yojson` and 3x `atd-yojson`.  For OCaml-only, Jane Street's `Bin_prot` outperforms even binary Protobuf by an impressive 2x, without shape validation.

### Note About Apache Thrift

My quick hack `thrift_buffer_transport.ml` is still included, in case anyone with OCaml 4.06 or lower wants to try it out.  On my laptop, it was roughly 15x slower than `ocaml-protoc` binary, so I lost interest.  (This was also consistent with Protobuf vs Thrift in Perl and JavaScript tests.)

## MIT License

MIT License

Copyright (c) 2019 Graph X Design

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

