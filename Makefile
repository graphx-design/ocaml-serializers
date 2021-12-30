ATD    := atdgen
OPROTOC := ocaml-protoc
CAPNP  := capnp compile -o ocaml
#THRIFT := thrift

#DEPS := $(wildcard src/*.mli src/*.ml src/thrift_buffer_transport.ml)
DEPS := \
	atd_payload_t.mli atd_payload_t.ml \
	atd_payload_j.mli atd_payload_j.ml \
	cap_payload.mli cap_payload.ml \
	protobuf_payload_types.mli protobuf_payload_types.ml \
	protobuf_payload_pb.mli protobuf_payload_pb.ml \
	protobuf_payload_yojson.mli protobuf_payload_yojson.ml \
	protoplugin_payload.ml

LIBS := core,core_bench,atdgen,ocaml-protoc,ocaml-protoc-yojson,bin_prot,ppx_bin_prot,ppx_deriving_yojson,ppx_deriving_protobuf,extunix,uint,ocplib-endian,res,capnp,ocaml-protoc-plugin

help:
	@echo "Available targets: help, clean, build, build-codecs"

clean:
	@cd src ; rm -f atd_*.ml* protobuf_*.ml* *.cmi *.cmx *.o

build-codecs:
	@cd src/; $(ATD) -t atd_payload.atd ; $(ATD) -j atd_payload.atd
	@cd src/; $(OPROTOC) -binary -ml_out ./ protobuf_payload.proto ; $(OPROTOC) -yojson -ml_out ./ protobuf_payload.proto
	@cd src/; protoc --ocaml_out=. protoplugin_payload.proto
	@cd src/; $(CAPNP) cap_payload.capnp
	#@cd src/; $(THRIFT) --gen ocaml -out ./ thrift_payload.thrift

build:	benchmarks.exe

run:	build
	./benchmarks.exe -quota 0.1

benchmarks.exe:	$(wildcard src/*.ml src/*.mli)
	@cd src ; ocamlfind ocamlopt $(DEPS) benchmarks.ml -o ../benchmarks.exe -O3 -thread -linkpkg -package $(LIBS)

# Undocumented: this was used when I needed Thrift
ocaml405:
	@docker run --name ocaml405 -it -v `pwd`:/work ocaml/opam:debian-9_ocaml-4.05.0_flambda bash

.PHONY:	help clean build run build-codecs ocaml405
