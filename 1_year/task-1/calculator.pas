program calculator;
uses Crt;

const
    MAX_LONGINT = 2147483647;        {Максимальное значение типа LongInt}
    MAX_LONGWORD = 4294967295;       {Максимальное значение типа LongWord}
    MAX_DOUBLE = 1.7E+308;           {Максимальное значение типа Double}
    MAX_INT64 = 9223372036854775807; {Максимальное значение типа Int64}
    DIGITS_AFTER_THE_DOT = 100;      {Максимальное число знаков после запятой}

var
    i: integer;                      {Счётчик}
    alphabet: array [0..69] of char; {Алфавит}
    epsilon: real;                   {Эпсилон в пределах [0, 1]}
    accuracy: integer;               {Точность - кол-во знаков после запятой}
    num_base: integer;               {Место хранения очередного осн. СС из ParamStr}
    input_chr: char;                 {Считываемый символ}
    res: double;                     {Результат}
    code: integer;                   {Код ошибки для Val}

{----------------------------------------------------------------------}

{
    Процедура выхода из программы при встрече со строкой
    неправильного формата
}

procedure Not_a_line;

begin
    writeln('All operations must be written in form');
    writeln('<sign> <base>:<numerator>/<denominator>');
    Halt(0)
end;

{----------------------------------------------------------------------}

{
    Функция возведение числа в целую стпепень
}

function Power(number: LongInt; n: integer): LongInt;

var
    temp: LongInt;
    i: integer;

begin
    if (n = 0) then Power := 1;
    if (n > 0) then
    begin
        temp := number;
        for i := 2 to n do number := number * temp;
        Power := number
    end;
end;

{----------------------------------------------------------------------}

{
    Процедура, проверющая, входит ли результат после очередной операции
    в границы типа Double. Если нет, то выводит ошибку
}

function Is_in_borders(sign: char; res, x: Extended): Boolean;

var
    flag: boolean;

begin
    flag := False;
    
    case sign of
        '+': if (abs(res + x) > MAX_DOUBLE) then flag := True;
        '-': if (abs(res - x) > MAX_DOUBLE) then flag := True;
        '*': if (abs(res * x) > MAX_DOUBLE) then flag := True;
        '/': if (abs(res / x) > MAX_DOUBLE) then flag := True;
    end;
    
    if flag then
    begin
        writeln('The answer is out of double');
        Writeln('The last appropriate result will be shown');
        writeln;
        Is_in_borders := False
    end
    else Is_in_borders := True;
end;

{----------------------------------------------------------------------}

{
    Процедура, проверяющая на Eof перед каждым чтением элемента
}

procedure Read_Eof(var finish: Boolean);

begin
    if not(Eof) then Read(input_chr);
end;

{----------------------------------------------------------------------}

{
    Проверка вхождения очередного символа в алфавит
}

procedure Is_in_alph;

var
    is_in_alph: Boolean; {Входит ли символ в алфавит: True, False}
    j: integer;          {Счётчик}

begin
    is_in_alph := False;
    
    for j := 0 to 69 do
    begin
        if (input_chr = alphabet[j]) then is_in_alph := True;
    end;

    if not(is_in_alph) then Not_a_line;
end;

{----------------------------------------------------------------------}

{
    Переход на новую строку с проверкой на конец файла
}

procedure To_next_line(var finish: Boolean);

begin
    if not(eof) then
    begin
        Readln;
        Read_Eof(finish)
    end
    else
    begin
        WriteLn('There is no finish word');
        Halt(0)
    end
end;

{----------------------------------------------------------------------}

{
    Ищем слово finish
}

procedure Is_finish(var finish: boolean);

var
    input_chr: char; {Очередной считываемы элемент}

begin
    read(input_chr);
    if input_chr = 'i' then
    begin
        read(input_chr);
        if input_chr = 'n' then
        begin
            read(input_chr);
            if input_chr = 'i' then
            begin
                read(input_chr);
                if input_chr = 's' then
                begin
                    read(input_chr);
                    if input_chr = 'h' then finish := True;
                end
                else Not_a_line
            end
            else Not_a_line
        end
        else Not_a_line
    end
    else Not_a_line
end;

{----------------------------------------------------------------------}

{
    Функция перевода числа из 10-ой СС в n-нную СС
}

procedure From_ten_to_n(
    n: integer; 
    a: double);

var
    integer_part: Int64;     {Целая часть числа}
    fractional_part: double; {Дробная часть числа}
    len: Int64;              {Длина целой части}
    j: integer;              {Счётчик}
    after_the_dot: double;   {Количество цифр после запятой в n-нной СС}
    temp: SmallInt;             {Временная переменная для хранения очередной
                              цифры разложения}
    
begin
    if n < 10 then write(' ');
    if a < 0 then write('-');

    a := abs(a);

    integer_part := trunc(a);
    fractional_part := frac(a);
    
    if (integer_part = 0) then write(0)
    else 
    begin
    	len := Trunc(ln(integer_part) / ln(n) + 1);

        for j := 1 to len do
        begin
            temp := integer_part div Power(n, len - j);
            write(alphabet[temp]);
            integer_part := integer_part - Power(n, len - j) * temp;
        end;
    end;

    if (epsilon <> 1) and (fractional_part = 0) then
    begin
        after_the_dot := -(ln(epsilon)/ln(n)) + 2;
        write('.');
        for j := 1 to Trunc(after_the_dot) do
            write(0)
    end;

    if (epsilon <> 1) and (fractional_part <> 0) then
    begin
        write('.');
        j := 0;

        after_the_dot := -(ln(epsilon)/ln(n)) + 1;

        if (after_the_dot > DIGITS_AFTER_THE_DOT) then
        begin
            after_the_dot := DIGITS_AFTER_THE_DOT
        end;
        
        repeat
        begin
            fractional_part := fractional_part * n;
            write(alphabet[trunc(fractional_part)]);
            fractional_part := frac(fractional_part);
            j := j + 1;
        end
        until (j > after_the_dot);
    end;
    WriteLn
end;

{---------------------------------------------------------------------}

{
    Основная процедура, производящая разбиение строки на части и
    производящая операции на результатом
}

procedure Math_operation;

var
    sign: char;            {знак операции}
    flag: boolean;         {нужен для понимания, правильно ли записана операция}
    numerator: longint;    {числитель дроби}
    denominator: longword; {знаменатель дроби}
    addition: double;      {часное от деления числителя на знаменатель}
    base: integer;         {основание СС}
    finish: boolean;       {флаг для нахождения слово finish}
    part: 0..2;            {нужен для понимания части: 
                            основание - 0; 
                            числитель - 1; 
                            наменатель - 2}
    minus: integer;        {сколько минусов стоит перед числителем}
    
begin
    finish := False;
    part := 0;

    Read_Eof(finish);
    
    repeat
    begin
        {
            Проверяю случай, когда сразу финиш
        }

        if (input_chr = 'f') then Is_finish(finish);

        {
            Если финиш, то всё
        }

        if finish then Break;

        {
            Если видим комментарий, переходим на следующую строку
        }

        if input_chr = ';' then
        begin
            To_next_line(finish);
            Continue
        end;
        
        {
            Пропускаем пробелы
        }

        if (input_chr = #32) or (input_chr = #9) or 
            (input_chr = #10) or (input_chr = #13) then 
        begin
            if not(Eoln) then
            begin
                Read_Eof(finish);
                Continue
            end
            else
            begin
                To_next_line(finish);
                Continue
            end
        end;

        {
            Начинаем считывать операцию
        }

        if (input_chr = '+') or (input_chr = '-') or
           (input_chr = '*') or (input_chr = '/') then
        begin
            sign := input_chr;
            base := 0;
            numerator := 0;
            denominator := 0;
            flag := False;
            minus := 0;

            {
                Считывание и обработка основания СС
            }

            repeat
                Read_Eof(finish);

                if (input_chr = #32) or (input_chr = #9) or (input_chr = #13) then 
                begin
                    if not(Eoln) then 
                    begin
                        continue
                    end
                    else Break;
                end;

                if (input_chr = ':') then
                begin
                    part := 1;
                    Break
                end;

                Is_in_alph;

                if (pos(input_chr, alphabet) - 1 >= 10) then
                begin
                    Writeln('Every base must be written in decimal number system');
                    Writeln('The last appropriate result will be shown');
                    writeln;
                    Exit
                end;

                base := base * 10;
                base := base + (pos(input_chr, alphabet) - 1);

            until Eoln or (input_chr = ';');
        end
        else Not_a_line;

        {
            Считывание и обработка числителя дроби
        }

        if (part = 1) and (input_chr <> ';') and not(Eoln) then
        begin
            repeat
                Read_Eof(finish);

                if (input_chr = #32) or (input_chr = #9) or 
                    (input_chr = #10) or (input_chr = #13) then 
                begin
                    if not(Eoln) then 
                    begin
                        continue
                    end
                    else Break;
                end;

                if (input_chr = ';') then break;

                if (input_chr = '-') then 
                begin
                    minus := minus + 1;
                    Continue
                end;

                if (input_chr = '/') then
                begin
                    part := 2;
                    Break
                end;

                Is_in_alph;

                if (pos(input_chr, alphabet) - 1 >= base) then
                begin
                    Writeln('One of the numbers is in the wrong numeral system');
                    Writeln('The last appropriate result will be shown');
                    writeln;
                    Exit
                end;

                if (numerator > ((MAX_LONGINT - 
                    (pos(input_chr, alphabet) - 1))/ base)) and 
                    not(Odd(minus)) then
                begin
                    Writeln('Numerator is out of LongInt');
                    Writeln('The last appropriate result will be shown');
                    writeln;
                    Exit
                end;

                if (numerator < ((-(MAX_LONGINT + 1) - 
                    (pos(input_chr, alphabet) - 1))/ base)) and 
                    Odd(minus) then
                begin
                    Writeln('Numerator is out of LongInt');
                    Writeln('The last appropriate result will be shown');
                    writeln;
                    Exit
                end;

                numerator := numerator * base;
                numerator := numerator + (pos(input_chr, alphabet) - 1);

            until Eoln;
        end;

        {
            Считывание и обработка знаменателя дроби
        }

        if (part = 2) and (input_chr <> ';') and not(Eoln) then
        begin
            repeat
                Read_Eof(finish);

                if (input_chr = #32) or (input_chr = #9) or 
                    (input_chr = #10) or (input_chr = #13) then 
                begin
                    if not(Eoln) then 
                    begin
                        continue
                    end
                    else Break;
                end;

                if (input_chr = ';') then break;

                if (input_chr = '-') then 
                begin
                    WriteLn('Denominator can not be negative');
                    Writeln('The last appropriate result will be shown');
                    writeln;
                    Exit
                end;

                Is_in_alph;

                if (pos(input_chr, alphabet) - 1 >= base) then
                begin
                    Writeln('One of the numbers is in the wrong numeral system');
                    Writeln('The last appropriate result will be shown');
                    writeln;
                    Exit
                end;

                if (denominator > ((MAX_LONGWORD - 
                    (pos(input_chr, alphabet) - 1))/ base)) then
                begin
                    Writeln('Denominator is out of LongWord');
                    Writeln('The last appropriate result will be shown');
                    writeln;
                    Exit
                end;

                denominator := denominator * base;
                denominator := denominator + (pos(input_chr, alphabet) - 1);
                flag := True

            until Eoln;
        end;
        
        if not(flag) then Not_a_line;
            
        if (base < 2) or (base > 70) then
        begin
            Writeln('One of the bases - ', base, ' - is out of range');
            Writeln('Base of the number system may be only in range of [2, 70]');
            Writeln('The last appropriate result will be shown');
            writeln;
            Exit
        end;

        if Odd(minus) then numerator := (-1) * numerator;

        {
            Вычисление результата после каждой прочтённой строки
        }
        
        if (denominator <> 0) then 
            addition := (numerator / denominator)
        else
        begin
            writeln('You can not divide by zero');
            Writeln('The last appropriate result will be shown');
            writeln;
            Exit
        end;

        case sign of
            '+': begin 
                    if Is_in_borders('+', res, addition) then 
                        res := res + addition
                    else Exit
                 end;
            '-': begin 
                    if Is_in_borders('-', res, addition) then 
                        res := res - addition
                    else Exit
                 end;
            '*': begin 
                    if Is_in_borders('*', res, addition) then 
                        res := res * addition
                    else Exit
                 end;
            '/': if (numerator <> 0) then
                 begin
                    if Is_in_borders('/', res, addition) then 
                        res := res / addition
                    else Exit
                 end
                 else
                 begin
                    writeln('You can not divide by zero');
                    Writeln('The last appropriate result will be shown');
                    writeln;
                    Exit
                 end
        end;
        Readln;
        Read_Eof(finish)
    end
    until finish or Eof;
    
    if not(finish) then
    begin
        WriteLn('There is no finish word');
        Halt(0)
    end;
end;

{---------------------------------------------------------------------}

begin
    ClrScr;

    {
        Задаём алфавит
    }
    
    for i := 0 to 9 do alphabet[i] := chr(48 + i);
    for i := 10 to 35 do 
    begin
        alphabet[i] := chr(65 - 10 + i);
        alphabet[i + 26] := chr(97 - 10 + i);
    end;
    alphabet[62] := '!'; alphabet[63] := '@';
    alphabet[64] := '#'; alphabet[65] := '$';
    alphabet[66] := '%'; alphabet[67] := '^';
    alphabet[68] := '&'; alphabet[69] := '*';

    {
        Считываем эпсилон, устанавливаем accuracy - точность округления
    }

    if (ParamCount = 0) then
    begin
        WriteLn('No parameters given. Unable to display the answer');
        Halt(0)
    end;

    res := 0;
    val(ParamStr(1), epsilon, code);

    if (code <> 0) then
    begin
        Writeln('Wrong epsilon, try real number between 0 and 1');
        Halt(0)
    end;

    if (epsilon > 1) or (epsilon < 0) then
    begin
        Writeln('Epsilon is out of range');
        Writeln('Number must be in range of [0, 1]');
        Halt(0)
    end;

    if (epsilon = 0) then
    begin
        Writeln('Unable to display result with this rounding');
        Halt(0)
    end;

    if (ParamCount = 1) then
    begin
        WriteLn('No base parameters. Unable to display the answer');
        Halt(0)
    end;

    if (epsilon <> 1) then accuracy := Length(ParamStr(1)) - 2;

    {
        Основная процедура - считывание строк и их обработка
    }
    
    Math_operation;

    if (epsilon = 1) then res := round(res);

    {
        Считывание остальных параметров и непосредственно вывод
        результата в указанных системах счисления
    }

    if (abs(res) > MAX_INT64) then
    begin
        writeln('Integer part of the answer is out of Int64');
        writeln('Result in the decimal number system is:');
        Writeln(res);
        Halt(0)
    end;
    
    for i := 2 to ParamCount do
    begin
        val(ParamStr(i), num_base, code);

        if (code <> 0) then
        begin
            Writeln('Bases must be given in decimal number system');
            Halt(0)
        end;
        
        if (num_base < 2) or (num_base > 70) then
        begin
            Writeln('One of the bases - ', num_base, ' - is out of range');
            Writeln('Base of the number system may be only in range of [2, 70]');
            continue
        end;
        
        if (res = 0) then
        begin
            if (num_base < 10) then
                writeln(num_base, '  ', 0)
            else
                writeln(num_base, ' ', 0);
            continue
        end;

        {
            Чтобы произвести вывод в соответствии с требованием,
            произведено разделение процесса на 3 случая, когда
            основание СС: 1) <10; 2) >10; 3) =10.
        }

        if (num_base < 10) then
        begin
            write(num_base, ' ');
            From_ten_to_n(num_base, res)
        end;
        
        if (num_base > 10) then
        begin
            write(num_base, ' ');
            From_ten_to_n(num_base, res)
        end;

        if (num_base = 10) then
        begin
            write(num_base, ' ');
            write(res:0:accuracy);
            Writeln
        end
    end
end.
