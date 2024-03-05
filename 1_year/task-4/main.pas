program main;

uses 
    MatType in './units/MatType.pas',
    Trees in './units/Trees.pas',
    MatRead in './units/MatRead.pas',
    MatMake in './units/MatMake.pas',
    MatGenerator in './units/MatGenerator.pas',
    MatMultiplier in './units/MatMultiplier.pas',
    MatIndex in './units/MatIndex.pas',
    Crt,
    Sysutils;
    
var
    code: integer;

{==============================================================================}

procedure Read_param;
var
    counter:      longint;
    num_of_param: integer;
    n, m:         longword;
    eps:          double;
    num:          double;
    mode:         shortint;
    result_name:  string;
    file_name_1:  string;
    file_name_2:  string;
    to_console:   Boolean;
    mat_type:     shortint;
    result_mat:   mat_tree_t = nil;
    mat_1:        mat_tree_t = nil;
    mat_2:        mat_tree_t = nil;
    dim_1, dim_2: dimensions_t;
    i, j:         LongWord;
    change_dim:   Boolean;

{------------------------------------------------------------------------------}

procedure No_param_error;
begin
    ClrScr;
    Writeln('Не было дано ни одного параметра');
    Writeln('Для ознакомления с существующими модулями');
    Writeln('напишите ./main help');
    Halt(0)
end;

{------------------------------------------------------------------------------}

procedure Val_error;
begin
    ClrScr;
    Writeln('Один из параметров не');
    WriteLn('соответсвует своему типу данных');
    Halt(0)
end;

{------------------------------------------------------------------------------}

procedure No_type_error;
begin
    ClrScr;
    Writeln('Тип матрицы может быть только');
    WriteLn('sparse / dence');
    Halt(0)
end;

{------------------------------------------------------------------------------}

procedure Mult_error;
begin
    ClrScr;
    Writeln('Дан лишь один множитель');
    WriteLn('Умножение невозможно');
    Halt(0)
end;

{------------------------------------------------------------------------------}

begin
    num_of_param := ParamCount;
    if (num_of_param = 0) then No_param_error;
    
    if (ParamStr(1) = 'help') then
    begin
        if (ParamCount = 2) then
        begin
            if (ParamStr(2) = 'generate') then
            begin
                ClrScr;
                Writeln('Генератор матрицы производит генерацию');
                Writeln('   матрицы с заданными свойствами');
                Writeln;
                Writeln('  Структура команды:');
                Writeln;
                Write('./main generate <n> <m> <eps> <mode> <file_name> ');
                WriteLn('<mat_type> (<to_console>)');
                WriteLn;
                Writeln('n           -кол-во строк');
                Writeln('m           -кол-во столбцов');
                Writeln('epsilon     -плотность строки (диагонали)');
                Writeln('mode        -режим генерации');
                Writeln('file_name   -имя сгенерированной матрицы');
                Writeln('mat_type    -тип сгенерированной матрицы');
                Writeln('to_console  -необязательный параметр,');
                WriteLn('             вывод матрицы в консоль');
                Writeln;
                Writeln('       Режимы генерации матрицы:');
                WriteLn('1. Заполненная единицами в случайных');
                Writeln('   позициях');
                WriteLn('2. Со случайными значениями');
                WriteLn('3. С единицами в случайных позициях');
                Writeln('   на диагонали');
                Writeln
            end
            else if (ParamStr(2) = 'multiply') then
            begin
                ClrScr;
                Writeln('Умножение 2ух и более матриц');
                Writeln;
                Writeln('  Структура команды:');
                Writeln;
                Write('./main multiply <eps> <mat_type> <file_name> <mat_1> ');
                WriteLn('<mat_2> {<mat_i>}...');
                WriteLn;
                Writeln('eps        -значение для оценки элементов');
                WriteLn('            результирующей матрицы');
                Writeln('mat_type   -тип результирующей матрицы');
                Writeln('file_name  -имя результирующей матрицы');
                Writeln('mat_1      -1ый множитель (с разрешением)');
                Writeln('mat_2      -2ой множитель  ------//-----');
                Writeln('mat_i      -iый множитель  ------//-----');
                Writeln
            end
            else if (ParamStr(2) = 'index') then
            begin
                ClrScr;
                Writeln('Построитель индекса');
                Writeln;
                Writeln('  Структура команды:');
                Writeln;
                Writeln('./main index <matrix_name> <index_name> [<to_console> <mode>]');
                WriteLn;
                Writeln('matrix_name -имя файла считываемой матрицы');
                Writeln('             (с разрешением)');
                Writeln('index_name  -имя результирующего файла');
                Writeln('to_console  -необязательный параметр');
                Writeln('             вывод индекса на консоль');
                Writeln('mode        -необязательный параметр');
                Writeln('             режим печати индекса');
                Writeln;
                WriteLn('       Режимы печати дерева');
                Writeln;
                Writeln('1. Печатается сначала левое поддерево,');
                Writeln('   затем правое');
                Writeln('2. Дерево печатается по уровням:');
                Writeln('   от корня к листям');
                Writeln
            end
            else if (ParamStr(2) = 'edit') then
            begin
                ClrScr;
                Writeln('Изменение значения элемента матрицы');
                Writeln;
                Writeln('  Структура команды:');
                Writeln;
                Writeln('./main edit <matrix_name> <i> <j> <num>');
                WriteLn;
                Writeln('matrix_name -имя файла считываемой матрицы');
                Writeln('             (с разрешением)');
                Writeln('i           -строка');
                Writeln('j           -столбец');
                Writeln('num         -значение элемента');
                Writeln;
                WriteLn('           Будьте осторожны');
                Writeln;
                Writeln('1. Добавление элемента за границами');
                Writeln('   матрицы изменит её размеры');
                Writeln('2. Изменения матрицы производятся');
                Writeln('   непосредственно с оригиналом');
                Writeln
            end
            else if (ParamStr(2) = 'print') then
            begin
                ClrScr;
                Writeln('      Отображатель индекса');
                Writeln;
                Writeln('       Структура команды:');
                Writeln;
                Writeln('./main print <file_name> <mode>');
                WriteLn;
                Writeln('file_name -файл с матрицей');
                Writeln('           (с разрешением)');
                Writeln('mode      -режим печати');
                Writeln;
                WriteLn('       Режимы печати дерева');
                Writeln;
                Writeln('1. Печатается сначала левое поддерево,');
                Writeln('   затем правое');
                Writeln('2. Дерево печатается по уровням:');
                Writeln('   от корня к листям');
                Writeln
            end
        end
        else
        begin
            ClrScr;
            Writeln('    Добро пожаловать в мою программу');
            Writeln(' Вам на выбор предоставляются следующие');
            Writeln('         операции с матрицами');
            Writeln;

            Writeln('  1. Генератор матриц    - generate');
            Writeln('  2. Умножение матриц    - multiply');
            Writeln('  3. Построитель индекса - index');
            Writeln('  4. Редактор матрицы    - edit');
            Writeln('  5. Печать матрицы      - print');
            Writeln;

            writeln(' Вы можете посмотреть подробную информацию');
            writeln('   по определённому модулю, написав:');
            writeln('       ./main help <имя_модуля>');

            Writeln
        end
    end
    else if (ParamStr(1) = 'generate') then
    begin
        val(ParamStr(2), n, code);
        if (code <> 0) then Val_error;
        val(ParamStr(3), m, code);
        if (code <> 0) then Val_error;
        val(ParamStr(4), eps, code);
        if (code <> 0) then Val_error;
        val(ParamStr(5), mode, code);
        if (code <> 0) then Val_error;

        file_name_1 := ParamStr(6);

        if (ParamStr(7) = 'sparse') then mat_type := SPARSE
        else if (ParamStr(7) = 'dence') then mat_type := DENCE
        else No_type_error;

        if num_of_param = 8 then
            if ParamStr(8) = 'true' then to_console := true
            else to_console := false;
        
        mat_1 := Generator(n, m, eps, mode, file_name_1, mat_type, to_console);

        Make_an_index(mat_1, file_name_1);

        Kill_tree(mat_1)
    end
    else if (ParamStr(1) = 'multiply') then
    begin
        val(ParamStr(2), eps, code);
        if code <> 0 then Val_error;
        if (ParamStr(3) = 'sparse') then mat_type := SPARSE
        else if (ParamStr(3) = 'dence') then mat_type := DENCE
        else No_type_error;
        result_name := ParamStr(4);
        
        if ParamCount = 5 then Mult_error
        else
        begin
            dim_1 := Read_mat(ParamStr(5), mat_1);
            for counter := 6 to ParamCount do
            begin
                dim_2 := Read_mat(ParamStr(counter), mat_2);
                result_mat := Mat_multi(eps, mat_type, result_name, 
                                        mat_1, mat_2, dim_1, dim_2);
                dim_1[2] := dim_2[2];
                Kill_tree(mat_1); Kill_tree(mat_2);
                mat_1 := result_mat; result_mat := nil
            end;
            Make_an_index(mat_1, result_name);
            Kill_tree(mat_1)
        end
    end
    else if (ParamStr(1) = 'edit') then
    begin
        file_name_1 := ParamStr(2);
        dim_1 := Read_mat(file_name_1, mat_1);
        
        val(ParamStr(3), i, code);
        if code <> 0 then Val_error;
        val(ParamStr(4), j, code);
        if code <> 0 then Val_error;
        val(ParamStr(5), num, code);
        if code <> 0 then Val_error;
	change_dim := false;
        change_dim := Mat_edit(mat_1, i, j, num);
        setLength(file_name_1, length(file_name_1) - 5);
        
        if change_dim then begin dim_1[1] := 0; dim_1[2] := 0 end; 
        
        Make_a_mat(mat_1, file_name_1, dim_1[3], dim_1[1], dim_1[2]);

        Kill_tree(mat_1)
    end
    else if (ParamStr(1) = 'index') then
    begin
        file_name_1 := ParamStr(2);
        file_name_2 := ParamStr(3);
        to_console := False; 
        if (ParamCount = 5) then
        begin
            to_console := True;
            val(ParamStr(5), mode, code);
            if code <> 0 then Val_error;
        end;

        Read_mat(file_name_1, mat_1);
        Make_an_index(mat_1, file_name_2);

        if to_console then Print_a_tree(mat_1, mode);

        Kill_tree(mat_1)
    end
    else if (ParamStr(1) = 'print') then
    begin
        file_name_1 := ParamStr(2);
        val(ParamStr(3), mode, code);
        if code <> 0 then Val_error;

        Read_mat(file_name_1, mat_1);
        Print_a_tree(mat_1, mode);

        Kill_tree(mat_1);

        Writeln
    end
    else
    begin
        ClrScr;
        Writeln('Введённой команды не существует');
        Writeln('Для ознакомления с существующими модулями');
        Writeln('напишите ./main help');
        Writeln
    end
end;

{==============================================================================}

begin

    Read_param;
    
end.
