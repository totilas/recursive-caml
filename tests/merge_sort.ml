let rec print_list l = match l with
|[] -> ()
|x::q -> prInt x; print_list q
;;

let rec fusion la lb =
  match (la, lb) with
  |(x::q, []) -> x::q
  |([], x::q) -> x::q
  |(x::q, y::t) -> if x < y then x::(fusion q lb) else y::(fusion la t)
  ;;



  print_list (fusion ([1;2;8;6;9]) ([1;2;3;4;5;6;7;8;9]))
