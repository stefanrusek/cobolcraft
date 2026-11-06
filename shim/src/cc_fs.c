/* cc_fs: directory enumeration (contracts/shim-abi.md §7). Glue only: GnuCOBOL 3.2 has no directory
 * listing and struct dirent is platform-specific (research R5).
 *
 * Every entry except "." and ".." is written as "<F|D><name>\n", sorted by byte order (strcmp
 * compares as unsigned char). The type follows symbolic links (stat): an entry that is, or links to,
 * a directory is D, everything else F. A directory that cannot be opened is reported as absent. On
 * CC_SMALL nothing is written and *count_out is 0; the caller enlarges `out` and retries. */
#include <dirent.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#include "ccshim.h"

typedef struct {
    char *name;
    int is_dir;
} entry_t;

static int by_name(const void *a, const void *b) {
    return strcmp(((const entry_t *)a)->name, ((const entry_t *)b)->name);
}

int32_t cc_fs_list(const char *dir, uint8_t *out, int32_t cap, int32_t *count_out) {
    *count_out = 0;
    DIR *d = opendir(dir);
    if (d == NULL) return CC_NOTFOUND;
    entry_t *entries = NULL;
    size_t count = 0, size = 0, needed = 0, dir_length = strlen(dir);
    struct dirent *e;
    while ((e = readdir(d)) != NULL) {
        if (strcmp(e->d_name, ".") == 0 || strcmp(e->d_name, "..") == 0) continue;
        if (count == size) {
            size = size * 2 + 16;
            entries = realloc(entries, size * sizeof *entries);
            if (entries == NULL) cc_fatal("cc_fs_list: out of memory");
        }
        size_t name_length = strlen(e->d_name);
        char *path = malloc(dir_length + name_length + 2);
        if (path == NULL) cc_fatal("cc_fs_list: out of memory");
        memcpy(path, dir, dir_length);
        path[dir_length] = '/';
        memcpy(path + dir_length + 1, e->d_name, name_length + 1);
        struct stat st;
        entries[count].is_dir = stat(path, &st) == 0 && S_ISDIR(st.st_mode);
        entries[count].name = strcpy(path, e->d_name);
        needed += name_length + 2;
        count++;
    }
    closedir(d);
    qsort(entries, count, sizeof *entries, by_name);
    int32_t rc = needed > (size_t)cap ? CC_SMALL : 0;
    for (size_t i = 0, at = 0; i < count; i++) {
        size_t name_length = strlen(entries[i].name);
        if (rc == 0) {
            out[at] = entries[i].is_dir ? 'D' : 'F';
            memcpy(out + at + 1, entries[i].name, name_length);
            out[at + 1 + name_length] = '\n';
        }
        at += name_length + 2;
        free(entries[i].name);
    }
    free(entries);
    if (rc == 0) *count_out = (int32_t)count;
    return rc;
}
