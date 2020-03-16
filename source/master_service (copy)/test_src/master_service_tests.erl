%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : 
%%% Three computers 
%%% {"pod_computer_1", "localhost",40100,parallell, 40101, 10}
%%% {"pod_computer_2", "localhost" 40200,parallell, 40201, 10}
%%% {"pod_computer_3", "localhost" 40300,parallell, 40301,10}
%%% Each pod has its port number as vm name pod_40101@asus
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(master_service_tests). 
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").
-include("common_macros.hrl").
-include("master_service_tests.hrl").
%% --------------------------------------------------------------------

%% External exports
%-export([start/0]).
-compile(export_all).


%% ====================================================================
%% External functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
cases_test()->
    [ets_start(),
     clean_start(),
     eunit_start(),
     % Add funtional test cases 
     master_service_test_cases:start_computer_pods(),
     etcd_test_cases:start(),
     
     master_service_test_cases:start_master_dns_service(),
     node_controller_test_cases:start(),
     app_controller_test_cases:start(),
  %   master_service_test_cases:
  %   master_service_test_cases:
   %  system_test_cases:test_adder_divi(),
     % cleanup and stop eunit 
     stop_computer_pods(),
     clean_stop(),
     eunit_stop()].


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
start()->
    spawn(fun()->eunit:test({timeout,30,master_service}) end).



ets_start()->
    ?ETS=ets:new(?ETS,[public,set,named_table]),
    {ok,Info}=file:consult("node.config"),
    ?assertEqual({computer_list,
		  [{"pod_landet_1","localhost",50100,parallell},
		   {"pod_lgh_1","localhost",40100,parallell},
		   {"pod_lgh_2","localhost",40200,parallell}]},lists:keyfind(computer_list,1,Info)),

    {computer_list,ComputerConfig}=lists:keyfind(computer_list,1,Info),
    ComputerInfoList=[master_service_test_cases:create_vm_info(CInfo)||CInfo<-ComputerConfig],
    ets:insert(?ETS,{computer_list,ComputerInfoList}),
    [ets:insert(?ETS,{Cid,CInfo})||{Cid,CInfo}<-ComputerInfoList],
  
    ComputerVmList=[{CInfo#node_info.vm_name,CInfo#node_info.vm}||{_Cid,CInfo}<-ComputerInfoList],
    ets:insert(?ETS,{computer_vm_list,ComputerVmList}),
    ok. 


clean_start()->
    os:cmd("rm -r  dns_service"),
    [{_,ComputerVmList}]=ets:lookup(?ETS,computer_vm_list),
    [rpc:call(Vm,init,stop,[])||{_,Vm}<-ComputerVmList],
    [pod:delete(node(),VmName)||{VmName,_}<-ComputerVmList],
    etcd:delete_app_dets(),
    etcd:delete_node_dets(),
    ok.
eunit_start()->
    [].

clean_stop()->
   
    ok.

stop_computer_pods()->
    [{_,ComputerVmList}]=ets:lookup(?ETS,computer_vm_list),
    [pod:delete(node(),VmName)||{VmName,_}<-ComputerVmList],
    os:cmd("rm -r  dns_service"),
    etcd:delete_app_dets(),
    etcd:delete_node_dets(),
    ok.

eunit_stop()->
    [
   %  stop_service(lib_service),
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

