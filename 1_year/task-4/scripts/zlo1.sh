cd ..
valgrind  ./main generate 10 10 0.6 1 m  sparse true 2>> log.txt
valgrind  ./main generate 10 10 1   3 m1 sparse false 2>> log.txt
valgrind  ./main edit m.smtr 3 3 0 2>> log.txt
valgrind  ./main edit m.smtr 3 4 1 2>> log.txt
valgrind  ./main edit m.smtr 4 3 1 2>> log.txt
valgrind  ./main multiply 0 dence res m.smtr m.smtr m.smtr m1.smtr 2>> log.txt
valgrind  ./main index res.dmtr res 2>> log.txt
valgrind  ./main index m1.smtr 2>> log.txt
valgrind  ./main print res.dmtr 2 2>> log.txt
