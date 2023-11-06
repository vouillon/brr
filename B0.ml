open B0_kit.V000

(* OCaml library names *)

let js_of_ocaml_toplevel = B0_ocaml.libname "js_of_ocaml-toplevel"
let js_of_ocaml_compiler_runtime =
  B0_ocaml.libname "js_of_ocaml-compiler.runtime"

let brr = B0_ocaml.libname "brr"
let brr_ocaml_poke = B0_ocaml.libname "brr.ocaml_poke"
let brr_ocaml_poke_ui = B0_ocaml.libname "brr.ocaml_poke_ui"
let brr_poke = B0_ocaml.libname "brr.poke"
let brr_poked = B0_ocaml.libname "brr.poked"

(* Units *)

let brr_lib =
  let srcs = [`Dir ~/"src"] in
  let requires = [js_of_ocaml_compiler_runtime] in
  B0_ocaml.lib brr ~doc:"Brr JavaScript FFI and browser API" ~srcs ~requires

let brr_ocaml_poke_lib =
  let srcs = [`Dir ~/"src/ocaml_poke"] in
  let requires = [brr] in
  let doc = "OCaml poke objects interaction" in
  B0_ocaml.lib brr_ocaml_poke ~doc ~srcs ~requires

let brr_ocaml_poke_ui_lib =
  let srcs = [`Dir ~/"src/ocaml_poke_ui"] in
  let requires = [brr; brr_ocaml_poke] in
  let doc = "OCaml poke user interface (toplevel)" in
  B0_ocaml.lib brr_ocaml_poke_ui ~doc ~srcs ~requires

let brr_poke_lib =
  let srcs = [`Dir ~/"src/poke"] in
  let requires = [js_of_ocaml_compiler_runtime; js_of_ocaml_toplevel; brr] in
  let doc = "Poke explicitely" in
  B0_ocaml.lib brr_poke ~doc ~srcs ~requires

let brr_poked_lib =
  let srcs = [`Dir ~/"src/poked"] in
  let requires = [brr_poke] in
  let doc = "Poke by side effect" in
  B0_ocaml.lib brr_poked ~doc ~srcs ~requires

(* Web extension *)

let console =
  let doc = "Browser developer tool OCaml console" in
  let srcs =
    [ `Dir ~/"src/console";
      (* FIXME we want something like ext_js *)
      `X ~/"src/console/ocaml_console.js"; (* GNGNGNGN *)
      `X ~/"src/console/devtools.js";
      `X ~/"src/console/highlight.pack.js" ]
  in
  let requires = [brr; brr_ocaml_poke; brr_ocaml_poke_ui] in
  let meta =
    B0_meta.empty
    |> B0_meta.add B0_jsoo.compilation_mode `Whole
    |> B0_meta.add B0_jsoo.source_map (Some `Inline)
    |> B0_meta.add B0_jsoo.compile_opts (Cmd.arg "--pretty")
  in
  B0_jsoo.web "ocaml_console" ~requires ~doc ~srcs ~meta

let test_poke =
  let doc = "OCaml console test" in
  let srcs =
    [`File ~/"test/poke.ml";
     `File ~/"test/base.css"]
  in
  let requires = [brr; brr_poked] in
  let meta = B0_meta.empty |> B0_meta.tag B0_jsoo.toplevel in
  B0_jsoo.web "test_poke" ~requires ~doc ~srcs ~meta

let top =
  let doc = "In page toplevel test" in
  let srcs = [
    `File ~/"test/top.ml";
    (* FIXME js_of_ocaml chokes `File "src/console/highlight.pack.js";
       FIXME it's likely fixed by now. *)
    `File ~/"src/console/ocaml_console.css" ] in
  let requires =
    [ js_of_ocaml_compiler_runtime;
      brr; brr_ocaml_poke_ui; brr_poke; brr_ocaml_poke]
  in
  let meta =
    B0_meta.empty
    |> B0_meta.add B0_jsoo.compilation_mode `Whole
    |> B0_meta.tag B0_jsoo.toplevel
  in
  B0_jsoo.web "top" ~requires ~doc ~srcs ~meta

(* Tests and samples *)

let test_assets = [ `File ~/"test/base.css" ]

let test ?(requires = [brr]) n ~doc =
  let srcs = `File (Fpath.v (Fmt.str "test/%s.ml" n)) :: test_assets in
  B0_jsoo.web n ~requires ~doc ~srcs

let test_module ?doc top m requires  =
  let test = Fmt.str "test_%s" (String.Ascii.uncapitalize m) in
  let doc = Fmt.str "Test %s.%s module" top m in
  let srcs = `File (Fpath.v (Fmt.str "test/%s.ml" test)) :: test_assets in
  let meta =
    B0_meta.empty
    |> B0_meta.add B0_jsoo.compile_opts Cmd.(arg "--pretty")
    |> B0_meta.add B0_show_url.path Fpath.(v test + ".html")
  in
  B0_jsoo.web test ~requires ~doc ~srcs ~meta

let hello = test "test_hello" ~doc:"Brr console hello size"
let test_base64 = test_module "Brr" "Base64" [brr]
let test_c2d = test_module "Brr_canvas" "C2d" [brr]
let test_clipboard = test_module "Brr_io" "Clipboard" [brr]
let test_console = test_module "Brr" "Console" [brr]
let test_file = test_module "Brr" "File" [brr]
let test_geo = test_module "Brr_io" "Geolocation" [brr]
let test_gl = test_module "Brr_canvas" "Gl" [brr]
let test_history = test_module "Brr" "History" [brr]
let test_media = test_module "Brr_io" "Media" [brr]
let test_notif = test_module "Brr_io" "Notification" [brr]
let test_webaudio = test_module "Brr_webaudio" "Audio" [brr]
let test_webcrypto = test_module "Brr_webcrypto" "Crypto" [brr]
let test_webmidi = test_module "Brr_webmidi" "Midi" [brr]
let test_webgpu = test_module "Brr_webgpu" "Gpu" [brr]
let test_worker = test_module "Brr" "Worker" [brr]

let min =
  let srcs = [ `File ~/"test/min.ml"; `File ~/"test/min.html" ] in
  let requires = [brr] in
  B0_jsoo.web "min" ~requires ~doc:"Brr minimal web page" ~srcs

let nop =
  let srcs = [ `File ~/"test/nop.ml" ] in
  B0_jsoo.web "nop" ~doc:"js_of_ocaml nop web page" ~srcs

(* Actions *)

let update_console =
  let doc = "Update dev console" in
  B0_action.make' ~units:[console] ~doc "update-console" @@
  fun _ env ~args ->
  let jsfile = "ocaml_console.js" in
  let src = B0_env.in_unit_dir env console ~/jsfile in
  let dst = B0_env.in_scope_dir env Fpath.(~/"src/console" / jsfile) in
  Os.File.copy ~force:true ~make_path:false ~src dst

(* Packs *)

let test_pack = (* FIXME b0 add stuff for testing *)
  let us = [ test_console ] in
  let meta = B0_meta.empty |> B0_meta.tag B0_meta.test in
  B0_pack.make ~locked:false "test" ~doc:"Brr test suite" ~meta us

let jsoo_toplevels =
  (* FIXME this is wrong and make that nice to write
     Not sure why this is wrong in fact. *)
  let tops = B0_unit.has_tag B0_jsoo.toplevel in
  let us = List.filter tops (B0_unit.list ()) in
  let doc = "Units with toplevel (slow to build)" in
  B0_pack.make ~locked:false "tops" ~doc us

let default =
  let meta =
    B0_meta.empty
    |> B0_meta.(add authors) ["The brr programmers"]
    |> B0_meta.(add maintainers)
      ["Daniel Bünzli <daniel.buenzl i@erratique.ch>"]
    |> B0_meta.(add homepage) "https://erratique.ch/software/brr"
    |> B0_meta.(add online_doc) "https://erratique.ch/software/brr/doc/"
    |> B0_meta.(add licenses) ["ISC"; "BSD-3-Clause"]
    |> B0_meta.(add repo) "git+https://erratique.ch/repos/brr.git"
    |> B0_meta.(add issues) "https://github.com/dbuenzli/brr/issues"
    |> B0_meta.(add description_tags)
      [ "reactive"; "declarative"; "frp"; "front-end"; "browser";
        "org:erratique"]
    |> B0_meta.(tag B0_opam.tag)
    |> B0_meta.(add B0_opam.build)
      {|[["ocaml" "pkg/pkg.ml" "build" "--dev-pkg" "%{dev}%"]]|}
    |> B0_meta.(add B0_opam.depends)
      [ "ocaml", {|>= "4.08.0"|};
        "ocamlfind", {|build|};
        "ocamlbuild", {|build|};
        "topkg", {|build & >= "1.0.3"|};
        "js_of_ocaml-compiler", {|>= "4.1.0"|};
        "js_of_ocaml-toplevel", {|>= "4.1.0"|} ]
  in
  B0_pack.make "default" ~doc:"brr package" ~meta ~locked:true @@
  B0_unit.list ()
