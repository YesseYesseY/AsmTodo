global _start

section .data
    str1pad db 32 dup(0)
    str2pad db 32 dup(0)
    str3pad db 32 dup(0)
    str4pad db 32 dup(0)
    str5pad db 32 dup(0)
    str6pad db 32 dup(0)
    str7pad db 32 dup(0)
    str8pad db 32 dup(0)
    str9pad db 32 dup(0)
    str10pad db 32 dup(0) 
    str11pad db 32 dup(0)
    str12pad db 32 dup(0)
    str13pad db 32 dup(0)
    str14pad db 32 dup(0)
    str15pad db 32 dup(0)
    str16pad db 32 dup(0)
    str_arr dd str1pad, str2pad, str3pad, str4pad, str5pad, str6pad, str7pad, str8pad, str9pad, str10pad, str11pad, str12pad, str13pad, str14pad, str15pad, str16pad

    welcome_message db "Welcome to this AsmTodo, here are the commands:", 0xA, "a [message] (Add an item to the list)", 0xA, "r (Remove the last item in the list)", 0xA, "v (View the list)", 0xA, "e (Exit the program)", 0xA, 0xA, "Warning: Messages are restricted to 32 characters", 0xA
    welcome_message_len equ $ - welcome_message

    input_buffer db 34 dup(0) ; 34 because command + space + message buffer
    input_buffer_len equ 34

    not_implemented_msg db "This is not implemented yet!", 0xA
    not_implemented_msg_len equ $ - not_implemented_msg

    new_line db 0xA

    reading_buffer db 16*32 dup(0)
    writing_buffer db 16*32 dup(0) ; i technically could make the reading_buffer and writing_buffer into a readwrite_buffer but nahhh thats too smart
    todo_dat_filename db "todo.dat", 0x0 ; 0x0 to end it because null terminated string
    todo_dat_fd dd 0

    limit_reached_error db "Error: List limit reached (16)", 0xA
    limit_reached_error_len equ $ - limit_reached_error

    nothing_to_delete_error db "Error: Nothing to delete!", 0xa
    nothing_to_delete_error_len equ $ - nothing_to_delete_error

section .text
_start:
    ; Checking if todo.dat exists
    mov eax, 33
    mov ebx, todo_dat_filename
    mov ecx, 0
    int 0x80

    cmp eax, 0
    je skipit
    
    ; todo.bat doesnt exist
    ; create new file and open for writing
    mov eax, 5
    mov ebx, todo_dat_filename
    mov ecx, 00000100 | 00000001 ; O_CREAT | O_WRONLY
    mov edx, 0
    int 0x80

    ; write empty buffer to fd
    mov [todo_dat_fd], eax
    mov eax, 4
    mov ebx, [todo_dat_fd]
    mov ecx, reading_buffer ; reading_buffer SHOULD be empty so there is no reason to create a new thingy just for an empty buffer
    mov edx, 16*32
    int 0x80

    ; close fd
    mov eax, 6
    mov ebx, [todo_dat_fd]
    int 0x80

skipit:
    call load_list
    mov eax, 4
    mov ebx, 1
    mov ecx, welcome_message
    mov edx, welcome_message_len
    int 0x80

start_input:
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buffer
    mov edx, input_buffer_len
    int 0x80

    jmp parse_input_buffer

exit:
    mov eax, 1
    mov ebx, 0
    int 0x80

parse_input_buffer:
    cmp [input_buffer], byte 'a'
    je add_msg

    cmp [input_buffer], byte 'v'
    je view

    cmp [input_buffer], byte 'r'
    je rem_last

    cmp [input_buffer], byte 'e'
    jmp exit


    jmp start_input

view:
    call get_list_length
    mov eax, esi
    cmp eax, 0
    je view_loop_end
    mov esi, 0
view_loop:
    mov edi, [str_arr+esi*4] ; multiply by 4 because pointers are 4 bytes :)
    mov ecx, edi
    mov edx, 32
    call print

    mov ecx, new_line
    mov edx, 1
    call print

    inc esi
    cmp esi, eax
    jl view_loop
view_loop_end:
    jmp exit

print:
    push eax
    push ebx
    mov eax, 4
    mov ebx, 1
    int 0x80
    pop ebx
    pop eax
    ret


add_msg:
    call get_list_length
    cmp esi, 16
    jl add_msg_no_errors

    mov eax, 4
    mov ebx, 1
    mov ecx, limit_reached_error
    mov edx, limit_reached_error_len
    int 0x80

    jmp exit
add_msg_no_errors:
    mov edx, [str_arr+esi*4]
    mov esi, 0
add_msg_no_errors_loop:
    mov al, [input_buffer+2+esi]
    cmp al, byte 0xA
    jne dont_fix_it
    mov al, byte 0x0
dont_fix_it:
    mov [edx+esi], al

    inc esi
    cmp esi, 32
    jl add_msg_no_errors_loop

    call save_list

    jmp exit

rem_last:
    call get_list_length
    cmp esi, 0
    jne rem_last_no_error

    mov eax, 4
    mov ebx, 1
    mov ecx, nothing_to_delete_error
    mov edx, nothing_to_delete_error_len
    int 0x80

    jmp exit
rem_last_no_error:
    mov eax, [str_arr+esi*4-4]
    mov esi, 0
rem_last_loop:
    mov [eax+esi], byte 0x0
    inc esi
    cmp esi, 32
    jl rem_last_loop

    call save_list

    jmp exit

save_list:
    ; open todo.dat
    mov eax, 5
    mov ebx, todo_dat_filename
    mov ecx, 00000100 | 00000001 
    mov edx, 0
    int 0x80

    mov [todo_dat_fd], eax

    ; fill writing_buffer
    mov esi, 0
save_list_loop:
    mov ecx, [str_arr+esi*4]
    mov edi, 0
save_list_loop_2:
    mov bl, [ecx+edi]
    mov eax, esi
    push ecx
    mov ecx, 32
    mul ecx
    pop ecx
    mov [writing_buffer+eax+edi], bl
    inc edi
    cmp edi, 32
    jl save_list_loop_2

    inc esi
    cmp esi, 16
    jl save_list_loop

    ; write to todo.dat
    mov eax, 4
    mov ebx, [todo_dat_fd]
    mov ecx, writing_buffer
    mov edx, 16*32
    int 0x80

load_list:
    mov esi, 0
    call read_todo
load_list_loop:
    mov edi, [str_arr+esi*4]
    mov ebx, 0
load_list_loop_2:
    mov edx, 32
    mov eax, esi
    mul edx
    mov cl, [reading_buffer+eax+ebx]
    mov [edi+ebx], cl

    inc ebx
    cmp ebx, 32
    jl load_list_loop_2

    inc esi
    cmp esi, 16
    jl load_list_loop
    ret

read_todo:
    push eax
    push ebx
    push ecx
    push edx

    ; open todo.bat
    mov eax, 5
    mov ebx, todo_dat_filename
    mov ecx, 00000000 ; O_RDONLY
    mov edx, 0
    int 0x80

    mov [todo_dat_fd], eax ; save fd to close file once done

    ; read todo.bat into reading_buffer
    mov eax, 3
    mov ebx, [todo_dat_fd]
    mov ecx, reading_buffer
    mov edx, 16*32
    int 0x80

    ; close todo.bat
    mov eax, 6
    mov ebx, [todo_dat_fd]
    int 0x80

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

is_string_empty:
    push esi
    mov eax, 1 ; eax will return 0 if not empty and 1 if empty
    mov esi, 0
is_string_empty_loop:
    cmp [edi+esi], byte 0
    jne is_string_empty_return_false
    inc esi
    cmp esi, 32
    jl is_string_empty_loop
    jmp is_string_empty_return_true
is_string_empty_return_false:
    mov eax, 0
is_string_empty_return_true:
    pop esi
    ret

get_list_length:
    mov esi, 0
get_list_length_loop:
    mov edi, [str_arr+esi*4]
    call is_string_empty
    cmp eax, 1
    je get_list_length_return
    inc esi
    cmp esi, 16
    jl get_list_length_loop
get_list_length_return:
    ret