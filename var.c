#include <stdio.h>
#include <stdint.h>
#include "symtab.h"
#include "var.h"

static struct symtab *vars = NULL;

int var_get(const char *name)
{
    uintptr_t tmp;
    if (vars == NULL)
        vars = symtab_new();

	if (!symtab_get(vars, name, &tmp)) {
		fprintf(stderr, "%s undefined!\n", name);
		return 0;
	}
    return (int)tmp;
}
void var_put(const char *name, int value){    uintptr_t tmp = (uintptr_t)value;
    if (vars == NULL)
        vars = symtab_new();

    symtab_put(vars, name, tmp);}
