%% This is the application resource file (.app file) for the 'base'
%% application.
{application, etcd_service,
[{description, "etcd_service  " },
{vsn, "1.0.0" },
{modules, 
	  [etcd_service_app,etcd_service_sup,etcd_service,etcd]},
{registered,[etcd_service]},
{applications, [kernel,stdlib]},
{mod, {etcd_service_app,[]}},
{start_phases, []}
]}.
