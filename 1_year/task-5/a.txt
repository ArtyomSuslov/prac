include console.inc

TRUE    equ 11111111b
FALSE   equ 00000000b
MAX_LEN equ 512

.data
    ;Два текста: их массивы, длины и метрики
    text_1     db MAX_LEN dup (?), 0
    len_text_1 dw 0
    metric_1   dw 0
    ;-------------------------------
    text_2     db MAX_LEN dup (?), 0
    len_text_2 dw 0
    metric_2   dw 0
    
    ;Булевские переменные - кастомные флаги
    is_error  db FALSE
    is_fin    db FALSE
    is_slash  db FALSE
    
    ;Временные/вспомогательные переменные
    slash_num    db 0
    temp         dd 0
    temp_char    db 0
    len_of_stack dd 0
    
    ;Константы
    for_number    db 16
    for_backwards dw 2

.code

;==============================================================================

;                      ///Процедура чтения текста\\\
;      На вход подаются:
;   1) Булевская переменная - возникла ли ошибка во время чтения
;   2) Ссылка на переменную, где будет храниться длина текста
;   3) Ссылка на начало текста

Read_text proc

    ;ПРОЛОГ
    push ebp
    mov ebp, esp
    push eax      ;Для чтения символов
    push ebx      ;Адрес начала текста
    push ecx      ;Счётчик
    push edx      ;Мультифункциональный регистр
    ;КОНЕЦ ПРОЛОГА
    
    mov ecx, 0         ;Счётчик с 0
    mov edx, 0
    mov ebx, [ebp + 8] ;ebx := ^text
    
Start_read:
    ;Ввод (чтение) очередного символа
    inchar al

Without_read:
    ;Проверка на обратный слэш
    cmp al, '\'
    je Slash_check

After_slash_check:
    ;Проверка на начало финишной посл-ти
    cmp al, '-'
    je Fin_check
    
Write_char:
    ;Запись считанного эл-та в массив
    mov [ebx], al

Skip_char:
    ;Указатель на следующий элемент текста
    inc ebx
    ;Увеличение счётчика и провека на переполнение
    inc ecx
    cmp ecx, MAX_LEN
    jbe Start_read
    ;Если переполнение - поднять флаг и на выход
    mov eax, [ebp + 16]
    mov ebx, TRUE
    mov [eax], bl
    jmp Read_epilogue

;-------------------ПРОВЕРКА ВСЕВОЗМОЖНЫХ ОСОБЫХ СЛУЧАЕВ-----------------------
Analysis:
    
;------------------Проверка на число после обратного слэша---------------------
    
    cmp is_slash, TRUE
    jne Without_slash
    mov is_slash, FALSE
    
    ;dl = 2 - Не число, первый элемент после сшэша на регистре al
    ;dl = 1 - Первый элемент - цифра, второй - нет, второй на регистре al
    ;dl = 0 - Число, поднимится соотвествующий флаг, обе цифры в стеке
   
    cmp edx, 2
    jne Maybe_a_number
    
    ;ПЕРВЫЙ СЛУЧАЙ dl = 2
    jmp Write_char
    
Maybe_a_number:
    cmp edx, 1
    jne Nuber_after_slash
    
    ;ВТОРОЙ СЛУЧАЙ dl = 1
    pop temp
    push eax
    mov eax, temp
    
    cmp al, 9
    ja Make_a_letter
    add al, '0'
    jmp Al_is_letter
    
Make_a_letter:
    sub al, 10
    add al, 'a'

Al_is_letter:
    mov [ebx], al
    inc ebx
    inc ecx
    pop eax
    jmp Write_char

Nuber_after_slash:
    ;ТРЕТИЙ СЛУЧАЙ dl = 0
    mov slash_num, 0
    inc ecx
    cmp ecx, MAX_LEN
    jbe Appropriate_len
    mov eax, [ebp + 16]
    mov ebx, TRUE
    mov [eax], bl
    jmp Read_epilogue

Appropriate_len:
    ;Собираем число из стека
    pop temp
    push eax
    mov eax, temp
    mov slash_num, al
    pop eax
    
    pop temp
    push eax
    mov eax, temp
    mul for_number
    add slash_num, al
    movzx eax, slash_num
    mov [ebx], al
    inc ebx
    pop eax
    jmp Start_read
    
;------------------Проверка на последовательность "-:fin:-" -------------------
    
Without_slash:
    cmp is_fin, TRUE
    je Read_epilogue
    
    ;Если не последовательность финиша, то собираем строку из символов в стеке
    add ecx, edx
    cmp ecx, MAX_LEN
    ja Read_error
    mov len_of_stack, edx
    add ebx, edx
    dec ebx
    
Out_stack_fin:
    pop temp
    push eax
    mov eax, temp
    mov [ebx], al
    pop eax
    dec ebx
    dec edx
    cmp edx, 0
    jne  Out_stack_fin
    
    mov edx, len_of_stack
    add ebx, edx
    inc ebx
    jmp Without_read

Out_read:
    cmp ecx, 0
    jne Read_epilogue
    mov eax, [ebp + 16]
    mov ebx, TRUE
    mov [eax], bl
    
    ;ЭПИЛОГ
Read_epilogue:
    mov eax, [ebp + 12]
    mov [eax], ecx
    pop edx
    pop ecx
    pop ebx
    pop eax
    pop ebp
    ret 3*4
    ;КОНЕЦ ЭПИЛОГА
    
;------------------------------------------------------------------------------
    
Fin_check:
    push eax
    sub edx, edx
    inc dl
    mov is_fin, FALSE
    
    inchar al
    cmp al, ':'
    jne Analysis
    push eax
    inc dl
    
    inchar al
    cmp al, 'f'
    jne Analysis
    push eax
    inc dl
    
    inchar al
    cmp al, 'i'
    jne Analysis
    push eax
    inc dl
    
    inchar al
    cmp al, 'n'
    jne Analysis
    push eax
    inc dl
    
    inchar al
    cmp al, ':'
    jne Analysis
    push eax
    inc dl
    
    inchar al
    cmp al, '-'
    jne Analysis
    
    mov is_fin, TRUE

Del_fin_reg:
    pop eax
    dec edx
    cmp edx, 0
    jne Del_fin_reg
    
    ;После этого участка на стеке будет лежать dl символов
    ;Если финиш, то поднимится сооветсвующий флаг
    
    jmp Out_read

;------------------------------------------------------------------------------

Slash_check:
    mov is_slash, TRUE
    sub edx, edx
    mov edx, 2
    inchar al
    
    cmp al, '\'
    je Write_char
    jmp Is_num
    
Number_check:
    inchar al
    
Is_num:
    cmp al, '0'
    jb Analysis
    cmp al, '9'
    ja Is_letter
    sub al, '0'
    jmp After_num_check
    
Is_letter:
    cmp al, 'a'
    jb Analysis
    cmp al, 'f'
    ja Analysis
    sub al, 'a'
    add al, 10
    
    
After_num_check:
    push eax
    dec dl
    cmp edx, 0
    jne Number_check
    
    jmp Analysis

;------------------------------------------------------------------------------
    
Read_text endp

;==============================================================================

;                     ///Процедура нахождения метрики\\\
;      На вход подаются:
;   1) Ссылка на переменную, где хранится длина текста
;   2) Ссылка на начало текста

Find_metric proc

    ;ПРОЛОГ
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    ;КОНЕЦ ПРОЛОГА
    
    mov ebx, [ebp + 8]
    mov eax, [ebp + 12]
    mov ecx, [eax]
    mov eax, 0
    mov edx, 0
    
Metric_loop:
    mov al, [ebx]
    cmp al, 9     ;Табуляция
    je Inc_metric
    cmp al, 10    ;Возврат каретки
    je Inc_metric
    cmp al, 13    ;Новая строка
    je Inc_metric
    cmp al, 32    ;Пробел
    je Inc_metric
    jmp Return_metic

Inc_metric:
    inc edx
    jmp Return_metic
    
Return_metic:
    inc ebx
    dec ecx
    cmp ecx, 0
    jne Metric_loop
    
    ;ЭПИЛОГ
    mov eax, [ebp + 16]
    mov [eax], dx
    pop edx
    pop ecx
    pop ebx
    pop eax
    pop ebp
    ret 3*4
    ;КОНЕЦ ЭПИЛОГА

Find_metric endp

;==============================================================================

;                 ///Процедура записи текста задом наперёд\\\
;      На вход подаются:
;   1) Ссылка на переменную, где хранится длина текста
;   2) Ссылка на начало текста

Make_text_backwards proc

    ;ПРОЛОГ
    push ebp
    mov ebp, esp
    push eax
    push edx
    push ebx
    push ecx
    ;КОНЕЦ ПРОЛОГА
    
    mov eax, [ebp + 12]
    mov eax, [eax]
    cmp ax, 1
    je Out_backwards
    mov temp, eax
    mov edx, 0
    div for_backwards
    mov edx, 0
    mov ecx, 0
    mov cx, ax
    
    mov eax, [ebp + 8]
    mov ebx, [ebp + 8]
    add bx, word ptr temp
    dec ebx
    
Backwards_loop:
    mov dl, [ebx]
    mov temp_char, dl
    mov dl, [eax]
    mov [ebx], dl
    mov dl, temp_char
    mov [eax], dl
    
    dec ebx
    inc eax
    dec ecx
    cmp ecx, 0
    jne Backwards_loop
    
    ;ЭПИЛОГ
Out_backwards:
    pop ecx
    pop ebx
    pop edx
    pop eax
    pop ebp
    ret 2*4
    ;КОНЕЦ ЭПИЛОГА


Make_text_backwards endp

;==============================================================================

;               ///Процедура для изменения на # всех символов\\\
;              ///        после последнего включения b        \\\
;      На вход подаются:
;   1) Ссылка на переменную, где хранится длина текста
;   2) Ссылка на начало текста

Change_after_b proc

    ;ПРОЛОГ
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    ;КОНЕЦ ПРОЛОГА
    
    mov eax, [ebp + 12]
    mov ecx, 0
    mov cx, [eax]
    mov eax, 0
    mov ebx, [ebp + 8]
    add ebx, ecx
    dec ebx
    mov al, [ebx]
    
Change_after_b_loop:
    mov al, [ebx]
    cmp al, 'b'
    je Found_b
    mov al, '#'
    mov [ebx], al
    
    dec ebx
    dec ecx
    cmp ecx, 0
    jne Change_after_b_loop
    
    ;ЭПИЛОГ
Found_b:
    pop ecx
    pop ebx
    pop eax
    pop ebp
    ret 2*4
    ;КОНЕЦ ЭПИЛОГА

Change_after_b endp

;==============================================================================

;                      ///Процедура вывода текста\\\
;      На вход подаются:
;   1) Ссылка на переменную, где хранится длина текста
;   2) Ссылка на начало текста

Out_text proc

    ;ПРОЛОГ
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    ;КОНЕЦ ПРОЛОГА
    
    mov eax, [ebp + 12]
    mov eax, [eax]
    mov ecx, 0
    mov cx, ax
    mov ebx, [ebp + 8]
    outchar 34
    outchar 34
    outcharln 34
    
Write_loop:
    mov al, [ebx]
    cmp al, 34
    je Check_for_three_q_m
    
    outchar al

No_three_quot_marks:
    inc ebx
    dec ecx
    cmp ecx, 0
    jne Write_loop
    
    ;ЭПИЛОГ
Out_write:
    outchar 34
    outchar 34
    outcharln 34
    pop ecx
    pop ebx
    pop eax
    pop ebp
    ret 2*4
    ;КОНЕЦ ЭПИЛОГА

;------------------------------------------------------------------------------

;ПРОВЕРКА ТРЁХ КАВЫЧЕК
Check_for_three_q_m:
    dec ecx
    cmp ecx, 0
    jne Another_to_read_1
    outchar al
    jmp Out_write
    
Another_to_read_1:
    inc ebx
    mov al, [ebx]
    cmp al, 34
    je Two_q_m
    outchar 34
    outchar al
    jmp No_three_quot_marks

Two_q_m:
    dec ecx
    cmp ecx, 0
    jne Another_to_read_2
    outchar 34
    outchar 34
    jmp Out_write
    
Another_to_read_2:
    inc ebx
    mov al, [ebx]
    cmp al, 34
    je Three_q_m
    outchar 34
    outchar 34
    outchar al
    jmp No_three_quot_marks

;Если три кавычки, то экранируем их
Three_q_m:
    outchar '\'
    outchar 34
    outchar 34
    outchar 34
    jmp No_three_quot_marks

;------------------------------------------------------------------------------

Out_text endp

;==============================================================================

;Аварийный выход из программы

Read_error:
    outstrln 'Length of the string is over max value / equals zero'
    exit 1

;------------------------------------------------------------------------------

;                      ///ОСНОВНАЯ ЧАСТЬ ПРОГРАММЫ\\\

Start:
    ConsoleTitle "Input and texp processing"
    
    ; Приветственное сообщение
    outstrln 'Programm for inputting and processing two texts using Assembler'
    newline
    outstrln 'Rules of text processing:'
    outstr   '1) Replace with # all elements following the last '
    outstrln 'occurrence of b in the text - #7'
    outstrln '2) Write the text backwards - #1'
    newline
    outstrln 'Length metric:'
    outstrln 'the number of whitespace characters in the text - #3'
    ;Приглашение на ввод первого текста
    newline 2
    outstrln 'Enter the first text'
    newline 1
    ;Ввод первого текста
    push offset is_error
    push offset len_text_1
    push offset text_1
    call Read_text
    cmp is_error, TRUE
    je Read_error
    ;Приглашение на ввод второго текста
    newline 1
    outstrln 'Enter the second text'
    newline 1
    ;Ввод вторго текста
    push offset is_error
    push offset len_text_2
    push offset text_2
    call Read_text
    cmp is_error, TRUE
    je Read_error
    ;Вычисление метрики первого текста
    push offset metric_1
    push offset len_text_1
    push offset text_1
    call Find_metric
    ;Вычисление метрики второго текста
    push offset metric_2
    push offset len_text_2
    push offset text_2
    call Find_metric
    ;Сравнение метрик текстов
    push eax
    mov ax, metric_1
    cmp ax, metric_2
    pop eax
    jb Second_is_bigger
    
;=======================ВТОРОЙ ТЕКСТ МЕНЬШЕ ПЕРВОГО============================
    
    ;Переворот большего текста
    push offset len_text_1
    push offset text_1
    call Make_text_backwards
    ;Преобразование (--> #) меньшего текста
    push offset len_text_2
    push offset text_2
    call Change_after_b
    ;Информация о меньшем тексте
    newline 2
    outstr 'Metric of small text - '
    outwordln metric_2
    outstr 'Length of small text - '
    outwordln len_text_2
    newline
    ;Вывод меньшего текста
    push offset len_text_2
    push offset text_2
    call Out_text
    ;Информация о большем тексте
    newline 2
    outstr 'Metric of bigger text - '
    outwordln metric_1
    outstr 'Length of bigger text - '
    outwordln len_text_1
    newline
    ;Вывод большего текста
    push offset len_text_1
    push offset text_1
    call Out_text

    jmp Na_vihod

;=========================ПЕРВЫЙ ТЕКСТ МЕНЬШЕ ВТОРОГО==========================

Second_is_bigger:
    ;Переворот большего текста
    push offset len_text_2
    push offset text_2
    call Make_text_backwards
    ;Преобразование (--> #) меньшего текста
    push offset len_text_1
    push offset text_1
    call Change_after_b
    ;Информация о меньшем тексте
    newline 2
    outstr 'Metric of small text - '
    outwordln metric_1
    outstr 'Length of small text - '
    outwordln len_text_1
    newline
    ;Вывод меньшего текста
    push offset len_text_1
    push offset text_1
    call Out_text
    ;Информация о большем тексте
    newline 2
    outstr 'Metric of bigger text - '
    outwordln metric_2
    outstr 'Length of bigger text - '
    outwordln len_text_2
    newline
    ;Вывод большего текста
    push offset len_text_2
    push offset text_2
    call Out_text

Na_vihod:
    newline
	exit 0
	end Start
