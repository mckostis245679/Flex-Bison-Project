%{

    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    int yylex();
    void yyerror(const char *s);

    int var_counter = 0;
    

    typedef struct data
    {
        char *name;
        char *type;//class-NO
        int category;//variable-0,function-1,class-2,class_end-3
        char *value;
        int visibility;
    } data; 

    data* stack[100];
    int top_data=0;
     /* datas Recognition */ 

    data * create_data(int visibility, char *type, char *name)
    {
        printf("Creating data...\n");
        data *v = (data *)malloc(sizeof(data));
        v->name = strdup(name); // strdup is used to copy the string
        v->type = type; 
        // v->value = value;
        v->category=0;
        v->visibility = visibility;
        return v;
    }
    data * create_function(int visibility, char *type, char *name)
    {
        printf("Creating function...\n");
        data *f = (data *)malloc(sizeof(data));
        f->name = strdup(name); // strdup is used to copy the string
        f->type = type; 
        f->category=1;
        f->visibility = visibility;
        return v;
    }
    data * create_class(int visibility, char *type, char *name)
    {
        printf("Creating class...\n");
        data *c = (data *)malloc(sizeof(data));
        c->name = strdup(name); // strdup is used to copy the string
        c->type =strdup("no"); 
        c->category=2;
        c->visibility = visibility;
        return v;
    }
    void create_end_class()
    {
        printf("Creating class...\n");
        data *c = (data *)malloc(sizeof(data));
        c->name = strdup("end_class"); // strdup is used to copy the string
        c->type =strdup("no"); 
        c->category=4;
        c->visibility = 0;
        push(c)
    }

    void push(data *v)
    {
        stack[top_data++] = v;
    }

    void pop()
    {   
        top_data--;
        free (stack[top_data]);
    }

    void print_stack_data()
    {
        printf("data stack \n");
        for(int i = 0; i < top_data; i++)
            print_data(stack[i]);
         printf("-------------------\n");
    }


    void print_data(data *v)
    {
        printf("Category: %s ,Name: %s, Type: %s, Value: %s,Visibility: %d\n", v->category,v->name, v->type ,v->value, v->visibility);
    }

    int find_data_access(char *name,int category){
        int i=top_data-1;
        while(top_data != 0  && stack[i]->category!=4 ){
            if(strcmp(stack[i]->name, name) == 0 && stack[i]->category==category)
            {
                print_data(stack[i]);
                return i;
            }
        }
        return -1;
    }




    int find_var(char *name)
    {

         while(i != 0  && stack[i]->category!=1 && stak )
        {
            if(strcmp(stack[i]->name, name) == 0 && stack[i]->category==0)
            {
                print_data(stack[i]);
                return i;
            }
            i--;
        }
        return -1;
    }
     int find_func(char *name)
    {
         while(i != 0  && stack[i]->category!=4 )
        {
            if(strcmp(stack[i]->name, name) == 0 && stack[i]->category==1)
            {
                print_data(stack[i]);
                return i;
            }
            i--;
        }
        return -1;
    }
     int find_class(char *name)
    {
         while(i != 0  && stack[i]->category!=4 )
        {
            if(strcmp(stack[i]->name, name) == 0 && stack[i]->category==2)
            {
                print_data(stack[i]);
                return i;
            }
            i--;
        }
        return -1;
    }

    void delete_function_vars(){
         printf("BEFORE FUNCTION VAR DELETION\n");
        print_stack_data();

        while(top_data != 0  && stack[top_data-1]->category!=1 ){
           pop(c);
        }
        printf("AFTER FUNCTION VAR DELETION\n");
        print_stack_data();
        return;
    }


    void data_initiliazation(int visibility , char *type, char *name,int category)
    {
        if (find_data_initialize(name,category) != -1)
        {   
            char *msg;
            yyerror("data has been initialized");
            printf("!!! data: %s has been initialized with type: %s !!!\n", name, type);
            exit(0);
        }
        else
        {  
            data* data;
            if (category==0)
                data = create_var(visibility, type, name); 
            if (category==1)
                data = create_functon(visibility, type, name); 
            if (category==2)
                data = create_class(visibility, type, name); 
            //print_data(data);
            push(data);
           // print_stack_data( stack,top_data);
        }
    }

    void fix_visibility(data* stack[],int top_data,int count, int visibility)
    {
        while (count != 0)
        {
            stack[top_data - 1 - count]->visibility = visibility;
            count --;
        }
      //  print_stack_data();
        count = 0;
    }

%}

// Declare the types of tokens that will be used in the grammar
%union
{
    int ival;
    char cval;
    double dval;
    char *sval;
}

// Brackets
%token CURLY_BRACKET_LEFT
%token CURLY_BRACKET_RIGHT
%token BRACKET_LEFT 
%token BRACKET_RIGHT
%token EQUAL_SIGN
%token SEMICOLON
%token SINGLE_MARK
%token COLON
%token COMMA
%token DOT  

%token PLUS
%token MINUS
%token MULTIPLY
%token DIVIDE

// Class Identifier
%token  PUBLIC
%token  PRIVATE
%type <ival> visibility

%token  CLASS
%token <sval> CLASS_NAME
%token NEW

// Loop Identifiers
%token IF
%token ELSE
%token FOR
%token DO
%token WHILE
%token CONDITION_SYMBOL
%token BOOL_SYMBOL
%token INCREAMENT_DECREAMENT
%token LOOP_STEP

//Condition Identifiers
%token SWITCH
%token CASE
%token DEFAULT

%token BREAK 
%token RETURN

//data Types
%type <sval> int_init;
%type <sval> double_init;
%type <sval> char_init;
%type <sval> bool_init;
%type <sval> string_init;

%type <sval> data_assignment
%type <sval> data_type

%type <sval> VAR_NAME;
// Function Type
%type <ival> function_visibility;

%token <sval> IDENT
%token <sval> VOID
%token <sval> INT
%token <sval> CHAR
%token <sval> DOUBLE
%token <sval> BOOLEAN
%token <sval> STRING
//%token EMTPY

//data Values
%token <ival> INT_VALUE 
%token <cval> CHAR_VALUE
%token <dval> DOUBLE_VALUE
%token <sval> BOOLEAN_VALUE
%token <sval> STRING_VALUE

%glr-parser


%start program

%%

program: %empty{print_program();} | class_identifier program ;

VAR_NAME: CLASS_NAME{$$=$1;} | IDENT{$$=$1;};

// Class Identifier of Only One Class
class_identifier: visibility CLASS CLASS_NAME CURLY_BRACKET_LEFT {printf("CLASS %s IDENTIFIED\n",$3);}class_body CURLY_BRACKET_RIGHT { create_end_class();printf("END OF CLASS %s\n",$3);}


// !! Double Check if class members before of functions
class_body: %empty |  functions class_body
	               |  class_members class_body // intitalisation class_body
                   |  class_identifier class_body ;
	        
class_members:   data_initialization SEMICOLON |   data_assignment SEMICOLON | member_access SEMICOLON;
// For the 2nd Version we need to recognise: int var = INT_Number exc.

//initialisation: data_init | function_init;
visibility:  %empty { $$ = 0; } | PUBLIC { $$ = 1; } | PRIVATE { $$ = 0; } ;


data_initialization:  visibility  INT  int_init next_int {data_initiliazation(classes[top_class-1]->stack,classes[top_class-1]->top_data,$1,"int",$3); fix_visibility(classes[top_class-1]->stack,classes[top_class-1]->top_data,var_counter, $1);} |
                          visibility  DOUBLE  double_init next_double { data_initiliazation(classes[top_class-1]->stack,classes[top_class-1]->top_data,$1,"double",$3);  fix_visibility(classes[top_class-1]->stack,classes[top_class-1]->top_data,var_counter, $1); }|
                          visibility  CHAR char_init next_char   { data_initiliazation(classes[top_class-1]->stack,classes[top_class-1]->top_data,$1,"char",$3);  fix_visibility(classes[top_class-1]->stack,classes[top_class-1]->top_data,var_counter, $1);}   |
                          visibility  BOOLEAN  bool_init next_bool  { data_initiliazation(classes[top_class-1]->stack,classes[top_class-1]->top_data,$1,"boolean",$3);  fix_visibility(classes[top_class-1]->stack,classes[top_class-1]->top_data,var_counter, $1);} |
                          visibility  STRING  string_init next_string { data_initiliazation(classes[top_class-1]->stack,classes[top_class-1]->top_data,$1,"String",$3);  fix_visibility(classes[top_class-1]->stack,classes[top_class-1]->top_data,var_counter, $1);};

next_int: %empty    | COMMA int_init next_int {data_initiliazation(classes[top_class-1]->stack,classes[top_class-1]->top_data,0,"int",$2); var_counter ++; };
next_double: %empty | COMMA double_init next_double;
next_char: %empty   | COMMA char_init next_char;
next_bool: %empty   | COMMA bool_init next_bool;
next_string: %empty | COMMA string_init next_string;

int_init: VAR_NAME {$$ = $1;}   | VAR_NAME EQUAL_SIGN INT_VALUE {printf("int %s = %d",$1,$3); $$ = $1;};
double_init: VAR_NAME {$$ = $1;} | VAR_NAME EQUAL_SIGN DOUBLE_VALUE {printf("double %s = %f",$1,$3); $$ = $1;};
char_init: VAR_NAME  {$$ = $1;} | VAR_NAME EQUAL_SIGN CHAR_VALUE {printf("char %s = '%c'",$1,$3); $$ = $1;};
bool_init: VAR_NAME   {$$ = $1;}| VAR_NAME EQUAL_SIGN BOOLEAN_VALUE {printf("bool %s = %s",$1,$3); $$ = $1;};
string_init: VAR_NAME {$$ = $1;}| VAR_NAME EQUAL_SIGN STRING_VALUE {printf("char* %s = %s",$1,$3); $$ = $1;} ;

// This is NEW
data_assignment:  VAR_NAME EQUAL_SIGN expression {  if (find_data_access(classes[top_class-1]->stack,classes[top_class-1]->top_data,$1) == -1)
                                                        {   
                                                            yyerror("data out of scope !!");
                                                            exit(0);
                                                        }
                                                        printf("succesfull var access\n");
                                                        };

expression: expression PLUS term  { printf("\n addition \n");} |expression MINUS term |  BRACKET_LEFT expression  BRACKET_RIGHT | term  ;
term:  term MULTIPLY id  { printf("\nmul\n");} | term DIVIDE id | BRACKET_LEFT term BRACKET_RIGHT | BRACKET_LEFT expression BRACKET_RIGHT | id  ;
id: data_value  | VAR_NAME |  BRACKET_LEFT id  BRACKET_RIGHT | BRACKET_LEFT expression BRACKET_RIGHT;



data_type: INT { $$ = "int"; }  
              |DOUBLE { $$ = "double";}
              |CHAR { $$ = "char";}
              |BOOLEAN {$$ = "boolean";}
              |STRING {$$ = "String";};

data_value:  INT_VALUE | CHAR_VALUE | DOUBLE_VALUE | BOOLEAN_VALUE | STRING_VALUE ;

//Class Instance
class_instance: CLASS_NAME VAR_NAME EQUAL_SIGN NEW CLASS_NAME BRACKET_LEFT BRACKET_RIGHT ;
member_access: VAR_NAME DOT VAR_NAME ; //End Class Instance


// Functions
functions: function_visibility VOID VAR_NAME BRACKET_LEFT arguments BRACKET_RIGHT CURLY_BRACKET_LEFT{function_counter++; printf("Function %s is identified\n"),$3;} inside_void_function CURLY_BRACKET_RIGHT  { printf("END OF Function\n"); delete_function_vars();function_initiliazation(classes[top_class-1]->functions,classes[top_class-1]->top_func,$1,"void",$3);}
         | function_visibility data_type VAR_NAME BRACKET_LEFT arguments BRACKET_RIGHT CURLY_BRACKET_LEFT{function_counter++; printf("Function %s is identified\n",$3);} inside_function CURLY_BRACKET_RIGHT  { printf("END OF Function\n"); delete_function_vars();function_initiliazation(classes[top_class-1]->functions,classes[top_class-1]->top_func,$1,$2,$3);};
function_visibility: PRIVATE {$$ = 0;} | PUBLIC { $$ = 1;};

arguments : %empty| parameters
parameters: data_type VAR_NAME arguments_end
arguments_end : %empty | COMMA parameters 

inside_void_function: inside_brackets | inside_brackets RETURN SEMICOLON ;
inside_function: inside_brackets  RETURN VAR_NAME SEMICOLON  | inside_brackets RETURN data_value SEMICOLON ;
// End Functions

// !! Ambiguity !!
inside_brackets: %empty | loops_n_condition inside_brackets | data_initialization  SEMICOLON inside_brackets | data_assignment SEMICOLON inside_brackets | class_instance SEMICOLON inside_brackets |member_access SEMICOLON inside_brackets ;



loops_n_condition: for_statement | switch | do_while | if  ; // + Δήλωση Μεταβλητών

// For Loop
for_statement:  FOR BRACKET_LEFT for_condition BRACKET_RIGHT CURLY_BRACKET_LEFT inside_brackets CURLY_BRACKET_RIGHT  {printf("\n For is identified\n");};
for_condition:  for_data SEMICOLON for_comparison SEMICOLON for_step ;

for_data: %empty | data_type VAR_NAME EQUAL_SIGN data_value  ;

for_comparison: %empty | VAR_NAME CONDITION_SYMBOL comparison_value for_bool_operator;
comparison_value: INT_VALUE | DOUBLE_VALUE | CHAR_VALUE | BOOLEAN_VALUE | VAR_NAME ;
for_bool_operator:  %empty | BOOL_SYMBOL for_comparison;

for_step : %empty | VAR_NAME step ;
step: INCREAMENT_DECREAMENT | LOOP_STEP step_value;
step_value: INT_VALUE | DOUBLE_VALUE ;
// End For Loop

// DO While Loop 
do_while: DO CURLY_BRACKET_LEFT inside_brackets CURLY_BRACKET_RIGHT  WHILE BRACKET_LEFT do_condition BRACKET_RIGHT SEMICOLON {printf("\n Do While is identified\n");};
do_condition: operand CONDITION_SYMBOL operand do_bool_operator| BOOLEAN_VALUE | VAR_NAME;
do_bool_operator: %empty | BOOL_SYMBOL do_condition;
operand: VAR_NAME | INT_VALUE | DOUBLE_VALUE | CHAR_VALUE | BOOLEAN_VALUE ;
// End While Loopo

// Switch  
switch: SWITCH BRACKET_LEFT VAR_NAME BRACKET_RIGHT CURLY_BRACKET_LEFT case default CURLY_BRACKET_RIGHT {printf("\n Switch\n");};
case: CASE switch_value COLON switch_content case
      |%empty

switch_value: INT_VALUE | CHAR_VALUE ;
switch_content: %empty | /*ACTUAL CONTENT*/ BREAK SEMICOLON;

default: DEFAULT COLON switch_content ;
         |%empty
         
// End Switch

// IF 
if: IF BRACKET_LEFT if_condition BRACKET_RIGHT CURLY_BRACKET_LEFT inside_brackets CURLY_BRACKET_RIGHT else_if{printf("\n If is identified\n");};
else_if: %empty | ELSE IF BRACKET_LEFT if_condition BRACKET_RIGHT CURLY_BRACKET_LEFT  inside_brackets CURLY_BRACKET_RIGHT else_if {printf("else if \n");} | else {printf("\n If is identified\n");};
else: ELSE CURLY_BRACKET_LEFT  inside_brackets CURLY_BRACKET_RIGHT {printf("\n Else is identified\n");};     
if_condition: operand  CONDITION_SYMBOL operand if_bool_operator| BOOLEAN_VALUE | VAR_NAME {printf("\n If Condition is identified\n");};
if_bool_operator: %empty | BOOL_SYMBOL if_condition;

         
// End Switch
            
%%

int main(void)
{
    yyparse();
}

void yyerror(const char *s)
{
    printf("Error: %s\n",s);
}