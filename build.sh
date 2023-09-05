nasm -f elf32 hello.asm -o hello.o
ld -m elf_i386 hello.o -o hello