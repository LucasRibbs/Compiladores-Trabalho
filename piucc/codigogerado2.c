#include <stdio.h>

int main(void) {

int x;
int y;
scanf("%d", &x);
y = (1 + (2 * (x + 4)));
if(!(y > 100)) goto L000;
printf("Maior que 100\n");
goto L001;
L000:
printf("Menor ou igual a 100\n");
L001:;
printf("Resultado: ");
printf("%.2f\n", (float)y);

return 0;

}
