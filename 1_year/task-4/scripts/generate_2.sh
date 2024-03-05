cd ..
./main generate 10 10 0.9 2 mat sparse true
./main index mat.smtr mat
./main print mat.smtr 2
