program graph;

uses Crt, sysutils, math;

const
    MAX_LONGINT = 2147483647;
    INFINITY = 1.0 / 0.0;

type
    superstring_t = array of char;          {Суперстрока - строка произвольной 
                                            длины}

    supertext_t = array of superstring_t;   {Массив суперстрок}

    city_t = record                    {Запись, содержащая всю информацию о 
                                        ребре графа}
        from_city: superstring_t;           {Город отправления}
        to_city: superstring_t;             {Город прибытия}
        transport_type: superstring_t;      {Вид транспорта}
        cruise_time: LongInt;               {Время поездки}
        cruise_fare: LongInt                {Стоимость поездки}
    end;

    map_t = array of city_t;                {Карта - массив рёбер графа}

    unique_t = record                  {
                                            Запись, содержащая информацию о всех
                                            уникальных городах отправления
                                            Необходима для реализации алгоритма 
                                            Беллмана-Форда
                                        }
        city: superstring_t;                {Сам город отправления}
        time: Double;                       {Минимальное время пути в 
                                            город city}
        fare: Double;                       {Минимальная стоимость для прибытия
                                            в город city}                       
        from_where: superstring_t;          {Город, откуда мы приехали 
                                            (нужен 1 - 3 режимов)}
        transport: superstring_t;           {Вид транспорта, на 
                                            котором мы приехали}
        visited: Single                     {Количесво посещённых городов}
    end; 

    superunique_t = array of unique_t;      {Массив всех записей, содержащих 
                                            уникальные города отправления}

var
    file_name: string;                      {Название файла, берётся из 
                                            параметра консоли}
    FC: Text;                               {Файловый дискриптор, связанный со 
                                            считываемым файлом}
    mode: longint;                          {Режим работы}
                                         
                                            {
    
        1. Среди кратчайших по времени путей между двумя городами найти
    путь минимальной стоимости. Если город достижим из города отправления.

        2. Среди путей между двумя городами найти путь минимальной стоимости. 
    Если город достижим из города отправления.

        3. Найти путь между двумя городами минимальный по числу посещённых 
    городов.

        4. Найти множество городов, достижимое из города отправителя 
    не более, чем за limit_cost денег.

        5. Найти множество городов, достижимое из города отправителя 
    не более, чем за limit_time времени.

                                            }

    map: map_t;                             {Карта - множество рёбер графа}
    unique_c_from: superunique_t;           {Массив уникальных городов}
    unique_t_t: supertext_t;                {Массив всех уникальных видов 
                                            транспорта}
    original_color: Byte;                   {Цвет текста по умолчанию}
    error_color: Byte;                      {Цвет ошибки}
    chosen_transports: supertext_t;         {Выбранные виды транспорта}

{==============================================================================}
function Out_of_borders_double(
    number: Double
    ): Boolean;

begin
    if number > MAX_LONGINT then
        Out_of_borders_double := True
    else
        Out_of_borders_double := False
end;

{==============================================================================}

{
    Функция, проверяющая число на переполнение типа LongInt
}

function Out_of_borders(
    number: Longint;
    addition: SmallInt
    ): Boolean;

begin
    if (number * 10 + addition) > MAX_LONGINT then
        Out_of_borders := True
    else
        Out_of_borders := False
end;

{==============================================================================}

{
    Процедура, говорящая о том, что выбранного города нет в списке существующих
}

procedure No_city;

begin
    ClrScr;
    TextAttr := Error_color;
    GotoXY(4, 2);
    Writeln('Выбранный город отсутствует в списке');
    GotoXY(4, 3); Writeln('доступных городов');
    GotoXY(1, 5);
    Halt(0)
end;

{==============================================================================}

{
    Процедура, копирующая суперстроку array1 в суперстроку array2
}

procedure Copy_array(
    var array1: superstring_t; 
    var array2: superstring_t
    );

var
    counter: longint;

begin
    SetLength(array2, 0);
    SetLength(array2, Length(array1));

    for counter := 0 to (Length(array1) - 1) do
        array2[counter] := array1[counter];
end;

{==============================================================================}

{
    Процедура, копирующая массив строк superarray1 в массив строк superarray2
}

procedure Copy_superarray(
    var superarray1: supertext_t; 
    var superarray2: supertext_t
    );

var
    counter: longint;

begin
    SetLength(superarray2, 0);
    SetLength(superarray2, Length(superarray1));

    for counter := 0 to (Length(superarray1) - 1) do
        Copy_array(superarray1[counter], superarray2[counter]);
end;
    

{==============================================================================}

{
    Функция, прверяющая равенство двух суперстрок
}

function Are_strings_equal(
    var string_1: superstring_t; 
    string_2: superstring_t
    ): Boolean;

var 
    counter: longint;

begin
    Are_strings_equal := False;
    if Length(string_1) <> Length(string_2) then Exit(False)
    else
    begin
        for counter := 0 to (Length(string_1) - 1) do
            if (string_1[counter] <> string_2[counter]) then Exit(False);
        
        Are_strings_equal := True
    end
end;

{==============================================================================}

{
    Функция, позволяющая определить индекс первого вхождения элемента 
    elem в массив записей superrecord, если такого нет, то выводит -1
    (для решения задачи нужно было лишь взять элемент .city)
}

function Find_index_in_record(
    var superrecord: superunique_t;     {где ищем}
    var elem: superstring_t             {что ищем}
    ): longint;

var
    counter: longint;

begin
    Find_index_in_record := -1;
    for counter := 0 to (Length(superrecord) - 1) do
        if Are_strings_equal(elem, superrecord[counter].city) then 
            Exit(counter);
end;


{==============================================================================}

{
    Функция, позволяющая определить индекс первого вхождения элемента 
    elem в массиве суперстрок superarray, если такого нет, то выводит -1
    (для решения задачи нужно было лишь взять элемент .city)
}

function Find_index(
    var superarray: supertext_t; 
    elem: superstring_t
    ): longint;

var
    counter: longint;

begin
    Find_index := -1;
    for counter := 0 to (Length(superarray) - 1) do
        if Are_strings_equal(elem, superarray[counter]) then Exit(counter);
end;

{==============================================================================}

{
    Процедура, печатающая суперстроку superstring
}

procedure Write_a_string(var superstring: superstring_t);
var
    position: Longint;

begin
    for position := 0 to (Length(superstring) - 1) do
        write(superstring[position]);
end;

{==============================================================================}

{
    Процедура, позволяющая удалить первый элемент elem из
    массива строк superarray
}

procedure Delete_elem_from_array(
    var superarray: supertext_t; 
    var elem: superstring_t
    );

var
    counter: longint;
    max_index: longint;
    elem_index: longint;

begin
    elem_index := Find_index(superarray, elem);
    max_index := Length(superarray) - 1;

    for counter := elem_index to max_index do 
        if counter = max_index then
            SetLength(superarray, Length(superarray) - 1)
        else
            Copy_array(superarray[counter], superarray[counter + 1])
end;

{==============================================================================}

{
    Процедура, реализующая выбор транспорта, на котором пользоватьель
    хочет либо не хочет передвигаться
}

procedure Choose_transports(
    var chosen_transports: supertext_t
    );

var
    t_mode: longint;
    sym: char;
    counter: longint;
    transport_type: longint;
    max_page: integer;
    current_page: integer;
    right, left: Boolean;

{/////////////////////////////////////////////////////////////////}

{
    Подпроцедура, выводящая ошибку при неверном вводе режима выбора
    транспорта
}

procedure Mode_error;

begin
    if (sym <> #10) then Readln;
    GotoXY(4, WhereY);
    TextAttr := Error_color;
    Writeln('Режим работы должен быть числом от 1 до 2');
    TextAttr := original_color;
    GotoXY(1, 4); ClrEol;
    GotoXY(4, 4);
    Write('Мой выбор: ');
    t_mode := 0
end;

{-----------------------------------------------------------------}

{
    Процедура, выводящая ошибку при исключении/выборе несуществующего
    вида транспорта
}

procedure Transport_type_error;

begin
    CLrScr; GotoXY(4, 2);
    TextAttr := Error_color;
    Writeln('Номер вида транспорта должен быть от 1 до ', Length(unique_t_t));
    TextAttr := original_color;
    GotoXY(1, 4);
    Halt(0)
end;

{-----------------------------------------------------------------}

{
    Процедура, выводящая ошибку при полном отсутствии доступных видов
    транспорта
}

procedure No_type_error;

begin
    if (sym <> #10) then Readln;
    GotoXY(4, WhereY);
    TextAttr := Error_color;
    Writeln('Не выбрано ни одного вида транспорта');
    TextAttr := original_color;
    GotoXY(1, 4); ClrEol;
    GotoXY(4, 4);
    Write('Мой выбор: ');
    
    transport_type := 0
end;

procedure No_page_error;

begin
    CLrScr; GotoXY(4, 2);
    TextAttr := Error_color;
    Write('Номер страницы выходит из');
    GotoXY(4, 3); Write('допустимых границ');
    TextAttr := original_color;
    GotoXY(1, 5);
    Halt(0)
end;


{/////////////////////////////////////////////////////////////////}

begin
    SetLength(chosen_transports, 0);

    {
    
    ClrScr; TextAttr := Green;
    GotoXY(4, 2);
    Write('Выберите, что вы хотите сделать');

    GotoXY(1, 6);

    TextAttr := Cyan;
    Writeln('1. Выбрать виды транспорта, на которых я ');
    Writeln('   хочу передвигаться');
    Writeln;
    writeln('2. Выбрать виды транспорта, на которых я ');
    Writeln('   НЕ хочу передвигаться');

    t_mode := 0;

    repeat 
        GotoXY(1, 4); ClrEol;
        GotoXY(4, 4); TextAttr := original_color;
        Write('Мой выбор: ');

        repeat 
            Read(sym);
            if (sym = #4) then Halt(0);

            if (sym <> #32) then 
            begin
                if (ord(sym) < ord ('0')) or (ord(sym) > ord('9')) then 
                    Mode_error
                else
                begin
                    t_mode := t_mode * 10;
                    t_mode := t_mode + (ord(sym) - ord('0'));
                end;

                if t_mode > 2 then Mode_error
            end
        until Eoln
    
    until t_mode <> 0;

    if (sym <> #10) then Readln;

    if (t_mode = 2) then Copy_superarray(unique_t_t, chosen_transports);

    }

    t_mode := 1;

    ClrScr; TextAttr := Green;
    GotoXY(4, 2);
    Write('Выберите виды транспорта');

    GotoXY(1, 6);

    max_page := (Length(unique_t_t) - 1) div 10 + 1;
    current_page := 1;

    TextAttr := Cyan;
    for counter := 1 to min(Length(unique_t_t), 10) do
    begin
        Write(counter, ' ');
        Write_a_string(unique_t_t[counter - 1]);
        writeln
    end;

    GotoXY(1, 17);
    Write('Страница: ', current_page, ' из ', max_page);

    transport_type := 0;
    left := False;
    right := False;
    
    while True do
    begin
        GotoXY(1, 4); ClrEol;
        TextAttr := original_color;
        GotoXY(4, 4); Write('Мой выбор: ');

        Read(sym);
        if (sym = #4) then Halt(0);

        if ((sym = #10) or (sym = #13)) and (Length(chosen_transports) = 0) then
            No_type_error;
        
        if (sym = #10) and (Length(chosen_transports) = Length(unique_t_t)) and 
            (t_mode = 2) then break;

        if (sym <> #32) then 
        begin
            if (sym = 'n') and (eoln) then 
                right := True
            else 
            if (sym = 'p') and (eoln) then
                left := True
            else 
            begin
                if ((ord(sym) < ord ('0')) or (ord(sym) > ord('9'))) then 
                    Transport_type_error;
                
                if Out_of_borders(transport_type, ord(sym) - ord('0')) then
                    Transport_type_error;

                transport_type := transport_type * 10;
                transport_type := transport_type + (ord(sym) - ord('0'));

                if transport_type > Length(unique_t_t) then 
                    Transport_type_error;
            end
        end
        else
        begin
            if (transport_type <> 0) then 
            begin
                if (t_mode = 1) then
                begin
                    SetLength(chosen_transports, Length(chosen_transports) + 1);
                    Copy_array(unique_t_t[transport_type - 1],
                               chosen_transports[Length(chosen_transports) - 1])
                end;
                if (t_mode = 2) then 
                    Delete_elem_from_array(chosen_transports, 
                                           unique_t_t[transport_type - 1])
            end;
            transport_type := 0
        end;

        if right then
        begin
            current_page := current_page + 1;
            if (current_page <= max_page) then
            begin
                GotoXY(1, 6);
                TextAttr := Cyan;
                
                for counter := 1 to 12 do 
                begin
                    ClrEol; WriteLn;
                end;

                GotoXY(1, 17); ClrEol;
                Write('Страница: ', current_page, ' из ', max_page);

                GotoXY(1, 6);
                
                for counter := ((current_page - 1) * 10 + 1) to 
                    min((current_page * 10), Length(unique_t_t)) do
                begin
                    Write(counter, ' ');
                    Write_a_string(unique_t_t[counter - 1]);
                    writeln
                end;
                right := False;
                ReadLn;  
                Continue
            end
            else No_page_error
        end
        else if left then
        begin
            current_page := current_page - 1;
            if (current_page > 0) then
            begin
                GotoXY(1, 6);
                TextAttr := Cyan;

                for counter := 1 to 12 do 
                begin
                    ClrEol; WriteLn;
                end;

                GotoXY(1, 17); ClrEol;
                Write('Страница: ', current_page, ' из ', max_page);

                GotoXY(1, 6);

                for counter := ((current_page - 1) * 10 + 1) to 
                    min((current_page * 10), Length(unique_t_t) - 1) do
                begin
                    ClrEol;
                    Write(counter, ' ');
                    Write_a_string(unique_t_t[counter - 1]);
                    writeln
                end;
                left := False;
                ReadLn;
                Continue
            end
            else No_page_error
        end;

        if eoln then Break
    end;

    if (transport_type <> 0) then 
    begin
        if (t_mode = 1) then
        begin
            SetLength(chosen_transports, Length(chosen_transports) + 1);
            Copy_array(unique_t_t[transport_type - 1],
                        chosen_transports[Length(chosen_transports) - 1])
        end;
        
        if (t_mode = 2) then 
            Delete_elem_from_array(chosen_transports, 
                                    unique_t_t[transport_type - 1])
    end;

    if (Length(chosen_transports) = 0) then No_type_error;

    if (sym <> #10) then Readln

end;

{==============================================================================}

{
    Функция, спрашивающая у пользователя его желание начать/продолжить
    работу
}

function If_continue: Boolean;

var
    counter: longint;
    sym: char;
    is_it: longint;

begin
    is_it := -1;
    ClrScr; TextAttr := Yellow;
    GotoXY(4, 2);
    Write('Хотите ли начать | продолжить работу');
    GotoXY(4, 3);
    Write('программы?');
    GotoXY(4, 5);
    TextAttr := original_color;
    Write('Y|n: ');

    counter := 0;

    repeat
        Read(sym);
        if (sym = #4) then Halt(0);

        if (sym = #10) then break;

        if (sym <> #32) then 
        begin
            Inc(counter);
            
            if (counter >= 2) then
            begin
                ClrScr; TextAttr := Error_color;
                GotoXY(4, 2);
                Writeln('Принимаются значения Y(yes) или n(not)');
                GotoXY(1, 4);
                Halt(0)
            end;

            if (sym = 'y') or (sym = 'Y') then is_it := 1;
            if (sym = 'n') or (sym = 'N') then is_it := 0
        end;   
    until Eoln;

    if (is_it = -1) then
    begin
        ClrScr; TextAttr := Error_color;
        GotoXY(4, 2);
        Writeln('Необходимо ввести значение Y(yes) или n(not)');
        GotoXY(1, 4);
        Halt(0)
    end;

    Readln;

    if (is_it = 0) then If_continue := False;
    if (is_it = 1) then If_continue := True
end;

{==============================================================================}

{
    Процедура, спрашивающая у пользователя режим работы mode
}

procedure Choose_mode(
    var mode: longint
    );

var
    sym: char;

{/////////////////////////////////////////////////////////////////}

{
    Процедура, выводящая ошибку при неправильном вводе режима работы
}

procedure Mode_error;

begin
    if (sym <> #10) then Readln;
    GotoXY(4, WhereY);
    TextAttr := Error_color;
    Writeln('Режим работы должен быть числом от 1 до 5');
    TextAttr := original_color;
    GotoXY(1, 4); ClrEol;
    GotoXY(4, 4);
    Write('Режим: ');
    mode := 0;
end;

{/////////////////////////////////////////////////////////////////}
    
begin
    ClrScr;

    TextAttr := Green;
    GotoXY(4, 2);
    Write('Выберите режим работы программы');
    GotoXY(1, 6);

    TextAttr := original_color;
    Writeln('Доступные режимы работы:');

    Writeln; TextAttr := Cyan;
   
    Writeln('1. Среди самых коротких путей найти ');
    Writeln('самый дешёвый.'); Writeln;
    
    Writeln('2. Найти один из самых дешёвых путей.'); Writeln;

    Writeln('3. Найти путь между двумя городами ');
    Writeln('минимальный по числу посещённых городов.'); Writeln;

    Writeln('4. Найти все города, куда можно добраться '); 
    Writeln('за limit_cost денег.'); Writeln;

    Writeln('5. Найти все города, куда можно добраться ');
    Writeln('за limit_time минут.');

    mode := 0;

    repeat
        GotoXY(4, 1); ClrEol; GotoXY(4, 4); TextAttr := original_color;
        Write('Режим: ');
        mode := 0;
        repeat 
            Read(sym);
            if (sym = #4) then Halt(0);

            if (sym <> #32) then 
            begin
                if (ord(sym) < ord ('0')) or (ord(sym) > ord('9')) then Mode_error
                else
                begin
                    mode := mode * 10;
                    mode := mode + (ord(sym) - ord('0'));
                end;

                if mode > 5 then Mode_error
            end
        until Eoln

    until mode <> 0;
    Readln
end;

{==============================================================================}

{
    Процедура, выводящяя ошибку о неправильности формата строки в
    считываемом файле
}

procedure Wrong_format;

begin
    CLrScr;
    GotoXY(4, 2); TextAttr := Error_color;
    Writeln('Файл содержит строки неверного формата'); Writeln;
    TextAttr := Green;
    Writeln('Все строки должны быть следующего вида:'); Writeln;
    TextAttr := original_color;
    Writeln('         "город_отправления"');
    Writeln('         "город_прибытия"');
    Writeln('         "вид_транспорта"');
    Writeln('          время_поездки');
    Writeln('          стоимость_поезки');
    Writeln;
    Halt(0)
end;

{==============================================================================}

{
    Процедура, производящая считывание данных из данного файла и
    записывающая их в массивы map, unique_c_from и unique_t_t
}

procedure Make_a_map(
    var FC: Text;                          {Наш счиываемый файл}
    var map: map_t;                        {Карта, содержащая все рёбра графа}
    var unique_c_from: superunique_t;      {Массив уникальных городов графа}
    var unique_t_t: supertext_t            {Массив уникальных видов транспорта}
    );

var
    i: longint;                            {Универсальный чётчик}
    map_len: longint;                      {Длина карты}
    sym: char;                             {Очередной считываемый символ}
    flag: longint;                         {Флаг, принимающий значения}
    
    {
        0 - до первого элемента строки
        1 - процесс чтения города отправления
        2 - между 1 и 3
        3 - процесс чтения транспорта
        4 - между 3 и 5
        5 - процесс чтения транспорта
        6 - после чтения транспорта
        7 - чтение времени поездки
        8 - между 7 и 9
        9 - чтение стоимости поездки
        10 - после всех эл-тов
    }

    words: array [1..3] of superstring_t;  {Массив трёх считываемых слов}
    nums: array [1..2] of Longint;         {Массив двух считываемых чисел}
    unique_flag: Boolean;                  {Уникален ли город}

begin
    Reset(FC);
    
    for i := 1 to 3 do SetLength(words[i], 0);
    for i := 1 to 2 do nums[i] := -1;
    flag := 0;
    map_len := 1;

    if Eof(FC) then
    begin
        ClrScr; TextAttr := Error_color;
        GotoXY(4, 2);
        Writeln('Зачем вы мне подсунули пустой файл');
        GotoXY(1, 4);
        Halt(0)
    end;

    repeat                             {Чтение строк}

        repeat                         {Чтение отдельной строки}
            
            Read(FC, sym);

            {
                Если видим комментарий, переходим на следующую строку
            }

            if sym = '#' then
            begin
                while not(Eoln(FC)) do Read(FC, sym);
                Break
            end;
            
            {
                Пропускаем пробелы
            }

            if (sym = #32) or (sym = #9) or 
                (sym = #10) or (sym = #13) then 
            begin
                if (flag <> 7) and (flag <> 9) then
                begin
                    if not(Eoln(FC)) then Continue
                    else break
                end
                else
                    if (flag = 7) then flag := 8
                    else flag := 10;
                    if not(Eoln(FC)) then Continue
                    else break
            end;

            {
                Считываем город отправления
            }

            if (flag = 0) then
                if (sym = #34) then 
                begin
                    flag := 1;
                    i := 1;
                end
                else Wrong_format
            
            else if (flag = 1) then
                if (sym = #34) then flag := 2
                else
                begin
                    SetLength(words[1], i);
                    words[1][Length(words[1]) - 1] := sym;
                    Inc(i)
                end

            {
                Считываем город прибытия
            }
            
            else if (flag = 2) then
                if (sym = #34) then 
                begin
                    flag := 3;
                    i := 1;
                end
                else Wrong_format
            
            else if (flag = 3) then
                if (sym = #34) then flag := 4
                else
                begin
                    SetLength(words[2], i);
                    words[2][Length(words[2]) - 1] := sym;
                    Inc(i)
                end
            
            {
                Считываем вид транспорт
            }
            
            else if (flag = 4) then
                if (sym = #34) then 
                begin
                    flag := 5;
                    i := 1;
                end
                else Wrong_format
            
            else if (flag = 5) then
                if (sym = #34) then flag := 6
                else
                begin
                    SetLength(words[3], i);
                    words[3][Length(words[3]) - 1] := sym;
                    Inc(i)
                end
            
            {
                Считываем время поездки
            }

            else if (flag = 6) then
                if (ord(sym) >= ord('0')) and 
                    (ord(sym) <= ord('9')) then
                begin
                    flag := 7;
                    nums[1] := 0;
                    nums[1] := nums[1] + (ord(sym) - ord('0'))
                end
                else Wrong_format
            
            else if (flag = 7) then
                if (ord(sym) >= ord('0')) and 
                    (ord(sym) <= ord('9')) then
                begin
                    if not(Out_of_borders(nums[1], (ord(sym) - ord('0')))) then
                    begin
                        nums[1] := 10 * nums[1] + (ord(sym) - ord('0'))
                    end
                    else
                    begin
                        ClrScr; TextAttr := Error_color;
                        GotoXY(4, 2);
                        Writeln('Одно из чисел выходит за границы типа');
                        GotoXY(1, 4);
                        Halt(0)
                    end
                end
                else Wrong_format
            
            {
                Считываем стоимость поездки
            }

            else if (flag = 8) then
                if (ord(sym) >= ord('0')) and 
                    (ord(sym) <= ord('9')) then
                begin
                    flag := 9;
                    nums[2] := 0;
                    nums[2] := nums[2] + (ord(sym) - ord('0'))
                end
                else Wrong_format
            
            else if (flag = 9) then
                if (ord(sym) >= ord('0')) and 
                    (ord(sym) <= ord('9')) then
                begin
                    if not(Out_of_borders(nums[2], (ord(sym) - ord('0')))) then
                    begin
                        nums[2] := 10 * nums[2] + (ord(sym) - ord('0'))
                    end
                    else
                    begin
                        ClrScr; TextAttr := Error_color;
                        GotoXY(4, 2);
                        Writeln('Одно из чисел выходит за границы типа');
                        GotoXY(1, 4);
                        Halt(0)
                    end
                end
                else Wrong_format

            {
                Проверяем, что других эл-тов в строке нет
            }
            
            else if (flag = 10) then Wrong_format;



        until Eoln(FC);                {Чтение отдельной строки}

        {
            Если все элементы строки существуют, то записываем их в массив map
        }

        if (words[1] <> Nil) and (words[2] <> Nil) and (words[3] <> Nil) and
            (nums[1] <> -1) and (nums[2] <> -1) then
        begin
            SetLength(map, map_len);
            Copy_array(words[1], map[map_len - 1].from_city);
            Copy_array(words[2], map[map_len - 1].to_city);
            Copy_array(words[3], map[map_len - 1].transport_type);
            map[map_len - 1].cruise_time := nums[1];
            map[map_len - 1].cruise_fare := nums[2];
            inc(map_len);
        end

        else if (flag <> 0) then 
        begin
            ClrScr; TextAttr := Error_color;
            GotoXY(4, 2);
            Writeln('Некоторые элементы отсутствуют');
            GotoXY(1, 4);
            Halt(0)
        end;

        {
        Создадим массив с уникальными значениями городов отправления
        для алгоритма Белмана-Форда
        }

        unique_flag := True;

        if (words[1] <> Nil) then
        begin
            for i := 0 to (Length(unique_c_from) - 1) do
                if Are_strings_equal(words[1], unique_c_from[i].city) then 
                    unique_flag := False;
            
            if unique_flag then
            begin
                SetLength(unique_c_from, Length(unique_c_from) + 1);
                Copy_array(words[1], 
                           unique_c_from[Length(unique_c_from) - 1].city)
            end
        end;

        unique_flag := True;

        if (words[2] <> Nil) then
        begin
            for i := 0 to (Length(unique_c_from) - 1) do
                if Are_strings_equal(words[2], unique_c_from[i].city) then 
                    unique_flag := False;
            
            if unique_flag then
            begin
                SetLength(unique_c_from, Length(unique_c_from) + 1);
                Copy_array(words[2], 
                           unique_c_from[Length(unique_c_from) - 1].city)
            end
        end;

        {
        Создадим массив с уникальными значениями видов транспорта
        для алгоритма Белмана-Форда
        }

        unique_flag := True;

        if (words[3] <> Nil) then
        begin
            for i := 0 to (Length(unique_t_t) - 1) do
                if Are_strings_equal(words[3], unique_t_t[i]) then 
                    unique_flag := False;
            
            if unique_flag then
            begin
                SetLength(unique_t_t, Length(unique_t_t) + 1);
                Copy_array(words[3], unique_t_t[Length(unique_t_t) - 1])
            end
        end;

        {
            Обнуление переменных
        }

        if not(Eof(FC)) then ReadLn(FC);
        for i := 1 to 3 do SetLength(words[i], 0);
        for i := 1 to 2 do nums[i] := 0;
        flag := 0

    until Eof(FC);                     {Чтение строк}

end;

{==============================================================================}

{
    Режим номер 1
}

procedure First_mode;

var
    counter: LongInt;                  {Счётчик, используется для прохождения
                                        по массиву unique_c_from}
    iter: longint;                     {Номер итерации}
    start: superstring_t;              {Название стартового города}
    finish: superstring_t;             {Название города прибытия}
    start_index: longint;              {Индекс города отправления в массиве 
                                        unique_c_from}
    finish_index: longint;             {Индекс города прибытия в массиве 
                                        unique_c_from}
    current_city : superstring_t;      {Название рассматриваемого города}
    to_city_index: longint;            {Индекс следующего по пути города}
    record_counter: longint;           {Счётчик, использующийся для прохождени 
                                        по массиву map}
    early_exit_flag: Boolean;          {Флаг, позволяющий завершить 
                                        алгоритм раньше}

{/////////////////////////////////////////////////////////////////}

procedure Print_path(
    var current_city: unique_t; 
    current_index: longint
    );

var
    prev_index: longint;

begin
    if (current_index <> start_index) then
    begin
        prev_index := Find_index_in_record(unique_c_from, 
                                           current_city.from_where);
        Print_path(unique_c_from[prev_index], prev_index);
        Writeln;
        Write_a_string(unique_c_from[current_index].from_where);
        Write(' --> ');
        Write_a_string(unique_c_from[current_index].city);
        Write(' (');
        Write_a_string(unique_c_from[current_index].transport);
        write(')');
        Write(' : ', Round(unique_c_from[current_index].time), ' ', 
              Round(unique_c_from[current_index].fare));
    end
end;

{/////////////////////////////////////////////////////////////////}

procedure Out_of_range_time;

begin
    ClrScr;
    TextAttr := Error_color;
    GotoXY(4, 2);
    Writeln('Время пути превышает максимально');
    GotoXY(4, 3);
    Writeln('допустимое');
    GotoXY(1, 5);
    Halt(0)
end;

{/////////////////////////////////////////////////////////////////}

procedure Out_of_range_fare;

begin
    ClrScr;
    TextAttr := Error_color;
    GotoXY(4, 2);
    Writeln('Стоимость пути превышает максимально');
    GotoXY(4, 3);
    Writeln('допустимое');
    GotoXY(1, 5);
    Halt(0)
end;

{/////////////////////////////////////////////////////////////////}

procedure Cant_reach;

begin
    ClrScr;
    TextAttr := Error_color;
    GotoXY(4, 2);
    Writeln('Город недостижим из города отправления');
    GotoXY(1, 4);
    Halt(0)
end;

{/////////////////////////////////////////////////////////////////}

procedure Choose_direction(
    var start: superstring_t; 
    var finish: superstring_t
    );

var
    sym: char;

begin
    SetLength(start, 0);
    SetLength(finish, 0);

    ClrScr; TextAttr := Green;
    GotoXY(4, 2);
    Write('Выберите пункт отправления');

    GotoXY(4, 4);
    TextAttr := original_color;
    Write('Я поеду из: ');

    repeat 
        Read(sym);
        if (sym = #4) then Halt(0);

        if (sym = #10) then break;

        if (sym <> #32) then 
        begin
            SetLength(start, Length(start) + 1);
            start[Length(start) - 1] := sym
        end

    until Eoln;

    if (sym <> #10) then Readln;

    if (Find_index_in_record(unique_c_from, start) = -1) then No_city;

    ClrScr; TextAttr := Green;
    GotoXY(4, 2);
    Write('Выберите пункт прибытия');

    GotoXY(4, 4);
    TextAttr := original_color;
    Write('Я поеду в: ');

    repeat 
        Read(sym);
        if (sym = #4) then Halt(0);

        if (sym = #10) then break;

        if (sym <> #32) then 
        begin
            SetLength(finish, Length(finish) + 1);
            finish[Length(finish) - 1] := sym
        end
        
    until Eoln;

    if (sym <> #10) then Readln;

    if (Find_index_in_record(unique_c_from, finish) = -1) then No_city;

end;

{/////////////////////////////////////////////////////////////////}

begin
    Choose_direction(start, finish);

    for counter := 0 to (Length(unique_c_from) - 1) do
    begin
        unique_c_from[counter].fare := INFINITY;
        unique_c_from[counter].time := INFINITY
    end;
    
    start_index := Find_index_in_record(unique_c_from, start);
    finish_index := Find_index_in_record(unique_c_from, finish);
    unique_c_from[start_index].fare := 0;
    unique_c_from[start_index].time := 0;

    for iter := 1 to (Length(unique_c_from) - 1) do
    begin
        early_exit_flag := True;

        for counter := start_index to (Length(unique_c_from) - 1) do
        begin
            if (unique_c_from[counter].time <> INFINITY) then
            begin
                Copy_array(unique_c_from[counter].city, current_city);

                for record_counter := 0 to (Length(map) - 1) do
                begin
                    if  Are_strings_equal(
                                        current_city, 
                                        map[record_counter].from_city
                                        ) 
                        and
                        
                        (Find_index(
                                    chosen_transports, 
                                    map[record_counter].transport_type
                                    ) <> -1) then
                    begin
                        to_city_index := 
                            Find_index_in_record(
                                                unique_c_from, 
                                                map[record_counter].to_city
                                                );
                        
                        if ((map[record_counter].cruise_time + 
                                unique_c_from[counter].time) 
                            < 
                            unique_c_from[to_city_index].time) then
                        begin
                            unique_c_from[to_city_index].time := 
                                map[record_counter].cruise_time + 
                                    unique_c_from[counter].time;
                            
                            Copy_array(
                                unique_c_from[counter].city, 
                                unique_c_from[to_city_index].from_where
                                );
                            
                            Copy_array(
                                map[record_counter].transport_type, 
                                unique_c_from[to_city_index].transport
                                );
                            
                            unique_c_from[to_city_index].fare := 
                                map[record_counter].cruise_fare + 
                                    unique_c_from[counter].fare;
                            
                            early_exit_flag := False
                        end
                        
                        else if ((map[record_counter].cruise_time + 
                                    unique_c_from[counter].time) 
                                =
                                unique_c_from[to_city_index].time) then
                        begin
                            if ((map[record_counter].cruise_fare + 
                                    unique_c_from[counter].fare) 
                                <
                                unique_c_from[to_city_index].fare) then
                            begin
                                unique_c_from[to_city_index].time := 
                                    map[record_counter].cruise_time + 
                                        unique_c_from[counter].time;
                                
                                Copy_array(
                                    unique_c_from[counter].city, 
                                    unique_c_from[to_city_index].from_where
                                    );
                                
                                Copy_array(
                                    map[record_counter].transport_type, 
                                    unique_c_from[to_city_index].transport
                                    );
                                
                                unique_c_from[to_city_index].fare := 
                                    map[record_counter].cruise_fare + 
                                        unique_c_from[counter].fare;
                                
                                early_exit_flag := False
                            end
                        end
                    end
                end
            end
        end;
        
        for counter := 0 to (start_index - 1) do
        begin
            if (unique_c_from[counter].time <> INFINITY) then
            begin
                Copy_array(unique_c_from[counter].city, current_city);

                for record_counter := 0 to (Length(map) - 1) do
                begin
                    if  Are_strings_equal(
                                        current_city, 
                                        map[record_counter].from_city
                                        ) 
                        and
                        
                        (Find_index(
                                    chosen_transports, 
                                    map[record_counter].transport_type
                                    ) <> -1) then
                    begin
                        to_city_index := 
                            Find_index_in_record(
                                                unique_c_from, 
                                                map[record_counter].to_city
                                                );
                        
                        if ((map[record_counter].cruise_time + 
                                unique_c_from[counter].time) 
                            < 
                            unique_c_from[to_city_index].time) then
                        begin
                            unique_c_from[to_city_index].time := 
                                map[record_counter].cruise_time + 
                                    unique_c_from[counter].time;
                            
                            Copy_array(
                                unique_c_from[counter].city, 
                                unique_c_from[to_city_index].from_where
                                );
                            
                            Copy_array(
                                map[record_counter].transport_type, 
                                unique_c_from[to_city_index].transport
                                );
                            
                            unique_c_from[to_city_index].fare := 
                                map[record_counter].cruise_fare + 
                                    unique_c_from[counter].fare;
                            
                            early_exit_flag := False
                        end
                        
                        else if ((map[record_counter].cruise_time + 
                                    unique_c_from[counter].time) 
                                =
                                unique_c_from[to_city_index].time) then
                        begin
                            if ((map[record_counter].cruise_fare + 
                                    unique_c_from[counter].fare) 
                                <
                                unique_c_from[to_city_index].fare) then
                            begin
                                unique_c_from[to_city_index].time := 
                                    map[record_counter].cruise_time + 
                                        unique_c_from[counter].time;
                                
                                Copy_array(
                                    unique_c_from[counter].city, 
                                    unique_c_from[to_city_index].from_where
                                    );
                                
                                Copy_array(
                                    map[record_counter].transport_type, 
                                    unique_c_from[to_city_index].transport
                                    );
                                
                                unique_c_from[to_city_index].fare := 
                                    map[record_counter].cruise_fare + 
                                        unique_c_from[counter].fare;
                                
                                early_exit_flag := False
                            end
                        end
                    end
                end
            end
        end;
        if early_exit_flag then Break
    end;

    if (unique_c_from[finish_index].fare = INFINITY) then Cant_reach;
    if (Out_of_borders_double(unique_c_from[finish_index].fare)) then
        Out_of_range_fare;
    if (Out_of_borders_double(unique_c_from[finish_index].time)) then
        Out_of_range_time;


    ClrScr; TextAttr := Yellow;
    GotoXY(4, 2);
    Write('Путь найден :)');
    TextAttr := original_color;
    GotoXY(1, 4);
    Writeln('Формат вывода:');

    TextAttr := Brown;
    GotoXY(1, 5);
    WriteLn('<from_city> --> <to_city>(<transport>):<total_time> <total_fare>');
    Writeln;

    TextAttr := original_color;
    Write('----------------------------------------------------------------');
    Print_path(unique_c_from[finish_index], finish_index);
    Writeln;
    Writeln('----------------------------------------------------------------');

    writeln;
    Write('Для продолжения нажмите на любую клавишу...');
    ReadKey

end;

{==============================================================================}

{
    Режим номер 2
}

procedure Second_mode;

var
    counter: LongInt;                  {Счётчик, используется для прохождения
                                        по массиву unique_c_from}
    iter: longint;                     {Номер итерации}
    start: superstring_t;              {Название стартового города}
    finish: superstring_t;             {Название города прибытия}
    start_index: longint;              {Индекс города отправления в массиве
                                        unique_c_from}
    finish_index: longint;             {Индекс города прибытия в массиве
                                        unique_c_from}
    current_city : superstring_t;      {Название рассматриваемого города}
    to_city_index: longint;            {Индекс следующего по пути города}
    record_counter: longint;           {Счётчик, использующийся для прохождени
                                        по массиву map}
    early_exit_flag: Boolean;          {Флаг, позволяющий завершить
                                        алгоритм раньше}

{/////////////////////////////////////////////////////////////////}

procedure Print_path(
    var current_city: unique_t;
    current_index: longint
    );

var
    prev_index: longint;

begin
    if (current_index <> start_index) then
    begin
        prev_index := Find_index_in_record(unique_c_from,
                                           current_city.from_where);
        Print_path(unique_c_from[prev_index], prev_index);
        Writeln;
        Write_a_string(unique_c_from[current_index].from_where);
        Write(' --> ');
        Write_a_string(unique_c_from[current_index].city);
        Write(' (');
        Write_a_string(unique_c_from[current_index].transport);
        write(')');
        Write(' : ', Round(unique_c_from[current_index].time), ' ',
              Round(unique_c_from[current_index].fare));
    end
end;

{/////////////////////////////////////////////////////////////////}

procedure Out_of_range_time;

begin
    ClrScr;
    TextAttr := Error_color;
    GotoXY(4, 2);
    Writeln('Время пути превышает максимально');
    GotoXY(4, 3);
    Writeln('допустимое');
    GotoXY(1, 5);
    Halt(0)
end;

{/////////////////////////////////////////////////////////////////}

procedure Out_of_range_fare;

begin
    ClrScr;
    TextAttr := Error_color;
    GotoXY(4, 2);
    Writeln('Стоимость пути превышает максимально');
    GotoXY(4, 3);
    Writeln('допустимое');
    GotoXY(1, 5);
    Halt(0)
end;

{/////////////////////////////////////////////////////////////////}

procedure Cant_reach;

begin
    ClrScr;
    TextAttr := Error_color;
    GotoXY(4, 2);
    Writeln('Город недостижим из города отправления');
    GotoXY(1, 4);
    Halt(0)
end;

{/////////////////////////////////////////////////////////////////}

procedure Choose_direction(
    var start: superstring_t;
    var finish: superstring_t
    );

var
    sym: char;

{\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\}

begin
    SetLength(start, 0);
    SetLength(finish, 0);

    ClrScr; TextAttr := Green;
    GotoXY(4, 2);
    Write('Выберите пункт отправления');

    GotoXY(4, 4);
    TextAttr := original_color;
    Write('Я поеду из: ');

    repeat
        Read(sym);
        if (sym = #4) then Halt(0);

        if (sym <> #32) then
        begin
            SetLength(start, Length(start) + 1);
            start[Length(start) - 1] := sym
        end

    until Eoln;

    Readln;

    if (Find_index_in_record(unique_c_from, start) = -1) then No_city;

    ClrScr; TextAttr := Green;
    GotoXY(4, 2);
    Write('Выберите пункт прибытия');

    GotoXY(4, 4);
    TextAttr := original_color;
    Write('Я поеду в: ');

    repeat
        Read(sym);
        if (sym = #4) then Halt(0);

        if (sym <> #32) then
        begin
            SetLength(finish, Length(finish) + 1);
            finish[Length(finish) - 1] := sym
        end

    until Eoln;

    Readln;

    if (Find_index_in_record(unique_c_from, finish) = -1) then No_city;

end;

{/////////////////////////////////////////////////////////////////}

begin
    Choose_direction(start, finish);

    for counter := 0 to (Length(unique_c_from) - 1) do
    begin
        unique_c_from[counter].fare := INFINITY;
        unique_c_from[counter].time := INFINITY
    end;

    start_index := Find_index_in_record(unique_c_from, start);
    finish_index := Find_index_in_record(unique_c_from, finish);
    unique_c_from[start_index].fare := 0;
    unique_c_from[start_index].time := 0;

    for iter := 1 to (Length(unique_c_from) - 1) do
    begin
        early_exit_flag := True;

        for counter := start_index to (Length(unique_c_from) - 1) do
        begin
            if (unique_c_from[counter].time <> INFINITY) then
            begin
                Copy_array(unique_c_from[counter].city, current_city);

                for record_counter := 0 to (Length(map) - 1) do
                begin
                    if  Are_strings_equal(
                                        current_city,
                                        map[record_counter].from_city
                                        )
                        and

                        (Find_index(
                                    chosen_transports,
                                    map[record_counter].transport_type
                                    ) <> -1) then
                    begin
                        to_city_index :=
                            Find_index_in_record(
                                                unique_c_from,
                                                map[record_counter].to_city
                                                );

                        if ((map[record_counter].cruise_fare +
                                unique_c_from[counter].fare)
                            <
                            unique_c_from[to_city_index].fare) then
                        begin
                            unique_c_from[to_city_index].fare :=
                                map[record_counter].cruise_fare +
                                    unique_c_from[counter].fare;

                            Copy_array(
                                unique_c_from[counter].city,
                                unique_c_from[to_city_index].from_where
                                );

                            Copy_array(
                                map[record_counter].transport_type,
                                unique_c_from[to_city_index].transport
                                );

                            unique_c_from[to_city_index].time :=
                                map[record_counter].cruise_time +
                                    unique_c_from[counter].time;

                            early_exit_flag := False
                        end

                        else if ((map[record_counter].cruise_fare +
                                    unique_c_from[counter].fare)
                                =
                                unique_c_from[to_city_index].fare) then
                        begin
                            if ((map[record_counter].cruise_time +
                                    unique_c_from[counter].time)
                                <
                                unique_c_from[to_city_index].time) then
                            begin
                                unique_c_from[to_city_index].fare :=
                                    map[record_counter].cruise_fare +
                                        unique_c_from[counter].fare;

                                Copy_array(
                                    unique_c_from[counter].city,
                                    unique_c_from[to_city_index].from_where
                                    );

                                Copy_array(
                                    map[record_counter].transport_type,
                                    unique_c_from[to_city_index].transport
                                    );

                                unique_c_from[to_city_index].time :=
                                    map[record_counter].cruise_time +
                                        unique_c_from[counter].time;

                                early_exit_flag := False
                            end
                        end
                    end
                end
            end
        end;

        for counter := 0 to (start_index - 1) do
        begin
            if (unique_c_from[counter].time <> INFINITY) then
            begin
                Copy_array(unique_c_from[counter].city, current_city);

                for record_counter := 0 to (Length(map) - 1) do
                begin
                    if  Are_strings_equal(
                                        current_city,
                                        map[record_counter].from_city
                                        )
                        and

                        (Find_index(
                                    chosen_transports,
                                    map[record_counter].transport_type
                                    ) <> -1) then
                    begin
                        to_city_index :=
                            Find_index_in_record(
                                                unique_c_from,
                                                map[record_counter].to_city
                                                );

                        if ((map[record_counter].cruise_fare +
                                unique_c_from[counter].fare)
                            <
                            unique_c_from[to_city_index].fare) then
                        begin
                            unique_c_from[to_city_index].fare :=
                                map[record_counter].cruise_fare +
                                    unique_c_from[counter].fare;

                            Copy_array(
                                unique_c_from[counter].city,
                                unique_c_from[to_city_index].from_where
                                );

                            Copy_array(
                                map[record_counter].transport_type,
                                unique_c_from[to_city_index].transport
                                );

                            unique_c_from[to_city_index].time :=
                                map[record_counter].cruise_time +
                                    unique_c_from[counter].time;

                            early_exit_flag := False
                        end

                        else if ((map[record_counter].cruise_fare +
                                    unique_c_from[counter].fare)
                                =
                                unique_c_from[to_city_index].fare) then
                        begin
                            if ((map[record_counter].cruise_time +
                                    unique_c_from[counter].time)
                                <
                                unique_c_from[to_city_index].time) then
                            begin
                                unique_c_from[to_city_index].fare :=
                                    map[record_counter].cruise_fare +
                                        unique_c_from[counter].fare;

                                Copy_array(
                                    unique_c_from[counter].city,
                                    unique_c_from[to_city_index].from_where
                                    );

                                Copy_array(
                                    map[record_counter].transport_type,
                                    unique_c_from[to_city_index].transport
                                    );

                                unique_c_from[to_city_index].time :=
                                    map[record_counter].cruise_time +
                                        unique_c_from[counter].time;

                                early_exit_flag := False
                            end
                        end
                    end
                end
            end
        end;
        if early_exit_flag then Break
    end;

    if (unique_c_from[finish_index].fare = INFINITY) then Cant_reach;
    
    if (Out_of_borders_double(unique_c_from[finish_index].fare)) then
        Out_of_range_fare;
    
    if (Out_of_borders_double(unique_c_from[finish_index].time)) then
        Out_of_range_time;


    ClrScr; TextAttr := Yellow;
    GotoXY(4, 2);
    Write('Путь найден :)');
    TextAttr := original_color;
    GotoXY(1, 4);
    Writeln('Формат вывода:');

    TextAttr := Brown;
    GotoXY(1, 5);
    WriteLn('<from_city> --> <to_city>(<transport>):<total_time> <total_fare>');
    Writeln;

    TextAttr := original_color;
    Write('----------------------------------------------------------------');
    Print_path(unique_c_from[finish_index], finish_index);
    Writeln;
    Writeln('----------------------------------------------------------------');

    writeln;
    Write('Для продолжения нажмите на любую клавишу...');
    ReadKey

end;

{==============================================================================}

{
    Режим номер 3
}

procedure Third_mode;

var
    counter: longint;
    iter: longint;
    start: superstring_t;
    finish: superstring_t;
    start_index: longint;
    finish_index: longint;
    current_city : superstring_t;
    to_city_index: longint;
    record_counter: longint;
    early_exit_flag: Boolean;

{/////////////////////////////////////////////////////////////////}

procedure Print_path(
    var current_city: unique_t; 
    current_index: longint);

var
    prev_index: longint;

begin
    if (current_index <> start_index) then
    begin
        prev_index := Find_index_in_record(unique_c_from, 
                                           current_city.from_where);
        Print_path(unique_c_from[prev_index], prev_index);
        Writeln;
        Write_a_string(unique_c_from[current_index].from_where);
        Write(' --> ');
        Write_a_string(unique_c_from[current_index].city);
        Write(' (');
        Write_a_string(unique_c_from[current_index].transport);
        write(')');
        Write(' : ', Round(unique_c_from[current_index].time), ' ',
              Round(unique_c_from[current_index].fare))
    end;
end;

{/////////////////////////////////////////////////////////////////}

procedure Cant_reach;

begin
    ClrScr;
    TextAttr := Error_color;
    GotoXY(4, 2);
    Writeln('Город недостижим из города отправления');
    GotoXY(1, 4);
    Halt(0)
end;

{/////////////////////////////////////////////////////////////////}

procedure Choose_direction(
    var start: superstring_t; 
    var finish: superstring_t
    );

var
    sym: char;

{/////////////////////////////////////////////////////////////////}

begin
    SetLength(start, 0);
    SetLength(finish, 0);

    ClrScr; TextAttr := Green;
    GotoXY(4, 2);
    Write('Выберите пункт отправления');

    GotoXY(4, 4);
    TextAttr := original_color;
    Write('Я поеду из: ');

    repeat 
        Read(sym);
        if (sym = #4) then Halt(0);

        if (sym <> #32) then 
        begin
            SetLength(start, Length(start) + 1);
            start[Length(start) - 1] := sym
        end

    until Eoln;

    Readln;

    if (Find_index_in_record(unique_c_from, start) = -1) then No_city;

    ClrScr; TextAttr := Green;
    GotoXY(4, 2);
    Write('Выберите пункт прибытия');

    GotoXY(4, 4);
    TextAttr := original_color;
    Write('Я поеду в: ');

    repeat 
        Read(sym);
        if (sym = #4) then Halt(0);

        if (sym <> #32) then 
        begin
            SetLength(finish, Length(finish) + 1);
            finish[Length(finish) - 1] := sym
        end
        
    until Eoln;

    Readln;

    if (Find_index_in_record(unique_c_from, finish) = -1) then No_city;

end;

{/////////////////////////////////////////////////////////////////}

begin
    Choose_direction(start, finish);

    for counter := 0 to (Length(unique_c_from) - 1) do
    begin
        unique_c_from[counter].fare := INFINITY;
        unique_c_from[counter].time := INFINITY;
        unique_c_from[counter].visited := INFINITY;
    end;
    
    start_index := Find_index_in_record(unique_c_from, start);
    finish_index := Find_index_in_record(unique_c_from, finish);
    unique_c_from[start_index].fare := 0;
    unique_c_from[start_index].time := 0;
    unique_c_from[start_index].visited := 0;
    

    for iter := 1 to (Length(unique_c_from) - 1) do
    begin
        early_exit_flag := True;

        for counter := start_index to (Length(unique_c_from) - 1) do
        begin
            if (unique_c_from[counter].fare <> INFINITY) then
            begin
                Copy_array(unique_c_from[counter].city, current_city);

                for record_counter := 0 to (Length(map) - 1) do
                begin
                    if Are_strings_equal(
                        current_city, 
                        map[record_counter].from_city
                        ) 
                        and
                        (Find_index(
                            chosen_transports, 
                            map[record_counter].transport_type
                            ) <> -1) then
                    begin
                        to_city_index := 
                        Find_index_in_record(
                            unique_c_from, 
                            map[record_counter].to_city
                            );
                        
                        if ((1 + unique_c_from[counter].visited) < 
                            unique_c_from[to_city_index].visited) then
                        begin
                            unique_c_from[to_city_index].visited := 
                                1 + unique_c_from[counter].visited;
                            
                            unique_c_from[to_city_index].fare := 
                                map[record_counter].cruise_fare + 
                                    unique_c_from[counter].fare;
                            
                            Copy_array(
                                unique_c_from[counter].city, 
                                unique_c_from[to_city_index].from_where
                                );
                            
                            Copy_array(
                                map[record_counter].transport_type, 
                                unique_c_from[to_city_index].transport
                                );
                            
                            unique_c_from[to_city_index].time := 
                                map[record_counter].cruise_time + 
                                    unique_c_from[counter].time;
                            
                            early_exit_flag := False
                        end
                    end
                end
            end
        end;
        
        for counter := 0 to (start_index - 1) do
        begin
            if (unique_c_from[counter].fare <> INFINITY) then
            begin
                Copy_array(unique_c_from[counter].city, current_city);

                for record_counter := 0 to (Length(map) - 1) do
                begin
                    if Are_strings_equal(
                        current_city, 
                        map[record_counter].from_city
                        ) 
                        and
                        (Find_index(
                            chosen_transports, 
                            map[record_counter].transport_type
                            ) <> -1) then
                    begin
                        to_city_index := 
                        Find_index_in_record(
                            unique_c_from, 
                            map[record_counter].to_city
                            );
                        
                        if ((1 + unique_c_from[counter].visited) < 
                            unique_c_from[to_city_index].visited) then
                        begin
                            unique_c_from[to_city_index].visited := 
                                1 + unique_c_from[counter].visited;
                            
                            unique_c_from[to_city_index].fare := 
                                map[record_counter].cruise_fare + 
                                    unique_c_from[counter].fare;
                            
                            Copy_array(
                                unique_c_from[counter].city, 
                                unique_c_from[to_city_index].from_where
                                );
                            
                            Copy_array(
                                map[record_counter].transport_type, 
                                unique_c_from[to_city_index].transport
                                );
                            
                            unique_c_from[to_city_index].time := 
                                map[record_counter].cruise_time + 
                                    unique_c_from[counter].time;
                            
                            early_exit_flag := False
                        end
                    end
                end
            end
        end;
        if early_exit_flag then Break
    end;

    if (unique_c_from[finish_index].fare = INFINITY) then Cant_reach;

    ClrScr; TextAttr := Yellow;
    GotoXY(4, 2);
    Write('Путь найден :)');
    TextAttr := original_color;
    GotoXY(1, 4);
    Writeln('Формат вывода:');

    TextAttr := Brown;
    GotoXY(1, 5);
    WriteLn('<from_city> --> <to_city>(<transport>):<total_time> <total_fare>');
    Writeln;

    TextAttr := original_color;
    Write('----------------------------------------------------------------');
    Print_path(unique_c_from[finish_index], finish_index);
    Writeln;
    Writeln('----------------------------------------------------------------');

    writeln;
    Write('Для продолжения нажмите на любую клавишу...');
    ReadKey

end;

{==============================================================================}

{
    Режим номер 4
}

procedure Fourth_mode;

var
    counter: longint;
    iter: longint;
    start: superstring_t;
    start_index: longint;
    current_city : superstring_t;
    to_city_index: longint;
    record_counter: longint;
    early_exit_flag: Boolean;
    limit_cost: double;
    unique_array: supertext_t;

{/////////////////////////////////////////////////////////////////}

procedure Nowhere_to_go;
begin
    ClrScr;
    TextAttr := Error_color;
    GotoXY(4, 2);
    Write('У вас нет средств чтобы выбраться из ');
    Write_a_string(unique_c_from[start_index].city);
    GotoXY(1, 4);
    Halt(0)
end;

{/////////////////////////////////////////////////////////////////}

procedure Add_to_array(var unique_array: supertext_t; var elem: superstring_t);

var
    unique_flag: Boolean;
    i: longint;

begin
    unique_flag := True;

    for i := 0 to (Length(unique_array) - 1) do
        if Are_strings_equal(unique_array[i], elem) then unique_flag := False;
    
    if unique_flag then
    begin
        SetLength(unique_array, Length(unique_array) + 1);
        Copy_array(elem, unique_array[Length(unique_array) - 1])
    end
end;

{/////////////////////////////////////////////////////////////////}

procedure Get_limit_cost(
    var start: superstring_t; 
    var limit_cost: Double
    );

var
    sym: char;

{/////////////////////////////////////////////////////////////////}

procedure Limit_error;

begin
    ClrScr;
    TextAttr := Error_color;
    GotoXY(4, 2);
    Writeln('Ограничение должно быть целым числом типа longint.');
    GotoXY(1, 4);
    Halt(0)
end;

{/////////////////////////////////////////////////////////////////}

begin
    SetLength(start, 0);

    ClrScr; TextAttr := Green;
    GotoXY(4, 2);
    Write('Выберите пункт отправления');

    GotoXY(4, 4);
    TextAttr := original_color;
    Write('Я поеду из: ');

    repeat 
        Read(sym);
        if (sym = #4) then Halt(0);

        if (sym <> #32) then 
        begin
            SetLength(start, Length(start) + 1);
            start[Length(start) - 1] := sym
        end

    until Eoln;

    Readln;

    if (Find_index_in_record(unique_c_from, start) = -1) then No_city;

    ClrScr; TextAttr := Green;
    GotoXY(4, 2);
    Write('Выберите ограничение по стоимости ');
    GotoXY(4, 3); Write('путешествия');

    GotoXY(4, 5);
    TextAttr := original_color;
    Write('Я заплачу: ');

    limit_cost := 0;

    repeat 
        Read(sym);
        if (sym = #4) then Halt(0);

        if (sym <> #32) then 
        begin
            if (ord(sym) < ord ('0')) or (ord(sym) > ord('9')) then Limit_error;

            limit_cost := limit_cost * 10;
            limit_cost := limit_cost + (ord(sym) - ord('0'));
            if Out_of_borders_double(limit_cost) then Limit_error
        end
        
    until Eoln;

    Readln;

end;

{/////////////////////////////////////////////////////////////////}

begin
    Get_limit_cost(start, limit_cost);

    for counter := 0 to (Length(unique_c_from) - 1) do
        unique_c_from[counter].fare := -1;
    
    start_index := Find_index_in_record(unique_c_from, start);
    unique_c_from[start_index].fare := limit_cost;

    SetLength(unique_array, 0);

    for iter := 1 to (Length(unique_c_from) - 1) do
    begin
        early_exit_flag := True;

        for counter := start_index to (Length(unique_c_from) - 1) do
        begin
            if (unique_c_from[counter].fare > 0) then
            begin
                Copy_array(unique_c_from[counter].city, current_city);

                for record_counter := 0 to (Length(map) - 1) do
                begin
                    if Are_strings_equal(
                        current_city, 
                        map[record_counter].from_city
                        ) and
                        (Find_index(
                            chosen_transports, 
                            map[record_counter].transport_type
                            ) <> -1) then
                    begin
                        to_city_index := 
                            Find_index_in_record(
                                unique_c_from, 
                                map[record_counter].to_city
                                );
                        
                        if ((unique_c_from[counter].fare - 
                                map[record_counter].cruise_fare) 
                            >= 
                            max(unique_c_from[to_city_index].fare, 0)) then
                        begin
                            Add_to_array(
                                unique_array, 
                                unique_c_from[to_city_index].city
                                );
                            
                            unique_c_from[to_city_index].fare := 
                                unique_c_from[counter].fare - 
                                    map[record_counter].cruise_fare;
                            
                            early_exit_flag := False
                        end
                    end
                end
            end
        end;
        
        for counter := 0 to (start_index - 1) do
        begin
            if (unique_c_from[counter].fare > 0) then
            begin
                Copy_array(unique_c_from[counter].city, current_city);

                for record_counter := 0 to (Length(map) - 1) do
                begin
                    if Are_strings_equal(
                        current_city, 
                        map[record_counter].from_city
                        ) 
                        and
                        (Find_index(
                            chosen_transports, 
                            map[record_counter].transport_type
                            ) <> -1) then
                    begin
                        to_city_index := 
                            Find_index_in_record(
                                unique_c_from, 
                                map[record_counter].to_city
                                );
                        
                        if ((unique_c_from[counter].fare - 
                                map[record_counter].cruise_fare) 
                            >= 
                            max(unique_c_from[to_city_index].fare, 0)) then
                        begin
                            Add_to_array(
                                unique_array, 
                                unique_c_from[to_city_index].city
                                );
                            
                            unique_c_from[to_city_index].fare := 
                                unique_c_from[counter].fare - 
                                    map[record_counter].cruise_fare;
                            
                            early_exit_flag := False
                        end
                    end
                end
            end
        end;
        if early_exit_flag then Break
    end;

    if (Length(unique_array) = 0) then Nowhere_to_go;

    ClrScr; TextAttr := Yellow;
    GotoXY(4, 2);
    Write('Вы можете выбраться из ');
    Write_a_string(unique_c_from[start_index].city);
    TextAttr := original_color;
    GotoXY(1, 4);
    Writeln('Куда вы можете отправиться:');
    Writeln;

    TextAttr := original_color;
    GotoXY(1, 6);
    Writeln('----------------------------------------------------------------');
    for counter := 0 to (Length(unique_array) - 1) do
    begin
        Write_a_string(unique_array[counter]);
        Writeln
    end;
    Writeln('----------------------------------------------------------------');

    Writeln;

    Write('Для продолжения нажмите на любую клавишу...');
    ReadKey

end;

{==============================================================================}

{
    Режим номер 5
}

procedure Fifth_mode;

var
    counter: longint;
    iter: longint;
    start: superstring_t;
    start_index: longint;
    current_city : superstring_t;
    to_city_index: longint;
    record_counter: longint;
    early_exit_flag: Boolean;
    limit_time: double;
    unique_array: supertext_t;

{/////////////////////////////////////////////////////////////////}

procedure No_time_to_explain;
begin
    ClrScr;
    TextAttr := Error_color;
    GotoXY(4, 2);
    Write('Вы никуда не успеете приехать и останетесь в ');
    Write_a_string(unique_c_from[start_index].city);
    GotoXY(1, 4);
    Halt(0)
end;

{/////////////////////////////////////////////////////////////////}

procedure Add_to_array(var unique_array: supertext_t; var elem: superstring_t);

var
    unique_flag: Boolean;
    i: longint;

begin
    unique_flag := True;

    for i := 0 to (Length(unique_array) - 1) do
        if Are_strings_equal(unique_array[i], elem) then unique_flag := False;
    
    if unique_flag then
    begin
        SetLength(unique_array, Length(unique_array) + 1);
        Copy_array(elem, unique_array[Length(unique_array) - 1])
    end
end;

{/////////////////////////////////////////////////////////////////}

procedure Get_limit_time(
    var start: superstring_t; 
    var limit_time: Double
    );

var
    sym: char;

{/////////////////////////////////////////////////////////////////}

procedure Limit_error;

begin
    ClrScr;
    TextAttr := Error_color;
    GotoXY(4, 2);
    Writeln('Ограничение должно быть целым числом типа longint.');
    GotoXY(1, 4);
    Halt(0)
end;

{/////////////////////////////////////////////////////////////////}

begin
    SetLength(start, 0);

    ClrScr; TextAttr := Green;
    GotoXY(4, 2);
    Write('Выберите пункт отправления');

    GotoXY(4, 4);
    TextAttr := original_color;
    Write('Я поеду из: ');

    repeat 
        Read(sym);
        if (sym = #4) then Halt(0);

        if (sym <> #32) then 
        begin
            SetLength(start, Length(start) + 1);
            start[Length(start) - 1] := sym
        end

    until Eoln;

    Readln;

    if (Find_index_in_record(unique_c_from, start) = -1) then No_city;

    ClrScr; TextAttr := Green;
    GotoXY(4, 2);
    Write('Выберите ограничение по ');
    GotoXY(4, 3); Write('длительности путешествия');

    GotoXY(4, 5);
    TextAttr := original_color;
    Write('У меня есть в запасе: ');

    limit_time := 0;

    repeat 
        Read(sym);
        if (sym = #4) then Halt(0);

        if (sym <> #32) then 
        begin
            if (ord(sym) < ord ('0')) or (ord(sym) > ord('9')) then Limit_error;

            limit_time := limit_time * 10;
            limit_time := limit_time + (ord(sym) - ord('0'));
            if Out_of_borders_double(limit_time) then Limit_error
        end
        
    until Eoln;

    Readln;

end;

{/////////////////////////////////////////////////////////////////}

begin
    Get_limit_time(start, limit_time);

    for counter := 0 to (Length(unique_c_from) - 1) do
        unique_c_from[counter].time := -1;
    
    start_index := Find_index_in_record(unique_c_from, start);
    unique_c_from[start_index].time := limit_time;

    SetLength(unique_array, 0);

    for iter := 1 to (Length(unique_c_from) - 1) do
    begin
        early_exit_flag := True;

        for counter := start_index to (Length(unique_c_from) - 1) do
        begin
            if (unique_c_from[counter].time > 0) then
            begin
                Copy_array(unique_c_from[counter].city, current_city);

                for record_counter := 0 to (Length(map) - 1) do
                begin
                    if Are_strings_equal(
                        current_city, 
                        map[record_counter].from_city
                        ) 
                        and
                        (Find_index(
                            chosen_transports, 
                            map[record_counter].transport_type
                            ) <> -1) 
                        then
                    
                    begin
                        to_city_index := 
                            Find_index_in_record(
                                unique_c_from, 
                                map[record_counter].to_city
                                );
                        
                        if ((unique_c_from[counter].time - 
                                map[record_counter].cruise_time) 
                            >= 
                            max(unique_c_from[to_city_index].time, 0)) then
                        begin
                            Add_to_array(
                                unique_array, 
                                unique_c_from[to_city_index].city
                                );
                            
                            unique_c_from[to_city_index].time := 
                                unique_c_from[counter].time - 
                                    map[record_counter].cruise_time;
                            
                            early_exit_flag := False
                        end
                    end
                end
            end
        end;
        
        for counter := 0 to (start_index - 1) do
        begin
            if (unique_c_from[counter].time > 0) then
            begin
                Copy_array(unique_c_from[counter].city, current_city);

                for record_counter := 0 to (Length(map) - 1) do
                begin
                    if Are_strings_equal(
                        current_city, 
                        map[record_counter].from_city
                        ) 
                        and
                        (Find_index(
                            chosen_transports, 
                            map[record_counter].transport_type
                            ) <> -1) 
                        then
                    
                    begin
                        to_city_index := 
                            Find_index_in_record(
                                unique_c_from, 
                                map[record_counter].to_city
                                );
                        
                        if ((unique_c_from[counter].time - 
                                map[record_counter].cruise_time) 
                            >= 
                            max(unique_c_from[to_city_index].time, 0)) then
                        begin
                            Add_to_array(
                                unique_array, 
                                unique_c_from[to_city_index].city
                                );
                            
                            unique_c_from[to_city_index].time := 
                                unique_c_from[counter].time - 
                                    map[record_counter].cruise_time;
                            
                            early_exit_flag := False
                        end
                    end
                end
            end
        end;
        if early_exit_flag then Break
    end;

    if (Length(unique_array) = 0) then No_time_to_explain;

    ClrScr; TextAttr := Yellow;
    GotoXY(4, 2);
    Write('Вы можете выбраться из ');
    Write_a_string(unique_c_from[start_index].city);
    TextAttr := original_color;
    GotoXY(1, 4);
    Writeln('Куда вы можете отправиться:');
    Writeln;

    TextAttr := original_color;
    GotoXY(1, 6);
    Writeln('----------------------------------------------------------------');
    for counter := 0 to (Length(unique_array) - 1) do
    begin
        Write_a_string(unique_array[counter]);
        Writeln
    end;
    Writeln('----------------------------------------------------------------');

    Writeln;

    Write('Для продолжения нажмите на любую клавишу...');
    ReadKey

end;

{==============================================================================}

begin
    ClrScr;
    Window(1, 1, 100, 100);
    original_color := TextAttr;
    error_color := original_color;

    SetLength(map, 0);
    SetLength(unique_c_from, 0);
    SetLength(unique_t_t, 0);

    {
        Считывание названия файла с учётом ошибок
    }

    if ParamCount = 0 then 
    begin
        GotoXY(4, 2);
        writeln('Не дано ни одного названия файла');
        GotoXY(1, 4);
        Halt(0)
    end
    else if ParamCount > 1 then
    begin
        GotoXY(4, 2);
        Writeln('Необходимо ввести название только одного файла');
        GotoXY(1, 4);
        Halt(0)
    end
    else
        file_name := ParamStr(1);

    {
        Проверяем существование файла
        Если он есть, то привязываем его
    }

    if FileExists(file_name) then
        Assign(FC, file_name)
    else
    begin
        GotoXY(4, 2);
        writeln('Файла с таким именем нет');
        GotoXY(1, 4);
        Halt(0)
    end;

    {
        Читаем файл и составляем массив рёбер графа и массив
        уникальных городов
    }

    Make_a_map(FC, map, unique_c_from, unique_t_t);

    While True do
    begin
        SetLength(chosen_transports, 0);

        if not(If_continue) then 
        begin
            GotoXY(WhereX, WhereY + 1);
            Halt(0)
        end;

        {
            Спрашиваем у пользователя режим работы
        }

        Choose_mode(mode);

        {
            Спрашиваем у пользователя предпочитаемые виды транспорта
        }

        Choose_transports(chosen_transports);

        {
            Основная часть программы
        }

        case mode of
            1: First_mode;
            2: Second_mode;
            3: Third_mode;
            4: Fourth_mode;
            5: Fifth_mode
        end
    end  
end.
