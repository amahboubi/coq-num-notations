# coq-num-notations
This is a small demo (and remainder) showing how to install a custom parser for numerals in a user-defined datatype in Coq.
For the sake of simplicity, we illustrate this on an isomorphic copy of nat.

It includes:
- an src directory, for the sources of the plugin. This plugin adapts the sources of the parser for nat.
- a theory directory, for the .v files. File [mynat.v](./mynat.v) defines a type Nat, its associated scope, 
  and loads the plugin. File [test.v](./test.v) imports the mynat library and tests the plugin.
- a _CoqProject file setting the right options for everything to be both properly installed and usable in "dev mode" (i.e.
  when editing the .v files under ./theories). Users of the ProofGeneral interface should pay attention at the incantation
  which starts the mynat.v file, which seems necessary to be able to load the plugin in this dev mode.
