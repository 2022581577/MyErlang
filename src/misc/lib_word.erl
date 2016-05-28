%%%----------------------------------------------------------------------
%%% @author : zhongbinbin <zhongbinbin@163.com>
%%% @date   : 2013.09.02
%%% @desc   : 字符串、文本的一些统计接口（如：屏蔽字、名字长度检测）
%%%----------------------------------------------------------------------
-module(lib_word).

-include("common.hrl").
-include("record.hrl").

-export([string_width/1,
        string_ver/1]).

%% 敏感词处理
-export([words_filter/1,
        words_ver/1]).

%% 字符宽度，1汉字=2单位长度，1数字字母=1单位长度
string_width(BinStr) when is_binary(BinStr) ->
    string_width(util:to_utf8_list(BinStr));
string_width(String) ->
    string_width(String, 0).
string_width([], Len) ->
    Len;
string_width([H | T], Len) ->
    case H > 255 of
        true ->
            string_width(T, Len + 2);
        false ->
            string_width(T, Len + 1)
    end.

%% 字符串中是否合法（有无非法字符）
string_ver(BinStr) when is_binary(BinStr) ->
    string_ver(util:to_utf8_list(BinStr));
string_ver(String) ->
    F = fun(Char) ->
            case Char =:= 8226 orelse
                Char < 48 orelse
                (Char > 57 andalso Char < 65) orelse
                (Char > 90 andalso Char < 95) orelse
                (Char > 122 andalso Char < 130) of
                true -> false;
                _ ->    true
            end
        end,
    lists:all(F, String).

%% 屏蔽敏感字
-spec words_filter(Args :: binary()) -> binary().
words_filter(WordsForFilter) ->     
    WordsList = data_words:get(),    
    F = fun(KWord, AccIn) ->
            re:replace(AccIn, KWord, "*", [global, caseless, {return, binary}])
        end,
    lists:foldl(F, WordsForFilter, WordsList).

%% 判断是否有敏感字
-spec words_ver(Args :: binary()) -> boolean().
words_ver(WordsForVer) -> 
    WordsList = data_words:get(),    
    words_ver(WordsList, util:to_list(WordsForVer)).

words_ver([H | T], WordsForVer) ->
    case string:str(WordsForVer,H) of
        0 -> 
            words_ver(T, WordsForVer);   
        _ -> 
            false 
    end;
words_ver([],_WordsForVer) ->
    true.
