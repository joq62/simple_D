%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(app1_test).  
   
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
    
    test_adder(),
    
    ok.



%% --------------------------------------------------------------------
%% Function:emulate loader
%% Description: requires pod+container module
%% Returns: non
%% --------------------------------------------------------------------

test_adder()->
    ?assertMatch(glurk,tcp_client:call(?DNS_ADDRESS,{dns_service,get,["_service"]})),
    ?assertEqual(42,tcp_client:call("adder_service",adder_service,add,[20,22],3,200)),

    ok.
    
