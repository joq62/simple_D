%%% -------------------------------------------------------------------
%%% Author  : Joq Erlang
%%% Description : test application calc
%%%  
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(etcd_service). 

-behaviour(gen_server). 
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("common_macros.hrl").
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Key Data structures
%% 
%% --------------------------------------------------------------------
-record(state,{}).

%% Definitions 

%% --------------------------------------------------------------------

%-export([update_app_list/5,delete_app_list/3,read_app_list/1,
%	 set_app_info/5,
%	 update_app_info/5,read_app_info/1,
%	 app_info_item/2
%	]).


-export([set_node_info/4,set_node_info/6,read_node_info/1,
	 read_node_info/2, update_node_info/4, update_node_info/6
%	 update_node_info/4,delete_node_info/1,read_node_info/1,
%	 node_info_item/2
	]).

-export([start/0,
	 stop/0,
	 ping/0
	]).

%% gen_server callbacks
-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).


%% ====================================================================
%% External functions
%% ====================================================================

%% Asynchrounus Signals



%% Gen server functions

start()-> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
stop()-> gen_server:call(?MODULE, {stop},infinity).

ping()-> gen_server:call(?MODULE, {ping},infinity).


%%-----------------------------------------------------------------------

set_node_info(IpAddr,Port,Mode,Status)->
    gen_server:call(?MODULE, {set_node_info,IpAddr,Port,Mode,Status},infinity).

set_node_info(VmName,Vm,IpAddr,Port,Mode,Status)->
    gen_server:call(?MODULE, {set_node_info,VmName,Vm,IpAddr,Port,Mode,Status},infinity).

read_node_info(VmName)->
    gen_server:call(?MODULE, {read_node_info,VmName},infinity).

read_node_info(IpAddr,Port)->
    gen_server:call(?MODULE, {read_node_info,IpAddr,Port},infinity).

update_node_info(IpAddr,Port,Mode,Status)->
    gen_server:call(?MODULE, {update_node_info,IpAddr,Port,Mode,Status},infinity).
update_node_info(VmName,Vm,IpAddr,Port,Mode,Status)->
    gen_server:call(?MODULE, {update_node_info,VmName,Vm,IpAddr,Port,Mode,Status},infinity).


%()->
 %   gen_server:call(?MODULE, {  },infinity).

%()->
 %   gen_server:call(?MODULE, {  },infinity).


%%-----------------------------------------------------------------------


%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%
%% --------------------------------------------------------------------
init([]) ->
    lib_etcd:init(),
    {ok, #state{}}.
%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (aterminate/2 is called)
%% --------------------------------------------------------------------
handle_call({ping}, _From, State) ->
     Reply={pong,node(),?MODULE},
    {reply, Reply, State};

handle_call({set_node_info,IpAddr,Port,Mode,Status}, _From, State) ->
    Reply=rpc:call(node(),lib_etcd,set_node_info,[IpAddr,Port,Mode,Status]),
    {reply, Reply, State};

handle_call({set_node_info,VmName,Vm,IpAddr,Port,Mode,Status}, _From, State) ->
    Reply=rpc:call(node(),lib_etcd,set_node_info,[VmName,Vm,IpAddr,Port,Mode,Status]),
    {reply, Reply, State};

handle_call({read_node_info,VmName}, _From, State) ->
    Reply=rpc:call(node(),lib_etcd,read_node_info,[VmName]),
    {reply, Reply, State};

handle_call({read_node_info,IpAddr,Port}, _From, State) ->
    Reply=rpc:call(node(),lib_etcd,read_node_info,[IpAddr,Port]),
    {reply, Reply, State};


handle_call({update_node_info,IpAddr,Port,Mode,Status}, _From, State) ->
    Reply=rpc:call(node(),lib_etcd,update_node_info,[IpAddr,Port,Mode,Status]),
    {reply, Reply, State};

handle_call({update_node_info,VmName,Vm,IpAddr,Port,Mode,Status}, _From, State) ->
    Reply=rpc:call(node(),lib_etcd,update_node_info,[VmName,Vm,IpAddr,Port,Mode,Status]),
    {reply, Reply, State};

handle_call({stop}, _From, State) ->
    {stop, normal, shutdown_ok, State};

handle_call(Request, From, State) ->
    Reply = {unmatched_signal,?MODULE,Request,From},
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast({heart_beat,_Interval}, State) ->
    ok,  
    {noreply, State};

handle_cast(Msg, State) ->
    io:format("unmatched match cast ~p~n",[{?MODULE,?LINE,Msg}]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info(Info, State) ->
    io:format("unmatched match info ~p~n",[{?MODULE,?LINE,Info}]),
    {noreply, State}.


%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------
%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Internal functions
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------

