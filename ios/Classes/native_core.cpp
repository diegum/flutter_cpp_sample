#include <cstdlib>
#include <cstring>

#define MALLOC(T, S) (T*)malloc(sizeof(T) * (S));

extern "C" __attribute__((visibility("default"))) __attribute__((used))
int32_t add_two_ints(int32_t x, int32_t y) {
    return x + y;
}

extern "C" __attribute__((visibility("default"))) __attribute__((used))
char *get_locale() {
    char *ret_value = MALLOC(char, 5+1);
    return strcpy(ret_value, "es_AR");
}

struct CStringArray {
    const char **entries;
    uint32_t size;
};

extern "C" __attribute__((visibility("default"))) __attribute__((used))
CStringArray *localize(const CStringArray *keys) {
    CStringArray *result = (CStringArray *)malloc(sizeof(CStringArray));
    result->entries = MALLOC(const char*, 2);
    result->size = 2;
    result->entries[0] = "Hola, mundo";
    result->entries[1] = "Yo prefiero C++";

    return result;
}
