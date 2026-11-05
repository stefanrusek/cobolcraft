/* Lint fixture: an unused variable is an error under -Wall -Werror. */
int lint_bad(int a) {
    int unused;
    return a;
}
