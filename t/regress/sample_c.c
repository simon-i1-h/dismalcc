#include <stdio.h>

int
main(int argc, char **argv)
{
	(void)argv;
	int n = 1;

	for (int i = 0; i < argc; i++)
		if (i < 3)
			n *= 2;
		else
			n += 1;

	printf("result: %d\n", n);

	return 0;
}
