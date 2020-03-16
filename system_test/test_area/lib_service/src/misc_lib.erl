%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%%
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(misc_lib).
  


%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("common_macros.hrl").
%% --------------------------------------------------------------------

%% External exports
%-export([unconsult/2,
%	 get_node_by_id/1,get_vm_id/0,get_vm_id/1,
%	 app_start/1
%	]).
	 
-compile(export_all).


%% ====================================================================
%% External functions
%% ====================================================================

call(ServiceId,M,F,A,NumTries,Delay)->
    call(ServiceId,M,F,A,NumTries,Delay,error).

call(ServiceId,M,F,A,0,Delay,Result)->
    {error,[exhausted_num_tries,Result,?MODULE,?LINE]};

call(ServiceId,M,F,A,NumTries,Delay,Result)->
    IpAddrList=tcp_client:call(?DNS_ADDRESS,{dns_service,get,[ServiceId]}),
    call(IpAddrList,ServiceId,M,F,A,NumTries,Delay,Result).

call([],ServiceId,M,F,A,NumTries,Delay,Result)->
    timer:sleep(Delay),
    IpAddrList=tcp_client:call(?DNS_ADDRESS,{dns_service,get,[ServiceId]}),
    call(IpAddrList,ServiceId,M,F,A,NumTries-1,Delay,error);

call([{IpAddr,Port,_Node}|T],ServiceId,M,F,A,NumTries,Delay,Result)->
    case tcp_client:call({IpAddr,Port},{M,F,A}) of
	{error,_}->
	    timer:sleep(Delay),
	    call(T,ServiceId,M,F,A,NumTries-1,Delay,error);
	{badrpc,_}->
	    timer:sleep(Delay),
	    call(T,ServiceId,M,F,A,NumTries-1,Delay,error);
	Result->
	    Result 
    end.
%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
log_event(Module,Line,Severity,Info)->
    SysLog=#syslog_info{date=date(),
			time=time(),
			ip_addr=na,
			port=na,
			pod=node(),
			module=Module,
			line=Line,
			severity=Severity,
			message=Info
		       },
    tcp_client:call("log_service",log_service,store,[SysLog],5,500).

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------

unconsult(File, L) ->
    {ok, S} = file:open(File, write),
    lists:foreach(fun(X) -> io:format(S, "~p.~n",[X]) end, L),
    file:close(S).

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
get_node_by_id(Id)->
    {ok,Host}=inet:gethostname(),
    list_to_atom(Id++"@"++Host).

get_vm_id()->
    get_vm_id(node()).
get_vm_id(Node)->
    % "NodeId@Host
    [NodeId,Host]=string:split(atom_to_list(Node),"@"), 
    {NodeId,Host}.
    
    
%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
app_start(Module)->
    Result=case rpc:call(node(),lib_service,dns_address,[],5000) of
	      {error,Err}->
		   {error,[eexists,dns_address,Err,?MODULE,?LINE]};
	      {DnsIpAddr,DnsPort}->
		   {MyIpAddr,MyPort}=lib_service:myip(),
		   {ok,Socket}=tcp_client:connect(DnsIpAddr,DnsPort),
		   ok=rpc:call(node(),tcp_client,cast,[Socket,{dns_service,add,[atom_to_list(Module),MyIpAddr,MyPort,node()]}]),
		   {ok,[{MyIpAddr,MyPort},{DnsIpAddr,DnsPort},Socket]};
	       Err ->
		   {error,[unmatched,Err,?MODULE,?LINE]}
	  end,   
    Result.
    
