#include <stdint.h>

extern uint8_t bambu_getchar();
extern void bambu_putchar(char c);

int main(void) {
    uint16_t c;
    uint8_t  r;
    while(1) {
       char x = bambu_getchar();
       if (x != '#') {
              put('4');
              put('2');
              put('\n');
       } else {
              put('\n');
       }
    }
    return 0;
}

