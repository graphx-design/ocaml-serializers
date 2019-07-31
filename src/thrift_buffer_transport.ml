(** There was no buffer transport, so, here's a quick hack... *)

open Thrift
module T = Transport

class t () =
  object (self)
    inherit T.t

    val mutable opened = true

    val mutable buffer = ""

    val mutable read_offset = 0

    method isOpen = opened

    method opn = ()

    method close = opened <- false

    method read buf off len =
      if opened then (
        let to_copy = min len (String.length buffer - read_offset) in
        if to_copy > 0 then (
          String.blit buffer read_offset buf off to_copy;
          read_offset <- read_offset + to_copy;
          to_copy
        ) else
          0
      ) else
        raise (T.E (T.NOT_OPEN, "TBufferTransport: Channel was closed"))

    method write buf off len =
      if opened then
        buffer <- buffer ^ String.sub buf off len
      else
        raise (T.E (T.NOT_OPEN, "TBufferTransport: Channel was closed"))

    method flush =
      buffer <- "";
      read_offset <- 0
  end
