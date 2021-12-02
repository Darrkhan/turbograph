all:
	rm -f calculette.exe scanner.cpp parser.cpp parser.h
	bison -d parser.y -o parser.cpp
	flex -o scanner.cpp scanner.l
	g++ -w scanner.cpp parser.cpp -o calculette
	./calculette test.txt