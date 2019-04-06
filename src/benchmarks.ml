open Core
open Core_bench.Std

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

let yojson_raw () =
  yojson_data |> Yojson.Basic.to_string |> Yojson.Basic.from_string
;;

let atd_data =
  Atd_payload_t.
    { first = false
    ; second = true
    ; third = 12345678.117
    ; fourth = 234567
    ; fifth =
        [ { first = Some "premier"
          ; second = Some "deuxieme"
          ; third = None
          ; fourth = None
          }
        ; { first = None
          ; second = None
          ; third = Some "troisieme"
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

let protobuf_data =
  Protobuf_payload_types.
    { first = false
    ; second = true
    ; third = 12345678.117
    ; fourth = 234567
    ; fifth =
        [ { first = "premier"; second = "deuxieme"; third = ""; fourth = "" }
        ; { first = ""
          ; second = ""
          ; third = "troisieme"
          ; fourth = "quatrieme"
          }
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

let protobuf_json =
  Yojson.Basic.to_string
    (Protobuf_payload_yojson.encode_protobuf_payload protobuf_data)
;;

let protobuf_json_read () =
  protobuf_json
  |> Yojson.Basic.from_string
  |> Protobuf_payload_yojson.decode_protobuf_payload
;;

let protobuf_json_write () =
  protobuf_data
  |> Protobuf_payload_yojson.encode_protobuf_payload
  |> Yojson.Basic.to_string
;;

let protobuf_json_rw () =
  protobuf_data
  |> Protobuf_payload_yojson.encode_protobuf_payload
  |> Yojson.Basic.to_string
  |> Yojson.Basic.from_string
  |> Protobuf_payload_yojson.decode_protobuf_payload
;;

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
        [ { first = Some "premier"
          ; second = Some "deuxieme"
          ; third = Some ""
          ; fourth = Some ""
          }
        ; { first = Some ""
          ; second = Some ""
          ; third = Some "troisieme"
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
  let buf = Bin_prot.Common.create_buf 1024 in
  let writer = Binprot_tests.bin_write_binprot_payload buf in
  let _ = writer ~pos:0 binprot_data in
  buf
;;

let binprot_rw () =
  if Binprot_tests.(String.compare shapedigest fakedigest) = 0
  then (
    let buf = Bin_prot.Common.create_buf 1024 in
    let writer = Binprot_tests.bin_write_binprot_payload buf in
    let _ = writer ~pos:0 binprot_data in
    let reader = Binprot_tests.bin_read_binprot_payload buf in
    let pos = ref 0 in
    reader pos |> ignore)
  else ()
;;

let binprot_write () =
  let buf = Bin_prot.Common.create_buf 1024 in
  let writer = Binprot_tests.bin_write_binprot_payload buf in
  writer ~pos:0 binprot_data
;;

let binprot_read () =
  if Binprot_tests.(String.compare shapedigest fakedigest) = 0
  then (
    let reader = Binprot_tests.bin_read_binprot_payload binprot_binbuf in
    let pos = ref 0 in
    reader pos |> ignore)
  else ()
;;

let main () =
  Command.run
    (Bench.make_command
       [ (* spacer *)
         Bench.Test.create ~name:"binprot: read-write" binprot_rw
       ; Bench.Test.create ~name:"protobuf-bin: read-write" protobuf_bin_rw
       ; Bench.Test.create ~name:"protobuf-json: read-write" protobuf_json_rw
       ; Bench.Test.create ~name:"atd-yojson: read-write" atd_yojson_rw
       ; Bench.Test.create ~name:"yojson: read-write PARTIAL" yojson_raw
       ; Bench.Test.create ~name:"binprot: read" binprot_read
       ; Bench.Test.create ~name:"binprot: write" binprot_write
       ; Bench.Test.create ~name:"protobuf-bin: read" protobuf_bin_read
       ; Bench.Test.create ~name:"protobuf-bin: write" protobuf_bin_write
       ; Bench.Test.create ~name:"protobuf-json: read" protobuf_json_read
       ; Bench.Test.create ~name:"protobuf-json: write" protobuf_json_write
       ; Bench.Test.create ~name:"atd-yojson: read" atd_yojson_read
       ; Bench.Test.create ~name:"atd-yojson: write" atd_yojson_write
       ])
;;

let () = main ()
