gcc -c -Wall -Werror -fPIC simioctl.cpp
gcc -shared -o libsimioctl.so simioctl.o
