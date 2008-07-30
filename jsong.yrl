Nonterminals array element elements arrobj object members member.

Terminals '{' '}' '[' ']' string ',' ':' integer float true false null.

Rootsymbol element.

arrobj -> array : '$1'.
arrobj -> object : '$1'.

object -> '{' members '}' : {obj, '$2'}.
object -> '{' '}' : {obj, []}.
% object -> '{' member '}' : {'$2'}. % results in a shift/reduce conflict...

members -> member ',' members : ['$1' | '$3'].
members -> member : ['$1'].

member -> string ':' element : {element(3, '$1'),'$3'}.

array -> '[' elements ']' : list_to_tuple('$2').

elements -> element ',' elements : ['$1' | '$3'].
elements -> element : ['$1'].
elements -> '$empty' : [].

element -> string : element(3, '$1').
element -> arrobj : '$1'.
element -> integer : element(3, '$1').
element -> float : element(3, '$1').
element -> true : element(1, '$1').
element -> false : element(1, '$1').
element -> null : element(1, '$1').