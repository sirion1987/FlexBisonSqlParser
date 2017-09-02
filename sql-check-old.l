%{
  #include "sql-check2.tab.h"
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include <ctype.h>
  extern char * buffer;
  int lineno = 1 ;
  char buf[200] ;
  //extern char * yytext;

  #define SAVEKEY(name)	{ sprintf(buf,"<a class=\"token\">%s</a>",yytext);\
			  save_buffer(buf);\
			  return name;	\
			}
  #define SAVETOK(name)	{ save_buffer(yytext); return name; }
  #define SAVENAME	{ save_buffer("<name>"); return NAME;}

%}

%%
  /* reserved word */
ALL 		SAVEKEY(ALL)
AMMSC 		SAVEKEY(AMMSC)
ANY 		SAVEKEY(ANY)
AS 		SAVEKEY(AS)
ASC 		SAVEKEY(ASC)
AUTHORIZATION 	SAVEKEY(AUTHORIZATION)
BETWEEN 	SAVEKEY(BETWEEN)
BY		SAVEKEY(BY)
CHAR(ACTER)? 	SAVEKEY(CHARACTER)
CHECK		SAVEKEY(CHECK)
CLOSE 		SAVEKEY(CLOSE)
COMMIT 		SAVEKEY(COMMIT)
CONTINUE	SAVEKEY(CONTINUE)
CREATE 		SAVEKEY(CREATE)
CURRENT		SAVEKEY(CURRENT)
CURSOR 		SAVEKEY(CURSOR)
DECIMAL 	SAVEKEY(DECIMAL)	
DECLARE 	SAVEKEY(DECLARE)
DEFAULT 	SAVEKEY(DEFAULT)
DELETE 		SAVEKEY(DELETE)
DESC 		SAVEKEY(DESC)	
DISTINCT 	SAVEKEY(DISTINCT)
DOUBLE		SAVEKEY(DOUBLE)
ESCAPE 		SAVEKEY(ESCAPE)
EXISTS 		SAVEKEY(EXISTS)
FETCH 		SAVEKEY(FETCH)
FLOAT 		SAVEKEY(FLOAT)
FOR 		SAVEKEY(FOR)
FOREIGN 	SAVEKEY(FOREIGN)
FOUND 		SAVEKEY(FOUND)
FROM 		SAVEKEY(FROM)
GO[ \t]*TO 	SAVEKEY(GOTO)
GRANT 		SAVEKEY(GRANT)
GROUP 		SAVEKEY(GROUP)
HAVING 		SAVEKEY(HAVING)
IN 		SAVEKEY(IN)
INDICATOR 	SAVEKEY(INDICATOR)
INSERT 		SAVEKEY(INSERT)
INT(EGER)?	SAVEKEY(INTEGER)
INTO		SAVEKEY(INTO)
IS 		SAVEKEY(IS)
KEY 		SAVEKEY(KEY)
LANGUAGE 	SAVEKEY(LANGUAGE)
LIKE 		SAVEKEY(LIKE)
MODULE 		SAVEKEY(MODULE)
NULLX 		SAVEKEY(NULLX)
NUMERIC 	SAVEKEY(NUMERIC)
OF 		SAVEKEY(OF)
ON		SAVEKEY(ON)
OPEN 		SAVEKEY(OPEN)
OPTION 		SAVEKEY(OPTION)
ORDER 		SAVEKEY(ORDER)
PRECISION 	SAVEKEY(PRECISION)
PRIMARY 	SAVEKEY(PRIMARY)
PRIVILAGES 	SAVEKEY(PRIVILAGES)
PROCEDURE 	SAVEKEY(PROCEDURE)
PUBLIC 		SAVEKEY(PUBLIC)
REAL 		SAVEKEY(REAL)
REFERENCE 	SAVEKEY(REFERENCES) 
ROLLBACK 	SAVEKEY(ROLLBACK)
SCHEMA		SAVEKEY(SCHEMA)
SELECT 		SAVEKEY(SELECT)
SET		SAVEKEY(SET)
SMALLINT 	SAVEKEY(SMALLINT)
SOME 		SAVEKEY(SOME)
SQLCODE 	SAVEKEY(SQLCODE)
SQLERROR 	SAVEKEY(SQLERROR)
TABLE 		SAVEKEY(TABLE)
TO		SAVEKEY(TO)
UNION		SAVEKEY(UNION)	
UNIQUE 		SAVEKEY(UNIQUE)
UPDATE 		SAVEKEY(UPDATE)
USER 		SAVEKEY(USER)
VALUES 		SAVEKEY(VALUES)
VIEW 		SAVEKEY(VIEW)
WHENEVER	SAVEKEY(WHENEVER)
WHERE 		SAVEKEY(WHERE)
WITH 		SAVEKEY(WITH)
WORK		SAVEKEY(WORK)

\(	{ save_buffer("(");return LPAR; }
\)	{ save_buffer(")");return RPAR; }
\,	{ save_buffer(",");return COMMA;}
;	{ save_buffer(";");return SEMICOLON;}
\*	{ save_buffer("*");return STAR;}
\.	{ save_buffer(".");return POINT; }

  /* puntaction */
"="  |
"<>" |
">"  |
"<"  |
"<=" |
">="	SAVETOK(COMPARISON)

  /* names */
[a-zA-Z][a-zA-Z0-9_]*	{ /*yylval.sval = strdup(yytext); return NAME;*/ 
			  yylval.sval = strdup(yytext);SAVENAME
			}

  /* number */
[0-9]* |
[0-9]*"."[0-9]* SAVETOK(INTNUM)
  /*"."[0-9]**/ 

[0-9]+[eE][+-]?[0-9]+ |
[0-9]+"."[0-9]*[eE][+-]?[0-9]+ |
"."[0-9]*[eE][+-]?[0-9]+	SAVETOK(APPROXNUM)

  /* string */
[^'\n]*' {
	    int c = (int) input();
	    unput(c);
	    if ( c != '\'' ){
	      SAVETOK(STRING);
	    }else{
	      yymore();
	    }
	 }

\n		{save_buffer(" ");lineno++;}
[ \t\r]+	save_buffer(" ");
"--".*		;
":"[a-zA-Z][a-zA-Z0-9_]* { return PARAMETER; }
.			 yyerror("invalid character\n");
%%

int main ( int argc, char ** argv )
{
  if ( argc > 1 && ( yyin = fopen(argv[1],"r")) == NULL ){
    perror(argv[1]);
    exit ( EXIT_FAILURE );
  }

  if ( !yyparse() ){
    fprintf ( stdout,"sql parse work\n" );
  }
  else{
    fprintf ( stdout,"sql parse failed\n" );
  }
}