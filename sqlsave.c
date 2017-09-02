#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#include "sqlsave.h"
  
struct master{
  char *c_ref[MAX_COLUMN];
  int   c_ref_n;
  char *t[MAX_TABLE];
  int   t_n;
  char *c[MAX_COLUMN];
  int   c_n;
  char *crs[MAX_COLUMN];
  int   crs_n;
}m = { NULL,0,NULL,0,NULL,0,NULL,0};

char *buffer = NULL;
int   size   = 0;
int   old_size = 0;
int   stat   = 0;

void save_buffer(char * s){
  int i = (s != NULL ) ? strlen(s) : 0;
  
  if ( i > 0 ){
    if (buffer){
	if ( size+i <= MAX_SIZE-1){ 
	  size += snprintf(&buffer[size],MAX_SIZE,"%s",s);
	}
    }else{
      buffer = (char*) malloc (MAX_SIZE-1);
      size = 0;
      if ( i <= MAX_SIZE ){
	size += snprintf(&buffer[size],MAX_SIZE,"%s ",s);
      }
    }
  }
}

void save ( char *s, int type ){
  int i = (s != NULL ) ? strlen(s) : 0;
  
  switch ( type ){
    case __COLUMN_REF :
      /* save column_ref*/
	if ( m.c_ref_n < MAX_COLUMN ){
	  m.c_ref[m.c_ref_n] = (char*) malloc (200);
	  sprintf(m.c_ref[m.c_ref_n], "<a class=\"column_ref\">%s</a>",s);
	  m.c_ref_n++;
	}
      break;
    case __TABLE :
      /* save table*/
	if ( m.t_n < MAX_TABLE ){
	  m.t[m.t_n] = (char*) malloc (200);
	  sprintf(m.t[m.t_n], "<a class=\"table\">%s</a>",s);
	  m.t_n++;
	}
      break;
    case __COLUMN :
	if ( m.c_n < MAX_TABLE ){
	  m.t[m.c_n] = (char*) malloc (i+20);
	  sprintf(m.c[m.c_n], "<a class=\"column\">%s</a>",s);
	  m.c_n++;
	}
      break;
    case __CURSOR :
	if ( m.crs_n < MAX_TABLE ){
	  m.crs[m.crs_n] = (char*) malloc (i+20);
	  sprintf(m.crs[m.crs_n], "<a class=\"cursor\">%s</a>",s);
	  m.crs_n++;
	}
      break;
    default: printf("Error save\n");
  }
}

void change ( char *str, char *a, char *b)
{
  char *bfr = NULL ;
  int size = 0;
  int s_a  = 0, s_b = 0, s_str = 0;
  s_str = (str != NULL ) ? strlen(str) : 0;
  s_a	= (a != NULL ) ? strlen(a) : 0;
  s_b	= (b != NULL ) ? strlen(b) : 0;
  int i = 0, k = s_a -1, j = 0, t = 0 ;
  
  if ( s_b > s_a ){
    size = s_str + (s_b - s_a);
  }else{
    if ( s_b < s_a ){
      size = s_str - s_b ;
    }else{
      size = s_str + s_b ;
    }
  }
  
  if ( size >= MAX_SIZE-1 ){
    printf("Errore: stringa troppo lunga, riallocare il buffer\n");
    exit(1);
  }
  
  if ( size > 0 ){
    if ( !(bfr = (char *) calloc(size,sizeof(char)))){
      fprintf(stdout,"Error alloc\n");
      exit(1);
    }
  }else{
    return ;
  }
 
  while ( str[i] != '\0' ){
      bfr[t] = str[i];
      if ( ( bfr[t] == a[j] ) && ( j < k )){
	j++;
      }else{
	if ( j == k ){
	  memmove(&bfr[t-j],b,strlen(b));
	    t += s_b-s_a;
	}
	j = 0;
      }
    i++; t++;
  }
  bfr[size] = '\0';
  strncpy(str,bfr,size-1);
  
  if ( bfr != NULL && size > 0 ){
    //free(bfr);
    //printf("%s\n",bfr);
  }
}

void printsql ( void )
{ 
  char *savebfr = (char *) malloc(MAX_SIZE);
  char *saveptr = NULL ;
  int   w       = 0;
  int   t	= 0;
    int  i_column_ref = 0,
	 i_column = 0,
	 i_table  = 0,
	 i_cursor = 0;
  
  if ( !buffer){
    return;
  } 
	 
  char * head = "";
  
  saveptr = strtok(buffer," ,;");
  
  FILE * f ;
  f = fopen("pippo.html","w");
  
  fprintf(f,"<html><head><link rel=\"stylesheet\" href=\"mystyle.css\"></head>");
 
  while (saveptr != NULL){
	t = 0;
	if ( strcmp(saveptr,__COLUMN_REF_R) == 0 ){
	    w +=sprintf (&savebfr[w],"<br>%s ",m.c_ref[i_column_ref]);
	    i_column_ref++;
	    t = 1;
	}
	if ( strcmp(saveptr,__COLUMN_R) == 0 ){
	    w +=sprintf (&savebfr[w],"<br>%s ",m.c[i_column]);
	    i_column++;
	    t = 1;
	}
	if ( strcmp(saveptr,__TABLE_R) == 0 ){
	    w +=sprintf (&savebfr[w],"<br>%s ",m.t[i_table]);
	    i_table++;
	    t = 1;
	}
	if ( strcmp(saveptr,__CURSOR_R) == 0 ){
	    w +=sprintf (&savebfr[w],"<br>%s ",m.crs[i_cursor]);
	    i_cursor++;
	    t = 1;
	}
	if ( t != 1 ){
	    w +=sprintf (&savebfr[w],"\n\t%s ",saveptr);
	}
	printf("%s\n",savebfr);
	saveptr = strtok(NULL," ,;");
  }
  fprintf(f,"%s",savebfr);
  fprintf(f,"</html>\n");
  //printf("ciao\n");
  fclose (f);
}
