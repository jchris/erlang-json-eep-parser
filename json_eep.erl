%% @author Chris Anderson <jchris@grabb.it>
%% @copyright 2008 Chris Anderson.
%% @author Bob Ippolito <bob@mochimedia.com>
%% @copyright 2006 Mochi Media, Inc.
%%
%% Permission is hereby granted, free of charge, to any person
%% obtaining a copy of this software and associated documentation
%% files (the "Software"), to deal in the Software without restriction,
%% including without limitation the rights to use, copy, modify, merge,
%% publish, distribute, sublicense, and/or sell copies of the Software,
%% and to permit persons to whom the Software is furnished to do
%% so, subject to the following conditions:
%%
%% The above copyright notice and this permission notice shall be included
%% in all copies or substantial portions of the Software.
%%
%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
%% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
%% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
%% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
%% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
%% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
%% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

%% @doc Parser to illustrate EEP
%% tests based on mochijson


-module(json_eep).
-author('bob@mochimedia.com').
-author('jchris@grabb.it').
-export([json_to_term/1]).
-export([test/0]).

json_to_term(S) ->
    {ok, Tokens, _} = json_lex2:string(S),
    % ?LOG("Tokens",Tokens),
    {ok, Result} = json_grammar:parse(Tokens),
    % ?LOG("Result",Result),
    Result.

%% Test for equivalence of Erlang terms.
%% Due to arbitrary order of construction, equivalent objects might
%% compare unequal as erlang terms, so we need to carefully recurse
%% through aggregates (tuples and objects).

equiv(T1, T2) when is_list(T1), is_list(T2) ->
    equiv_list(T1, T2);
equiv({T1}, {T2}) when is_list(T1), is_list(T2) ->
    equiv_object(T1, T2);
equiv(N1, N2) when is_number(N1), is_number(N2) -> N1 == N2;
equiv(S1, S2) when is_binary(S1), is_binary(S2) -> S1 == S2;
equiv(true, true) -> true;
equiv(false, false) -> true;
equiv(null, null) -> true.

%% Object representation and traversal order is unknown.
%% Use the sledgehammer and sort property lists.

equiv_object(Props1, Props2) ->
    L1 = lists:keysort(1, Props1),
    L2 = lists:keysort(1, Props2),
    Pairs = lists:zip(L1, L2),
    true = lists:all(fun({{K1, V1}, {K2, V2}}) ->
    equiv(K1, K2) and equiv(V1, V2)
    end, Pairs).

%% Recursively compare tuple elements for equivalence.

equiv_list([], []) ->
    true;
equiv_list([V1 | L1], [V2 | L2]) ->
    case equiv(V1, V2) of
    true ->
        equiv_list(L1, L2);
    false ->
        false
    end.

test() -> 
  test_next(tests(binary)).

test_next([]) -> {ok, passed};

test_next([{E,J}|Rest]) ->
  io:format("~p ~p~n", [E, J]),
  Decoded = json_to_term(J),
  io:format("~p ~p~n", [E, Decoded]),
  true = equiv(E, Decoded),
  test_next(Rest).
  
tests(binary) ->
  [
    {{[{<<"key">>,<<"value">>}]}, "{\"key\":\"value\"}"},
    {{[]},"{}"},
    {[], "[]"},
    {[1], "[1]"},
    {[3.1416], "[3.14160]"}, % text representation may truncate, trail zeroes
    {[-1], "[-1]"},
    {[-3.1416], "[-3.14160]"},
    {{[{<<"number">>, 12.0e10}]}, "{\"number\":1.20000e+11}"},
    {[1.234E+10], "[1.23400e+10]"},
    {[-1.234E-10], "[-1.23400e-10]"},
    {[10.0], "[1.0e+01]"},
    {[123.456], "[1.23456E+2]"},
    {[10.0], "[1e1]"},
    {[<<"foo">>], "[\"foo\"]"},
    {[<<>>], "[\"\"]"},
    {[<<"1/4">>], "[\"1\/4\"]"},
    {[<<"name is \"Quentin\"">>], "[\"name is \\\"Quentin\\\"\"]"},
    {[<<"\n\n\n">>], "[\"\\n\\n\\n\"]"},
    {[iolist_to_binary("foo" ++ [5] ++ "bar")], "[\"foo\\u0005bar\"]"},
    {{[{<<"foo">>, <<"bar">>}]}, "{\"foo\":\"bar\"}"},
    {{[{<<"foo">>, <<"bar">>}, {<<"baz">>, 123}]}, "{\"foo\":\"bar\",\"baz\":123}"},
    {[[]], "[[]]"},
    {[1, <<"foo">>], "[1,\"foo\"]"},

    % json array in a json object
    {{[{<<"foo">>, [123]}]}, "{\"foo\":[123]}"},

    % json object in a json object
    {{[{<<"foo">>, {[{<<"bar">>, true}]}}]},
     "{\"foo\":{\"bar\":true}}"},

    % fold evaluation order
    {{[{<<"foo">>, []},
                     {<<"bar">>, {[{<<"baz">>, true}]}},
                     {<<"alice">>, <<"bob">>}]},
     "{\"foo\":[],\"bar\":{\"baz\":true},\"alice\":\"bob\"}"},

    % json object in a json array
    {[-123, <<"foo">>, {[{<<"bar">>, []}]}, null],
     "[-123,\"foo\",{\"bar\":[]},null]"}
  ].