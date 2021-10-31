%{
	 //2019CSC1049
    //Radha Kishore Das
	#include <stdio.h>
	#include "question2.tab.h"							
%}


%%

[0-9][0-9]*(.[0-9]+)?		{yylval.d_val=atof(yytext); return NUMBER;}
"<"A[1-9][0-9]*">"			{yylval.s_val=yytext; return VARIABLE;}
"+"							{return PLUS;}
"-"							{return MINUS;}
"*"							{return TIMES;}
"/"							{return FSLASH;}							
"("							{return LPAREN;}
")"							{return RPAREN;}
\n							{return 0;}
[ \t]						
.							{printf("Unknown character %s\n", yytext);}

%%


int yywrap(){
	return 1;
}




