#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/wait.h>
#include <unistd.h>

void setRandom(unsigned int seed) {
    srand(seed);
}

int randInt(size_t max) {
    return rand() % max;
}

typedef enum {
    STATUS_NO_EXE,
    STATUS_ERR,
    STATUS_EXITED,
    STATUS_SIGNALED,
    STATUS_STOPPED,
    STATUS_UNKNOWN,
} status_t;

typedef struct {
    char *input;
    char *description;
    size_t input_len;
    int code;
    int status;
} details_t;

details_t runner(char *exec, char **envp, char *input) {
    details_t details = {};
    details.input = input;

    char *argv[3];
    argv[0] = exec;
    argv[1] = input;
    argv[2] = 0;

    pid_t pid = fork();
    if ( pid == 0 ) {
        if ( execve(argv[0], argv, envp) < 0 ) {
            details.description = "Erro: command not found";
            details.status = STATUS_NO_EXE;
            return details;
        }
    } if ( pid < 0 ) {
        fprintf(stderr, "Erro: fork.\n");
    }

    int status;
    if ( waitpid(pid, &status, WUNTRACED) == -1 ) {
        details.description = "Erro: wait";
        details.status = STATUS_ERR;
        return details;
    }

    if (WIFEXITED(status)) {
        details.description = "Exited";
        details.code = WEXITSTATUS(status);
        details.status = STATUS_EXITED;
    } else if (WIFSIGNALED(status)) {
        details.description = "Signaled";
        details.code = WTERMSIG(status);
        details.status = STATUS_SIGNALED;
#ifdef WCOREDUMP
        if (WCOREDUMP(status)) {
            details.description = "Signaled (core dumped)";
        }
#endif
    } else if (WIFSTOPPED(status)) {
        details.description = "Stopped";
        details.code = WSTOPSIG(status);
        details.status = STATUS_STOPPED;
    } else {
        details.description = "Unknown";
        details.code = 0;
        details.status = STATUS_UNKNOWN;
    }

    return details;
}

#define INPUT_SIZE_THRESHOLD    0x100
#define CRASH_FILE_LEN  81
#define CRASH_FILE "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

void print(FILE *flog, details_t d, int i) {
    char *log = "no";
    char logged = 0;
    static char crash[CRASH_FILE_LEN] = CRASH_FILE;
    char old_crash[CRASH_FILE_LEN];

    switch ( d.status ) {
        case STATUS_ERR:
            putchar('%');
            break;
        case STATUS_EXITED:
            putchar( d.code ? 'X' : '.');
            break;
        case STATUS_SIGNALED:
            putchar('!');
            break;
        case STATUS_STOPPED:
            putchar('&');
            break;
        case STATUS_UNKNOWN:
            putchar('?');
            break;
        default:
            putchar('*');
            break;
    }

    if ( d.status == STATUS_EXITED && d.code != 0 ) {
        FILE *fp = fopen(crash, "w");
        if ( !fp ) {
            log = "err fopen";
        } else {
            fwrite(d.input, 1, d.input_len, fp);
            fclose(fp);
            log = "yes";
        }

        for ( int i = 0; i < CRASH_FILE_LEN; i++ ) {
            old_crash[i] = crash[i];
        }
        // "increment" crash
        for ( int i = CRASH_FILE_LEN-2; i >= 0; i-- ) {
            char c = crash[i];
            if ( c == 'z' ) {
                crash[i] = 'A';
            } else if ( 'a' <= c && c < 'z' ) {
                crash[i] += 1;
            } else if ( c == 'Z' ) {
                crash[i] = 'a';
                continue;
            } else if ( 'A' <= c && c < 'Z' ) {
                crash[i] += 1;
            } else {
                fprintf(stderr, "Err on incrementing crash: %s\n", crash);
            }
            break;
        }
    }

    fprintf(flog, "=========== Try: %03d ===========\n", i);
    if ( d.input_len < INPUT_SIZE_THRESHOLD )
        fprintf(flog, "\tinput: %s\n", d.input);
    else
        fprintf(flog, "\tinput: *TOO BIG*\n");
    fprintf(flog, "\t%s: %d\n", d.description, d.code);
    fprintf(flog, "\tLog: %s\n", log);
    if ( logged )
        fprintf(flog, "\tLog name: %s\n", old_crash);
    else
        fprintf(flog, "\tLog name: No Log\n");
    fprintf(flog, "=================================\n");
}

#define MUTATE_RATE     0.01
#define MAGIC_RATE      0.005
#define CASE_COUNT      8

void mutate(char *current_input, size_t len) {
    size_t count;

    // mutate bits
    count = (size_t) (((float)(len*8)) * MUTATE_RATE);
    if ( count <= 0 ) count = 1;

    for ( int i = 0; i < count; i++ ) {
        size_t bit = randInt(len*8);
        size_t index = bit / 8;
        size_t bindx = bit % 8;
        current_input[index] ^= 1 << (7 - bindx);
    }

    // mutate bytes
    count = (size_t) (((float)len) * MUTATE_RATE);
    if ( count <= 0 ) count = 1;

    for ( int i = 0; i < count; i++ ) {
        size_t index = randInt(len);
        char value = randInt(0x100);
        current_input[index] = value;
    }

    // magic mutation
    count = (size_t) (((float)len) * MAGIC_RATE);
    if ( count <= 0 && randInt(2) ) count = 1;

    for ( int i = 0; i < count; i++ ) {
        size_t index = randInt(len);
        size_t magic = randInt(CASE_COUNT);
        char value[4] = { 0, 0, 0, 0 };
        char size = 1;
        switch (magic) {
            default:
            case 0:
                value[0] = 0xff;
                break;
            case 1:
                value[0] = 0x7f;
                break;
            case 2:
                value[0] = 0x00;
                break;
            case 3:
                value[0] = 0xff;
                value[1] = 0xff;
                size = 2;
                break;
            case 4:
                value[0] = 0x00;
                value[1] = 0x00;
                size = 2;
                break;
            case 5:
                value[0] = 0xff;
                value[1] = 0xff;
                value[2] = 0xff;
                value[3] = 0xff;
                size = 4;
                break;
            case 6:
                value[0] = 0x00;
                value[1] = 0x00;
                value[2] = 0x00;
                value[3] = 0x00;
                size = 4;
                break;
            case 7:
                value[0] = 0x80;
                value[1] = 0x00;
                value[2] = 0x00;
                value[3] = 0x00;
                size = 4;
                break;
            case 8:
                value[0] = 0x40;
                value[1] = 0x00;
                value[2] = 0x00;
                value[3] = 0x00;
                size = 4;
                break;
        }

        if ( index + size > len ) continue;

        for ( int j = 0; j < size; j++ ) {
            current_input[index + j] = value[j];
            if ( j > 0 ) count -= 1;
        }
    }
}

#define LOG_FILENAME    "loglog.txt"

int main(int argc, char **argv, char **envp) {
    char *exe, *filename, *current_input;
    size_t curr_in_len = 0;
    unsigned int seed = time(NULL);
    unsigned int tries = 10;
    FILE *flog;

    if ( argc < 3 ) {
        fprintf(stderr,
                "usage: %s <file to fuzz> <input filename> [tries] [seed]\n",
                argv[0]);
        return 0;
    } else {
        switch (argc) {
            default:
            case 5:
                seed = atoll(argv[4]);
            case 4:
                tries = atoll(argv[3]);
            case 3:
                filename = argv[2];
            case 2:
                exe = argv[1];
            break;
        }
    }

    setRandom(seed);

    { // Open file, and copy input
    FILE *fp = fopen(filename, "r");
    if ( !fp ) {
        fprintf(stderr, "Could not open file: %s\n", filename);
        return 1;
    }
    fseek(fp, 0, SEEK_END);
    curr_in_len = ftell(fp);
    fseek(fp, 0, SEEK_SET);
    current_input = (char *) malloc(curr_in_len);
    if ( !current_input ) {
        fprintf(stderr, "Could not malloc %ld bytes\n", curr_in_len);
        return 1;
    }
    size_t read = fread(current_input, 1, curr_in_len, fp);
    if ( read != curr_in_len ) {
        fprintf(stderr, "Could only read %ld/%ld bytes at once\n",
                read, curr_in_len);
        return 1;
    }
    fclose(fp);
    }

    flog = fopen(LOG_FILENAME, "w");
    if ( !flog ) {
        fprintf(stderr, "Could not open file: %s\n", LOG_FILENAME);
        return 1;
    }

    details_t details;
    for ( int i = 0; i < tries; i++ ) {
        details = runner(exe, envp, current_input);
        if ( details.status == STATUS_NO_EXE ) break;

        print(flog, details, i);

        mutate(current_input, curr_in_len);
    }
    putchar('\n');

    fclose(flog);

    return 0;
}
