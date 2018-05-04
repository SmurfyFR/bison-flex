/* C-=2 template with AST */

%{
/* Here, C #include, declarations, #defines. No code. */
#include <stdio.h>
#include "ast.h"
#include <ctype.h>
#include "c--.parser.h"
#include "var.h"
#include "symtab.h"

/* Variables table management */
struct symtab *vars;
int var_get(const char *name);
void var_put(const char *name, int value);

int yylex(void);
void yyerror(char const *);

/* Main AST evaluation */
//int ast_eval(struct ast_node *node); Replaced by eval_list
int eval_list(struct ast_node *node);
int eval_expression(struct ast_node *node);
int eval_boolean_expression(struct ast_node *node);
int eval_assignment(struct ast_node *node);
int eval_conditionnal(struct ast_node *node);
int eval_loop(struct ast_node *node);

/* The AST built by yyparse():
   a clean way would be to have it returned by yyparse(), but it is more complicated */
struct ast_node *the_ast;

%}

/* Declaration of possible types for semantic values */
%union {
       int i_val;
       char *s_val;
       struct ast_node *n_val;
}

/* Tokens declarations */
/* if you add more tokens, don't forget to add them here and very likely also in the Flex file */
/* an integer, semantic value is an int, i.e. field i_val of the union */
%token <i_val> INTEGER
/* an extra token, used to label nodes in the AST for expression/instruction lists
   this token is never returned by yylex(), it is used only for AST
*/
%token LIST
%token WHILE
%token IF
%token ELSE
%token LESS_EQUAL
%token GREATER_EQUAL
%token DIFFERENT
%token EQUALS

/* Operators declaration with associativity and precedence */
/* if you add more operators, don't forger to add them here, or you'll get shift/reduce conflicts */
%right '='
%left IF ELSE
%left '+' '-'    /* + and - are at the same level of precedence */
%left '*' '/'    /* * and / are at a higher precedence than + and - */
%left '<' '>'


%token <s_val> IDENTIFIER

/* Type declarations for non-terminals */
/* if you add more non-terminals, don't forget to declare their type here */
/* in general, non-terminals are of type n_val, which corresponds to field n_val of the union */
%type <n_val> program input line expression boolean_expression assignment conditionnal loop

%%

/* Entry point of the grammar, used to get the top-level AST */
program: input
                    { the_ast = $1; }

/* an input is a list of lines */
input: input line
                    { $$ = ast_node_new(LIST, $1, NULL, $2); }
     | /* empty */
                    { $$ = NULL; }
;


line: '\n'
                    { $$ = NULL; }
    | assignment '\n'
                    { $$ = $1; }
    | expression '\n'
                    { $$ = $1; }
    | boolean_expression '\n'
                    { $$ = $1; }
    | loop '\n'
    | conditionnal '\n'
;

loop:
    WHILE boolean_expression '{' input '}'
        { $$ = ast_node_new(WHILE, $2, NULL, $4); }
;

conditionnal:
    IF boolean_expression '{' input '}'
        { $$ = ast_node_new(IF, $2, $4, NULL); }
    | IF boolean_expression '{' input '}' ELSE '{' input '}'
        { $$ = ast_node_new(IF, $2, $4, $8); }
;

expression:
    INTEGER         { $$ = ast_node_leaf_i(INTEGER, $1); }
   | IDENTIFIER
                    { $$ = ast_node_leaf_s(IDENTIFIER, $1); }
   | expression '+' expression
                    { $$ = ast_node_new('+', $1, NULL, $3); }
   | expression '-' expression
                    { $$ = ast_node_new('-', $1, NULL, $3); }
   | expression '*' expression
                    { $$ = ast_node_new('*', $1, NULL, $3); }
   | expression '/' expression
                    { $$ = ast_node_new('/', $1, NULL, $3); }
   | '(' expression ')'
                    { $$ = $2; }
;

assignment:
    IDENTIFIER '=' expression
      { $$ = ast_node_new('=', ast_node_leaf_s(IDENTIFIER, $1), NULL, $3) }
;

boolean_expression:
    expression '<' expression
      { $$ = ast_node_new('<', $1, NULL, $3); }
    | expression LESS_EQUAL expression
      { $$ = ast_node_new(LESS_EQUAL, $1, NULL, $3); }
    | expression '>' expression
      { $$ = ast_node_new('>', $1, NULL, $3); }
    | expression GREATER_EQUAL expression
      { $$ = ast_node_new(GREATER_EQUAL, $1, NULL, $3); }
    | expression EQUALS expression
      { $$ = ast_node_new(EQUALS, $1, NULL, $3); }
    | expression DIFFERENT expression
      { $$ = ast_node_new(DIFFERENT, $1, NULL, $3); }
;

%%

/* This function is called in case of syntax error */
void yyerror (char const *message)
{
    fprintf(stderr, "%s\n", message);
}

/*
    a skeleton for AST evaluation
    it is incomplete w.r.t. several tokens: some operators, LIST etc
*/
int ast_eval(struct ast_node *node)
{
    int op_left, op_right;

    /* this should never happen however */
    if (node == NULL)
        return 0;

    switch(node->token) {
        case LIST:
            op_left = ast_eval(node->left);
            op_right = ast_eval(node->right);
            // printf("Left evaluation : %d\n", op_left);
            // printf("Right evaluation : %d\n", op_right);
            break;

        case IDENTIFIER:
            printf("> %s = %d\n", ast_node_get_str(node), var_get(ast_node_get_str(node)));
            return var_get(ast_node_get_str(node));
            break;

        case INTEGER:
        case '+':
        case '-':
        case '*':
        case '/':
            return eval_expression(node);
            break;

        // Boolean expressions
        case '>':
        case GREATER_EQUAL:
        case '<':
        case LESS_EQUAL:
        case DIFFERENT:
        case EQUALS:
            return eval_boolean_expression(node);
            break;

        // Asignments
        case '=':
          return eval_assignment(node);
          break;

        // Loops
        case WHILE:
          return eval_loop(node);
          break;

        // Conditionals
        case IF:
          return eval_conditionnal(node);
          break;

        default:
            fprintf(stderr, "ast_eval - unknown token (id: %d)\n", node->token);
            break;
    }
    return 0;
}

int eval_expression(struct ast_node *node) {
    if (node == NULL)
        return 0;

    switch(node->token) {
        case INTEGER:
            return ast_node_get_int(node);
            break;
        case IDENTIFIER:
            return var_get(ast_node_get_str(node));
            break;
        case '+':
            return eval_expression(node->left) + eval_expression(node->right);
            break;
        case '-':
            return eval_expression(node->left) - eval_expression(node->right);
            break;
        case '*':
            return eval_expression(node->left) * eval_expression(node->right);
            break;
        case '/':
            return eval_expression(node->left) / eval_expression(node->right);
            break;

        default:
            fprintf(stderr, "eval_expression - unknown token (id : %d)\n", node->token);
            break;
    }

    return 0;
}

int eval_boolean_expression(struct ast_node *node) {
    if (node == NULL)
        return 0;

    switch(node->token) {
      case '>':
          return eval_expression(node->left) > eval_expression(node->right);
          break;
      case GREATER_EQUAL:
          return eval_expression(node->left) >= eval_expression(node->right);
          break;
      case '<':
          return eval_expression(node->left) < eval_expression(node->right);
          break;
      case LESS_EQUAL:
          return eval_expression(node->left) <= eval_expression(node->right);
          break;
      case DIFFERENT:
          return eval_expression(node->left) != eval_expression(node->right);
          break;
      case EQUALS:
          return eval_expression(node->left) == eval_expression(node->right);
          break;

      /* other cases here */
      default:
          fprintf(stderr, "eval_boolean_expression - unknown token (id : %d)\n", node->token);
          break;
    }

    return 0;
}

int eval_assignment(struct ast_node *node) {
    if(node == NULL) {
      return 0;
    }

    char* name = ast_node_get_str(node->left);
    int value = ast_eval(node->right);

    var_put(name, value);

    return 0;
}

int eval_loop(struct ast_node *node) {
  if(node == NULL) {
      return 0;
  }

  // Partie gauche : Condition à évaluer
  // Partie droite : Instructions
  while(eval_boolean_expression(node->left)) {
      ast_eval(node->right);
  }

  return 0;
}

int eval_conditionnal(struct ast_node *node) {
    if(node == NULL) {
      return 0;
    }

    // On a dans la partie gauche la condition,
    // au milieu les instructions dans le cas ou la condition est évaluée à TRUE
    // à droite les instructions dans le cas contraire
    // Dans le cas d'un if condition { block } (sans else), la partie de droite est NULL
    // Le cas est déjà géré par ast_eval (si node == NULL ...)
    if(eval_boolean_expression(node->left)) {
        ast_eval(node->middle);
    } else {
        ast_eval(node->right);
    }

    return 0;
}

int var_get(const char *name)
{
    uintptr_t tmp;

    if (!symtab_get(vars, name, &tmp)) {
        fprintf(stderr, "%s undefined!\n", name);
        return 0;
    }

    return (int)tmp;
}

void var_put(const char *name, int value)
{
    uintptr_t tmp = (uintptr_t)value;

    symtab_put(vars, name, tmp);
}

int main(int argc, char **argv)
{
    /* Initialize symbol table */
    vars = symtab_new();

    yyparse();

    ast_node_print(the_ast);

    printf("Output : \n\n");

    ast_eval(the_ast);

    printf("\n");
}
