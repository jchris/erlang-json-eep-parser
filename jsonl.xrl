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

\-?{D}+\.{D}+((E|e)(\+|\-)?{D}+)? : {token,{float,TokenLine,list_to_float(TokenChars)}}.
\-?{D}+(E|e)(\+|\-)?{D}+ : {token,{float,TokenLine,whole_float(TokenChars)}}.
\-?{D}+		:	{token,{integer,TokenLine,list_to_integer(TokenChars)}}.

% "[^"\\]*(\\[^u][^"\\]*)*"  : {token,{string,TokenLine,strip(unicode_string(TokenChars),TokenLen)}}.
"[^"\\]*(\\.[^"\\]*)*"  : {token,{string,TokenLine,parse_string(strip(TokenChars,TokenLen))}}.


% \\u{H}{H}{H}{H} : {token, {unicode, TokenLine,TokenChars}}.

true : {token,{'true', TokenLine}}.
false : {token,{'false', TokenLine}}.
null : {token,{'null', TokenLine}}.

: : {token, {':', TokenLine}}.
, : {token, {',', TokenLine}}.

{WS}+       :   skip_token.

Erlang code.
% "

-define(LOG(Name, Value), 
        io:format("{~p:~p}: ~p -> ~s~n", [?MODULE, ?LINE, Name, Value])).
-define(PLOG(Name, Value), 
        io:format("{~p:~p}: ~p -> ~p~n", [?MODULE, ?LINE, Name, Value])).

strip(TokenChars,TokenLen) -> lists:sublist(TokenChars, 2, TokenLen - 2).

whole_float(TokenChars) ->
  {ok, NowFloat, 1 } = regexp:sub(TokenChars,"e",".0e"),
  list_to_float(NowFloat).

unescape_quote(String) ->
  case regexp:first_match(String,"\\\\[\\\\\"\\/]") of
    {match, Pos, _} ->
      {Before, [_|After]} = lists:split(Pos-1, String),
      Before ++ unescape_quote(After);
    nomatch ->
      String
  end.
      
unescape_control(String) ->
  case regexp:first_match(String,"\\\\[bfnrt]") of
    {match, Pos, _} ->
      {Before, [_|[ContC|After]]} = lists:split(Pos-1, String),
      C = case ContC of
        $b -> $\b;
        $f -> $\f;
        $n -> $\n;
        $r -> $\r;
        $t -> $\t
      end,
      Before ++ [C] ++ unescape_control(After);
    nomatch ->
      String
  end.

unescape_unicode(String) ->
  case regexp:first_match(String,"\\\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]") of
    {match, Pos, _} ->
      {Before, After} = lists:split(Pos-1, String),
      % ?LOG("before",Before),
      {Code, Remain} = lists:split(6, After),
      % ?LOG("code",Code),
      % ?LOG("after",Remain),
      [_, _, C3, C2, C1, C0] = Code,
      % ?PLOG("pcode",{dehex(C0), dehex(C1), dehex(C2), dehex(C3)}),
      C = dehex(C0) bor
      (dehex(C1) bsl 4) bor
      (dehex(C2) bsl 8) bor
      (dehex(C3) bsl 12),
      Before ++ [C] ++ unescape_unicode(Remain);
    nomatch ->
      String
  end.

dehex(C) when C >= $0, C =< $9 ->
    C - $0;
dehex(C) when C >= $a, C =< $f ->
    C - $a + 10;
dehex(C) when C >= $A, C =< $F ->
    C - $A + 10.

parse_string(StringChars) -> 
  % ?LOG("string",StringChars),
  QuotesUnescaped = unescape_quote(StringChars),
  ControlUnescaped = unescape_control(QuotesUnescaped),
  unescape_unicode(ControlUnescaped).
