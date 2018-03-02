
open Arguments;;
open Expr;;
open Env;;
open Safe;;
open Parser;;
open Affichage;;


(* Fonction principale  *)
let interpreter () =
  
  (* On parse les arguments passés en CLI *)
  (* Arg.parse List -> (anon_arg string -> ()) -> in_channel*)
  Arg.parse optlist getsrcfile usage;

  (* On  initialise le parseur et le lexeur en lui donnant notre fichier comme flux entrant. Voir Arguments.ml pour les déclarations
 *)
  let lexbuf = Lexing.from_channel (!srcfile) in
  let parse () = Parser.main Lexer.token lexbuf in

  let ast = parse () in
  if(!debugmode) then (affiche_expr ast);
  eval ast ( Environnement.empty);

  flush stdout; 
;;


(* On  exécute l'interpréteur *)
let _ = interpreter ();;
