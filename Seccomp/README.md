# How to Compile

```bash
gcc -o sudoku sudoku/sudoku.c
```
# ALLOW List

```bash
SECCOMP_SYSCALL_ALLOW=wait4:red:write:close:stat:fstat:lseek:mmap:mprotect:munmap:brk:rt_sigaction:rt_sigprocmask:ioctl:access:getpid:clone:execve:getuid:getgid:geteuid:getegid:getppid:arch_prctl:time:openat
```

# Notas

1. Tem um ``strace -cfq`` no arquivo [lista de syscalls](listadesyscalls.txt)
1. Não consegui dar ``pathelf --add-needed libsandbox.so sudoku``
aparentemente o ``pathelf`` quebrou meu elf.
