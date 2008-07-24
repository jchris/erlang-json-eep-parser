Nonterminals list element elements.

Terminals '(' ')' 'atom'.

Rootsymbol list.

list -> '(' ')' : nil.
list -> '(' elements ')' : '$2'.

elements -> element : {cons, '$1', nil}.
elements -> element elements : {cons, '$1', '$2'}.
element -> atom : '$1'.
element -> list : '$1'.