%{

    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    int yylex();
    void yyerror(const char *s);

    int var_counter = 0;
    

    typedef struct variable
    {
        char *name;
        char *type;
        char *value;
        int visibility;
        int inside_function;//bool value 
        int class_level;
    } variable; 

    typedef struct function
    {
        char *name;
        char *return_type;
        int visibility;  
        int class_level;
    } function;

    typedef struct class
    {
        char *name;
        int visibility;  
        variable * stack[100];
        function * functions[100];
        struct class * inner[10];
        int top_var;
        int top_func ;
        int class_level;
    } class;

    class * classes[100];
    int top_class=0;
    int class_level=0;
    int function_counter=0;
    /*Class Recognition*/
    
    class * create_class(int visibility, char *name)
    {
        printf("Creating class\n");
         class* v = ( class *)malloc(sizeof( class));
        v->name = strdup(name); // strdup is used to copy the string
        v->visibility = visibility;
        v->top_var=0;
        v->top_func=0;
       v->class_level=class_level;
        return v;
    }

    void delete_inner_classes(){
        printf("BEFORE INNER CLASS DELETION\n");
        print_program();
        for(int i=top_class-1;i>class_level;i--)
            pop_class();
        class_level--;
        printf("AFTER INNER CLASS DELETION\n");
        print_program();
    }

    void print_program(){
        printf("PROGRAM\n");
        print_stack_classes();
        for(int i=0;i<top_class;i++){
            printf("----%d-Class %s----\n",i,classes[i]->name);
            print_stack_variable(classes[i]->stack,classes[i]->top_var);
            print_stack_functions(classes[i]->functions,classes[i]->top_func);
        }
    }

     void print_class(class *c)
    {
        printf("  Name: %s, Visibility: %d\n", c->name, c->visibility);
    }

    void print_stack_classes()
    {
        printf("Class Stack:\n");
        for(int i = 0; i < top_class; i++)
            print_class(classes[i]);
    }

    int find_classes(char *name)
    {
        for(int i = 0; i < top_class; i++)
        {
            if(strcmp(classes[i]->name, name) == 0 && classes[i]->class_level==class_level)
            {
                print_class(classes[i]);
                return i;
            }
        }
        return -1;
    }

    void push_class(class *v)
    {   
        classes[top_class] = v;
        top_class++;
    }

    void pop_class()
    {
        while(classes[top_class-1]->top_var>0)
            pop_var();
        while(classes[top_class-1]->top_func>0)
            pop_function();
        free(classes[top_class-1]);
        top_class--;
    }
    

    void class_initiliazation(int visibility , char *name)
    {
        if (find_classes(name) != -1)
        {   
            char *msg;
            yyerror("Class has been initialized");
            printf("!!! Class: %s has been initialized with visibility: %d !!!\n", name, visibility);
            exit(0);
        }
        else
        {
            class* var = create_class(visibility, name);
            if (class_level==0)
                push_class(var);
           // print_stack_classes();
        }
    }
    
    /* Functions Recognition */ 

    function * create_function(int visibility, char *return_type, char *name)
    {
        function *v = (function *)malloc(sizeof(function));
        v->name = strdup(name); // strdup is used to copy the string
        v->return_type = return_type; 
        v->visibility = visibility;
        return v;
    }

    void print_function(function *f)
    {
        printf("Name: %s, Return Type: %s, Visibility: %d\n", f->name, f->return_type, f->visibility);
    }

    void print_stack_functions(function* functions[],int top_func)
    {
        printf("Function stack...\n");
        for(int i = 0; i < top_func; i++)
            print_function(functions[i]);
         printf("-------------------\n");
    }

    int find_functions(function* functions[],int top_func,char *name)
    {
        for(int i = 0; i < top_func; i++)
        {
            if(strcmp(functions[i]->name, name) == 0)
            {
                print_function(functions[i]);
                return i;
            }
        }
        return -1;
    }

    void push_function(class* c,function *f)
    {   
        c->functions[c->top_func] = f;
        c->top_func++;
    }

    void pop_function(class* c)
    {
        c->top_func--;
        free(c->functions[c->top_func]);
    }
    

    void function_initiliazation(function* functions[],int top_func , int visibility , char *return_type, char *name)
    {
        if (find_functions(functions,top_func,name) > 0)
        {   
            char *msg;
            yyerror("Variable has been initialized");
            printf("!!! Variable: %s has been initialized with type: %s !!!\n", name, return_type);
            exit(0);
        }
        else
        {
            function* var = create_function(visibility, return_type, name); 
           // print_function(var);
            push_function(var);
           // print_stack_functions(classes[top_class-1]->functions,classes[top_class-1]->top_func);
        }
    }
    
   
    
     /* Variables Recognition */ 

    variable * create_variable(int visibility, char *type, char *name)
    {
        printf("Creating variable...\n");
        variable *v = (variable *)malloc(sizeof(variable));
        v->name = strdup(name); // strdup is used to copy the string
        v->type = type; 
        // v->value = value;
        v->visibility = visibility;
        v->inside_function = function_counter;
        return v;
    }

    void push_var(class* c,variable *v)
    {
        c->stack[c->top_var++] = v;
    }

    void pop_var(class* c)
    {   
        c->top_var--;
        free (c->stack[c->top_var]);
    }

    void print_stack_variable(variable* stack[],int top_var)
    {
        printf("Variable stack \n");
        for(int i = 0; i < top_var; i++)
            print_variable(stack[i]);
         printf("-------------------\n");
    }


    void print_variable(variable *v)
    {
        printf("Name: %s, Type: %s, Value: %s, Visibility: %d , inside_function: %d\n", v->name, v->type, v->value, v->visibility,v->inside_function);
    }

    int find_variable_access(variable* stack[],int top_var,char *name){
        for(int i = 0; i < top_var; i++)
        {
            if(strcmp(stack[i]->name, name) == 0)
            {
                print_variable(stack[i]);
                return i;
            }
        }
        return -1;
    }
    int find_variable_initialize(variable* stack[],int top_var,char *name)
    {
        for(int i = 0; i < top_var; i++)
        {
            if(strcmp(stack[i]->name, name) == 0 && stack[i]->inside_function == function_counter)
            {
                print_variable(stack[i]);
                return i;
            }
        }
        return -1;
    }

    void delete_function_vars(class* c){
         printf("BEFORE FUNCTION VAR DELETION\n");
        print_stack_variable( c->stack,c->top_var);

        while(c->top_var != 0  && c->stack[c->top_var-1]->inside_function == function_counter ){
           pop_var(c);
        }
        function_counter--;

        printf("AFTER FUNCTION VAR DELETION\n");
        print_stack_variable( c->stack,c->top_var);
        return;
    }


    void variable_initiliazation(class *c,int visibility , char *type, char *name)
    {
        if (find_variable_initialize(c->stack,c->top_var,name) != -1)
        {   
            char *msg;
            yyerror("Variable has been initialized");
            printf("!!! Variable: %s has been initialized with type: %s !!!\n", name, type);
            exit(0);
        }
        else
        {
            variable* var = create_variable(visibility, type, name); 
            //print_variable(var);
            push_var(c,var);
           // print_stack_variable( c->stack,c->top_var);
        }
    }

    void fix_visibility(variable* stack[],int top_var,int count, int visibility)
    {
        while (count != 0)
        {
            stack[top_var - 1 - count]->visibility = visibility;
            count --;
        }
      //  print_stack_variable();
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

//Variable Types
%type <sval> int_init;
%type <sval> double_init;
%type <sval> char_init;
%type <sval> bool_init;
%type <sval> string_init;

%type <sval> variable_assignment
%type <sval> variable_type

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

//Variable Values
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
class_identifier: visibility CLASS CLASS_NAME CURLY_BRACKET_LEFT {printf("CLASS %s IDENTIFIED\n",$3);class_initiliazation($1,$3);class_level++;}class_body CURLY_BRACKET_RIGHT { class_level--;printf("END OF CLASS %s\n",$3);}


// !! Double Check if class members before of functions
class_body: %empty |  functions class_body
	               |  class_members class_body // intitalisation class_body
                   |  class_identifier class_body ;
	        
class_members:   variable_initialization SEMICOLON |   variable_assignment SEMICOLON | member_access SEMICOLON;
// For the 2nd Version we need to recognise: int var = INT_Number exc.

//initialisation: variable_init | function_init;
visibility:  %empty { $$ = 0; } | PUBLIC { $$ = 1; } | PRIVATE { $$ = 0; } ;


variable_initialization:  visibility  INT  int_init next_int {variable_initiliazation(classes[top_class-1]->stack,classes[top_class-1]->top_var,$1,"int",$3); fix_visibility(classes[top_class-1]->stack,classes[top_class-1]->top_var,var_counter, $1);} |
                          visibility  DOUBLE  double_init next_double { variable_initiliazation(classes[top_class-1]->stack,classes[top_class-1]->top_var,$1,"double",$3);  fix_visibility(classes[top_class-1]->stack,classes[top_class-1]->top_var,var_counter, $1); }|
                          visibility  CHAR char_init next_char   { variable_initiliazation(classes[top_class-1]->stack,classes[top_class-1]->top_var,$1,"char",$3);  fix_visibility(classes[top_class-1]->stack,classes[top_class-1]->top_var,var_counter, $1);}   |
                          visibility  BOOLEAN  bool_init next_bool  { variable_initiliazation(classes[top_class-1]->stack,classes[top_class-1]->top_var,$1,"boolean",$3);  fix_visibility(classes[top_class-1]->stack,classes[top_class-1]->top_var,var_counter, $1);} |
                          visibility  STRING  string_init next_string { variable_initiliazation(classes[top_class-1]->stack,classes[top_class-1]->top_var,$1,"String",$3);  fix_visibility(classes[top_class-1]->stack,classes[top_class-1]->top_var,var_counter, $1);};

next_int: %empty    | COMMA int_init next_int {variable_initiliazation(classes[top_class-1]->stack,classes[top_class-1]->top_var,0,"int",$2); var_counter ++; };
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
variable_assignment:  VAR_NAME EQUAL_SIGN expression {  if (find_variable_access(classes[top_class-1]->stack,classes[top_class-1]->top_var,$1) == -1)
                                                        {   
                                                            yyerror("Variable out of scope !!");
                                                            exit(0);
                                                        }
                                                        printf("succesfull var access\n");
                                                        };

expression: expression PLUS term  { printf("\n addition \n");} |expression MINUS term |  BRACKET_LEFT expression  BRACKET_RIGHT | term  ;
term:  term MULTIPLY id  { printf("\nmul\n");} | term DIVIDE id | BRACKET_LEFT term BRACKET_RIGHT | BRACKET_LEFT expression BRACKET_RIGHT | id  ;
id: variable_value  | VAR_NAME |  BRACKET_LEFT id  BRACKET_RIGHT | BRACKET_LEFT expression BRACKET_RIGHT;



variable_type: INT { $$ = "int"; }  
              |DOUBLE { $$ = "double";}
              |CHAR { $$ = "char";}
              |BOOLEAN {$$ = "boolean";}
              |STRING {$$ = "String";};

variable_value:  INT_VALUE | CHAR_VALUE | DOUBLE_VALUE | BOOLEAN_VALUE | STRING_VALUE ;

//Class Instance
class_instance: CLASS_NAME VAR_NAME EQUAL_SIGN NEW CLASS_NAME BRACKET_LEFT BRACKET_RIGHT ;
member_access: VAR_NAME DOT VAR_NAME ; //End Class Instance


// Functions
functions: function_visibility VOID VAR_NAME BRACKET_LEFT arguments BRACKET_RIGHT CURLY_BRACKET_LEFT{function_counter++; printf("Function %s is identified\n"),$3;} inside_void_function CURLY_BRACKET_RIGHT  { printf("END OF Function\n"); delete_function_vars();function_initiliazation(classes[top_class-1]->functions,classes[top_class-1]->top_func,$1,"void",$3);}
         | function_visibility variable_type VAR_NAME BRACKET_LEFT arguments BRACKET_RIGHT CURLY_BRACKET_LEFT{function_counter++; printf("Function %s is identified\n",$3);} inside_function CURLY_BRACKET_RIGHT  { printf("END OF Function\n"); delete_function_vars();function_initiliazation(classes[top_class-1]->functions,classes[top_class-1]->top_func,$1,$2,$3);};
function_visibility: PRIVATE {$$ = 0;} | PUBLIC { $$ = 1;};

arguments : %empty| parameters
parameters: variable_type VAR_NAME arguments_end
arguments_end : %empty | COMMA parameters 

inside_void_function: inside_brackets | inside_brackets RETURN SEMICOLON ;
inside_function: inside_brackets  RETURN VAR_NAME SEMICOLON  | inside_brackets RETURN variable_value SEMICOLON ;
// End Functions

// !! Ambiguity !!
inside_brackets: %empty | loops_n_condition inside_brackets | variable_initialization  SEMICOLON inside_brackets | variable_assignment SEMICOLON inside_brackets | class_instance SEMICOLON inside_brackets |member_access SEMICOLON inside_brackets ;



loops_n_condition: for_statement | switch | do_while | if  ; // + Δήλωση Μεταβλητών

// For Loop
for_statement:  FOR BRACKET_LEFT for_condition BRACKET_RIGHT CURLY_BRACKET_LEFT inside_brackets CURLY_BRACKET_RIGHT  {printf("\n For is identified\n");};
for_condition:  for_variable SEMICOLON for_comparison SEMICOLON for_step ;

for_variable: %empty | variable_type VAR_NAME EQUAL_SIGN variable_value  ;

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