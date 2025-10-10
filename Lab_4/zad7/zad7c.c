#include <stdio.h>

int reverseNumber(int m) {
    int reversed = 0;

    while (m > 0) {
        reversed = reversed * 10 + m % 10;
        m /= 10;
    }

    return reversed;
}

int main() {
    int m;


        printf("Введите число m: ");
        scanf("%d", &m);


        int reversed = reverseNumber(m);
        printf("Обращенное число: %d\n", reversed);


    return 0;
}
