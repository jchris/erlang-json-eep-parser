Nonterminals array element elements arrobj object members member.

Terminals '{' '}' '[' ']' string ',' ':' integer true false null.

Rootsymbol arrobj.

arrobj -> array : '$1'.
arrobj -> object : '$1'.

object -> '{' members '}' : '$2'.
object -> '{' member '}' : {'$2'}. % results in a shift/reduce conflict...

members -> member ',' members : {'$1', '$3'}.
members -> member : '$1'.

member -> string ':' element : {element(3, '$1'),'$3'}.

array -> '[' elements ']' : '$2'.

elements -> element ',' elements : lists:flatten(['$1', '$3']). % can this be faster?
elements -> element : '$1'.
elements -> '$empty' : nil.

element -> string : element(3, '$1').
element -> arrobj : '$1'.
element -> integer : element(3, '$1').
element -> true : element(1, '$1').
element -> false : element(1, '$1').
element -> null : element(1, '$1').