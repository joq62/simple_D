all:
	rm -rf ebin/* src/*~;
	erlc -o ebin src/*.erl;
	cp src/*.app ebin;
	erl -pa ebin -s node_controller_service start -sname node_controller_service

test:
	rm -rf dns_service log_service lib_service ../ebin/* ../src/*~ test_ebin/* ../test_src/*~ ../test_src/lib_service* ../test_src/container*;
	cp ../src/*.app ebin;
	cp -r /home/pi/erlang/simple_d/source/lib_service .;
	cp /home/pi/erlang/simple_d/source/lib_service/src/*.app ebin;
	erlc -D local -I /home/pi/erlang/simple_d/source/include -o ebin lib_service/src/*.erl;
	cp -r /home/pi/erlang/simple_d/source/log_service .;
	cp /home/pi/erlang/simple_d/source/log_service/src/*.app ebin;
	erlc -D local -I /home/pi/erlang/simple_d/source/include -o ebin log_service/src/*.erl;
	erlc -D local -I /home/pi/erlang/simple_d/source/include -o test_ebin ../test_src/*.erl;
	erlc -D local -I /home/pi/erlang/simple_d/source/include -o ebin ../src/*.erl;
	erl -pa ebin -pa test_ebin -s master_service_tests start -sname pod_master
