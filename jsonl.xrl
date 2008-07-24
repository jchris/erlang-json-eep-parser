Definitions.

ST = [^"]
L = [A-Za-z]
WS  = ([\000-\s]|%.*)
D = [0-9]
H = [0-9a-fA-F]

Rules.

{   : {token, {'{', TokenLine}}.
}   : {token, {'}', TokenLine}}.

\[   : {token, {'[', TokenLine}}.
\]   : {token, {']', TokenLine}}.

{D}+\.{D}+((E|e)(\+|\-)?{D}+)? :
			{token,{float,TokenLine,list_to_float(TokenChars)}}.
{D}+		:	{token,{integer,TokenLine,list_to_integer(TokenChars)}}.

% "[^"\\]*(\\[^u][^"\\]*)*"  : {token,{string,TokenLine,strip(TokenChars,TokenLen)}}.
"[^"\\]*(\\.[^"\\]*)*"  : {token,{string,TokenLine,list_to_binary(strip(TokenChars,TokenLen))}}.


\\u{H}{H}{H}{H} : {token, {unicode, TokenLine,TokenChars}}.

true : {token,{'true', TokenLine}}.
false : {token,{'false', TokenLine}}.
null : {token,{'null', TokenLine}}.

: : {token, {':', TokenLine}}.
, : {token, {',', TokenLine}}.

{WS}+       :   skip_token.

Erlang code.

strip(TokenChars,TokenLen) -> lists:sublist(TokenChars, 2, TokenLen - 2).

