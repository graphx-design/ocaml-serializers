ATD    := atdgen
PROTOC := ocaml-protoc
#THRIFT := thrift

#DEPS := $(wildcard src/*.mli src/*.ml src/thrift_buffer_transport.ml)
DEPS := \
	atd_payload_t.mli atd_payload_t.ml \
	atd_payload_j.mli atd_payload_j.ml \
	protobuf_payload_types.mli protobuf_payload_types.ml \
	protobuf_payload_pb.mli protobuf_payload_pb.ml \
	protobuf_payload_yojson.mli protobuf_payload_yojson.ml

LIBS := core,core_bench,atdgen,ocaml-protoc,ocaml-protoc-yojson,bin_prot,ppx_bin_prot,ppx_deriving_yojson,ppx_deriving_protobuf

help:
	@echo "Available targets: help, clean, build, build-codecs"

clean:
	@cd src ; rm -f atd_*.ml* protobuf_*.ml* *.cmi *.cmx *.o

build-codecs:
	@cd src/; $(ATD) -t atd_payload.atd ; $(ATD) -j atd_payload.atd
	@cd src/; $(PROTOC) -binary -ml_out ./ protobuf_payload.proto ; $(PROTOC) -yojson -ml_out ./ protobuf_payload.proto
	#@cd src/; $(THRIFT) --gen ocaml -out ./ thrift_payload.thrift

build:	benchmarks.exe

benchmarks.exe:	$(wildcard src/*.ml src/*.mli)
	@cd src ; ocamlfind ocamlopt $(DEPS) benchmarks.ml -o ../benchmarks.exe -thread -linkpkg -package $(LIBS)

# Undocumented: this was used when I needed Thrift
ocaml405:
	@docker run --name ocaml405 -it -v `pwd`:/work ocaml/opam:debian-9_ocaml-4.05.0_flambda bash

.PHONY:	help clean build build-codecs ocaml405
