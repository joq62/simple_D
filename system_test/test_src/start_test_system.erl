%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%%
%%% {"pod_master",'pod_master@asus',"localhost",40000,parallell}.
%%% {"pod_landet_1",'pod_landet_1@asus',"localhost",50100,parallell}.
%%% {"pod_lgh_1",'pod_lgh_1@asus',"localhost",40100,parallell}.
%%% {"pod_lgh_2",'pod_lgh_2@asus',"localhost",40200,parallell}.
%%%
%%% {"adder_service",2,["pod_landet_1","pod_lgh_2"]}.
%%% {"divi_service",1,[]}.
%%% 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(start_test_system).  
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").
-include("common_macros.hrl").

%% --------------------------------------------------------------------
-compile(export_all).



%% ====================================================================
%% External functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function:emulate loader
%% Description: requires pod+container module
%% Returns: non
%% --------------------------------------------------------------------
start()->
    start_nodes(),
    ok=application:start(master_service),
    check_all_services_started(6,1000,1),
    check_nodes(),
    ok.

check_all_services_started(NumApps,Interval,N)->
    case lists:flatlength(dns_service:all()) of
	NumApps->
	    N;
	_ ->
	    timer:sleep(Interval),
	    check_all_services_started(NumApps,Interval,N+1)
    end.	    


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
check_nodes()->
    NodesInfo=master_service:nodes(),
    ?assertMatch([],
		 lib_master:check_missing_nodes(NodesInfo)),
    ok.
    



%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
start_nodes()->
    %% Start lib_service and tcp_server for pod_master 
    ok=application:start(lib_service),    
   lib_service:start_tcp_server("localhost",40000,parallell), 
    D=date(),
    ?assertEqual(D,tcp_client:call({"localhost",40000},{erlang,date,[]})),
    %% Create worker pods 
    {ok,NodeList}=file:consult(?NODE_CONFIG),
    WorkerList=[{NodeId,Node,IpAddr,Port,Mode}||{NodeId,Node,IpAddr,Port,Mode}<-NodeList,
						NodeId=/="pod_master"],
    IpInfoComputer={"localhost",40000},
    NodeComputer='pod_master@asus',
    NeededServices=[{{service,"lib_service"},{dir,"/home/pi/erlang/d/source"}}],
  
%  ?assertMatch([ok,ok,ok],[lib_master:start_pod(IpInfoComputer,NodeComputer,
%						  {Node,NodeId,IpAddrPod,PortPod,ModePod},
%						  NeededServices)
%		 ||{NodeId,Node,IpAddrPod,PortPod,ModePod}<-WorkerList]),
    ?assertMatch([ok,ok,ok],[tcp_client:call(IpInfoComputer,{lib_master,start_pod,
							     [{"localhost",40000},NodeComputer,
							      {Node,NodeId,IpAddrPod,PortPod,ModePod},
							      NeededServices]})
		     ||{NodeId,Node,IpAddrPod,PortPod,ModePod}<-WorkerList]),
    ok.



%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------


