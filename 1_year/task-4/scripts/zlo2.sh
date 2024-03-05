cd ..
./main generate 12 14 0.85 2 k1 sparse true
./main generate 14 5 0.7 1 k2 dence false
./main generate 5 18 0.6 2 k3 sparse false
./main multiply 0 sparse k4 k1.smtr k2.dmtr k3.smtr
