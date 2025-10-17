#include <stdio.h>
#include <stdbool.h>

bool IsDigitsNonDecreasing(int n) {
    if (n < 0) {
        n = -n;
    }


    if (n < 10) {
        return true;
    }

    int prevDigit = n % 10;
    n /= 10;

    while (n > 0) {
        int currentDigit = n % 10;
        if (currentDigit > prevDigit) {
            return false;
        }

        prevDigit = currentDigit;
        n /= 10;
    }

    return true;
}

int main() {
    int number;

    printf("Введите число: ");
    scanf("%d", &number);

    if (IsDigitsNonDecreasing(number)) {
        printf("Цифры числа идут в неубывающем порядке\n", number);
    } else {
        printf("Цифры числа не идут в неубывающем порядке\n", number);
    }

    return 0;
}
