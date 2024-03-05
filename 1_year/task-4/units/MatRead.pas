unit MatRead;

{$mode objfpc}

{------------------------------------------------------------------------------}

interface

uses
    Trees,
    MatType, 
    Crt,
    Sysutils;

function Read_mat(file_name: string; var tree: mat_tree_t): dimensions_t;

{------------------------------------------------------------------------------}

implementation

{
    Процедура, производящая считывание данных из входного файла и
    добавляющая их в АВЛ-дерево
}

function Read_mat(
        file_name:    string;                     //Наш счиываемый файл
    var tree:         mat_tree_t                 //Создаваемая матрица
    ): dimensions_t;

var
    mat_file:        text;                     //Наш счиываемый файл
    sym:             char;                     //Очередной считываемый символ
    mode:            SmallInt = -1;            
                                               //Режим чтения матрицы:
                                               //  0) Разреженная матрицы
                                               //  1) Плотная матрица
                                               
    n:               longint = 0;
    m:               longint = 0;
    mode_string:     string = '';
    part:            longword = 1;
    mode_flag:       Boolean = False;          //Прочтён ли режим записи матрицы
    go_to_next_line: Boolean = False;
    i, j:            longword;
    num:             double;
    after_dot:       Boolean = False;          //Прочли ли мы точку(для разреж.)
    ad_counter:      LongWord;                 //after_dot_counter
    negative:        Boolean = False;
    word_starts:     Boolean = False;
    i_d, j_d:        longword;
    started:         Boolean = False;
    expotent_flag:   Boolean = False;
    positive_exp:    Boolean = False;
    expotent:        Longword = 0;
    path:            String;

{----------------------------------------------------------------------}

function Is_a_letter(sym: char): Boolean;
begin
    if ((sym >= 'A') and (sym <= 'z')) or (sym = '_') then Is_a_letter := True
    else Is_a_letter := False
end;

{----------------------------------------------------------------------}

function Is_a_number(sym: char): Boolean;
begin
    if (sym >= '0') and (sym <= '9') then Is_a_number := True
    else Is_a_number := False
end;

{----------------------------------------------------------------------}

procedure Wrong_mode_format;
begin
    ClrScr;
    Writeln('Неверный формат ввода вида матрицы и');
    Writeln('её размера');
    Halt(0)
end;

{----------------------------------------------------------------------}

procedure Mode_error;
begin
    ClrScr;
    Writeln(mode_string, ' матрицы не существует');
    WriteLn('Доступные виды:');
    WriteLn('разреженная - sparse_matrix');
    WriteLn('плотная - dence_matrix');
    Halt(0)
end;

{----------------------------------------------------------------------}

procedure Wrong_sparse_line_format;
begin
    ClrScr;
    Writeln('Неверный формат ввода элементов');
    Writeln('разреженной матрицы');
    Halt(0)
end;

{----------------------------------------------------------------------}

procedure Wrong_dence_line_format;
begin
    ClrScr;
    Writeln('Неверный формат ввода элементов');
    Writeln('плотной матрицы');
    Halt(0)
end;

{----------------------------------------------------------------------}

procedure No_file_error;
begin
    ClrScr;
    Writeln('Файла с названием ', file_name);
    Writeln('не существует');
    Halt(0)
end;

{----------------------------------------------------------------------}

procedure Expotent_error;
begin
    ClrScr;
    Writeln('Несколько раз введена степенная часть элемента матрицы');
    Writeln('не существует');
    Halt(0)
end;

{----------------------------------------------------------------------}

begin
    path := './Matrix/';

    if FileExists(path + file_name) then
        Assign(mat_file, path + file_name)
    else No_file_error;

    Reset(mat_file);

    if Eof(mat_file) then
    begin
        ReadKey; ClrScr;
        GotoXY(4, 2);
        Writeln('Зачем вы мне подсунули пустой файл');
        GotoXY(1, 4);
        Halt(0)
    end;

    i := 0; j := 0; num := 0.0; ad_counter := 1;
    i_d := 1; j_d := 1;

    repeat                             //Чтение строк
        repeat                         //Чтение отдельной строки

            if Eoln(mat_file) and not(started) then
                Continue;

            Read(mat_file, sym);

            //Write(sym);

            if not(started) then started := True;

            if go_to_next_line then Continue
            
            //Если видим комментарий, переходим на следующую строку
            
            else if sym = '#' then go_to_next_line := True
            
            //Пропускаем пробелы
            
            else if (sym = #32) or (sym = #9) or 
                    (sym = #10) or (sym = #13) then 
            begin
                if (mode = DENCE) and not(odd(part)) then
                begin
                    if (num <> 0.0) then
                    begin
                        if not(positive_exp) then num := num * exp(ln(10) * -expotent)
                        else num := num * exp(ln(10) * expotent);
                        FormAVL(tree, i_d, j_d, num)
                    end;

                    negative := False;
                    ad_counter := 1;
                    after_dot := False;
                    inc(j_d);
                    num := 0.0;
                    expotent_flag := False;
                    positive_exp := True;
                    expotent := 0;
                end;
                
                if not(odd(part)) then inc(part);

                word_starts := False;

                if not(Eoln(mat_file)) then Continue
                else break
            end

            else if not(mode_flag) then
            begin
                if not(word_starts) then 
                    begin
                        word_starts := True;
                        Inc(part)
                    end;

                if (part = 2) then
                begin
                    if not(Is_a_letter(sym)) then Wrong_mode_format
                    else
                    begin
                        mode_string := mode_string + sym
                    end
                end

                else if (part = 4) or (part = 6) then
                begin
                    if not(Is_a_number(sym)) then Wrong_mode_format
                    else
                    begin
                        if (part = 4) then 
                            n := n * 10 + ord(sym) - ord('0')
                        else  
                            m := m * 10 + ord(sym) - ord('0')
                    end
                end

                else Wrong_mode_format
            end

            else
            begin

                if (mode = SPARSE) then     //Чтение разреженной матрицы
                begin
                    if not(word_starts) then 
                    begin
                        word_starts := True;
                        Inc(part)
                    end;

                    if (part = 2) or (part = 4) then
                    begin
                        if not(Is_a_number(sym)) then Wrong_sparse_line_format
                        else
                        begin
                            if (part = 2) then 
                                i := i * 10 + ord(sym) - ord('0')
                            else
                                j := j * 10 + ord(sym) - ord('0')
                        end
                    end
                    else if (part = 6) then
                    begin
                        if (sym = '-') and not(negative) then
                            negative := True
                        
                        else if (sym = '.') then
                        begin
                            if not(after_dot) then after_dot := True
                            else Wrong_sparse_line_format
                        end

                        else if (sym = 'E') then
                        begin
                            if not(expotent_flag) then expotent_flag := True
                            else Expotent_error;

                            Read(mat_file, sym);
                            if (sym = '+') then positive_exp := true
                            else positive_exp := False
                        end

                        else if Is_a_number(sym) then
                        begin
                            if not(expotent_flag) then
                            begin
                                if not(after_dot) then 
                                    num := num * 10 + (ord(sym) - ord('0'))
                                else
                                begin
                                    num := num + (exp(ln(10) * -ad_counter)) * 
                                        (ord(sym) - ord('0'));
                                    inc(ad_counter)
                                end
                            end
                            else
                                expotent := expotent * 10 + 
                                            (ord(sym) - ord('0'))
                        end

                        else Wrong_sparse_line_format
                    end
                    else Wrong_sparse_line_format
                end

                else                         //Чтение плотной матрицы
                begin
                    if not(word_starts) then 
                    begin
                        word_starts := True;
                        Inc(part)
                    end;

                    if not(odd(part)) then
                    begin
                        if (i_d > n) or (j_d > m) then
                        begin
                            Wrong_dence_line_format;
                        end;
                        if (sym = '-') and not(negative) then
                            negative := True
                        
                        else if (sym = '.') then
                        begin
                            if not(after_dot) then after_dot := True
                            else Wrong_dence_line_format
                        end

                        else if (sym = 'E') then
                        begin
                            if not(expotent_flag) then expotent_flag := True
                            else Expotent_error;

                            Read(mat_file, sym);
                            if (sym = '+') then positive_exp := true
                            else positive_exp := False
                        end


                        else if Is_a_number(sym) then
                        begin
                            if not(expotent_flag) then
                            begin
                                if not(after_dot) then 
                                    num := num * 10 + (ord(sym) - ord('0'))
                                else
                                begin
                                    num := num + (exp(ln(10) * -ad_counter)) * 
                                        (ord(sym) - ord('0'));
                                    inc(ad_counter)
                                end
                            end
                            else
                                expotent := expotent * 10 + 
                                            (ord(sym) - ord('0'))
                        end
                        
                        else Wrong_dence_line_format
                    end
                end

            end;

        until Eoln(mat_file);                //Чтение отдельной строки

        //writeln;
        //ReadKey;

        if (mode = SPARSE) and (started) then
        begin
            if (negative) then num := -num;
            if (i <> 0) and (j <> 0) and (num <> 0.0) then
            begin
                if not(positive_exp) then
                    num := num * exp(ln(10) * -expotent)
                else
                    num := num * exp(ln(10) * expotent);
                FormAVL(tree, i, j, num)
            end
        end;
        
        if (mode = DENCE) and (started) then
        begin
            if (num <> 0.0) and not(odd(part)) then
                FormAVL(tree, i_d, j_d, num);
            inc(i_d);
            j_d := 1
        end;

        if (part = 6) or (part = 7) then 
            if not(mode_flag) then
            begin
                mode_flag := True;
                     if (mode_string = 'dence_matrix')  then mode := DENCE
                else if (mode_string = 'sparse_matrix') then mode := SPARSE
                else Mode_error
            end
        else if ((part > 1) and (part < 6)) and (mode = SPARSE) then
            if   mode_flag then Wrong_sparse_line_format
            else                Wrong_mode_format;

        if not(Eof(mat_file)) then ReadLn(mat_file);

        part := 1; 
        i := 0; j := 0; num := 0.0; 
        ad_counter := 1;
        go_to_next_line := False; 
        after_dot := False;
        negative := False;
        word_starts := False;
        started := False;
        expotent_flag := False;
        positive_exp := False;
        expotent := 0;


    until Eof(mat_file);                     //Чтение строк

    Read_mat[1] := n;
    Read_mat[2] := m;
    Read_mat[3] := mode

end;

{------------------------------------------------------------------------------}

begin

end.