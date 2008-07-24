Definitions.

L = [A-Za-z]
WS  = ([\000-\s]|%.*)

Rules.

\[   : {token, {'(', TokenLine}}.
\]   : {token, {')', TokenLine}}.
{L}+  : {token,{atom,TokenLine,TokenChars}}.
{WS}+       :   skip_token.

Erlang code.

