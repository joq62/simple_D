%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(app_test_cases). 
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").
-include("common_macros.hrl").
-include("master_service_tests.hrl").
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
 %   cleanup(),
    lib_app:create_dets(),
    ?assertEqual(ok,app_info_test()),
 %  ?assertEqual(ok,read_info_test()),
    

  %  cleanup(),
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
read_info_test()->
    ?assertEqual({dir,"/home/pi/erlang/simple_d/source"},etcd:app_info_item("adder_service",source)),
    ?assertEqual({error,[undef,glurk]},etcd:app_info_item("adder_service",glurk)),
    ?assertEqual({error,[undef,"no_service"]},etcd:app_info_item("no_service",source)),
    ?assertEqual("localhost",etcd:node_info_item("pod_lgh_1",ip_addr)),
    ?assertEqual({error,[undef,glurk_item]},etcd:node_info_item("pod_lgh_1",glurk_item)),
    ?assertEqual({error,[undef,"pod_glurk"]},etcd:node_info_item("pod_glurk",ip_addr)),
    
    ok.



%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
app_info_test()->
    {ok,Files}=file:list_dir("appfiles"),
    AppInfo=[file:consult(filename:join("appfiles",File))||File<-Files,filename:extension(File)=:=".spec"],

 %   AppInfoList=[etcd:set_app_info(ServiceId,Num,Nodes,Source,not_loaded)||{ok,[{service,ServiceId},
%									     {num_instances,Num},
%									     {nodes,Nodes},
%									     {source,Source}
%									    ]
%									}<-AppInfo],
 %    ?assertEqual(glurk,AppInfoList),
    [master_service:update_app_info(ServiceId,Num,Nodes,Source,not_loaded)||{ok,
							       [{service,ServiceId},
								{num_instances,Num},
								{nodes,Nodes},
								{source,Source}
							       ]
							      }<-AppInfo],
    AppInfoList=master_service:read_app_info(all),
  %  ?assertEqual(glurk,AppInfoList),
    [I]= [X||X<-AppInfoList,X#app_info.service=:="adder_service"],
    ?assertEqual({app_info,"adder_service",2,
		   [{"pod_landet_1","localhost",50100},
		    {"pod_lgh_1","localhost",40100}],
		   {dir,"/home/pi/erlang/simple_d/source"},
		   not_loaded},I),
  %  ok=etcd:update_app_info(I#app_info.service,3,I#app_info.nodes,I#app_info.source,loaded),
    ok=master_service:update_app_info(I#app_info.service,I#app_info.num,I#app_info.nodes,I#app_info.source,running),
    
  %  AppInfoList1=master_service:read_app_info(all),
   % [I1]= [X1||X1<-AppInfoList1,X1#app_info.service=:="adder_service"],
   % ?assertEqual({app_info,"adder_service",2,
%		   [{"pod_landet_1","localhost",50100},
%		    {"pod_lgh_1","localhost",40100}],
%		   {dir,"/home/pi/erlang/simple_d/source"},
%		   running},I1),

    ?assertEqual([{app_info,"adder_service",2,
		   [{"pod_landet_1","localhost",50100},
		    {"pod_lgh_1","localhost",40100}],
		   {dir,"/home/pi/erlang/simple_d/source"},
		   running}],[X||X<-master_service:read_app_info(all),X#app_info.service=:="adder_service"]),

    ok=master_service:update_app_info("service_2",I#app_info.num,I#app_info.nodes,I#app_info.source,glurk),
    ?assertEqual([{app_info,"service_2",2,
		   [{"pod_landet_1","localhost",50100},
		    {"pod_lgh_1","localhost",40100}],
		   {dir,"/home/pi/erlang/simple_d/source"},
		   glurk},
		  {app_info,"adder_service",2,
		   [{"pod_landet_1","localhost",50100},
		    {"pod_lgh_1","localhost",40100}],
		   {dir,"/home/pi/erlang/simple_d/source"},
		   running}],master_service:read_app_info(all)),

    ?assertEqual([{app_info,"service_2",2,
		   [{"pod_landet_1","localhost",50100},
		    {"pod_lgh_1","localhost",40100}],
		   {dir,"/home/pi/erlang/simple_d/source"},
		   glurk}],master_service:read_app_info("service_2")),

    []=master_service:read_app_info("glurk_2"),

    master_service:delete_app_info("service_2"),
    ?assertMatch([{app_info,"adder_service",2,
		   [{"pod_landet_1","localhost",50100},
		    {"pod_lgh_1","localhost",40100}],
		   {dir,"/home/pi/erlang/simple_d/source"},
		   running}],master_service:read_app_info(all)),
    ok.



%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
