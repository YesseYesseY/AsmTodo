nasm -f elf32 hello.asm -o hello.o
nasm -f elf32 test.asm -o test.o
ld -m elf_i386 hello.o -o hello
ld -m elf_i386 test.o -o test