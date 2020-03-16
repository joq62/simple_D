%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%%
%%% Created : 10 dec 2012 
%%% -------------------------------------------------------------------
-module(lib_etcd). 
  
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("common_macros.hrl").
%% --------------------------------------------------------------------
%% Data Type
%% --------------------------------------------------------------------
-define(ETS_NODE_INFO,node_info).
-define(ETS_APP_INFO,app_info).
%-define(STATUS_INFO_FILE,status_info).

-define(ETS_NODE_ARGS,[public,bag,named_table]).
-define(ETS_APP_ARGS,[public,bag,named_table]).
%-define(STATUS_DETS,?STATUS_INFO_FILE,[{type,set}).

%%-- glurk tas bort 
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
    ets:new(?ETS_NODE_INFO,?ETS_NODE_ARGS),
    ok.
    


read_app_info(all)->
    {ok,[{app_info,Info}]}=etcd:read(?APP_INFO_FILE,app_info),
    Info.
%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
update_app_list(ServiceId,IpAddr,Port,Source,Status)->
    etcd:update(?APP_INFO_FILE,{app_list,ServiceId,IpAddr,Port},[Source,Status]).

delete_app_list(ServiceId,IpAddr,Port,Source,Status)->
    etcd:delete(app_list,ServiceId,IpAddr,Port).

read_app_list(all)->
    ok.
    



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
set_node_info(VmName,Vm,IpAddr,Port,Mode,Status)->
    {VmName,#node_info{vm_name=VmName,vm=Vm,ip_addr=IpAddr,port=Port,mode=Mode,status=Status}}.
set_node_info(IpAddr,Port,Mode,Status)->  
    Vm=tcp_client:call({IpAddr,Port},{erlang,node,[]}),
    %% Vm='VmName@Host'
    VmStr=atom_to_list(Vm),
    [VmName,_Host]=string:tokens(VmStr,"@"),
    {VmName,#node_info{vm_name=VmName,vm=Vm,ip_addr=IpAddr,port=Port,mode=Mode,status=Status}}.



read_node_info(all)->
    ets:tab2list(?ETS_NODE_INFO);

read_node_info(VmName)->
 %  Result=case ets:match(?ETS_NODE_INFO,{{node_info,vm_name,vm,ipaddr,port},'$3'}) of
    Result=case ets:match(?ETS_NODE_INFO,{{node_info,VmName,'$2','$3'},'$4'}) of
	      []->
		  glurk;
	      Info ->
		  % [{_,NodeInfo}]=Info,
		  % NodeInfo
		   Info
		   
	   end,
    Result.
read_node_info(IpAddr,Port)->
    Result=case ets:match(?ETS_NODE_INFO,{{node_info,'$1',IpAddr,Port},'$2'}) of
	      []->
		  [];
	      Info ->
		   [{_,NodeInfo}]=Info,
		   NodeInfo
	   end,
    Result.
  
    
update_node_info(IpAddr,Port,Mode,Status)->
    {_,I}=set_node_info(IpAddr,Port,Mode,Status),
    update_node_info(I#node_info.vm_name,I#node_info.vm,I#node_info.ip_addr,I#node_info.port,
		     I#node_info.mode,I#node_info.status).

update_node_info(VmName,Vm,IpAddr,Port,Mode,Status)->
    NewNodeInfo=#node_info{vm_name=VmName,vm=Vm,ip_addr=IpAddr,port=Port,mode=Mode,status=Status},
    ets:insert(?ETS_NODE_INFO,{{node_info,VmName,Vm,IpAddr,Port},NewNodeInfo}).
    


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
delete(File,Key)->
    case filelib:is_file(File) of 
	true->
	    {ok,Descriptor}=dets:open_file(File),
	    case dets:lookup(Descriptor, Key) of
		[]->
		    Reply = {error,no_entry};
		X->
		    Reply=dets:delete(Descriptor, Key)
	    end,
	    dets:close(Descriptor);
	false->
	    Reply = {error,no_file}
    end.


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
