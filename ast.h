#ifndef AST_H
#define AST_H

#include <assert.h>

/**
   An enum to identify the type of a semantic value
 */
enum ast_sval_type {
	SVAL_VOID,
	SVAL_INT,
	SVAL_FLOAT,
	SVAL_STR,
	SVAL_POINTER,
};

/**
   The structure representing a node of the Abstract Syntax Tree
 */
struct ast_node {
	/* the token labeling the node */
	int token;
	/* the token in a printable form */
	const char *printable_token;
	/* the type of the semantic value */
	enum ast_sval_type sval_type;
	/* an union storing the different possible semantic value types */
	union {
		int i_val;      /* semantic value is an int */
		float f_val;    /* semantic value is a float */
		char *s_val;    /* semantic value is a string */
		void *p_val;    /* semantic value is a generic pointer */
	} usval;
	/* the node can have up to 3 descendants */
	struct ast_node *left, *middle, *right;
};

/**
   ast_node_new allocates and initialize an internal node

   NOTE: this function sets the semantic value to void. In general, an internal
   node does not have an associated semantic value. If necessary, semantic value
   can be filled after calling the function.

   Parameters:
   token     the token labeling the node
   left      pointer to left descendant
   middle    pointer to middle descendant
   right     pointer to right descendant

   Returns: the new node
 */
#define ast_node_new(token, left, middle, right) _ast_node_new(token, #token, left, middle, right)

/**
   ast_node_set_void set the semantic value of the node to void (no value)

   Parameters:
   N    the node
 */
#define ast_node_set_void(N) ((N)->sval_type = SVAL_VOID)

/**
   ast_node_set_int set the semantic value of the node to an int

   Parameters:
   N    the node
   I    the int value
 */
#define ast_node_set_int(N, I) ((N)->sval_type = SVAL_INT, (N)->usval.i_val = (I))

/**
   ast_node_get_int returns the semantic value of a node containing an int

   Parameters:
   N    the node

   Returns: the int semantic value
 */
#define ast_node_get_int(N) (assert((N)->sval_type == SVAL_INT), (N)->usval.i_val)

/**
   ast_node_set_float set the semantic value of the node to a float

   Parameters:
   N    the node
   F    the float value
 */
#define ast_node_set_float(N, F) ((N)->sval_type = SVAL_FLOAT, (N)->usval.f_val = (F))

/**
   ast_node_get_float returns the semantic value of a node containing a float

   Parameters:
   N    the node

   Returns: the float semantic value
 */
#define ast_node_get_float(N) (assert((N)->sval_type == SVAL_FLOAT), (N)->usval.f_val)

/**
   ast_node_set_str set the semantic value of the node to a string

   Parameters:
   N    the node
   S    the string value
 */
#define ast_node_set_str(N, S) ((N)->sval_type = SVAL_STR, (N)->usval.s_val = (S))

/**
   ast_node_get_str returns the semantic value of a node containing a string

   Parameters:
   N    the node

   Returns: the char * semantic value
 */
#define ast_node_get_str(N) (assert((N)->sval_type == SVAL_STR), (N)->usval.s_val)

/**
   ast_node_set_pointer set the semantic value of the node to a pointer

   Parameters:
   N    the node
   P    the pointer value
 */
#define ast_node_set_pointer(N, P) ((N)->sval_type = SVAL_POINTER, (N)->usval.p_val = (P))

/**
   ast_node_get_pointer returns the semantic value of a node containing a pointer

   Parameters:
   N    the node

   Returns: the void * semantic value
 */
#define ast_node_get_pointer(N) (assert((N)->sval_type == SVAL_POINTER), (N)->usval.p_val)

/**
   ast_node_leaf_i allocates and initialize a leaf containing an integer semantic value

   Parameters:
   token     the token labeling the node
   i_val     the semantic value

   Returns: the new node
 */
#define ast_node_leaf_i(token, i_val) _ast_node_leaf_i(token, #token, i_val)

/**
   ast_node_leaf_f allocates and initialize a leaf containing a float semantic value

   Parameters:
   token     the token labeling the node
   f_val     the semantic value

   Returns: the new node
 */
#define ast_node_leaf_f(token, f_val) _ast_node_leaf_f(token, #token, f_val)

/**
   ast_node_leaf_s allocates and initialize a leaf containing a string semantic value

   Parameters:
   token     the token labeling the node
   s_val     the semantic value

   Returns: the new node
 */
#define ast_node_leaf_s(token, s_val) _ast_node_leaf_s(token, #token, s_val)

/**
   ast_node_leaf_p allocates and initialize a leaf containing a pointer semantic value

   Parameters:
   token     the token labeling the node
   p_val     the semantic value

   Returns: the new node
 */
#define ast_node_leaf_p(token, p_val) _ast_node_leaf_p(token, #token, p_val)

void ast_node_print(struct ast_node *node);

/* Deliberately non-documented functions */
struct ast_node *_ast_node_new(int token, const char *printable_token, struct ast_node *left, struct ast_node *middle, struct ast_node *right);
struct ast_node *_ast_node_leaf_i(int token, const char *printable_token, int i_val);
struct ast_node *_ast_node_leaf_f(int token, const char *printable_token, float f_val);
struct ast_node *_ast_node_leaf_s(int token, const char *printable_token, char *s_val);
struct ast_node *_ast_node_leaf_p(int token, const char *printable_token, void *p_val);

#endif
