open Core
open Core_bench

(* Generic data *)

let string_a = String.make 1000 'A'
let string_b = String.make 500 'B'

(* Raw Yojson *)

let yojson_data =
  Yojson.Basic.(
    `Assoc
      [ "first", `Bool false
      ; "second", `Bool true
      ; "third", `Float 12345678.117
      ; "fourth", `Int 234567
      ; ( "fifth"
        , `List
            [ `Assoc
                [ "first", `String string_a
                ; "second", `String "deuxieme"
                ; "third", `String ""
                ; "fourth", `String ""
                ]
            ; `Assoc
                [ "first", `String ""
                ; "second", `String ""
                ; "third", `String string_b
                ; "fourth", `String "quatrieme"
                ]
            ; `Assoc
                [ "first", `String "premier"
                ; "second", `String "deuxieme"
                ; "third", `String ""
                ; "fourth", `String ""
                ]
            ; `Assoc
                [ "first", `String ""
                ; "second", `String ""
                ; "third", `String "troisieme"
                ; "fourth", `String "quatrieme"
                ]
            ] )
      ; ( "sixth"
        , `List
            [ `Int 1234
            ; `Int 2345
            ; `Int 3456
            ; `Int 4567
            ; `Int 5678
            ; `Int 6789
            ; `Int 7890
            ] )
      ])
;;

let yojson_rw () =
  yojson_data |> Yojson.Basic.to_string |> Yojson.Basic.from_string
;;

(* ATD *)

let atd_data =
  Atd_payload_t.
    { first = false
    ; second = true
    ; third = 12345678.117
    ; fourth = 234567
    ; fifth =
        [ { first = Some string_a
          ; second = Some "deuxieme"
          ; third = None
          ; fourth = None
          }
        ; { first = None
          ; second = None
          ; third = Some string_b
          ; fourth = Some "quatrieme"
          }
        ; { first = Some "premier"
          ; second = Some "deuxieme"
          ; third = None
          ; fourth = None
          }
        ; { first = None
          ; second = None
          ; third = Some "troisieme"
          ; fourth = Some "quatrieme"
          }
        ]
    ; sixth = [ 1234; 2345; 3456; 4567; 5678; 6789; 7890 ]
    }
;;

let atd_json = Atd_payload_j.string_of_atd_payload atd_data
let atd_yojson_read () = atd_json |> Atd_payload_j.atd_payload_of_string
let atd_yojson_write () = atd_data |> Atd_payload_j.string_of_atd_payload

let atd_yojson_rw () =
  atd_data
  |> Atd_payload_j.string_of_atd_payload
  |> Atd_payload_j.atd_payload_of_string
;;

(* ocaml-protoc: binary & JSON *)

let protobuf_data =
  Protobuf_payload_types.
    { first = false
    ; second = true
    ; third = 12345678.117
    ; fourth = 234567
    ; fifth =
        [ { first = string_a; second = "deuxieme"; third = ""; fourth = "" }
        ; { first = ""; second = ""; third = string_b; fourth = "quatrieme" }
        ; { first = "premier"; second = "deuxieme"; third = ""; fourth = "" }
        ; { first = ""
          ; second = ""
          ; third = "troisieme"
          ; fourth = "quatrieme"
          }
        ]
    ; sixth = [ 1234; 2345; 3456; 4567; 5678; 6789; 7890 ]
    }
;;

let protobuf_bin_write () =
  let pb_encoder = Pbrt.Encoder.create () in
  Protobuf_payload_pb.encode_protobuf_payload protobuf_data pb_encoder;
  Pbrt.Encoder.to_bytes pb_encoder
;;

let protobuf_bin = protobuf_bin_write ()

let protobuf_bin_read () =
  protobuf_bin
  |> Pbrt.Decoder.of_bytes
  |> Protobuf_payload_pb.decode_protobuf_payload
;;

let protobuf_bin_rw () =
  let my_encoder = Pbrt.Encoder.create () in
  Protobuf_payload_pb.encode_protobuf_payload protobuf_data my_encoder;
  let my_binary = Pbrt.Encoder.to_bytes my_encoder in
  Protobuf_payload_pb.decode_protobuf_payload (Pbrt.Decoder.of_bytes my_binary)
;;

let pbuf_json =
  Yojson.Basic.to_string
    (Protobuf_payload_yojson.encode_protobuf_payload protobuf_data)
;;

let pbuf_json_read () =
  pbuf_json
  |> Yojson.Basic.from_string
  |> Protobuf_payload_yojson.decode_protobuf_payload
;;

let pbuf_json_write () =
  protobuf_data
  |> Protobuf_payload_yojson.encode_protobuf_payload
  |> Yojson.Basic.to_string
;;

let pbuf_json_rw () =
  protobuf_data
  |> Protobuf_payload_yojson.encode_protobuf_payload
  |> Yojson.Basic.to_string
  |> Yojson.Basic.from_string
  |> Protobuf_payload_yojson.decode_protobuf_payload
;;

(* Bin_prot a.k.a. bin-io *)

module Binprot_tests = struct
  type binprot_payload_fifth =
    { first : string option
    ; second : string option
    ; third : string option
    ; fourth : string option
    }
  [@@deriving bin_io]

  type binprot_payload =
    { first : bool
    ; second : bool
    ; third : float
    ; fourth : int
    ; fifth : binprot_payload_fifth list
    ; sixth : int list
    }
  [@@deriving bin_io]

  let shapedigest =
    bin_shape_binprot_payload |> Bin_prot.Shape.eval_to_digest_string
  ;;

  let fakedigest = "f13160093f976a7cb3c92909c3053b28"
end

let binprot_data =
  Binprot_tests.
    { first = false
    ; second = true
    ; third = 12345678.117
    ; fourth = 234567
    ; fifth =
        [ { first = Some string_a
          ; second = Some "deuxieme"
          ; third = Some ""
          ; fourth = Some ""
          }
        ; { first = Some ""
          ; second = Some ""
          ; third = Some string_b
          ; fourth = Some "quatrieme"
          }
        ; { first = Some "premier"
          ; second = Some "deuxieme"
          ; third = Some ""
          ; fourth = Some ""
          }
        ; { first = Some ""
          ; second = Some ""
          ; third = Some "troisieme"
          ; fourth = Some "quatrieme"
          }
        ]
    ; sixth = [ 1234; 2345; 3456; 4567; 5678; 6789; 7890 ]
    }
;;

let binprot_binbuf =
  let open Binprot_tests in
  let buf =
    Bin_prot.Common.create_buf (bin_size_binprot_payload binprot_data)
  in
  let writer = bin_write_binprot_payload buf in
  let _ = writer ~pos:0 binprot_data in
  buf
;;

let binprot_rw () =
  let open Binprot_tests in
  match Binprot_tests.(String.compare shapedigest fakedigest) = 0 with
  | false -> ()
  | true ->
    let buf =
      Bin_prot.Common.create_buf (bin_size_binprot_payload binprot_data)
    in
    let writer = bin_write_binprot_payload buf in
    let _ = writer ~pos:0 binprot_data in
    let reader = bin_read_binprot_payload buf in
    let pos = ref 0 in
    reader pos |> ignore
;;

let binprot_write () =
  let open Binprot_tests in
  let buf =
    Bin_prot.Common.create_buf (bin_size_binprot_payload binprot_data)
  in
  let writer = bin_write_binprot_payload buf in
  writer ~pos:0 binprot_data
;;

let binprot_read () =
  match Binprot_tests.(String.compare shapedigest fakedigest) = 0 with
  | false -> ()
  | true ->
    let reader = Binprot_tests.bin_read_binprot_payload binprot_binbuf in
    let pos = ref 0 in
    reader pos |> ignore
;;

(* Cap'n Proto *)

module CPP = Cap_payload.Make [@inlined] (Capnp.BytesMessage)

let capnp_write () =
  let cpp_root = CPP.Builder.CPayload.init_root () in
  let cfifths = CPP.Builder.CPayload.fifth_init cpp_root 4 in
  let csixths = CPP.Builder.CPayload.sixth_init cpp_root 7 in
  CPP.Builder.CPayload.first_set cpp_root false;
  CPP.Builder.CPayload.second_set cpp_root true;
  CPP.Builder.CPayload.third_set cpp_root 12345678.117;
  CPP.Builder.CPayload.fourth_set cpp_root (Int32.of_int_exn 234567);
  let cf = Capnp.Array.get cfifths 0 in
  CPP.Builder.CPayloadFifth.first_set cf string_a;
  CPP.Builder.CPayloadFifth.second_set cf "deuxieme";
  CPP.Builder.CPayloadFifth.third_set cf "";
  CPP.Builder.CPayloadFifth.fourth_set cf "";
  let cf = Capnp.Array.get cfifths 1 in
  CPP.Builder.CPayloadFifth.first_set cf "";
  CPP.Builder.CPayloadFifth.second_set cf "";
  CPP.Builder.CPayloadFifth.third_set cf string_b;
  CPP.Builder.CPayloadFifth.fourth_set cf "quatrieme";
  let cf = Capnp.Array.get cfifths 2 in
  CPP.Builder.CPayloadFifth.first_set cf "premier";
  CPP.Builder.CPayloadFifth.second_set cf "deuxieme";
  CPP.Builder.CPayloadFifth.third_set cf "";
  CPP.Builder.CPayloadFifth.fourth_set cf "";
  let cf = Capnp.Array.get cfifths 3 in
  CPP.Builder.CPayloadFifth.first_set cf "";
  CPP.Builder.CPayloadFifth.second_set cf "";
  CPP.Builder.CPayloadFifth.third_set cf "troisieme";
  CPP.Builder.CPayloadFifth.fourth_set cf "quatrieme";
  Capnp.Array.set csixths 0 (Int32.of_int_exn 1234);
  Capnp.Array.set csixths 1 (Int32.of_int_exn 2345);
  Capnp.Array.set csixths 2 (Int32.of_int_exn 3456);
  Capnp.Array.set csixths 3 (Int32.of_int_exn 4567);
  Capnp.Array.set csixths 4 (Int32.of_int_exn 5678);
  Capnp.Array.set csixths 5 (Int32.of_int_exn 6789);
  Capnp.Array.set csixths 6 (Int32.of_int_exn 7890);
  ()
;;

(* ppx_deriving_yojson *)

module Dyo_tests = struct
  type dyo_payload_fifth =
    { first : string option
    ; second : string option
    ; third : string option
    ; fourth : string option
    }
  [@@deriving yojson { strict = false }]

  type dyo_payload =
    { first : bool
    ; second : bool
    ; third : float
    ; fourth : int
    ; fifth : dyo_payload_fifth list
    ; sixth : int list
    }
  [@@deriving yojson { strict = false }]
end

let dyo_data =
  Dyo_tests.
    { first = false
    ; second = true
    ; third = 12345678.117
    ; fourth = 234567
    ; fifth =
        [ { first = Some string_a
          ; second = Some "deuxieme"
          ; third = Some ""
          ; fourth = Some ""
          }
        ; { first = Some ""
          ; second = Some ""
          ; third = Some string_b
          ; fourth = Some "quatrieme"
          }
        ; { first = Some "premier"
          ; second = Some "deuxieme"
          ; third = Some ""
          ; fourth = Some ""
          }
        ; { first = Some ""
          ; second = Some ""
          ; third = Some "troisieme"
          ; fourth = Some "quatrieme"
          }
        ]
    ; sixth = [ 1234; 2345; 3456; 4567; 5678; 6789; 7890 ]
    }
;;

let dyo_jsonbuf =
  dyo_data |> Dyo_tests.dyo_payload_to_yojson |> Yojson.Safe.to_string
;;

let dyo_rw () =
  dyo_data
  |> Dyo_tests.dyo_payload_to_yojson
  |> Yojson.Safe.to_string
  |> Yojson.Safe.from_string
  |> Dyo_tests.dyo_payload_of_yojson
;;

let dyo_write () =
  dyo_data |> Dyo_tests.dyo_payload_to_yojson |> Yojson.Safe.to_string
;;

let dyo_read () =
  dyo_jsonbuf |> Yojson.Safe.from_string |> Dyo_tests.dyo_payload_of_yojson
;;

(* ppx_deriving_protobuf *)

module Dpb_tests = struct
  type dpb_payload_fifth =
    { first : string option [@key 1]
    ; second : string option [@key 2]
    ; third : string option [@key 3]
    ; fourth : string option [@key 4]
    }
  [@@deriving protobuf]

  type dpb_payload =
    { first : bool [@key 1]
    ; second : bool [@key 2]
    ; third : float [@key 3]
    ; fourth : int [@key 4]
    ; fifth : dpb_payload_fifth list [@key 5]
    ; sixth : int list [@key 6]
    }
  [@@deriving protobuf]
end

let dpb_data =
  Dpb_tests.
    { first = false
    ; second = true
    ; third = 12345678.117
    ; fourth = 234567
    ; fifth =
        [ { first = Some string_a
          ; second = Some "deuxieme"
          ; third = Some ""
          ; fourth = Some ""
          }
        ; { first = Some ""
          ; second = Some ""
          ; third = Some string_b
          ; fourth = Some "quatrieme"
          }
        ; { first = Some "premier"
          ; second = Some "deuxieme"
          ; third = Some ""
          ; fourth = Some ""
          }
        ; { first = Some ""
          ; second = Some ""
          ; third = Some "troisieme"
          ; fourth = Some "quatrieme"
          }
        ]
    ; sixth = [ 1234; 2345; 3456; 4567; 5678; 6789; 7890 ]
    }
;;

let dpb_binbuf =
  dpb_data |> Protobuf.Encoder.encode_exn Dpb_tests.dpb_payload_to_protobuf
;;

let dpb_rw () =
  dpb_data
  |> Protobuf.Encoder.encode_exn Dpb_tests.dpb_payload_to_protobuf
  |> Protobuf.Decoder.decode_exn Dpb_tests.dpb_payload_from_protobuf
;;

let dpb_write () =
  dpb_data |> Protobuf.Encoder.encode_exn Dpb_tests.dpb_payload_to_protobuf
;;

let dpb_read () =
  dpb_binbuf |> Protobuf.Decoder.decode_exn Dpb_tests.dpb_payload_from_protobuf
;;

(* Putting it all together *)

let main () =
  Command.run
    (Bench.make_command
       [
         (* spacer *)
         Bench.Test.create ~name:"binprot: rw" binprot_rw;
         Bench.Test.create ~name:"protobuf-bin: rw" protobuf_bin_rw;
         Bench.Test.create ~name:"deriving-protobuf: rw" dpb_rw;
         Bench.Test.create ~name:"atd-yojson: rw" atd_yojson_rw;
         Bench.Test.create ~name:"deriving-yojson: rw" dyo_rw;
         Bench.Test.create ~name:"protobuf-json: rw" pbuf_json_rw;
         Bench.Test.create ~name:"yojson-no-marshal: rw" yojson_rw;
         Bench.Test.create ~name:"binprot: read" binprot_read;
         Bench.Test.create ~name:"binprot: write" binprot_write;
         Bench.Test.create ~name:"capnp:write" capnp_write;
         Bench.Test.create ~name:"protobuf-bin: read" protobuf_bin_read;
         Bench.Test.create ~name:"protobuf-bin: write" protobuf_bin_write;
         Bench.Test.create ~name:"deriving-protobuf: read" dpb_read;
         Bench.Test.create ~name:"deriving-protobuf: write" dpb_write;
         Bench.Test.create ~name:"atd-yojson: read" atd_yojson_read;
         Bench.Test.create ~name:"atd-yojson: write" atd_yojson_write;
         Bench.Test.create ~name:"deriving-yojson: read" dyo_read;
         Bench.Test.create ~name:"deriving-yojson: write" dyo_write;
         Bench.Test.create ~name:"protobuf-json: read" pbuf_json_read;
         Bench.Test.create ~name:"protobuf-json: write" pbuf_json_write;
       ])
;;

let () = main ()
