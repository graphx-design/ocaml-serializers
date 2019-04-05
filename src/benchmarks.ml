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

(* TODO: remove ignore(), I think they're unnecessary? *)

let yojson_raw () =
  yojson_data |> Yojson.Basic.to_string |> Yojson.Basic.from_string |> ignore
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

let atd_yojson_read () =
  atd_json |> Atd_payload_j.atd_payload_of_string |> ignore
;;

let atd_yojson_write () =
  atd_data |> Atd_payload_j.string_of_atd_payload |> ignore
;;

let atd_yojson_rw () =
  atd_data
  |> Atd_payload_j.string_of_atd_payload
  |> Atd_payload_j.atd_payload_of_string
  |> ignore
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
  |> ignore
;;

let protobuf_bin_rw () =
  let my_encoder = Pbrt.Encoder.create () in
  Protobuf_payload_pb.encode_protobuf_payload protobuf_data my_encoder;
  let my_binary = Pbrt.Encoder.to_bytes my_encoder in
  ignore
    (Protobuf_payload_pb.decode_protobuf_payload
       (Pbrt.Decoder.of_bytes my_binary))
;;

let protobuf_json =
  Yojson.Basic.to_string
    (Protobuf_payload_yojson.encode_protobuf_payload protobuf_data)
;;

let protobuf_json_read () =
  protobuf_json
  |> Yojson.Basic.from_string
  |> Protobuf_payload_yojson.decode_protobuf_payload
  |> ignore
;;

let protobuf_json_write () =
  protobuf_data
  |> Protobuf_payload_yojson.encode_protobuf_payload
  |> Yojson.Basic.to_string
  |> ignore
;;

let protobuf_json_rw () =
  protobuf_data
  |> Protobuf_payload_yojson.encode_protobuf_payload
  |> Yojson.Basic.to_string
  |> Yojson.Basic.from_string
  |> Protobuf_payload_yojson.decode_protobuf_payload
  |> ignore
;;

let main () =
  Command.run
    (Bench.make_command
       [ Bench.Test.create ~name:"protobuf-bin: read-write" protobuf_bin_rw
       ; Bench.Test.create ~name:"protobuf-json: read-write" protobuf_json_rw
       ; Bench.Test.create ~name:"atd-yojson: read-write" atd_yojson_rw
       ; Bench.Test.create ~name:"yojson: read-write PARTIAL" yojson_raw
       ; Bench.Test.create ~name:"protobuf-bin: read" protobuf_bin_read
       ; Bench.Test.create ~name:"protobuf-bin: write" protobuf_bin_write
       ; Bench.Test.create ~name:"protobuf-json: read" protobuf_json_read
       ; Bench.Test.create ~name:"protobuf-json: write" protobuf_json_write
       ; Bench.Test.create ~name:"atd-yojson: read" atd_yojson_read
       ; Bench.Test.create ~name:"atd-yojson: write" atd_yojson_write
       ])
;;

let () = main ()
