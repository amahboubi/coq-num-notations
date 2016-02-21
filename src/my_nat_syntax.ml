(* This file extends Coq's printing/parsing features for the type Nat
   defined in theories/nat.v, which is isomorphic to nat (but in sort Type).

It has been  written by immitating nat_syntax, r_syntax (from Coq sources) and
the the sources of the ARBR contrib, sometimes not understanding fully what
happens here so immitate it at your own risks. *)

(* opens taken from nat_syntax, r_syntax *)
open Glob_term
open Bigint
open Pp
open Errors

open Names
open Globnames

open Term

(* Borrowed from Damien P. & Thomas B.'s ATBR plugin: access to Coq constants *)
(* The string seems to be only used for tagging error messages. *)
let get_const dir s =
  Coqlib.find_reference "MyNum.ssrhott_nat_syntax" dir s

(* Borrowed from nat_syntax (including the TODO):
   access to the kernel name of the type. *)

let make_dir l = DirPath.make (List.rev_map Id.of_string l)
let nat_definitions = make_dir ["MyNum";"mynat"]
let make_path dir id = Libnames.make_path dir (Id.of_string id)


let nat_path = make_path nat_definitions "Nat"

(* TODO: temporary hack *)
let make_path dir id = Globnames.encode_con dir (Id.of_string id)

let nat_kn = make_path nat_definitions "Nat"
let glob_Nat = ConstRef nat_kn

(* Using ATBR's function to get the global names of OO and SS *)
let glob_OO = get_const ["MyNum";"mynat"] "OO"
let glob_SS = get_const ["MyNum";"mynat"] "SS"

(*----------------------------------------------------------------------------*)
(* Again borrowed from nat_syntax:  Parsing numerals via scopes *)
(* For example, (nat_of_string "3") is <<(SS (SS (SS OO)))>> *)

let threshold = of_int 5000

let nat_of_int dloc n =
  if is_pos_or_zero n then begin
      if less_than threshold n then
        msg_warning
          (strbrk "Stack overflow or segmentation fault happens when " ++
           strbrk "working with large numbers in nat (observed threshold " ++
           strbrk "may vary from 5000 to 70000 depending on your system " ++
           strbrk "limits and on the command executed).");
      let ref_OO = GRef (dloc, glob_OO, None) in
      let ref_SS = GRef (dloc, glob_SS, None) in
      let rec mk_nat acc n =
        if n <> zero then
          mk_nat (GApp (dloc,ref_SS, [acc])) (sub_1 n)
        else
          acc
      in
      mk_nat ref_OO n
    end
  else
      user_err_loc (dloc, "nat_of_int",
        str "Cannot interpret a negative number as a number of type nat")

(*----------------------------------------------------------------------------*)
(* Again borrowed from nat_syntax: Printing via scopes *)

exception Non_closed_number

let rec int_of_nat = function
  | GApp (_,GRef (_,s,_),[a]) when Globnames.eq_gr s glob_SS ->
    add_1 (int_of_nat a)
  | GRef (_,z,_) when Globnames.eq_gr z glob_OO -> zero
  | _ -> raise Non_closed_number

let uninterp_nat p =
  try
    Some (int_of_nat p)
  with
    Non_closed_number -> None

(*----------------------------------------------------------------------------*)
(* Again borrowed from nat_syntax: Declare the primitive parsers and printers *)

let _ =
  Notation.declare_numeral_interpreter "Nat_scope"
    (nat_path,["MyNum";"mynat"])
    nat_of_int
    ([GRef (Loc.ghost,glob_SS,None);
      GRef (Loc.ghost,glob_OO,None)], uninterp_nat, true)


let mkGRef gr = GRef (Loc.ghost,gr,None)
