%{
  #include <stdio.h>
  #include <string.h>
  #include "sqlsave.h"
  extern char * yytext;
  extern char buf[1024];
  extern char * buffer;
%}

%union{
  int    val ;
  char * sval;
}

%token <sval> NAME 
%token STRING
%token APPROXNUM INTNUM

%token ALL AMMSC ANY AS ASC AUTHORIZATION BETWEEN BY
%token CHARACTER CHECK CLOSE COMMIT CONTINUE CREATE CURRENT
%token CURSOR DECIMAL DECLARE DEFAULT DELETE DESC DISTINCT DOUBLE
%token ESCAPE EXISTS FETCH FLOAT FOR FOREIGN FOUND FROM GOTO
%token GRANT GROUP HAVING IN INDICATOR INSERT INTEGER INTO
%token IS KEY LANGUAGE LIKE MODULE NULLX NUMERIC OF ON
%token OPEN OPTION ORDER PRECISION PRIMARY PRIVILAGES PROCEDURE
%token PUBLIC REAL REFERENCE ROLLBACK SCHEMA SELECT SET
%token SMALLINT SOME SQLCODE SQLERROR TABLE TO UNION
%token UNIQUE UPDATE USER VALUES VIEW WHENEVER WHERE WITH WORK


%token SEMICOLON REA LPAR RPAR REFERENCES COMMA STAR POINT PARAMETER


%left <sval> OR
%left <sval> AND
%left <sval> NOT
%left <sval> COMPARISON
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS

%%
  sql_list : sql SEMICOLON
	     { printsql(); }
	   | sql_list sql SEMICOLON
	   ;
  sql      : schema
	   ;
  schema   : CREATE SCHEMA AUTHORIZATION user
	     opt_schema_element_list
	   ;
  opt_schema_element_list : 
			  | schema_element_list 
			  ;
  schema_element_list : schema_element
		      | schema_element_list schema_element
                      ;
  schema_element : base_table_def
		 | view_def
		 | privilage_def
		 ;
  base_table_def : CREATE TABLE table LPAR base_table_element_commalist RPAR
		 ;
  base_table_element_commalist : base_table_element
                               | base_table_element_commalist COMMA base_table_element
			       ;
  base_table_element : column_def
		     | table_constraint_def
		     ;
  column_def : column data_type column_def_opt_list
	     ;
  column_def_opt_list :
		      | column_def_opt_list column_def_opt 
		      ;
  column_def_opt : NOT NULLX
		 | NOT NULLX UNIQUE
		 | NOT NULLX PRIMARY KEY
		 | DEFAULT literal
		 | DEFAULT NULLX
		 | DEFAULT USER
		 | CHECK LPAR search_condition RPAR
	         | REFERENCES table
		 | REFERENCES table LPAR column_commalist RPAR
		 ;
  table_constraint_def : UNIQUE LPAR column_commalist RPAR
		       | PRIMARY KEY LPAR column_commalist RPAR
		       | FOREIGN KEY LPAR column_commalist RPAR 
			 REFERENCES table
		       | FOREIGN KEY LPAR column_commalist RPAR
			 REFERENCES table LPAR column_commalist RPAR
		       | CHECK LPAR search_condition RPAR
		       ;
  column_commalist : column
		   | column_commalist COMMA column
		   ;
  view_def : CREATE VIEW table opt_column_commalist
	     AS query_spec opt_with_check_option
	   ;
  opt_with_check_option :
			| WITH CHECK OPTION
			;
  opt_column_commalist :
		       | LPAR column_commalist RPAR
                       ;
  privilage_def : GRANT privilages ON table TO grantee_commalist
		  opt_with_grant_option
		;
  opt_with_grant_option :
		        | WITH GRANT OPTION
			;
  privilages : ALL PRIVILAGES
	     | ALL
	     | operation_commalist
	     ;
  operation_commalist : operation
		      | operation_commalist COMMA operation
		      ;
  operation : SELECT
	    | INSERT
	    | DELETE
	    | UPDATE opt_column_commalist
	    | REFERENCES opt_column_commalist
	    ;
  grantee_commalist : grantee
		    | grantee_commalist COMMA grantee
		    ;
  grantee : PUBLIC
	  | user
	  ;
  sql : cursor_def
      ;
  cursor_def : DECLARE cursor CURSOR FOR query_exp opt_order_by_clause
	     ;
  opt_order_by_clause :
		      | ORDER BY ordering_spec_commalist
		      ;
  ordering_spec_commalist : ordering_spec
			  | ordering_spec_commalist COMMA ordering_spec
			  ;
  ordering_spec : INTNUM opt_asc_desc
	        | column_ref opt_asc_desc
		;
  opt_asc_desc :
	       | ASC
	       | DESC
	       ;
  sql : manipulative_statement
      ;
  manipulative_statement : close_statement
		         | commit_statement
		         | delete_statement_positioned
			 | delete_statement_searched
		         | fetch_statement
			 | insert_statement
		         | open_statement
		         | rollback_statement
		         | select_statement
		         | update_statement_positioned
			 | update_statement_searched
			 ;
  close_statement : CLOSE cursor
		  ;
  commit_statement: COMMIT WORK
		  ;
  delete_statement_positioned : DELETE FROM table WHERE CURRENT OF cursor
			      ;
  delete_statement_searched : DELETE FROM table opt_where_clause
			    ;
  fetch_statement : FETCH cursor INTO target_commalist
		  ;
  insert_statement: INSERT INTO table opt_column_commalist values_or_query_spec
		  ;
  values_or_query_spec : VALUES LPAR insert_atom_commalist RPAR
		       | query_spec
		       ;
  insert_atom_commalist : insert_atom
		        | insert_atom_commalist COMMA insert_atom
			;
  insert_atom : atom
	      | NULLX
	      ;
  open_statement : OPEN cursor
		 ;
  rollback_statement : ROLLBACK WORK
		     ;
  select_statement : SELECT opt_all_distinct selection table_exp
		   | SELECT opt_all_distinct selection 
		     INTO target_commalist table_exp
		   ;
  opt_all_distinct :
		   | ALL
		   | DISTINCT
		   ;
  update_statement_positioned : UPDATE table SET assignment_commalist
				WHERE CURRENT OF cursor
			      ;
  assignment_commalist : assignment
		       | assignment_commalist COMMA assignment
		       ;
  assignment : column '=' scalar_exp
	     | column '=' NULLX
	     ;
  update_statement_searched : UPDATE table SET assignment_commalist opt_where_clause
			    ;
  target_commalist : target
		   | target_commalist COMMA target
		   ;
  target : parameter_ref
	 ;
  opt_where_clause :
		   | where_clause
		   ;
  query_exp : query_term
	    | query_exp UNION query_term
	    | query_exp UNION ALL query_term
	    ;
  query_term : query_spec
             | LPAR query_exp RPAR
	     ;
  query_spec : SELECT opt_all_distinct selection table_exp
	     ;
  selection  : scalar_exp_commalist
             | STAR
	     ;
  table_exp  : from_clause		
               opt_where_clause		
               opt_group_by_clause	
	       opt_having_clause
	     ;
  from_clause : FROM table_ref_commalist
	      ;
  table_ref_commalist : table_ref
		      | table_ref_commalist COMMA table_ref 
		      ;
  table_ref : table
	    | table range_variable
	    ;
  where_clause : WHERE search_condition
	       ;
  opt_group_by_clause :
		      | GROUP BY column_ref_commalist
		      ;
  column_ref_commalist : column_ref
		       | column_ref_commalist COMMA column_ref
		       ;
  opt_having_clause :
		    | HAVING search_condition
		    ;
  search_condition :
		   | search_condition OR search_condition
		   | search_condition AND search_condition
		   | NOT search_condition
		   | LPAR search_condition RPAR
		   | predicate
		   ;
  predicate : comparison_predicate
	    | between_predicate
	    | like_predicate
	    | test_for_null
	    | in_predicate
	    | all_or_any_predicate
	    | existence_test
	    ;
  comparison_predicate : scalar_exp COMPARISON scalar_exp
		       | scalar_exp COMPARISON subquery
		       ;
  between_predicate : scalar_exp NOT BETWEEN scalar_exp AND scalar_exp
		    | scalar_exp BETWEEN scalar_exp AND scalar_exp
		    ;
  like_predicate : scalar_exp NOT LIKE atom opt_escape
	         | scalar_exp LIKE atom opt_escape
		 ;
  opt_escape :
	     | ESCAPE atom
	     ;
  test_for_null : column_ref IS NOT NULLX
	        | column_ref IS NULLX
	        ;
  in_predicate : scalar_exp NOT IN LPAR subquery RPAR 
	       | scalar_exp IN LPAR subquery RPAR
	       | scalar_exp NOT IN LPAR atom_commalist RPAR
	       | scalar_exp IN LPAR atom_commalist RPAR
	       ;
  atom_commalist : atom
		 | atom_commalist COMMA atom
		 ;
  all_or_any_predicate : scalar_exp COMPARISON any_all_some subquery
		       ;
  any_all_some : ANY
	       | ALL
	       | SOME
	       ;
  existence_test : EXISTS subquery
		 ;

  subquery   : LPAR SELECT opt_all_distinct selection table_exp RPAR
	     ;
  scalar_exp : scalar_exp '+' scalar_exp
             | scalar_exp '-' scalar_exp
	     | scalar_exp '*' scalar_exp
	     | scalar_exp '/' scalar_exp
	     | '+' scalar_exp %prec UMINUS
	     | '-' scalar_exp %prec UMINUS
	     | atom
	     | column_ref
	     | function_ref
	     | LPAR scalar_exp RPAR
	     ;
  scalar_exp_commalist : scalar_exp 
		       | scalar_exp_commalist COMMA scalar_exp 
		       ;
  atom : parameter_ref
       | literal
       | USER
       ;

  parameter_ref : parameter
		| parameter parameter
		| parameter INDICATOR parameter
		;
  function_ref : AMMSC LPAR STAR RPAR
	       | AMMSC LPAR DISTINCT column_ref RPAR
	       | AMMSC LPAR ALL scalar_exp RPAR
	       | AMMSC LPAR scalar_exp RPAR
	       ;
  literal : STRING
	  | INTNUM
	  | APPROXNUM
	  ;
  
  table : NAME
	  {
	    change(buffer,"<name>",__TABLE_R);
	    save($1,__TABLE);
	  }
        | NAME POINT NAME
	;
  column_ref : NAME
		{
		  change(buffer,"<name>",__COLUMN_REF_R);
		  save($1,__COLUMN_REF);
		}
	     | NAME POINT NAME
	     | NAME POINT NAME POINT NAME
             ;
  data_type : CHARACTER
	    | CHARACTER LPAR INTNUM RPAR
	    | NUMERIC
	    | NUMERIC LPAR INTNUM RPAR
	    | NUMERIC LPAR INTNUM COMMA INTNUM RPAR
	    | DECIMAL
	    | DECIMAL LPAR INTNUM RPAR
	    | DECIMAL LPAR INTNUM COMMA INTNUM RPAR
	    | INTEGER
	    | SMALLINT
	    | FLOAT
	    | FLOAT LPAR INTNUM RPAR
	    | REA
	    | DOUBLE PRECISION
	    ;
  column : NAME
	   {
	      change(buffer,"<name>",__COLUMN_R);
	      save($1,__COLUMN);
	   }
	 ;
  cursor : NAME
	   {
	      change(buffer,"<name>",__CURSOR_R);
	      save($1,__CURSOR);
	   }
	 ;
  parameter : PARAMETER
	    ;
  range_variable : NAME
		 ;
  user : NAME
       ;
%%
