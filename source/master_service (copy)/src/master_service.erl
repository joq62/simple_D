%%% -------------------------------------------------------------------
%%% Author  : Joq Erlang
%%% Description : test application calc
%%%  
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(master_service).  

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
-record(state,{dns_address,tcp_servers}).


%% --------------------------------------------------------------------
%% Definitions 
%% --------------------------------------------------------------------




-export([update_node_info/4,read_node_info/1,
	 node_availability/1,
	 update_app_info/5,read_app_info/1,
	 app_availability/1
	]).

-export([start/0,
	 stop/0,
	 ping/0,
	 heart_beat/1
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


ping()-> 
    gen_server:call(?MODULE, {ping},infinity).

%%-----------------------------------------------------------------------
app_availability(ServiceId)->
    gen_server:call(?MODULE, {app_availability,ServiceId},infinity).

update_app_info(ServiceId,Num,Nodes,Source,Status)->
    gen_server:call(?MODULE, {update_app_info,ServiceId,Num,Nodes,Source,Status},infinity).

read_app_info(ServiceId)->
    gen_server:call(?MODULE, {read_app_info,ServiceId},infinity).

node_availability(NodeId)->
    gen_server:call(?MODULE, {node_availability,NodeId},infinity).

update_node_info(IpAddr,Port,Mode,Status)->
    gen_server:call(?MODULE, {update_node_info,IpAddr,Port,Mode,Status},infinity).

read_node_info(NodeId)->
    gen_server:call(?MODULE, {read_node_info,NodeId},infinity).

%%-----------------------------------------------------------------------

heart_beat(Interval)->
    gen_server:cast(?MODULE, {heart_beat,Interval}).


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
    etcd:create_app_dets(),
    etcd:create_node_dets(),
  %  MyPid=self(),
   % spawn(fun()->do_dns_address(MyPid) end),
 %   spawn(fun()->h_beat(?HB_INTERVAL) end),
	
    {ok, #state{dns_address=[],tcp_servers=[]}}.   
    
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
handle_call({app_availability,ServiceId}, _From, State) ->
    Reply=rpc:call(node(),lib_master,app_availability,[ServiceId]),
    {reply, Reply,State};

handle_call({update_app_info,ServiceId,Num,Nodes,Source,Status}, _From, State) ->
    Reply=rpc:call(node(),lib_master,update_app_info,[ServiceId,Num,Nodes,Source,Status]),
    {reply, Reply,State};


handle_call({read_app_info,ServiceId}, _From, State) ->
    Reply=rpc:call(node(),lib_master,read_app_info,[ServiceId]),
    {reply, Reply,State};

handle_call({node_availability,NodeId}, _From, State) ->
    Reply=rpc:call(node(),lib_master,node_availability,[NodeId]),
    {reply, Reply,State};

handle_call({update_node_info,IpAddr,Port,Mode,Status}, _From, State) ->
    Reply=rpc:call(node(),lib_master,update_node_info,[IpAddr,Port,Mode,Status]),
    {reply, Reply,State};


handle_call({read_node_info,NodeId}, _From, State) ->
    Reply=rpc:call(node(),lib_master,read_node_info,[NodeId]),
    {reply, Reply,State};

handle_call({ping},_From,State) ->
    Reply={pong,node(),?MODULE},
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
handle_cast({heart_beat,Interval}, State) ->

    spawn(fun()->h_beat(Interval) end),    
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
h_beat(Interval)->
    timer:sleep(Interval),
    rpc:cast(node(),?MODULE,heart_beat,[Interval]).

%% --------------------------------------------------------------------
%% Internal functions
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
