/* 
 * Based on https://gist.github.com/Ricket/939687
 */

#include <stdio.h>

int main(int argc, char **argv)
{
	FILE *in = stdin, *out = stdout;
	int c;
	int cellsize = 128;

	fprintf(out,
		"#include \"lib/bambu_io.h\"\n"
		"int main(void)\n{\n"
		"\tunsigned char mem[%d];\n"
		"\tchar *cell = mem;\n", cellsize
	);

	while ((c = getc(in)) != EOF) {
		switch (c) {
			case '>': fprintf(out, "\t\t++cell;\n"); break;
			case '<': fprintf(out, "\t\t--cell;\n"); break;
			case '+': fprintf(out, "\t\t++*cell;\n"); break;
			case '-': fprintf(out, "\t\t--*cell;\n"); break;
			case '.': fprintf(out, "\t\tput(*cell);\n"); break;
			case ',': fprintf(out, "\t\t*cell = get();\n"); break;
			case '[': fprintf(out, "\twhile (*cell) {\n"); break;
			case ']': fprintf(out, "\t}\n"); break;
			default: break;
		}
	}
	
	fprintf(out, "\n\t;\n\treturn get();\n}\n\n");
}
