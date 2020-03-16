%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(orchistrate_test).  
   
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
    ?assertMatch([{"dns_service","localhost",40000,pod_master@asus,
		   _},
		  {"master_service","localhost",40000,pod_master@asus,
		   _}],dns_service:all()),
    master_service:campaign(),
    timer:sleep(15*1000),
    ?assertMatch(6,lists:flatlength(dns_service:all())),

    ?assertMatch([{"localhost",_,_},
		  {"localhost",_,_}],tcp_client:call(?DNS_ADDRESS,{dns_service,get,["adder_service"]})),

    ?assertMatch([{"localhost",_,_}],tcp_client:call(?DNS_ADDRESS,{dns_service,get,["divi_service"]})),

    %% do something
    [{IpAddrDivi,PortDivi,_}|_]=tcp_client:call(?DNS_ADDRESS,{dns_service,get,["divi_service"]}),
    ?assertEqual(42.0,tcp_client:call({IpAddrDivi,PortDivi},{divi_service,divi,[420,10]})),
    
    % remove divi_service
    master_service:stop_unload("divi_service",IpAddrDivi,PortDivi),
    ?assertMatch({badrpc,_},tcp_client:call({IpAddrDivi,PortDivi},{divi_service,divi,[420,10]})),
    ?assertEqual([],tcp_client:call(?DNS_ADDRESS,{dns_service,get,["divi_service"]})),

    %% RESTART divi 
    master_service:campaign(),
    timer:sleep(10*1000),
  %% do something
    [{IpAddrDivi2,PortDivi2,_}|_]=tcp_client:call(?DNS_ADDRESS,{dns_service,get,["divi_service"]}),
    ?assertEqual(84.0,tcp_client:call({IpAddrDivi2,PortDivi2},{divi_service,divi,[840,10]})),

    %% Node missing 
   
    pod:delete('pod_landet_1@asus', "pod_landet_1"),
    ?assertMatch({error,_},tcp_client:call({IpAddrDivi2,PortDivi2},{divi_service,divi,[840,10]})),

    %% campaign
    %% 1). Update configs - ensure that only availble nodes are part of the orchistration
    %% 2). Remove missing services from dns . Registered Service Not memeber of Desired  
    %% 3). Try to start missing services based on available nodes

    master_service:campaign(),
   %  ?assertEqual(glurk,tcp_client:call(?DNS_ADDRESS,{dns_service,get,["divi_service"]})),
    timer:sleep(2*1000),
    ServiceId="divi_service",
    M=divi_service,
    F=divi,
    A=[980,10],
    NumTries=10,
    Delay=200,
    ?assertEqual(98.0,tcp_client:call(ServiceId,M,F,A,NumTries,Delay)),
    ok.

do_call([],ServiceId,M,F,A,Result,N)->
    timer:sleep(500),
    IpAddrList=tcp_client:call(?DNS_ADDRESS,{dns_service,get,[ServiceId]}),
    do_call(IpAddrList,ServiceId,M,F,A,Result,N+1);
do_call([{IpAddr,Port,_Node}|_],ServiceId,M,F,A,Result,N)->
    case tcp_client:call({IpAddr,Port},{M,F,A}) of
	{error,_}->
	    timer:sleep(500),
	    IpAddrList=tcp_client:call(?DNS_ADDRESS,{dns_service,get,[ServiceId]}),
	    do_call(IpAddrList,ServiceId,M,F,A,Result,N+1);
	{badrpc,_}->
	     timer:sleep(500),
	    IpAddrList=tcp_client:call(?DNS_ADDRESS,{dns_service,get,[ServiceId]}),
	    do_call(IpAddrList,ServiceId,M,F,A,Result,N+1);
	_->
	    ?assertEqual(Result,tcp_client:call({IpAddr,Port},{M,F,A}))
    end.

%% --------------------------------------------------------------------
%% Function:emulate loader
%% Description: requires pod+container module
%% Returns: non
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
% Missing,{"divi_service","localhost",40000},


load_start([],StartResult)->
    StartResult;
load_start([{ServiceId,IpAddrPod,PortPod}|T],Acc)->
    NewAcc=[master_service:load_start(ServiceId,IpAddrPod,PortPod)|Acc],
    load_start(T,NewAcc).



%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
find_obsolite()->
  %  ?assertMatch([],tcp_client:call({"localhost",45000},{list_to_atom("glurk_service"),ping,[]})),
    DS=master_service:desired_services(),
    ?assertMatch([{"dns_service","localhost",40000},
		  {"master_service","localhost",40000}],lib_master:check_obsolite_services(DS)),
    DS2=[{"divi_service","localhost",40000}|DS],
    ?assertMatch([{"dns_service","localhost",40000},
		  {"master_service","localhost",40000}],lib_master:check_obsolite_services(DS2)),
    
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
available()->
    NodesInfo=master_service:nodes(),
    ?assertMatch([{"pod_master",pod_master@asus,"localhost",40000,parallell}],
		 lib_master:check_available_nodes(NodesInfo)),
  
    
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
find_missing()->
  %  ?assertMatch([],tcp_client:call({"localhost",45000},{list_to_atom("glurk_service"),ping,[]})),
    NodesInfo=master_service:nodes(),
    ?assertMatch([{"pod_landet_1",pod_landet_1@asus,"localhost",50100,parallell},
		  {"pod_lgh_1",pod_lgh_1@asus,"localhost",40100,parallell},
		  {"pod_lgh_2",pod_lgh_2@asus,"localhost",40200,parallell}],
		 lib_master:check_missing_nodes(NodesInfo)),
  
    
    ok.

