%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(boot_service_test_cases). 
   
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

% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
sim_makefile()->
    % copy or clone services and compile them
    % clone lib_service
    % erlc lib_service
    % clone boot_service alredy done 
    ?assertEqual(ok,container:create(node(),".",
		     [{{service,"lib_service"},
		       {dir,"/home/pi/erlang/simple_d/source"}}
		     ])),
    ?assertEqual(ok,application:start(boot_service)),
    ?assertMatch({pong,_,boot_service},tcp_client:call({"localhost",40100},{boot_service,ping,[]})).

% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
create_config_file()->
    Info=[{vm_name,"pod_computer_1"},
	  {vm,'pod_computer_1@asus'},
	  {ip_addr,"localhost"},
	  {port,40100},
	  {mode,parallell},
	  {worker_start_port,40101},
	  {num_workers,5},
	  {source,{dir,"/home/pi/erlang/d/source"}},
%	  {services_to_load,["lib_service","computer_service","log_service","local_dns_service"]},
	  {services_to_load,["lib_service","adder_service"]},
	  {files_to_keep,[".git","Makefile","computer.config","boot_service","include","lib_service","ebin","test_ebin"]},
	  {master_dns,{"localhost",portGlurk}}],
    misc_lib:unconsult("computer.config",Info),
    ?assertEqual({ok,Info},file:consult("computer.config")).
    
% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
scratch_computer()->
    {ok,Info}=file:consult("computer_1.config"),
    {files_to_keep,FilesToKeep}=lists:keyfind(files_to_keep,1,Info),
 %   ?assertEqual(glurk,FilesToKeep).
    boot_service:scratch_computer(FilesToKeep).

% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
start_computer_pod()->
    {ok,Info}=file:consult("computer_1.config"),
    {vm_name,VmName}=lists:keyfind(vm_name,1,Info),
    {ok,Vm}=pod:create(node(),VmName),
    ?assertEqual(pong,net_adm:ping(Vm)),
    % Need to copy config file for the computerPod or ?
    {ok,_}=file:copy("computer_1.config",filename:join([VmName,"computer_1.config"])),
     ?assertEqual({ok,Info},file:consult(filename:join([VmName,"computer_1.config"]))).
 %   ?assertEqual({ok,glurk},rpc:call(Vm,file,get_cwd,[])).
% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

load_mandatory_services()->
    {ok,Info}=file:consult("computer_1.config"),
    {vm_name,VmName}=lists:keyfind(vm_name,1,Info),
    {vm,Vm}=lists:keyfind(vm,1,Info),
    {source,Source}=lists:keyfind(source,1,Info),
    {services_to_load,ServicesToLoad}=lists:keyfind(services_to_load,1,Info),
    [container:create(Vm,VmName,[{{service,ServiceStr},Source}])||ServiceStr<-ServicesToLoad],
   
    R1=[rpc:call(Vm,list_to_atom(ServiceStr),ping,[])||ServiceStr<-ServicesToLoad],
    ?assertEqual([],[X||{X,_,_}<-R1,X=/=pong]). 
%    ?assertEqual([],[{X,A,B}||{X,A,B}<-R1,X=:=pong]). 
    
% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
