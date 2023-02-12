default:
	yacc -d piucc.y
	lex piucc.l
	gcc y.tab.c lex.yy.c -o piucc

compile:
	./piucc <exemplo1.piu >codigogerado1.c
	./piucc <exemplo2.piu >codigogerado2.c

exec1:
	gcc codigogerado1.c -o a.out
	./a.out

exec2:
	gcc codigogerado2.c -o a.out
	./a.out

clean:
	rm y.tab.h y.tab.c lex.yy.c piucc a.out

compile1:
	./piucc <exemplo1.piu >codigogerado1.c

compile2:
	./piucc <exemplo2.piu >codigogerado2.c
