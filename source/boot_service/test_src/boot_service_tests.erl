%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(boot_service_tests). 
   
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
cases_test()->
    clean_start(),
    eunit_start(),
     % Add funtional test cases 
    boot_service_test_cases:create_config_file(),
    boot_service_test_cases:sim_makefile(),
  %   boot_service_test_cases:scratch_computer(),
  %   boot_service_test_cases:start_computer_pod(),
 %    boot_service_test_cases:load_mandatory_services(), just load lib_serive and start computer service which will fix the rest
     %_service_test_cases:tcp_service(),
     %lib_service_test_cases:unconsult(),
     % cleanup and stop eunit 
     clean_stop(),
     eunit_stop().


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
start()->
    spawn(fun()->eunit:test({timeout,30,boot_service}) end).



clean_start()->
    os:cmd("rm -r lib_service"),
    file:delete("computer_1.config"),
    pod:delete(node(),"pod_computer_1").


eunit_start()->
    [].



clean_stop()->
    application:stop(boot_service),
   ?assertMatch({badrpc,_},tcp_client:call({"localhost",40100},{boot_service,ping,[]})),
    ?assertEqual([ok],container:delete(node(),".",["lib_service"])),
    pod:delete(node(),"pod_computer_1").

eunit_stop()->
    %stop_service(lib_service),
     timer:sleep(1000),
     init:stop().

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

