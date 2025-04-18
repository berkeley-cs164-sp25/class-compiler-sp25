open Shared

module I : Infra.T = struct
  type program = Ast.program

  let parse syntax s =
    match syntax with
    | Infra.Lisp -> Lisp_syntax.parse s
    | Infra.Mlb -> failwith "can't do mlb"

  let interp = Lib.Interp.interp
  let interp_io ~input prog = Lib.Interp.interp_io prog input
  let compile = Lib.Compile.compile
  let runtime_object_file = Lib.Runtime.runtime
end

module Cli = Shared.Cli.Make (I)
module Difftest = Shared.Difftest.Make (I)
