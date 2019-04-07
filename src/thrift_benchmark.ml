open Core
open Core_bench.Std

exception Oops of string

open Payloads_t
open Thrift
open Thrift_buffer_transport
open Tpayloads_consts
open Tpayloads_types

let main () =
  let t_transport = new Thrift_buffer_transport.t () in
  let t_protocol = new TBinaryProtocol.t (t_transport :> Transport.t) in
  let thrift_payload = new tPayload in
  thrift_payload#set_tfirst false;
  thrift_payload#set_tsecond true;
  thrift_payload#set_tthird 12345678.117;
  thrift_payload#set_tfourth 234567l;
  let thrift_payloadf1 = new tPayloadFifth in
  thrift_payloadf1#set_tffirst "premier";
  thrift_payloadf1#set_tfsecond "deuxieme";
  let thrift_payloadf2 = new tPayloadFifth in
  thrift_payloadf2#set_tfthird "troisieme";
  thrift_payloadf2#set_tffourth "quatrieme";
  let thrift_payloadf3 = new tPayloadFifth in
  thrift_payloadf3#set_tffirst "premier";
  thrift_payloadf3#set_tfsecond "deuxieme";
  let thrift_payloadf4 = new tPayloadFifth in
  thrift_payloadf4#set_tfthird "troisieme";
  thrift_payloadf4#set_tffourth "quatrieme";
  thrift_payload#set_tfifth
    [ thrift_payloadf1; thrift_payloadf2; thrift_payloadf3; thrift_payloadf4 ];
  thrift_payload#set_tsixth [ 1234l; 2345l; 3456l; 4567l; 5678l; 6789l; 7890l ];
  Command.run
    (Bench.make_command
       [ Bench.Test.create ~name:"thrift-bin read-write" (fun () ->
             thrift_payload#write t_protocol;
             ignore (read_tPayload t_protocol);
             (* let decoded = read_tPayload t_protocol in match
                decoded#get_fourth with | Some 234567l -> () | _ -> raise (Oops
                "fourth did not match after codec") *)
             t_transport#flush)
       ])
;;

let () = main ()
