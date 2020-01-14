#include <stdio.h>

int
main(int argc, char **argv)
{
	(void)argv;

	/* label as value */
	void *labels[] = {&&foo, &&bar, &&baz, &&qux, &&quux};
	int n = argc - 1;

	switch (n) {
	/* case range */
	case 0 ... 4:
		/* computed goto */
		goto *labels[n];
	default:
		goto out;
	}

foo:
	printf("foo\n");
	goto out;
bar:
	printf("bar\n");
	goto out;
baz:
	printf("baz\n");
	goto out;
qux:
	printf("qux\n");
	goto out;
quux:
	printf("quux\n");
	goto out;

out:
	return 0;
}
