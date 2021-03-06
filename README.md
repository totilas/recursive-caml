# Caml in Caml


> "Cet intérêt, nous l'appelons passion lorsque, refoulant tout autre intérêt ou but, l'individualité entière se projette sur un objectif avec toutes les fibres de son vouloir intérieur et concentre dans ce but tout ses forces et tous ses besoins. Rien de grand ne s'est accompli sans passion." -- __Hegel__


Le readme global est dans le dossier rapport.

## Utilisation

Exécuter la commande make à la racine du projet aura pour effet de compiler la présentation, le rapport, fouine ainsi que la documentation.

* A la racine:
  * `make` génère le rapport, la présentation ainsi que fouine et sa documentation
    - `make fouine` (exécute `make` dans le dossier `src/`)
    - `make report`
  * `make clean` supprime la documention, l'exécutable, les fichiers temporaires tex etc...
* Dans `src/`
  * `make` compile fouine et sa documentation
    - `make exec`
    - `make doc`
  * `make clean` supprime la documentation et l'exécutable



## Documentation

La documentation se trouve dans le dossier doc. Quelques informations complémentaires écrites à la main sont présentes ainsi que la documentation générée par ocamldoc lors de la compilation.

## Remarques

Nous avons implémenté une machine à pile qui gère les parties de fouine demandées : fonction récursives, aspects impératifs et exceptions et les nuplets. En bonus, nous avons choisi de faire de l'inférence de types.

Notre rendu propose aussi une version corrigée des rendus précédents, et notamment sur les points problématiques des traductions.


## Notre machine

Ses composants sont définis dans composantmachine. Nous récupérons l'arbre issu du parseur de fouine que nous compilons puis exécutons dans tradmachine. Enfin, nous avons créé plusieurs fonctions d'affichage dans showmachine, à la fois pour l'option stackcode et plus globalement pour que s'affiche le code, la pile et l'environnement en cas de problème lors de l'exécution.

Notre langage à pile est défini comme dans le cours, avec les choix suivants pour les parties non traitées en cours :

- Les exceptions sont construites de la façon suivante. On ne gère que le cas des (E variable). Pour traduire try e1 with E x -> e2, on compile e1, puis on pose un jalon Beginwith lors duquel on regarde si on a récupère une exception lors de l'exécution de e1. Dans ce cas, on déclare celle-ci comme étant la valeur de la variable. Le endwith aurait donc pu être supprimé, mais nous l'avons d'une part pour nous aider à voir la distinction entre deux étapes et d'autre part dans l'optique d'une possible généralisation de la portée des exceptions. Enfin, on execute e2 puis on supprime la variable que l'on a déclaré. Dans le cas contraire où aucune exception n'a été rencontrée on continue en ignorant le code jusqu'à Endexcep.

- Les aspects impératifs sont implémentés de façon très analogue à celle dans fouine. Nous avons changé de mémoire (cf `memmachine`) pour des problèmes de type, mais le reste fonctionne de la même manière.

- Les fonctions récursives sont définies par ClotR(f, x,code,env) sur la pile. Pour traduire un `let rec` on évalue d'abord le contenu que l'on place sur la pile (qui est une cloture d'une fonction classique), puis la commande `Rec f` construit une clôture récursive à partir de la cloture sur la pile. De plus, de la même manière que dans l'interpreter. Une cloture récursive conserve le nom de la fonction, l'argument, le code et l'état de la pile lors de sa création.

- Les couples sont implémentés de la façon suivante. On distingue les couples lors du let, et ceux utilisés avec des valeurs déjà définies. Dans le premier cas, on construit un Acoupler alors que sinon on définit un simple couple. Le fonctionnement est le suivant : on calcule progressivement toutes les valeurs du n-uplet sur la pile dans des Valcouple, puis quand le n-uplet est terminé on dépile jusqu'au début du couple. Ce fonctionnement ne marchait pas pour les déclarations de forme let (a,b) = (1,2) car il engendrait un Access à une variable qui devait au contraire être déclaré, d'où l'apparition de acoupler. Des solutions plus élégantes et plus efficaces sont sans aucun doute possibles, par exemple pour permettre des déclarations enchâssées.

- Au niveau de l'affichage : on affiche les print en cours d'exécution.
En cas de problème au cours de l'exécution, on affiche qu'on a eu un problème, puis on affiche le code restant, les noms des éléments présents dans l'environnement et ce qu'il y a dans la pile. Pour un uplet, on affiche les éléments qui sont des nombres, et NAN sinon.

Voici une description du langage de notre machine:

```
type instruction =
  | C of int (*Pour les constantes*)
  | Add  | Mul | Sub | Div
  | Let of name (*Fidèle aux notations du cours*)
  | Access of name
  | Endlet
  | Clos of name * (instruction list)
  | Rec of name
  | Ret
  | Apply
  | IfThenElse of (instruction list) * (instruction list)
  | Eq | Neq  | Lt  | Gt  | Le  | Ge
  | Print

  (*Les aspects impératifs*)
  | Ref
  | Aff
  | Bang

(*Les exceptions*)
  | Raise
  | Beginwith
  | Endwith
  | Endexcep

  (*Les couples*)
  | Ajoutcouple
  | Acoupler of (instruction list list) (*Pour les couples à gauche d'un let*)
  | Couple of (instruction list list)

```



## L'inférence de type

Nous gérons l'inférence de type dans le fichier `typechecking.ml`. L'inférence de type correspond à un union find pour déterminer les classes d'équivalences des différentes variables et à un algorithme d'unification qui essaie de déterminer si deux éléments peuvent avoir le même type.

Nous avons implémenté ces aspects à partir d'une fonction `infer` qui renvoie le type de l'expression considérée ainsi qu'un environnement contenant les assignations de types aux différentes variables. Une seconde fonction `t_unify` tente d'unifier 2 types qui lui sont passés en argument. Si elle réussit, elle retourne le type convenant aux 2 sinon elle explose et engendre une erreur rattrapée par le gestionnaire d'erreur qui peut alors afficher la ligne / caractères qui posent problème ainsi que les 2 types qui ne sont pas cohérents.

La structure d'union find est implémentée en utilisant un constructeur de type `TypeOf` pour signifier que l'élément en question a le type de telle variable. Cela correspond à une structure d'arbre dont la racine possède un type explicite ou non que l'on assigne à tous les éléments de la classe d'équivalence.

Nous gérons une forme simple du polymorphisme ainsi que le typage de certains des bonus précédemment réalisés comme les listes ou les n-uplets.

L'option `-disptype` affiche le type de sortie d'un programme (et vérifie la cohérence de ses types sans l'exécuter). Quant à l'option `-typecheck` elle provoque la vérification des types, sans afficher le type de sortie puis exécute le programme si on a pas explosé avant à cause d'une erreur de typage.



## Remarques
- La compilation de fouine est maintenant Warning Free. Nous avons grandement amélioré la gestion des erreurs.
- Nous avons corrigé le bug lié aux retours à la ligne.
- Nous avons corrigé une partie importante des traductions. Un problème persiste cependant lorsque l'on effectue la traduction -ER car nos fonctions de gestion de la mémoire sont écrites en fouine et ne passent pas la traduction en continuation (question de pattern matching etc...). (Nous n'avions pas vu ce problème lors du rendu précédent)
- Nous avons aussi effectué un "fix" rapide pour coller aux consignes pour la syntaxe des exceptions: (E x).
- Les tests sont dans différents sous-dossiers de tests. `machine` correspond aux tests de la machine à pile, `manual` aux tests nécessitant une correction manuelle, `simples` les tests pouvant être corrigés par OCaml, `trans_excep` les tests pour la traduction -E et `trans_imp` ceux pour la traduction impérative. Des scripts bash pour chaque dossier sont fournis.
