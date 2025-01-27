(*---------------------------------------------------------------------------
   Copyright (c) 2020 The brr programmers. All rights reserved.
   Distributed under the ISC license, see terms at the end of the file.
  ---------------------------------------------------------------------------*)

open Brr

let button ?at onclick label =
  let but = El.button ?at [El.txt (Jstr.v label)] in
  ignore (Ev.listen Ev.click (fun _e -> onclick ()) (El.as_target but)); but

let with_frag frag u = Uri.with_uri ~fragment:(Jstr.v frag) u
let test_history () =
  let h = Window.history G.window in
  let loc = Window.location G.window in
  Window.History.push_state h ~uri:(with_frag "h1" loc |> Result.get_ok);
  Window.History.push_state h ~uri:(with_frag "h2" loc |> Result.get_ok);
  Window.History.push_state h ~uri:(with_frag "h3" loc |> Result.get_ok);
  ()

let test_no_reload () =
  let loc = Window.location G.window in
  Window.set_location G.window (with_frag "l1" loc |> Result.get_ok);
  Window.set_location G.window (with_frag "l2" loc |> Result.get_ok);
  ()

let test_back () = Window.History.back (Window.history G.window)
let test_forward () = Window.History.forward (Window.history G.window)
let test_reload () = Window.reload G.window

let main () =
  let noreload = button test_no_reload "Set window location" in
  let history = button test_history "Use history API" in
  let reload  = button test_reload "Reload window" in
  let prev = button test_back "← prev" in
  let next = button test_forward "next →" in
  let children = [ El.p [prev; next];
                   El.p [noreload; history; reload ]]
  in
  El.append_children (Document.body G.document) children

let () = main ()

(*---------------------------------------------------------------------------
   Copyright (c) 2020 The brr programmers

   Permission to use, copy, modify, and/or distribute this software for any
   purpose with or without fee is hereby granted, provided that the above
   copyright notice and this permission notice appear in all copies.

   THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
   WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
   MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
   ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
   WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
   ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
   OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  ---------------------------------------------------------------------------*)
