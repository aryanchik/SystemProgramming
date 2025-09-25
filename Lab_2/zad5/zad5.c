#include <stdio.h>
#include <stdlib.h>

int main() {
    int number = 300;
    int sum = 0;


    while (number > 0) {
        sum += number % 10;
        number /= 10;
    }


    printf("Сумма цифр: %d\n", sum);

    return 0;
}
