global _start

section .data
    string db 4 dup(0)
    string_2 db "1337"
    new_line db 0xA

section .text
_start:
    mov esi, string_2
    mov ecx, 4
    call string_to_int

    mov eax, ebx
    mov ebx, string
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

; eax = str
; ebx = str_len
reverse_string:
    mov esi, eax         ; ptr to start of string
    mov edi, eax         
    add edi, ebx         ; ptr to end of string
    sub edi, 1
reverse_string_loop:
    mov cl, [esi]        ; first char
    mov dl, [edi]        ; last char

    mov [edi], cl
    mov [esi], dl

    inc esi
    dec edi

    cmp esi, edi
    jle reverse_string_loop
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
    mov [ebx+esi], dl     ; Add the char to string
    inc esi               ; i++
    cmp eax, 0
    jg int_to_str_loop    ; if (num > 0) goto int_to_str_loop

    mov eax, string
    mov ebx, esi
    call reverse_string
    ret

; esi = str
; ecx = str_len
; return ebx
string_to_int:
    xor edx, edx
    mov edi, esi
    add edi, ecx
    sub edi, 1        ; edi = ptr to end of string
    mov ecx, 1
string_to_int_loop:
    movzx eax, byte [edi]     
    sub eax, byte '0'
    mul ecx
    add ebx, eax

    mov eax, ecx
    mov ecx, 10
    mul ecx
    mov ecx, eax
    
    dec edi     ; dec the end_of_str ptr
    cmp edi, esi
    jge string_to_int_loop ; if the ptr is greater than start of string then loop
    ret
