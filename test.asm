global _start

section .data
    string db 0 dup(4)

    test_str db "yesseY"
    new_line db 0xA

section .text
_start:
    mov eax, 1337
    mov ebx, string
    mov esi, 0
    call int_to_str
    
    mov eax, 4
    mov ebx, 1
    mov ecx, string
    mov edx, 4
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, new_line
    mov edx, 1
    int 0x80

    mov eax, 1
    mov ebx, 0
    int 0x80

reverse_string:
    ret

; eax = num
; ebx = str
int_to_str:
    mov esi, 0            ; esi = i
int_to_str_loop:
    mov ecx, 10
    xor edx, edx          ; Clear edx, otherwise get Floating point exception
    div ecx               ; Divide num by 10
    add edx, 48           ; Add 48 to remainder, this will give the ASCII value of the number
    mov [ebx+esi], edx    ; Add the char to string
    inc esi               ; i++
    cmp eax, 0
    jg int_to_str_loop    ; if (num > 0) goto int_to_str_loop
    ; TODO: Reverse string
    ret