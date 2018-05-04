#include <stdlib.h>
#include <stdio.h>
#include "ast.h"

struct ast_node *_ast_node_new(int token, const char *printable_token, struct ast_node *left, struct ast_node *middle, struct ast_node *right)
{
	struct ast_node *node = calloc(1, sizeof(struct ast_node));

	node->token = token;
	node->printable_token = printable_token;

	ast_node_set_void(node);

	node->left = left;
	node->middle = middle;
	node->right = right;

	return node;
}

struct ast_node *_ast_node_leaf_i(int token, const char *printable_token, int i_val)
{
	struct ast_node *node = _ast_node_new(token, printable_token, NULL, NULL, NULL);

	ast_node_set_int(node, i_val);

	return node;
}

struct ast_node *_ast_node_leaf_f(int token, const char *printable_token, float f_val)
{
	struct ast_node *node = _ast_node_new(token, printable_token, NULL, NULL, NULL);

	ast_node_set_float(node, f_val);

	return node;
}

struct ast_node *_ast_node_leaf_s(int token, const char *printable_token, char *s_val)
{
	struct ast_node *node = _ast_node_new(token, printable_token, NULL, NULL, NULL);

	ast_node_set_str(node, s_val);

	return node;
}

struct ast_node *_ast_node_leaf_p(int token, const char *printable_token, void *p_val)
{
	struct ast_node *node = _ast_node_new(token, printable_token, NULL, NULL, NULL);

	ast_node_set_pointer(node, p_val);

	return node;
}

static void ast_node_print_aux(struct ast_node *node, int depth)
{
	int i;

	if (node == NULL)
		return;

	for (i = 0; i < depth; i++)
		printf("   ");

	printf("-- AST node: token %s - semantic value type ", node->printable_token);
	switch(node->sval_type) {
	case SVAL_VOID:
		printf("void");
		break;
	case SVAL_INT:
		printf("int value %d", ast_node_get_int(node));
		break;
	case SVAL_FLOAT:
		printf("float value %f", ast_node_get_float(node));
		break;
	case SVAL_STR:
		printf("str value \"%s\"", ast_node_get_str(node));
		break;
	case SVAL_POINTER:
		printf("pointer value %p", ast_node_get_pointer(node));
		break;
	}
	printf("\n");

	ast_node_print_aux(node->left, depth + 1);
	ast_node_print_aux(node->middle, depth + 1);
	ast_node_print_aux(node->right, depth + 1);
}

void ast_node_print(struct ast_node *node)
{
	ast_node_print_aux(node, 0);
}
