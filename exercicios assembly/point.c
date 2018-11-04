#include <stdio.h>
#include <stdio.h>

void TESTANDO(int *a){
	*a = 4;
}
void ALOALO(){
	char nulo = '\0';
}
int main(int argc, char const *argv[])
{
	int b = 0;
	TESTANDO(&b);
	return b;
}