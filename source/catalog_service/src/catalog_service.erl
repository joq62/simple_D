%%% -------------------------------------------------------------------
%%% Author  : Joq Erlang
%%% Created : 10 dec 2012
%%% Description boot_service
%%% Make and start the board start SW.
%%% Makefile
%%% 	rm -rf ebin/* src/*~ src/container.erl src/pod.erl src/misc_lib.erl test_ebin/* test_src/*~;
%%&     clone lib_service
%%%     clone boot_service
%%%     erlc lib_service
%%%     erlc boot_service
%%%     erl -pa */ebin -s boot_strap start port -sname board_id
%%% 
%%%  boot_strap: sets the boot_service application_env port and starts lib_service and boot_service 
%%%  boot_service initiates tcp_server and listen on port
%%%  Then it's standby and waits for controller to detect the board and start to load applications
%%% 
%%%     
%%% -------------------------------------------------------------------
-module(boot_service). 

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
-record(state,{ip_addr,port}).


	  
%% --------------------------------------------------------------------

%% ====================================================================
%% External functions
%% ====================================================================


%% server interface
-export([config/0	 
	]).



-export([ping/0,
	 start/0,
	 stop/0
	 ]).
%% internal 
%% gen_server callbacks
-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).


%% ====================================================================
%% External functions
%% ====================================================================

%% Asynchrounus Signals
%boot_strap()->
 %   PortStr=atom_to_list(PortArg),
 %   Port=list_to_integer(PortStr),
   % application:set_env([{boot_service,{port,Port}}]),
%    application:start(boot_service).
	
%% Gen server function

start()-> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
stop()-> gen_server:call(?MODULE, {stop},infinity).


%%----------------------------------------------------------------------
ping()->
    gen_server:call(?MODULE,{ping},infinity).

config()->
    gen_server:call(?MODULE,{config},infinity).


%%___________________________________________________________________


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
    %% scratch computer
    FilesToKeep=lib_boot_service:get_config(files_to_keep),
    lib_boot_service:scratch(FilesToKeep),
    %%
    application:start(lib_service),
    IpAddr=lib_boot_service:get_config(ip_addr),
    Port=lib_boot_service:get_config(port),
    Mode=lib_boot_service:get_config(mode),
    ok=lib_service:start_tcp_server(IpAddr,Port,Mode),
    {ok, #state{ip_addr=IpAddr,port=Port}}.
    
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

handle_call({config}, _From, State) ->
    Reply=glurk,
    {reply, Reply, State};



handle_call({stop}, _From, State) ->
    lib_service:stop_tcp_server(State#state.ip_addr,State#state.port),
    {stop, normal, shutdown_ok, State};

handle_call(Request, From, State) ->
    Reply = {unmatched_signal,?MODULE,?LINE,Request,From},
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------


handle_cast(Msg, State) ->
    io:format("unmatched match cast ~p~n",[{?MODULE,?LINE,Msg}]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)

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
%% Internal functions
%% --------------------------------------------------------------------
