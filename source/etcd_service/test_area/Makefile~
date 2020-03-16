all:
	rm -rf ebin/* src/*~;
	erlc -o ebin src/*.erl;
	cp src/*.app ebin;
	erl -pa ebin -s node_controller_service start -sname node_controller_service

test:
	rm -rf ../ebin/* ../src/*~ ../test_ebin/* ../test_src/*~ ../test_src/lib_service* ../test_src/container*;
	cp -r /home/pi/erlang/simple_d/source/lib_service/src/* ../test_src;
	cp ../test_src/*.app ../test_ebin;
	cp ../src/*.app ../ebin;
	erlc -D local -I /home/pi/erlang/simple_d/source/include -I ../test_src -o ../test_ebin ../test_src/*.erl;
	erlc -D local -I /home/pi/erlang/simple_d/source/include -I ../src -o ../ebin ../src/*.erl;
	erl -pa ../ebin -pa ../test_ebin -s master_service_tests start -sname master_service_test
