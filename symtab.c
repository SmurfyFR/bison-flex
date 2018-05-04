#include <stdlib.h>
#include <string.h>
#include "symtab.h"

struct entry {
	const char *key;
	uintptr_t value;
	struct entry *next;
};

struct symtab {
	struct entry *syms;
};

struct symtab *symtab_new(void)
{
	struct symtab *st = malloc(sizeof(struct symtab));

	st->syms = NULL;

	return st;
}

int symtab_get(struct symtab *st, const char *key, uintptr_t *pvalue)
{
	struct entry *e;

	for (e = st->syms; e != NULL; e = e->next) {
		if (!strcmp(e->key, key)) {
			*pvalue = e->value;
			return 1;
		}
	}

	return 0;
}

int symtab_put(struct symtab *st, const char *key, uintptr_t value)
{
	struct entry *e;

	for (e = st->syms; e; e = e->next)
		if (!strcmp(e->key, key)) {
			e->value = value;
			return 1;
		}

	e = malloc(sizeof(struct entry));
	e->key = key;
	e->value = value;
	e->next = st->syms;

	st->syms = e;

	return 0;
}
