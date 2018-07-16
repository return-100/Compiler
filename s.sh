bison -d -y -v 1505100.y
g++ -w -c -o y.o y.tab.c
flex 1505100.l
g++ -w -c -o l.o lex.yy.c
g++ -o a.out y.o l.o -ll -ly
./a.out input.c log.txt error.txt code.asm
