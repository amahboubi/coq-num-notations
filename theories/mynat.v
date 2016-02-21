(* -*- coq-prog-args: ("-emacs" "-top" "MyNum.mynat") -*- *)

(* The magic incantation above is here to allow processing the present file in
   "dev mode", with a Proof General executed from the root of the sources
    directory, and still have the plugin found by the coq toplevel. Hence the
    dev of the library can use his/her own parser inside the present file.

    The options of the _CoqProject file at the root of the directory should be
    enough for CoqIde but I have not tested yet.*)

(*------------------------------------------------------------------------------
 In this file, we define a type Nat and install a numeral parser/printer for it.
------------------------------------------------------------------------------*)

Load "options".

(* Natural numbers, in sort Type. *)
Inductive Nat : Type := OO : Nat | SS : Nat -> Nat.

Delimit Scope Nat_scope with Nat.
Bind Scope Nat_scope with Nat.
Arguments SS _%Nat.
Arguments SS _.

(* Importing the parser plugin. *)
Declare ML Module "my_nat_syntax_plugin".

(* Parsing *)
Check 0%Nat.

(* Printing *)
Check (SS OO).