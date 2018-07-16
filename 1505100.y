%{
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include "SymbolTable.h"

using namespace std;

int yyparse(void);
int yylex(void);
int label_cnt, var_cnt, scope_cnt;

extern FILE *yyin;
extern int line_count;
extern int error_count;

FILE *logout, *errorout, *code;

vector <tree_node*> node;
vector <string> program_vec, ls;

string type_name, ret_type, asm_code, str, variable, func_name;

symbolTable table(10);
functionTable functable;

string get_label()
{
	string temp;
	char var[5];
	sprintf(var, "%d", label_cnt++);
	temp = "L";
	temp += var;
	return temp;
}

string get_temp_var()
{
	string temp;
	char var[5];
	sprintf(var, "%d", var_cnt++);
	temp = "t";
	temp += var;
	return temp;
}

string get_scope_cnt(int cnt)
{
	string temp;
	char var[5];
	sprintf(var, "%d", cnt);
	temp += var;
	return temp;
}

void yyerror(const char *s)
{
	++error_count;
	fprintf(errorout, "At line : %d %s\n\n", line_count, s);
}

tree_node* get_node()
{
	tree_node *temp = new tree_node();
	return temp;
}

tree_node* info_node(symbolInfo *inf)
{
	tree_node *temp = get_node();
	temp->str = inf->get_name();
	temp->type = inf->get_type();
	temp->line_num = inf->line_num;

	return temp;
}

void var_insert(string name, string type, string var_type)
{

}

symbolInfo *var_cur_search(string name)
{

}

symbolInfo *var_search(string name)
{

}

%}

%union {
	int ival;
	double dval;
	symbolInfo *symbol;
	tree_node *node;
}

%token <symbol> IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE ASSIGNOP INCOP DECOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON COMMENT PRINTLN
%token <symbol> CONST_INT CONST_FLOAT CONST_CHAR STRING ID ADDOP MULOP RELOP LOGICOP BITOP

%type <node> func_declaration func_definition unit program go_to_scope go
%type <node> declaration_list parameter_list argument_list arguments variable type_specifier
%type <node> expression unary_expression logic_expression rel_expression simple_expression term factor
%type <node> statements statement compound_statement expression_statement var_declaration

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
%define parse.error verbose

%%

start : program
		;

program : program unit
		{

		}
		| unit
		{

		}
		;

unit : var_declaration
		{
		 		asm_code += $1->code;
	 	}
     	| func_declaration
	 	{
			ls.clear();
	 	}
     	| func_definition
	 	{
				ls.clear();
				asm_code += $1->code;
	 	}
     	;

func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
		{
				bool mark = false;

				table.enter_scope();

				$$ = get_node();
				$$->line_num = $1->line_num;

				for (int i = 0; i < $4->vec.size(); ++i)
				{
					if ($4->vec[i]->str.size())
					{
						if (table.cur_look_up($4->vec[i]->str))
							++error_count, fprintf(logout, "At line no : %d redeclaration of parameter\n\n", $4->vec[i]->line_num);
						else
							table.insert($4->vec[i]->str, "ID", $4->vec[i]->type);
					}
				}

				func_node *temp = new func_node();

				if (table.look_up($2->get_name()))
					++error_count, fprintf(logout, "At line no : %d redeclaration of variable\n\n", $2->line_num);
				else if (functable.is_declared($2->get_name()))
					++error_count, fprintf(logout, "At line no : %d redeclaration of function\n\n", $2->line_num);
				else if (functable.is_defined($2->get_name()))
					++error_count, fprintf(logout, "At line no : %d function has already defined\n\n", $2->line_num);
				else
				{
					temp->name = $2->get_name();
					temp->type = $1->str;

					for (int i = 0; i < $4->vec.size(); ++i)
						temp->vec.push_back($4->vec[i]->type);

					mark = true;
				}

				table.exit_scope();

				if (mark)
				{
					functable.insert_dec(temp);
					table.insert($2->get_name(), $2->get_type(), $1->str);
				}
		}
		| type_specifier ID LPAREN RPAREN SEMICOLON
		{
				bool mark = false;

				table.enter_scope();

			 	$$ = get_node();
				$$->line_num = $1->line_num;

				func_node *temp = new func_node();

				if (table.look_up($2->get_name()))
					++error_count, fprintf(logout, "At line no : %d redeclaration of variable\n\n", $2->line_num);
				else if (functable.is_declared($2->get_name()))
					++error_count, fprintf(logout, "At line no : %d redeclaration of function\n\n", $2->line_num);
				else if (functable.is_defined($2->get_name()))
					++error_count, fprintf(logout, "At line no : %d function has already defined\n\n", $2->line_num);
				else
					temp->name = $2->get_name(), temp->type = $1->str, mark = true;

				table.exit_scope();

				if (mark)
				{
					functable.insert_dec(temp);
					table.insert($2->get_name(), $2->get_type(), $1->str);
				}
		}
		;

func_definition : go_to_scope compound_statement
		{
				bool mark = false;
				bool isdefine = false;

				$$ = get_node();
				$$->code += $1->code + $2->code;
				$$->code += "\n" + $1->str + " ENDP\n\n";
				$$->line_num = $1->line_num;

				func_node *temp = functable.is_declared(node[2]->str);

				if (functable.is_defined(node[2]->str))
					++error_count, fprintf(logout, "At line no : %d redefination of function\n\n", node[2]->line_num);
				else if (temp)
				{
					if (node[1]->str != temp->type)
						++error_count, fprintf(logout, "At line no : %d return type mismatch\n\n", node[1]->line_num);
					else if (node[1]->str != "float" && node[1]->str != ret_type)
						++error_count, fprintf(logout, "At line no : %d return type mismatch\n\n", node[1]->line_num);
					else if (temp->vec.size() > node[4]->vec.size())
						++error_count, fprintf(logout, "At line no : %d too few parameters\n\n", node[3]->line_num);
					else if (temp->vec.size() < node[4]->vec.size())
						++error_count, fprintf(logout, "At line no : %d too many parameters\n\n", node[3]->line_num);
					else
					{
						bool isgood = true;

						for (int i = 0; i < temp->vec.size(); ++i)
						{
							if (temp->vec[i] != node[4]->vec[i]->type)
							{
								isgood = false;
								++error_count, fprintf(logout, "At line no : %d parameter type mismatch\n\n", node[3]->line_num);
								break;
							}
						}

						isdefine = mark = isgood;
					}
				}
				else
				{
					if (node[1]->str != "float" && node[1]->str != ret_type)
						++error_count, fprintf(logout, "At line no : %d return type mismatch\n\n", node[1]->line_num);
					else
					{
						temp = new func_node();
						temp->name = node[2]->str;
						temp->type = node[1]->str;

						for (int i = 0; i < node[4]->vec.size(); ++i)
							temp->vec.push_back(node[4]->vec[i]->type);

						mark = true;
					}
				}

				table.exit_scope();
				node.clear();
				ret_type = "void";

				if (mark)
				{
					temp->param = ls;
					ls.clear();
					functable.insert_def(temp);

					if (!isdefine)
						table.insert(node[2]->str, node[2]->type, node[1]->str);
				}
		}
		| go_to_scope
		{
				$$ = get_node();
				$$->code += $1->code;
				$$->code += "\n" + $1->str + " ENDP\n\n";
				$$->line_num = $1->line_num;
		}
 		;

go_to_scope : type_specifier ID LPAREN parameter_list RPAREN
		{
				++scope_cnt;
				table.enter_scope();

				func_name = $2->get_name();

				$$ = get_node();
				$$->str = $2->get_name();
				$$->code += $2->get_name() + " PROC\n\n";
				$$->line_num = $1->line_num;

				if (func_name != "main")
					$$->code += "ret\n";

				for (int i = 0; i < $4->vec.size(); ++i)
				{
					if (table.cur_look_up($4->vec[i]->str))
						++error_count, fprintf(logout, "At line no : %d redeclaration of parameter\n\n", $4->vec[i]->line_num);
					else
						table.insert($4->vec[i]->str, "ID", $4->vec[i]->type);
				}

				node.push_back($1), node.push_back($1), node.push_back(info_node($2));
				node.push_back(info_node($3)), node.push_back($4), node.push_back(info_node($5));
		}
		|
		go compound_statement
		{
				bool mark = false;
				bool isdefine = false;

				$$ = get_node();
				$$->str = $1->str;
				$$->code += $1->code + $2->code;
				$$->line_num = node[1]->line_num;

				if (func_name != "main")
					$$->code += "ret\n";

				func_node *temp = functable.is_declared(node[2]->str);

				if (functable.is_defined(node[2]->str))
					++error_count, fprintf(logout, "At line no : %d redefination of function\n\n", node[2]->line_num);
				else if (temp)
				{
					if (node[1]->str != temp->type)
						++error_count, fprintf(logout, "At line no : %d return type mismatch\n\n", node[1]->line_num);
					else if (temp->type != "float" && temp->type != ret_type)
						++error_count, fprintf(logout, "At line no : %d return type mismatch\n\n", node[1]->line_num);
					else if (temp->vec.size())
						++error_count, fprintf(logout, "At line no : %d too few parameters\n\n", node[3]->line_num);
					else
						isdefine = mark = true;
				}
				else
				{
					if (node[1]->str != "float" && node[1]->str != ret_type)
						++error_count, fprintf(logout, "At line no : %d return type mismatch\n\n", node[1]->line_num);
					else
					{
						temp = new func_node();
						temp->name = node[2]->str;
						temp->type = node[1]->str;
						mark = true;
					}
				}

				table.exit_scope();
				node.clear();
				ret_type = "void";

				if (mark)
				{
					functable.insert_def(temp);

					if (!isdefine)
						table.insert(node[2]->str, node[2]->type, node[1]->str);
				}
		}
		;

go : type_specifier ID LPAREN RPAREN
		{
				table.enter_scope();
				++scope_cnt;

				func_name = $2->get_name();

				$$ = get_node();
				$$->str = $2->get_name();
				$$->code += $2->get_name() + " PROC\n\n";

				if ($2->get_name() == "main")
					$$->code += "MOV AX, @DATA\nMOV DS, AX\n";

				$$->line_num = $1->line_num;

				node.push_back($1), node.push_back($1), node.push_back(info_node($2));
				node.push_back(info_node($3)), node.push_back(info_node($4));
		}
		;

parameter_list  : parameter_list COMMA type_specifier ID
		{
				tree_node *temp = get_node();
				temp->str = $4->get_name();
				temp->type = type_name;
				temp->line_num = $4->line_num;
				$$->vec.push_back(temp);
				ls.push_back($4->get_name() + get_scope_cnt(scope_cnt + 1));

				variable += $4->get_name() + get_scope_cnt(scope_cnt + 1) + " DW ?\n";
		}
		| parameter_list COMMA type_specifier
		{
				tree_node *temp = get_node();
				temp->type = type_name;
				$$->vec.push_back(temp);
		}
 		| type_specifier ID
		{
				tree_node *temp = get_node();
				temp->str = $2->get_name();
				temp->type = type_name;
				temp->line_num = $2->line_num;
				ls.push_back($2->get_name() + get_scope_cnt(scope_cnt + 1));

				$$ = get_node();
				$$->vec.push_back(temp);
				$$->line_num = $1->line_num;

				variable += $2->get_name() + get_scope_cnt(scope_cnt + 1) + " DW ?\n";
		}
		| type_specifier
		{
				tree_node *temp = get_node();
				temp->type = $1->str;

				$$ = get_node();
				$$->vec.push_back(temp);
				$$->line_num = $1->line_num;
		}
 		;

compound_statement : LCURL statements RCURL
		{
				$$ = get_node();
				$$ = $2;
				$$->line_num = $1->line_num;
		}
 		| LCURL RCURL
		{
				$$ = get_node();
				$$->line_num = $1->line_num;
		}
 		;

var_declaration : type_specifier declaration_list SEMICOLON
		 {
			 	$$ = get_node();
				$$->line_num = $1->line_num;
		 }
 		 ;

type_specifier	: INT
		{
				$$ = get_node();
				$$->str = "int";
				$$->line_num = $1->line_num;
				type_name = "int";
		}
 		| FLOAT
		{
				$$ = get_node();
				$$->str = "float";
				$$->line_num = $1->line_num;
				type_name = "float";
		}
 		| VOID
		{
				$$ = get_node();
				$$->str = "void";
				$$->line_num = $1->line_num;
				type_name = "void";
		}
 		;

declaration_list : declaration_list COMMA ID
		{
				tree_node *temp = get_node();
				temp->str = $3->get_name();
				temp->type = type_name;

				$$->vec.push_back(temp);
				$$->line_num = $1->line_num;

				variable += $3->get_name() + get_scope_cnt(scope_cnt) + " DW ?\n";

				if (type_name == "void")
					++error_count, fprintf(logout, "At line no : %d variable type can not be void\n\n", $3->line_num);
				else if (table.cur_look_up($3->get_name()))
					++error_count, fprintf(logout, "At line no : %d redeclaration of variable\n\n", $3->line_num);
				else
					table.insert($3->get_name(), $3->get_type(), type_name);
		}
 		| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
		{
				tree_node *temp = get_node();
				temp->str = $3->get_name();
				temp->type = type_name;

				$$->vec.push_back(temp);
				$$->line_num = $1->line_num;

				variable += $3->get_name() + get_scope_cnt(scope_cnt) + " DW " + $5->get_name() + " DUP(0)\n";

				if (type_name == "void")
					++error_count, fprintf(errorout, "At line no : %d variable type can not be void\n\n", $3->line_num);
				else if (table.cur_look_up($3->get_name()))
					++error_count, fprintf(errorout, "At line no : %d redeclaration of variable\n\n", $3->line_num);
				else
					table.insert($3->get_name(), "array", type_name);
		}
 		| ID
		{
				tree_node *temp = get_node();
				temp->str = $1->get_name();
				temp->type = type_name;

				$$ = get_node();
				$$->vec.push_back(temp);
				$$->line_num = $1->line_num;

				variable += $1->get_name() + get_scope_cnt(scope_cnt) + " DW ?\n";

				if (type_name == "void")
					++error_count, fprintf(errorout, "At line no : %d variable type can not be void\n\n", $1->line_num);
				else if (table.cur_look_up($1->get_name()))
					++error_count, fprintf(errorout, "At line no : %d redeclaration of variable\n\n", $1->line_num);
				else
					table.insert($1->get_name(), $1->get_type(), type_name);
		}
 		| ID LTHIRD CONST_INT RTHIRD
		{
				tree_node *temp = get_node();
				temp->str = $1->get_name();
				temp->type = type_name;

				$$ = get_node();
				$$->vec.push_back(temp);
				$$->line_num = $1->line_num;

				variable += $1->get_name() + get_scope_cnt(scope_cnt) + " DW " + $3->get_name() + " DUP(0)\n";

				if (type_name == "void")
					++error_count, fprintf(errorout, "At line no : %d variable type can no be void\n\n", $1->line_num);
				else if (table.cur_look_up($1->get_name()))
					++error_count, fprintf(errorout, "At line no : %d variable name already declared\n\n", $1->line_num);
				else
					table.insert($1->get_name(), "array", type_name);
		}
 		;

statements : statement
	   	{
	   			$$ = get_node();
				$$ = $1;
	   	}
	   	| statements statement
	   	{
	   			$$ = get_node();
				$$->code = $1->code + $2->code;
				$$->line_num = $1->line_num;
	   	}
	   	;

statement : var_declaration
		{
		  		$$ = get_node();
				$$ = $1;
		}
		| expression_statement
		{
		  		$$ = get_node();
				$$ = $1;
		}
		| compound_statement
		{
		  		$$ = get_node();
				$$ = $1;
		}
		| FOR LPAREN expression_statement expression_statement expression RPAREN statement
		{
				string conditionlabel = get_label();
				string statementlabel = get_label();
				string exitscopelabel = get_label();

		  		$$ = get_node();
				$$->code += $3->code;
				$$->code += conditionlabel + ":\n";
				$$->code += $4->code;
				$$->code += "CMP " + $4->str + ", 1\n";
				$$->code += "JE " + statementlabel + "\n";
				$$->code += "JMP " + exitscopelabel + "\n";
				$$->code += statementlabel + ":\n";
				$$->code += $7->code + $5->code;
				$$->code += "JMP " + conditionlabel + "\n";
				$$->code += exitscopelabel + ":\n";
				$$->line_num = $1->line_num;
		}
		| IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
		{
				string conditionlabel = get_label();
				string statementlabel = get_label();
				string exitscopelabel = get_label();

		  		$$ = get_node();
				$$->code += conditionlabel + ":\n";
				$$->code += $3->code;
				$$->code += "CMP " + $3->str + ", 0\n";
				$$->code += "JMP " + exitscopelabel + "\n";
				$$->code += "JE " + statementlabel + "\n";
				$$->code += statementlabel + ":\n";
				$$->code += $5->code;
				$$->code += exitscopelabel + ":\n";
				$$->line_num = $1->line_num;
		}
		| IF LPAREN expression RPAREN statement ELSE statement
		{
				string conditionlabel = get_label();
				string statementlabel = get_label();
				string elselabel = get_label();
				string exitscopelabel = get_label();

		  		$$ = get_node();
				$$->code += conditionlabel + ":\n";
				$$->code += $3->code;
				$$->code += "CMP " + $3->str + ", 0\n";
				$$->code += "JMP " + elselabel + "\n";
				$$->code += "JE " + statementlabel + "\n";
				$$->code += statementlabel + ":\n";
				$$->code += $5->code;
				$$->code += "JMP " + exitscopelabel + "\n";
				$$->code += elselabel + ":\n";
				$$->code += $7->code;
				$$->code += exitscopelabel + ":\n";
				$$->line_num = $1->line_num;
		}
		| WHILE LPAREN expression RPAREN statement
		{
				string conditionlabel = get_label();
				string statementlabel = get_label();
				string exitscopelabel = get_label();

				$$ = get_node();
				$$->code += conditionlabel + ":\n";
				$$->code += $3->code;
				$$->code += "CMP " + $3->str + ", 0\n";
				$$->code += "JE " + exitscopelabel + "\n";
				$$->code += "JMP " + statementlabel + "\n";
				$$->code += statementlabel + ":\n";
				$$->code += $5->code;
				$$->code += "JMP " + conditionlabel + "\n";
				$$->code += exitscopelabel + ":\n";
				$$->line_num = $1->line_num;
		}
		| PRINTLN LPAREN ID RPAREN SEMICOLON
		{
		  		$$ = get_node();

				symbolInfo *temp = table.look_up($3->get_name());

				$$->code += "MOV AX, " + $3->get_name() + get_scope_cnt(temp->num) + "\n";
				$$->code += "CALL OUP\n";
				$$->code += "MOV AH, 2\n";
				$$->code += "MOV DL, 0AH\n";
				$$->code += "INT 21H\n";
				$$->code += "MOV DL, 0DH\n";
				$$->code += "INT 21H\n";
		}
		| RETURN expression SEMICOLON
		{
		  		$$ = get_node();
				$$ = $2;

				if (func_name != "main")
				{
					$$->code += "MOV AX, " + $2->str + "\n";
					$$->code += "PUSH AX\n";
				}

				$$->line_num = $1->line_num;
				ret_type = $2->type;
		}
		;

expression_statement : SEMICOLON
		{
				$$ = get_node();
				$$->line_num = $1->line_num;
		}
		| expression SEMICOLON
		{
				$$ = get_node();
				$$ = $1;
		}
		;

variable : ID
	 	{
	 			$$ = get_node();
				$$->line_num = $1->line_num;

				symbolInfo *temp = table.look_up($1->get_name());

				if (temp)
				{
					if (temp->isarray)
						++error_count, fprintf(logout, "At line no : %d array type without []\n\n", $1->line_num);
					else
					{
						$$->str = $1->get_name() + get_scope_cnt(temp->num);
						$$->type = temp->var_type;
					}
				}
				else
					++error_count, fprintf(logout, "At line no : %d undeclared variable\n\n", $1->line_num);
	 	}
	 	| ID LTHIRD expression RTHIRD
	 	{
				$$ = get_node();
				$$->code += $3->code;
				$$->code += "MOV BX, " + $3->str + "\n";
				$$->code += "SHL BX, 2\n";
				$$->line_num = $1->line_num;

				symbolInfo *temp = table.look_up($1->get_name());

				if ($3->type != "int")
					++error_count, fprintf(logout, "At line no : %d non integer array index\n\n", $3->line_num);
				else if (temp)
				{
					if (!temp->isarray)
						++error_count, fprintf(logout, "At line no : %d variable is not an array type\n\n", $1->line_num);
					else
					{
						$$->str = $1->get_name() + get_scope_cnt(temp->num) + "[BX]";
						$$->type = temp->var_type;
					}
				}
				else
					++error_count, fprintf(logout, "At line no : %d undeclared variable\n\n", $1->line_num);
	 	}
	 	;

expression : logic_expression
	  	{
	  			$$ = get_node();
				$$ = $1;
	  	}
	  	| variable ASSIGNOP logic_expression
	  	{
	  			$$ = get_node();
				$$->str = $1->str;
				$$->code += $3->code;
				$$->code += "MOV AX, " + $3->str + "\n";
				$$->code += $1->code;
				$$->code += "MOV " + $$->str + ", AX\n";
				$$->line_num = $1->line_num;

				if ($3->type == "void")
					++error_count, fprintf(errorout, "At line no : %d void can not be a type in ASSIGNOP\n\n", $3->line_num);
				else if ($1->type == "int" && $3->type == "float")
					++error_count, fprintf(errorout, "At line no : %d type mismatch\n\n", $2->line_num);
				else
					$$->type = $1->type;
	  	}
	  	;

logic_expression : rel_expression
		{
		 		$$ = get_node();
				$$ = $1;
		}
		| rel_expression LOGICOP rel_expression
		{
		 		$$ = get_node();
				$$->str = get_temp_var();
				$$->code += $3->code + $1->code;
				$$->code += "MOV AX, " + $1->str + "\n";
				$$->line_num = $1->line_num;
				variable += $$->str + " DW ?\n";

				if ($2->get_name() == "&&")
					$$->code += "AND AX, " + $3->str + "\n";
				else
					$$->code += "OR AX, " + $3->str + "\n";

				$$->code += "MOV " + $$->str + ", AX\n";

				if ($1->type == "void" || $3->type == "void")
					++error_count, fprintf(errorout, "At line no : %d void can not be used in LOGICOP\n\n", $1->line_num);
				else
					$$->type = "int";
		}
		;

rel_expression : simple_expression
		{
				$$ = get_node();
				$$ = $1;
		}
		| simple_expression RELOP simple_expression
		{
				$$ = get_node();
				$$->str = get_temp_var();
				$$->code += $3->code + $1->code;
				$$->code += "MOV AX, " + $3->str + "\n";
				$$->code += "CMP " + $1->str + ", AX\n";
				$$->line_num = $1->line_num;
				variable += $$->str + " DW ?\n";

				string label1 = get_label();
				string label2 = get_label();

				if ($2->get_name() == "<")
					$$->code += "JL " + label1 + "\n";
				else if ($2->get_name() == "<=")
					$$->code += "JLE " + label1 + "\n";
				else if ($2->get_name() == ">")
					$$->code += "JG " + label1 + "\n";
				else if ($2->get_name() == ">=")
					$$->code += "JGE " + label1 + "\n";
				else if ($2->get_name() == "==")
					$$->code += "JE " + label1 + "\n";

				$$->code += "MOV " + $$->str + ", 0\n";
				$$->code += "JMP " + label2 + "\n";
				$$->code += label1 + ":\n";
				$$->code += "MOV " + $$->str + ", 1\n";
				$$->code += label2 + ":\n";

				if ($1->type == "void" || $3->type == "void")
					++error_count, fprintf(errorout, "At line no : %d void can not be used in RELOP\n\n", $1->line_num);
				else
					$$->type = "int";
		}
		;

simple_expression : term
		{
		  		$$ = get_node();
				$$ = $1;
		}
		| simple_expression ADDOP term
		{
		  		$$ = get_node();
				$$->str = get_temp_var();
				$$->code += $3->code + $1->code;
				$$->code += "MOV AX, " + $1->str + "\n";

				if ($2->get_name() == "+")
					$$->code += "ADD AX, " + $3->str + "\n";
				else
					$$->code += "SUB AX, " + $3->str + "\n";

				$$->code += "MOV " + $$->str + ", AX\n";
				$$->line_num = $1->line_num;
				variable += $$->str + " DW ?\n";

				if ($1->type == "void" || $3->type == "void")
					++error_count, fprintf(errorout, "At line no : %d void can not be used in ADDOP\n\n", $1->line_num);
				else if ($1->type == "float" || $3->type == "float")
					$$->type = "float";
				else
					$$->type = "int";
		}
		;

term :	unary_expression
	 	{
	 			$$ = get_node();
				$$ = $1;
	 	}
     	|  term MULOP unary_expression
	 	{
	 			$$ = get_node();
				$$->str = get_temp_var();
				$$->line_num = $1->line_num;

				if ($2->get_name() == "*")
				{
					$$->code += $3->code;
					$$->code += "MOV AX, " + $1->str + "\n";
					$$->code += $1->code;
					$$->code += "MOV BX, " + $3->str + "\n";
					$$->code += "MUL BX\n";
					$$->code += "MOV " + $$->str + ", AX\n";
				}
				else
				{
					$$->code += $3->code;
					$$->code += "MOV AX, " + $1->str + "\n";
					$$->code += $1->code;
					$$->code += "MOV DX, 0\n";
					$$->code += "MOV BX, " + $3->str + "\n";
					$$->code += "DIV BX\n";

					if ($2->get_name() == "/")
						$$->code += "MOV " + $$->str + ", AX\n";
					else
						$$->code += "MOV " + $$->str + ", DX\n";
				}

				variable += $$->str + " DW ?\n";

				if ($2->get_name() == "%" && ($1->type != "int" || $3->type != "int"))
					++error_count, fprintf(errorout, "At line no : %d interger expected in both operand of modulus\n\n", $1->line_num);
				else if ($1->type == "void" || $3->type == "void")
					++error_count, fprintf(errorout, "At line no : %d void can not be used in MULOP\n\n", $1->line_num);
				else if ($1->type == "float" || $3->type == "float")
					$$->type = "float";
				else
					$$->type = "int";
	 	}
     	;

unary_expression : ADDOP unary_expression
		{
				$$ = get_node();

				if ($1->get_name() == "-")
				{
					$$->str = get_temp_var();
					$$->code += $2->code;
					$$->code += "MOV AX, " + $2->str + "\n";
					$$->code += "NEG AX\n";
					$$->code += "MOV " + $$->str + ", AX\n";
					variable += $$->str + " DW ?\n";
				}

				$$->type = $2->type;
				$$->line_num = $1->line_num;
		}
		| NOT unary_expression
		{
		 		$$ = get_node();
				$$->str = get_temp_var();
				$$->code += $2->code;
				$$->code += "MOV AX, " + $2->str + "\n";
				$$->code += "NOT AX\n";
				$$->code += "MOV " + $$->str + ", AX\n";
				$$->line_num = $1->line_num;
				variable += $$->str + " DW ?\n";

				if ($2->type != "int")
					++error_count, fprintf(logout, "At line no : %d interger expected in NOT operator\n\n", $2->line_num);
				else
					$$->type = "int";
		}
		| factor
		{
				$$ = get_node();
				$$ = $1;
		}
		;

factor	: variable
		{
				$$ = get_node();
				$$ = $1;
		}
		| ID LPAREN argument_list RPAREN
		{
				func_node *temp = functable.is_defined($1->get_name());

				$$ = get_node();

				if (temp->param.size() == $3->vec.size())
				{
					for (int i = 0; i < $3->vec.size(); ++i)
					{
						$$->code += "MOV AX, " + $3->vec[i]->str + "\n";
						$$->code += "MOV " + temp->param[i] + ", AX\n";
					}
				}

				$$->code += "CALL " + $1->get_name() + "\n";
				$$->line_num = $1->line_num;

				if (temp)
				{
					if (temp->vec.size() > $3->vec.size())
						++error_count, fprintf(logout, "At line no : %d too few arguments\n\n", $3->line_num);
					else if (temp->vec.size() < $3->vec.size())
						++error_count, fprintf(logout, "At line no : %d too many arguments\n\n", $3->line_num);
					else
					{
						for (int i = 0; i < temp->vec.size(); ++i)
						{
							if (temp->vec[i] != "float" && temp->vec[i] != $3->vec[i]->type.c_str())
							{
								++error_count, fprintf(logout, "At line no : %d type mismatch\n\n", $3->line_num);
								break;
							}

							if (i == temp->vec.size() - 1)
								$$->type = temp->type;
						}

						if (!temp->vec.size())
							$$->type = temp->type;

						if (temp->type != "void")
						{
							$$->str = get_temp_var();
							$$->code += "POP " + $$->str + "\n";
							variable += $$->str + " DW ?\n";
						}
					}
				}
			 	else
					++error_count, fprintf(logout, "At line no : %d function is not defined\n\n", $1->line_num);
		}
		| LPAREN expression RPAREN
		{
				$$ = get_node();
				$$->type = $2->type;
				$$->str = $2->str;
				$$->code += $2->code;
				$$->line_num = $1->line_num;
		}
		| CONST_INT
		{
				$$ = get_node();
				$$->type = "int";
				$$->str = get_temp_var();
				$$->code += "MOV AX, " + $1->get_name() + "\n";
				$$->code += "MOV " + $$->str + ", AX\n";
				variable += $$->str + " DW ?\n";
				$$->line_num = $1->line_num;
		}
		| CONST_FLOAT
		{
				$$ = get_node();
				$$->type = "float";
				$$->str = get_temp_var();
				$$->code += "MOV AX, " + $1->get_name() + "\n";
				$$->code += "MOV " + $$->str + ", AX\n";
				variable += $$->str + " DW ?\n";
				$$->line_num = $1->line_num;
		}
		| variable INCOP
		{
				$$ = get_node();
				$$->str = $1->str;
				$$->type = $1->type;
				$$->code += "INC " + $1->str + "\n";
				$$->line_num = $1->line_num;
		}
		| variable DECOP
		{
				$$ = get_node();
				$$->str = $1->str;
				$$->type = $1->type;
				$$->code += "DEC " + $1->str + "\n";
				$$->line_num = $1->line_num;
		}
		;

argument_list : arguments
		{
				$$ = get_node();
				$$ = $1;
		}
		|
		{
			$$ = get_node();
			$$->line_num = line_count;
		}
		;

arguments : arguments COMMA logic_expression
		{
				$$->vec.push_back($3);
				$$->line_num = $1->line_num;
		}
	    | logic_expression
		{
				$$ = get_node();
				$$ = $1;
				$$->vec.push_back($1);
		}
	    ;

%%

int main(int argc,char *argv[])
{
	if((yyin=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}

	variable += "SZ DW ?\n";
	string oup, str;

	ifstream in("oup.txt");

	while (getline(in, str))
		oup += str + "\n";

	label_cnt = 1;
	var_cnt = 1;
	scope_cnt = 1;

	logout = fopen(argv[2], "w");
	fclose(logout);

	errorout = fopen(argv[3],"w");
	fclose(errorout);

	code = fopen(argv[4], "w");
	fclose(code);

	logout = fopen(argv[2],"a");
	errorout = fopen(argv[3],"a");
	code = fopen(argv[4], "a");

	ret_type = "void";
	table.enter_scope();
	yylval.symbol = new symbolInfo();

	yyparse();

	asm_code = ".MODEL SMALL\n\n.STACK 100H\n\n.DATA\n\n" + variable + "\n.CODE\n\n" + oup + "\n" + asm_code + "END main";
	fprintf(code, "%s", asm_code.c_str());

	fprintf(logout, "Total lines: %d\n\n", line_count);
	fprintf(logout, "Total error: %d\n\n", error_count);
	fprintf(errorout, "Total error: %d\n\n", error_count);

	fclose(logout);
	fclose(errorout);
	fclose(code);

	return 0;
}
