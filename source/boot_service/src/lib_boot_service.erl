%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%%
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(lib_boot_service).
  


%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("common_macros.hrl").
%% --------------------------------------------------------------------

%% External exports
%-export([start/1
%	]).
	 
-compile(export_all).


%% ====================================================================
%% External functions
%% ====================================================================
get_config()->
    R=file:consult("computer.config"),
    R.
get_config(Key)->
    case file:consult("computer.config") of
	{ok,I}->
	    proplists:get_value(Key,I);
	{error,Err} ->
	    {error,Err}
    end.
%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
scratch(FilesToKeep)->
    {ok,Files}=file:list_dir("."),
    FilesToDelete=[File||File<-Files,false=:=lists:member(File,FilesToKeep)],
    [os:cmd("rm -rf "++File)||File<-FilesToDelete],
    FilesToDelete.

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% -------------------------------------------------------------------
start(Port)->
    glurk=Port.
