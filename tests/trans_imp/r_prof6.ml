let f x =

  raise (E (let _ = raise (E 12) in x))

in

 let x = try f 100

  with E y -> y

 in

 prInt x