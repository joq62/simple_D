%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(log_service_test_cases). 
   
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

store_all_severity()->
 
    log_service:log_event(module_1,1,error,["test 1",glurk]),
    lib_service:log_event(module_2,2,warning,["test 2",glurk]),
    lib_service:log_event(module_3,3,info,["test 3",glurk]),     
    lib_service:log_event(module_4,4,warning,["test 4",glurk]),


    ?assertMatch([{{2019,10,21},{13,10,0},ipaddr4,port4,pod4,module_4,4,warning,["test 4",glurk]},
     {{2019,10,20},{22,0,0},ipaddr1,port1,pod1,module_3,3,info,["test 3",glurk]},
     {{2019,10,10},{1,32,55},ipaddr2,port2,pod2,module_2,2,warning,["test 2",glurk]},
     {{2019,10,20},{22,0,10},ipaddr1,port1,pod1,module_1,1,error,["test 1",glurk]}],log_service:all()),

    [{{2019,10,20},{22,0,10},ipaddr1,port1,pod1,module_1,1,error,["test 1",glurk]}]=log_service:severity(error),
    []=log_service:severity(glurk),
    ok.

latest_event_node_module()->
  [{{2019,10,21},{13,10,0},ipaddr4,port4,pod4,module_4,4,warning,["test 4",glurk]}
  ]=log_service:latest_event(),
    
    [{{2019,10,21},{13,10,0},ipaddr4,port4,pod4,module_4,4,warning,["test 4",glurk]},
     {{2019,10,20},{22,0,0},ipaddr1,port1,pod1,module_3,3,info,["test 3",glurk]},
     {{2019,10,10},{1,32,55},ipaddr2,port2,pod2,module_2,2,warning,["test 2",glurk]}
    ]=log_service:latest_events(3),

   [{{2019,10,10},{1,32,55},ipaddr2,port2,pod2,module_2,2,warning,["test 2",glurk]}
   ]=log_service:node(ipaddr2,port2,pod2),
    [{{2019,10,20},{22,0,10},ipaddr1,port1,pod1,module_1,1,error,["test 1",glurk]}
    ]=log_service:module(module_1),
    ok.

date_day_month_year()->
    [{{2019,10,20},{22,0,10},ipaddr1,port1,pod1,module_1,1,error,["test 1",glurk]},
     {{2019,10,10},{1,32,55},ipaddr2,port2,pod2,module_2,2,warning,["test 2",glurk]},
     {{2019,10,20},{22,0,0},ipaddr1,port1,pod1,module_3,3,info,["test 3",glurk]},
     {{2019,10,21},{13,10,0},ipaddr4,port4,pod4,module_4,4,warning,["test 4",glurk]}
    ]=log_service:year(2019),

   [{{2019,10,20}, {22,0,10},ipaddr1,port1,pod1,module_1,1,error, ["test 1",glurk]},
    {{2019,10,10},{1,32,55},ipaddr2,port2,pod2,module_2,2,warning, ["test 2",glurk]},
    {{2019,10,20},{22,0,0},ipaddr1,port1,pod1,module_3,3,info,["test 3",glurk]},
    {{2019,10,21},{13,10,0},ipaddr4,port4,pod4,module_4,4,warning,["test 4",glurk]}
   ]=log_service:month(2019,10),
    
    [{{2019,10,20},{22,0,10},ipaddr1,port1,pod1,module_1,1,error,["test 1",glurk]},
     {{2019,10,20},{22,0,0},ipaddr1,port1,pod1,module_3,3,info,["test 3",glurk]}
    ]=log_service:day(2019,10,20),
    [{{2019,10,10},{1,32,55},ipaddr2,port2,pod2,module_2,2,warning,["test 2",glurk]}]=log_service:day(2019,10,10),
    ok.
