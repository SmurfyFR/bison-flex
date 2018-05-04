#ifndef SYMTAB_H
#define SYMTAB_H

#include <stdint.h>

struct symtab;

/**
   symtab_new allocates and initializes a symbol table

   Returns: the new symbol table
 */
struct symtab *symtab_new(void);

/**
   symtab_get retrieves the value associated with a key

   Parameters:
   key  const char *  a C string containing the key
   pvalue uintptr *   a pointer to the retrieved value

   Returns:
   0 if key does not exists in symbol table,
   1 if key exists, and in this case associated value is stored in *pvalue
 */
int symtab_get(struct symtab *st, const char *key, uintptr_t *pvalue);

/**
   symtab_put inserts or modifies a value associated with a key

   Parameters:
   key  const char *  a C string containing the key
   value uintptr      the new value

   Returns:
   0 if key did not exist in symbol table,
   1 if key existed in symbol table
 */
int symtab_put(struct symtab *st, const char *key, uintptr_t value);

#endif
