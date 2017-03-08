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
            fprintf(out, "put(*cell);\n");
            break;
        case ',':
            fprintf(out, "*cell = get();\n");
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

    fprintf(out, "\n;\nwhile(1) get();\nreturn 0;\n}\n\n");
}
