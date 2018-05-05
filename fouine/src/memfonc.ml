
  (*les trois fonctions de gestion mémoire à inclure au début de la traduction*)

  (*alloc de type unit -> loc*)
let allocate valeur memoire = match memoire with
  | [] -> (0, [ (0,valeur)] )
  | (n,v)::q -> (n+1, ((n+1, valeur)::(n,v)::q))

;;

(*read de type loc -> value*)
let rec read num memoire = match memoire with
  | (n,v)::q -> if n = num then v else read num q
  | [] -> raise Notfound
;;

(*modify de type loc -> value -> unit*)
let rec modify memoire couple = match memoire with
  | (n,v)::q -> let (num, newval)= couple in if n = num then (num, newval)::q else (n,v)::(modify q couple)
  | [] -> raise Notfound
;;