%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%%
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(etcd). 
  
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("common_macros.hrl").
%% --------------------------------------------------------------------
%% Data Type
%% --------------------------------------------------------------------
-define(NODE_INFO_FILE,"node_info.dets").
-define(APP_INFO_FILE,"app_info.dets").
-define(STATUS_INFO_FILE,"status_info.dets").

-define(NODE_DETS,?NODE_INFO_FILE,[{type,set}]).
-define(APP_DETS,?APP_INFO_FILE,[{type,set}]).
-define(STATUS_DETS,?STATUS_INFO_FILE,[{type,set}).


%% --------------------------------------------------------------------

%% External exports

%-export([create/2,delete/2]).

-compile(export_all).

%% ====================================================================
%% External functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Function:init 
%% Description: creates key schemes
%% "node_info.dets": desired nodes
%% "application_info.dets": desired applications
%% "status.dets": status vs desired state and changes 
%% Returns: non
%% open_file(Name, Args) -> {ok, Name} | {error, Reason}
%% Args = [OpenArg]
%% type() = bag | duplicate_bag | set
%%  
%%
%% --------------------------------------------------------------------
init()->
    
    ok.
    


read_app_info(all)->
    {ok,[{app_info,Info}]}=etcd:read(?APP_INFO_FILE,app_info),
    Info.
%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% 1) Update the record 
%% 2) Update the list 
%% 3) update dets table
%% --------------------------------------------------------------------
create_app_dets()->
    create_file(?APP_DETS),
    ok.

delete_app_dets()->
    delete_file(?APP_INFO_FILE),
    ok.
%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
update_app_info(ServiceId,Num,Nodes,Source,Status)->
    {NewServiceId,NewAppInfo}=set_app_info(ServiceId,Num,Nodes,Source,Status),
    UpdatedList=case etcd:read(?APP_INFO_FILE,app_info) of
		    {ok,[]}->
		       %NoEntries 
			[{"pod_landet_1",
			  {node_info,
			   "pod_landet_1",pod_landet_1@asus,"localhost",50100,
			   parallell,no_status_info}
			 }
			],[{NewServiceId,NewServiceId}],
			[{NewServiceId,NewAppInfo}];
		    {ok,[{app_info,AppInfoList}]}->
			case lists:keymember(NewServiceId,1,AppInfoList) of
			    false->
				[{NewServiceId,NewAppInfo}|AppInfoList];
			    true->
				lists:keyreplace(NewServiceId,1,AppInfoList,{NewServiceId,NewAppInfo})
			end
		end,
    ok=etcd:update(?APP_INFO_FILE,app_info,UpdatedList),
    ok.

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
app_info_item(Key,Item)->
    {ok,[{app_info,AppInfo}]}=etcd:read(?APP_INFO_FILE,app_info),
    case proplists:get_value(Key,AppInfo) of
	undefined->
	    {error,[undef, Key]};
	I->
	    case Item of
		service->
		    I#app_info.service;
		num ->
		    I#app_info.num;
		nodes ->
		    I#app_info.nodes;
		source ->
		    I#app_info.source;
		status ->
		    I#app_info.status;
		_->
		    {error,[undef, Item]}
	    end
    end.

set_app_info(ServiceId,Num,Nodes,Source,Status)->
    {ServiceId,#app_info{service=ServiceId,num=Num,nodes=Nodes,source=Source,status=Status}}.

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% 1) Update the record 
%% 2) Update the list 
%% 3) update dets table
%% --------------------------------------------------------------------
create_node_dets()->
    create_file(?NODE_DETS),
    ok.

delete_node_dets()->
    delete_file(?NODE_INFO_FILE),
    ok.


read_node_info(all)->
    {ok,[{node_info,Info}]}=etcd:read(?NODE_INFO_FILE,node_info),
    Info.

update_node_info(IpAddr,Port,Mode,Status)->
  %  {ok,[{node_info,NodeInfo}]}=etcd:read(?NODE_INFO_FILE,node_info)
    {NewVmName,NewNodeInfo}=set_node_info(IpAddr,Port,Mode,Status),
    UpdatedList=case etcd:read(?NODE_INFO_FILE,node_info) of
		    {ok,[]}->
		       %NoEntries 
			[{"pod_landet_1",
			  {node_info,
			   "pod_landet_1",pod_landet_1@asus,"localhost",50100,
			   parallell,no_status_info}
			 }
			],[{NewVmName,NewNodeInfo}],
			[{NewVmName,NewNodeInfo}];
		    {ok,[{node_info,NodeInfoList}]}->
			case lists:keymember(NewVmName,1,NodeInfoList) of
			    false->
				[{NewVmName,NewNodeInfo}|NodeInfoList];
			    true->
				lists:keyreplace(NewVmName,1,NodeInfoList,{NewVmName,NewNodeInfo})
			end
		end,
    ok=etcd:update(?NODE_INFO_FILE,node_info,UpdatedList),
    ok.


%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
%item_node_info(Item)->
 %   {ok,[{node_info,ComputerInfo}]}=etcd:read(?NODE_INFO_FILE,node_info),
  %  case Item of

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
node_info_item(Key,Item)->
    {ok,[{node_info,NodeInfo}]}=etcd:read(?NODE_INFO_FILE,node_info),
    case proplists:get_value(Key,NodeInfo) of
	undefined->
	    {error,[undef, Key]};
	I->
	    case Item of
		vm_name->
		    I#node_info.vm_name;
		vm ->
		    I#node_info.vm;
		ip_addr ->
		    I#node_info.ip_addr;
		port ->
		    I#node_info.port;
		mode->
		    I#node_info.mode;
		status ->
		    I#node_info.status;
		_->
		    {error,[undef, Item]}
	    end
    end.

set_node_info(IpAddr,Port,Mode,Status)->  
    Vm=tcp_client:call({IpAddr,Port},{erlang,node,[]}),
    %% Vm='VmName@Host'
    VmStr=atom_to_list(Vm),
    [VmName,_Host]=string:tokens(VmStr,"@"),
    {VmName,#node_info{vm_name=VmName,vm=Vm,ip_addr=IpAddr,port=Port,mode=Mode,status=Status}}.

%% --------------------------------------------------------------------
%% Function:init 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
create_file(File,Args)->
    case filelib:is_file(File) of 
	true->
	    {ok,file_already_exsist};
	false->
	    {ok,Descriptor}=dets:open_file(File,Args),
	    dets:close(Descriptor),
	    {ok,Descriptor}
    end.


delete_file(File)->
    case filelib:is_file(File) of 
	true->
	    file:delete(File),
	    {ok,file_deleted};
	false->
	    {ok,file_not_exist}
    end.

exists_file(File)->
    filelib:is_file(File).

%% --------------------------------------------------------------------
%% Function:init 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------

update(File,Key,Value)->
    case filelib:is_file(File) of 
	true->
	    {ok,Descriptor}=dets:open_file(File),
	    ok=dets:insert(Descriptor, {Key,Value}),
	    dets:close(Descriptor),
	    ok;
	false->
	    {error,[eexits,File]}
    end.

read(File,Key)->
    case filelib:is_file(File) of 
	true->
	    {ok,Descriptor}=dets:open_file(File),
	    Value=dets:lookup(Descriptor, Key),
	    dets:close(Descriptor),
	    {ok,Value};
	false->
	    {error,[eexits,File]}
    end.



all(File)->
    case filelib:is_file(File) of 
	true->
	    {ok,Descriptor}=dets:open_file(File),
	    Key=dets:first(Descriptor),
	    Reply=get_all(Descriptor,Key,[]),
	    dets:close(Descriptor),
	    Reply;
	false->
	    {error,[eexits,File]}
    end.


get_all(_Desc,'$end_of_table',Acc)->
    {ok,Acc};
get_all(Desc,Key,Acc)->  
    Status=dets:lookup(Desc, Key),
    Acc1=lists:append(Status,Acc),
    Key1=dets:next(Desc,Key),
    get_all(Desc,Key1,Acc1).
