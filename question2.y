//2019CSC1049
//Radha Kishore Das
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "sqlite3.h"
    #include <string.h>
	
	int yylex();
	void yyerror(char*);
    char* arr[200];
    int callback(void *NotUsed, int argc, char **argv, char **azColName);
%}



%union
{
	int i_val;
	double d_val;
	char* s_val;
}

%token <i_val> PLUS MINUS TIMES FSLASH LPAREN RPAREN
%token <s_val> VARIABLE;
%token <d_val> NUMBER


%start rootnode

%%

rootnode:  exp	{printf("The expression is correct. \n");} ;

exp: exp op exp | LPAREN exp RPAREN | term;
op : PLUS | MINUS | TIMES | FSLASH;
term: VARIABLE |NUMBER ;

%%

int main(){


	sqlite3 *db;
    char *err_msg = 0;
    sqlite3_stmt *res;
    
    int rc = sqlite3_open("SPAssignment.db", &db);
    
    if (rc != SQLITE_OK) {
        
        fprintf(stderr, "Cannot open database: %s\n", sqlite3_errmsg(db));
        sqlite3_close(db);
        
        return 1;
    }
    


     //Program to select the formula from FORMULAE table and pass in the parser for verification;
    
    
    char *sql = "SELECT FORMULA FROM FORMULAE WHERE Id = ?";
        
    rc = sqlite3_prepare_v2(db, sql, -1, &res, 0);
    
    if (rc == SQLITE_OK) {
        
        int testInteger,inputID=-1;
        printf("Enter the ID of the formula to check : ");
        scanf("%d", &inputID);
        sqlite3_bind_int(res, 1,inputID );
    } 
    else {
        
        fprintf(stderr, "Failed to execute statement: %s\n", sqlite3_errmsg(db));
    }
    
    int step = sqlite3_step(res);
    const char* formula;
    if (step == SQLITE_ROW) {
        
        printf("%s: ", sqlite3_column_text(res, 0));
        formula=sqlite3_column_text(res, 0);
        
        
        FILE *fp;

        fp = fopen("test.txt", "w+");
        fputs(formula, fp);
        fclose(fp);
        
    } 
    
    
	extern FILE *yyin;
	yyin=fopen("test.txt","r");
	yyparse();
	
	
	
    

     //Program to select the COLUMNNAME from FORMULAFIELDS table and replace it with the VARIABLENAME;




    char temp[100]="SELECT (";
    
    rc = sqlite3_open("SPAssignment.db", &db);
    
    if (rc != SQLITE_OK) {
        
        fprintf(stderr, "Cannot open database: %s\n", sqlite3_errmsg(db));
        sqlite3_close(db);
        
        return 1;
    }
    
    char *sql1 = "SELECT COLUMNNAME FROM FORMULAFIELDS WHERE VARIABLENAME = ?";
        
    rc = sqlite3_prepare_v2(db, sql1, -1, &res, 0);

    for(int i=0;i<=strlen(formula);i++)
    {	
        char read=formula[i];
		
        if(read=='<')
        
        {
			char str[5];
			int v=0;
			str[v++]=read;
			do{
				i++;
				read=formula[i];
				str[v++]=read;
			}while(read!='>');


			if (rc == SQLITE_OK) {
				sqlite3_bind_text(res, 1, str,-1,0);
			} else {
				fprintf(stderr, "Failed to execute statement: %s\n", sqlite3_errmsg(db));
			}
		
			int step = sqlite3_step(res);
			char* replace;
			if (step == SQLITE_ROW) {
				
				replace=(char*)sqlite3_column_text(res, 0);
			}

			strcat(temp, replace);
			
		}
		else
        {
            
			strncat(temp, &read,1);
		}

		}
		strcat(temp, " ) as RESULT from SALARY");
        printf("\n %s","The Generated Query is : ");
		printf(" %s \n", temp);

        printf("\n %s \n","The RESULTS GENERATED FROM SALARY ARE :");




     //Program to successfully run the generated query using MYSqlite;
	
  

	 rc = sqlite3_exec(db, temp, callback, 0, &err_msg);
    
    if (rc != SQLITE_OK ) {
        
        fprintf(stderr, "Failed to select data\n");
        fprintf(stderr, "SQL error: %s\n", err_msg);

        sqlite3_free(err_msg);
        sqlite3_close(db);
        
        return 1;
    } 
    
	sqlite3_finalize(res);
    sqlite3_close(db);
    
    return 0;
}

void yyerror(char *s) 
{
   fprintf(stderr, "%s\n", s);
   exit(0);
}

int callback(void *NotUsed, int argc, char **argv, char **azColName) 

{
    
    NotUsed = 0;
    
    for (int i = 0; i < argc; i++) {

        printf("%s = %s\n", azColName[i], argv[i] ? argv[i] : "NULL");
    }
    
    printf("\n");
    
    return 0;
}
