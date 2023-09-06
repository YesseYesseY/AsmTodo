#include <stdio.h>
#include <string.h>
#include <math.h>

// The purpose of this c file is to have a reference on how to do these types of functions, everything in the todoapp will be written in assembly

#define ASCII_ZERO 48

void reverse_string(char* str)
{
    int len = strlen(str);
    char temp;
    for(int i = 0; i < floor(len / 2); i++)
    {
        int ri = len - i - 1;
        temp = str[i];
        str[i] = str[ri];
        str[ri] = temp;
    }
}

void int_to_str(int num, char* str)
{
    float number = (float)num;
    int rest = floor(number / 10);
    int last = num % 10;

    char char_to_add = ASCII_ZERO + last;
    strcat(str, &char_to_add);
    if(rest > 0)
        int_to_str(rest, str);
    else
        reverse_string(str);
}

void str_to_int(char* str, int* num)
{
    int str_len = strlen(str);
    for(int i = 0; i < str_len; i++)
    {
        char chr = str[i];
        int ri = str_len - i - 1;
        int val = chr - ASCII_ZERO;
        int what_to_multiply_with = (int)pow(10, ri);
        
        *num += val * what_to_multiply_with;
    }
}

int main() {
    int num = 1337;
    char yes[32];

    int_to_str(num, yes);
    printf("%s\n", yes);

    char yes2[] = "1337";
    int num2 = 0;

    str_to_int(yes2, &num2);
    printf("%i\n", num2);

    return 0;
}

