cd ..
valgrind --leak-check=full ./main generate 10 10 0.6 1 m sparse true 2>> log.txt 
valgrind --leak-check=full ./main generate 10 10 1 3 m1 sparse false 2>> log.txt 
valgrind --leak-check=full ./main edit m1.smtr 3 3 0 2>> log.txt 
valgrind --leak-check=full ./main edit m1.smtr 3 4 1 2>> log.txt 
valgrind --leak-check=full ./main edit m1.smtr 4 3 1 2>> log.txt 
valgrind --leak-check=full ./main print m1.smtr 2 2>> log.txt 
valgrind --leak-check=full ./main multiply 0 dence res m.smtr m.smtr m.smtr m1.smtr 2>> log.txt 
valgrind --leak-check=full ./main index res res 2>> log.txt 
valgrind --leak-check=full ./main index m m 2>> log.txt 
