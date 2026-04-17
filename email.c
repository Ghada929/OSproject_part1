#include<stdio.h>
#include<stdlib.h>

int textLength(char text[]){
   int counter =0;
   while (text[counter]!='\0'){
      counter++;
   }
   return counter; 
}


int checkEmailFormat(char email[]){
    int size = textLength(email);
    // checking the size 
    if (size<5){
        return 0; // too short to be valid
    }    
    // checking the start of the email 
    if(email[0]=='@' || email[0]=='.' || email[0]=='-'){
        return 0; // cannot start with @ or .
    }
    // count the number of @ and dots 
    int at_count=0, dot_count=0;
    for (int i =0 ; email[i]!='\0' ; i++){
        if (email[i]=='@'){
            at_count++;
        }
        else if (email[i]=='.'){
            dot_count++;
        }
    }
    // check if there is no dot and the is either 0 or more than one @ 
    if (at_count !=1 || dot_count <1){
        return 0; // must contain exactly one @ and at least one .
    }
    // check positions of @ and .
    int m=-1,k=-1;
    for (int i =0 ; email[i]!='\0' ; i++){
        // checking spaces
        if(email[i]==' '){
            return 0;
        }
        //checking recursive dots 
        if(email[i]=='.' && email[i+1]=='.'){
            return 0;
        }
        //check if  the is a dot before @
        if (email[i]=='@'){           
             m = i;
        }
        else if (email[i]=='.'){
                k = i;
        }
        if(m==-1 && k!=-1){// to check if there is . before @
            return 0;
        }
        else if(k==m+1 || k==m+2){ // to check if there is . just after @ or 2 places after @
                return 0;
        }
    }
    // check if it ends with dot 
    if(email[size-1]=='.')
    {
            return 0;
    }
    //checking if there at least 2 element after the last dot 
    if(email[k]=='.' && email[k+2]=='\0'){
        return 0;
    }
    return 1;
}



int main(int argc , char *argv[]){
     // argc is the number of arguments
     // *argv[] is an array of arguments
     if ( argc < 2)
     {
        return 1;
     }
     return checkEmailFormat(argv[1]) ? 0 : 1;
}