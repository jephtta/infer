(*
 * Copyright (c) 2016 - present Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 *)

(** module for escaping clang arguments on the command line and put them into files *)

open! IStd
module L = Logging

(** quoting style of the arguments *)
type style =
  | EscapedDoubleQuotes
      (** the arguments should be enclosed in "double quotes" and are already escaped *)
  | SingleQuotes  (** the arguments should be enclosed in 'single quotes' and have to be escaped *)
  | EscapedNoQuotes  (** the arguments should not be enclosed in quotes and are already escaped *)

let quote style =
  match style with
  | EscapedNoQuotes ->
      fun s -> s
  | EscapedDoubleQuotes ->
      fun s -> "\"" ^ s ^ "\""
  | SingleQuotes ->
      fun s -> Escape.escape_in_single_quotes s


let mk_arg_file prefix style args =
  let file = Filename.temp_file prefix ".txt" in
  let write_args outc =
    List.map ~f:(quote style) args |> String.concat ~sep:" " |> Out_channel.output_string outc
  in
  Utils.with_file_out file ~f:write_args |> ignore ;
  L.(debug Capture Medium) "Clang options stored in file %s@\n" file ;
  if not Config.debug_mode then Utils.unlink_file_on_exit file ;
  file
