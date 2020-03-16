%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(iaas_service_tests). 
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").
-include("common_macros.hrl").
%% --------------------------------------------------------------------

%% External exports
-export([start/0]).



%% ====================================================================
%% External functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
-define(NODES,[{"pod_lib_1",'pod_lib_1@asus',"localhost",50001,sequence},
	       {"pod_lib_2",'pod_lib_2@asus',"localhost",50002,sequence},
	       {"pod_lib_3",'pod_lib_3@asus',"localhost",50003,sequence},
	       {"pod_lib_4",'pod_lib_4@asus',"localhost",50004,sequence}]).
-define(SOURCE,{dir,"/home/pi/erlang/d/source"}).
cases_test()->
    [clean_start(),
     eunit_start(),
     % Add funtional test cases 
     iaas_service_test_cases:add_pods(),
     iaas_service_test_cases:detect_lost_computer(),
     iaas_service_test_cases:detect_restarted_computer(),
     % cleanup and stop eunit 
     clean_stop(),
     eunit_stop()].







%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
start()->
    spawn(fun()->eunit:test({timeout,30,iaas_service}) end).



clean_start()->
    Glurk=['pod_computer_1@asus','pod_computer_2@asus','pod_computer_3@asus','pod_computer_4@asus'],
    [rpc:call(Node,init,stop,[])||Node<-Glurk],
    
    [pod:delete(node(),PodName)||{PodName,_,_,_,_}<-?NODES],
    [pod:create(node(),PodName)||{PodName,_,_,_,_}<-?NODES],
    [container:create(Computer,PodName,
		      [{{service,"lib_service"},
			?SOURCE}
		      ])||{PodName,Computer,_,_,_}<-?NODES],
    ?assertEqual([{pong,pod_lib_1@asus,lib_service},
		  {pong,pod_lib_2@asus,lib_service},
		  {pong,pod_lib_3@asus,lib_service},
		  {pong,pod_lib_4@asus,lib_service}],
		 [rpc:call(Computer,lib_service,ping,[])||{_,Computer,_,_,_}<-?NODES]),
    [rpc:call(Computer,lib_service,start_tcp_server,[IpAddr,Port,ServerMode])||{_,Computer,IpAddr,Port,ServerMode}<-?NODES],
    %% GLURK very strange do not understande where computer comes from
    ?assertEqual([{pong,pod_lib_1@asus,lib_service},
		  {pong,pod_lib_2@asus,lib_service},
		  {pong,pod_lib_3@asus,lib_service},
		  {pong,pod_lib_4@asus,lib_service}],
		 [tcp_client:call({IpAddr,Port},{lib_service,ping,[]})||{_,_,IpAddr,Port,_}<-?NODES]),
    
    ok.


eunit_start()->
    [start_service(lib_service),
     check_started_service(lib_service),
     start_service(iaas_service),
     check_started_service(iaas_service)].



clean_stop()->
    [pod:delete(node(),PodName)||{PodName,_,_,_,_}<-?NODES],
    ?assertMatch([{error,_},
		  {error,_},
		  {error,_},
		  {error,_}],
		 [tcp_client:call({IpAddr,Port},{lib_service,ping,[]})||{_,_,IpAddr,Port,_}<-?NODES]).
eunit_stop()->
    [stop_service(lib_service),
     stop_service(iaas_service),
     timer:sleep(1000),
     init:stop()].

%% --------------------------------------------------------------------
%% Function:support functions
%% Description: Stop eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

start_service(Service)->
    ?assertEqual(ok,application:start(Service)).
check_started_service(Service)->
    ?assertMatch({pong,_,Service},Service:ping()).
stop_service(Service)->
    ?assertEqual(ok,application:stop(Service)),
    ?assertEqual(ok,application:unload(Service)).

