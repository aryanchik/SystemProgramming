#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

extern long long *array_begin;
extern long long count;
extern long long count_remainder_1;
extern long long prime_count;

extern void* create_array(unsigned long size);
extern void add_end(long long value);
extern void delete_begin();
extern void count_num_end_one();
extern void count_prime_number();

extern long long* get_odd_numbers_addr();
extern long long get_odd_numbers_count();

void print_array(const char* label) {
    printf("\n %s \n", label);
    printf("Текущая длина (count): %lld\n", count);
    printf("Адрес начала (array_begin): %p\n", (void*)array_begin);

    if (count > 0) {
        printf("Элементы: ");
        for (long long i = 0; i < count; i++) {
            printf("%lld", array_begin[i]);
            if (i < count - 1) {
                printf(", ");
            }
        }
        printf("\n");
    } else {
        printf("Массив пуст.\n");
    }
}

int main() {
    const int initial_capacity = 5;
    unsigned long total_size_bytes = (unsigned long)initial_capacity * 8;

    array_begin = (long long *)create_array(total_size_bytes);

    if (array_begin == (void*)-1 || array_begin == NULL) {
        perror("Ошибка выделения памяти");
        return 1;
    }

    add_end(11); add_end(22); add_end(31); add_end(44); add_end(53);

    print_array("Исходный массив: [11, 22, 31, 44, 53]");

    count_num_end_one();
    printf("\nТест: count_num_end_one\n");
    printf("Количество чисел, оканчивающихся на 1: %lld (Нужно: 2)\n", count_remainder_1);

    count_prime_number();
    printf("\nТест: count_prime_number\n");
    printf("Количество простых чисел: %lld (Нужно: 3)\n", prime_count);

    long long *odd_array = get_odd_numbers_addr();
    long long odd_count = get_odd_numbers_count();

    printf("\nТест: get_odd_numbers\n");
    printf("Количество нечетных чисел: %lld\n", odd_count);
    printf("Адрес нового массива: %p\n", (void*)odd_array);

    if (odd_count > 0 && odd_array != NULL) {
        printf("Нечетные элементы: ");
        for (long long i = 0; i < odd_count; i++) {
            printf("%lld", odd_array[i]);
            if (i < odd_count - 1) printf(", ");
        }
        printf("\n");
    }

    delete_begin();
    print_array("Массив после delete_begin (удален 11)");

    delete_begin();
    print_array("Массив после 2-го delete_begin (удален 22)");

    return 0;
}
