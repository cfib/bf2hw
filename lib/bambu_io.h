#include <stdint.h>

extern uint16_t bambu_getchar();
extern uint8_t bambu_putchar(char c);

char get() {
    uint16_t C;
    do {
       C = bambu_getchar();
    } while(!(C & 0xFF00));
    return C & 0xFF;;
}

void put(char c) {
    uint8_t C;
    do {
       C = bambu_putchar(c);
    } while(!(C & 0xFF));
}
