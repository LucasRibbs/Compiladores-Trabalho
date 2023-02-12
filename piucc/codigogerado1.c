#include <stdio.h>

int main(void) {

int x;
x = (((2 * 3) + 1) + (5 / -2));
x = -(x + 2);
scanf("%d", &x);
printf("%.2f\n", (float)x);
float y;
y = 0.500000;
scanf("%f", &y);
printf("%.2f\n", (float)y);
if(!(x >= 0)) goto L000;
printf("%.2f\n", (float)999);
if(!(x == 0)) goto L001;
printf("%.2f\n", (float)888);
L001:;
goto L002;
L000:
printf("%.2f\n", (float)777);
L002:;
if(!(x >= 0)) goto L003;
printf("%.2f\n", (float)999);
L003:;
if(!(x == 0)) goto L004;
printf("%.2f\n", (float)888);
goto L005;
L004:
printf("%.2f\n", (float)777);
L005:;
x = 10;
L006:
if(!(x > 0)) goto L007;
printf("%.2f\n", (float)x);
x = ((x - 1) - 1);
goto L006;
L007:;
printf("%.2f\n", (float)((x + (y * y)) + y));

return 0;

}
