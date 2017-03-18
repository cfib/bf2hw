// BF2HW
// Copyright (C) 2017  Christian Fibich
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 3 of the License, or
// (at your option) any later version.

//
// Converts a BF program to C
//


/*
 * Based on https://gist.github.com/Ricket/939687
 */

#include <stdio.h>
#include <time.h>
#include <assert.h>

int main(void)
{
    FILE *in = stdin, *out = stdout;
    int c;
    int cellsize = MEMORY_SIZE;
    time_t tloc;
    assert(time(&tloc) != ((time_t) -1));
    char *timestr = ctime(&tloc);
    assert(timestr != NULL);

    fprintf(out,
            "/*\n"
            " * Translated by bf2c\n"
            " * %s "
            " */\n\n"
            "#include \"lib/bambu_io.h\"\n"
            "int main(void)\n{\n"
            "static unsigned char mem[%d];\n"
            "char *cell = mem;\n"
            "\n", timestr, cellsize
           );

    while ((c = getc(in)) != EOF) {
        switch (c) {
        case '>':
            fprintf(out, "++cell;\n");
            break;
        case '<':
            fprintf(out, "--cell;\n");
            break;
        case '+':
            fprintf(out, "++*cell;\n");
            break;
        case '-':
            fprintf(out, "--*cell;\n");
            break;
        case '.':
            fprintf(out, "bambu_putchar(*cell);\n");
            break;
        case ',':
            fprintf(out, "*cell = bambu_getchar();\n");
            break;
        case '[':
            fprintf(out, "while (*cell) {\n");
            break;
        case ']':
            fprintf(out, "}\n");
            break;
        default:
            break;
        }
    }

    fprintf(out, "\n;\nwhile(1) bambu_getchar(); /* pause before termination */\nreturn 0;\n}\n\n");
}
