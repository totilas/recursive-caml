open Traduction;; 
open Arguments;;
open Expr;;
open Env;;
open Safe;;
open Parser;;
open Affichage;;
open Eval;;


(* Fonction principale  *)
let interpreter () =

  (* On parse les arguments passés en CLI *)
  (* Arg.parse List -> (anon_arg string -> ()) -> in_channel*)
  Arg.parse optlist getsrcfile usage;

  (* On  initialise le parseur et le lexeur en lui donnant notre fichier comme
   flux entrant. Voir Arguments.ml pour les déclarations
 *)
  let lexbuf = Lexing.from_channel (!srcfile) in
(*  if (!tradimp) then
    (*à faire : ajouter la traduction des fonctions de la mémoire en haut du code à traduire*)

   (* let parse () = Parser.main Lexer.token lexbuf in
    let ast = parse () in
    let ast = App(trad_expr ast, Vide)*)


  else
 *)
   let parse () = Parser.main Lexer.token lexbuf in
    let ast = parse ()

    in


  if(!debugmode) then (aff_expr ast; print_newline());
  let _ = eval ast ( Environnement.empty) in

  flush stdout;
;;


(* On  exécute l'interpréteur *)
let _ = interpreter ();;
