open Printf

type error = Expected of string | Unexpected of string

let run cmd args =
  let open Shexp_process in
  let open Shexp_process.Infix in
  (* eval (run cmd args |- read_all) *)
  begin match eval (err_to_out (run_exit_status cmd args) |+ read_all) with
    | (Exited 0, output) -> output
    | (_, output) -> raise (Failure (String.trim output))
  end

let run_exit_code cmd args =
  let open Shexp_process in
  let open Shexp_process.Infix in
  eval (run_exit_code cmd args |+ read_all)

let run_exit_code_input cmd args input =
  let open Shexp_process in
  let open Shexp_process.Infix in
  eval (echo input |- run_exit_code cmd args |+ read_all)

let asm_name directory name = Printf.sprintf "%s/%s.s" directory name

let object_name directory name = Printf.sprintf "%s/%s.o" directory name

let binary_name directory name = Printf.sprintf "%s/%s.exe" directory name

let macos () = run "uname" ["-s"] |> String.trim |> String.equal "Darwin"

let asm_to_file instrs asm_file =
  let text =
    instrs
    |> List.map (Directive.string_of_directive ~macos:(macos ()))
    |> String.concat "\n"
  in
  let file =
    Unix.openfile asm_file [Unix.O_WRONLY; Unix.O_CREAT; Unix.O_TRUNC] 0o666
  in
  Unix.write_substring file text 0 (String.length text)
  |> fun _ -> Unix.close file

let assemble asm_file object_file =
  let format = if macos () then "macho64" else "elf64" in
  run "nasm" [asm_file; "-o"; object_file; "-f"; format] |> ignore

let copy_runtime runtime_file runtime_text =
  let file =
    Unix.openfile runtime_file [Unix.O_WRONLY; Unix.O_CREAT; Unix.O_TRUNC] 0o666
  in
  Unix.write_substring file runtime_text 0 (String.length runtime_text)
  |> fun _ -> Unix.close file

let link object_file runtime_file binary_file =
  let disable_pie = if macos () then "-Wl,-no_pie" else "-no-pie" in
  run "gcc" [disable_pie; object_file; runtime_file; "-o"; binary_file]
  |> ignore

let remove_object_files object_file runtime_file =
  run "rm" [object_file; runtime_file] |> ignore

let build directory runtime name instrs =
  let _ = try Unix.mkdir directory 0o777 with Unix.Unix_error _ -> () in
  let asm_file = asm_name directory name in
  let object_file = object_name directory name in
  let runtime_file = object_name directory "runtime" in
  let binary_file = binary_name directory name in
  asm_to_file instrs asm_file ;
  assemble asm_file object_file ;
  copy_runtime runtime_file runtime ;
  link object_file runtime_file binary_file ;
  remove_object_files object_file runtime_file ;
  binary_file

let eval directory runtime name args instrs =
  let exit =
    try Ok (run_exit_code (build directory runtime name instrs) args)
    with e -> Error (Unexpected (Printexc.to_string e))
  in
  Result.bind exit (function
    | 0, output ->
        Ok output
    | 1, output ->
        Error (Expected output)
    | code, output ->
        Error (Unexpected (sprintf "Exited with code %d: %s" code output)))

let eval_input directory runtime name args instrs input =
  let exit =
    try
      Ok (run_exit_code_input (build directory runtime name instrs) args input)
    with e -> Error (Unexpected (Printexc.to_string e))
  in
  Result.bind exit (function
    | 0, output ->
        Ok output
    | 1, output ->
        Error (Expected output)
    | code, output ->
        Error (Unexpected (sprintf "Exited with code %d: %s" code output)))
