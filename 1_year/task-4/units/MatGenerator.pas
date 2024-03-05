unit MatGenerator;

{$mode objfpc}

{------------------------------------------------------------------------------}

interface

uses
    MatType,
    Trees,
    MatMake,
    MatIndex,
    Crt;

type
    list_t = ^node_t;
    node_t = record
        i, j: longword;
        next: list_t
    end;

function Generator(n, m: LongWord; 
                   eps: double; mode: SmallInt; 
                   file_name: String; mat_type: SmallInt;
                   to_console: Boolean = False): mat_tree_t;

{------------------------------------------------------------------------------}

implementation

function Generator(
    n, m:       LongWord;       // Размеры матрицы
    eps:        Double;         // Степень разреженности в строке матрицы

    mode:       SmallInt;       // 1. Заполненная единицами в 
                                //    случайных позициях
                                // 2. Со случайными значениями
                                // 3. С единицами в случайных позициях 
                                //    на диагонали
    
    file_name:  String;         // Название создаваемого файла

    mat_type:   SmallInt;       // 0. Разреженная матрица
                                // 1. Плотная матрица
    
    to_console: Boolean = False // Необязательный параметр - вывод матрицы в
                                // консоль
    ): mat_tree_t;

var
    tree:      mat_tree_t;
    non_zero:  LongWord = 0;
    min_nm:    Longword;
    temp_tree: mat_tree_t;
    i, j:      Longword;
    sign:      SmallInt;
    list:      list_t = Nil;
    koords:    dimensions_t;

{----------------------------------------------------------------------}

procedure Mode_error;
begin
    ClrScr;
    Writeln('Введённый режим генерации не существует');
    Halt(0)
end;

{----------------------------------------------------------------------}

procedure No_elem;
begin
    ClrScr;
    Writeln('В генереруемой матрице нет ненулевых');
    Writeln('элементов');
end;

{----------------------------------------------------------------------}

function Min(x, y: Longword): Longword;
begin if x > y then Min := y else Min := x end;

{----------------------------------------------------------------------}

procedure Add_to_list(var list: list_t; i, j: longword);
var 
    p, q: list_t;

begin
    p := list;
    new(q); q^.i := i; q^.j := j; q^.next := nil;
    if (p = nil) then list := q
    else
    begin
        q^.next := p;
        list := q
    end
end;

{----------------------------------------------------------------------}

function Find_node(list: list_t; i, j: longword): list_t;
var 
    p: list_t;

begin
    p := list;
    while (p^.i <> i) and (p^.j <> j) do p := p^.next;
    Find_node := p
end;

{----------------------------------------------------------------------}

function Delete_node(var list: list_t; x: longword): dimensions_t;
var 
    p, q: list_t;
    i: longword;

begin
    if (x = 1) then
    begin
        if (list^.next = nil) then
        begin
            Delete_node[1] := list^.i; Delete_node[2] := list^.j;
            Dispose(list); 
            list := nil
        end
        else
        begin
            p := list; list := list^.next; p^.next := nil;
            Delete_node[1] := p^.i; Delete_node[2] := p^.j;
            Dispose(p); 
            p := nil
        end
    end
    else
    begin
        p := list;
        for i := 2 to x do
        begin
            q := p;
            p := p^.next
        end;
        q^.next := p^.next;
        p^.next := nil;
        Delete_node[1] := p^.i; Delete_node[2] := p^.j;
        Dispose(p); p := nil
    end
end;

{----------------------------------------------------------------------}

procedure Print_list(list: list_t);
begin
    while list <> nil do 
    begin 
        write('(', list^.i, ' ', list^.j, ')'); 
        list := list^.next 
    end
end;

{----------------------------------------------------------------------}

procedure Kill_list(var list: list_t);
begin
    if (list <> nil) then Kill_list(list^.next);
    Dispose(list); list := nil
end;

{----------------------------------------------------------------------}

begin
    Randomize;
    
    tree := nil;

    if      (mode = 1) then
    begin
        non_zero := Round(m * eps);
        list := nil;
        for i := 1 to n do
        begin
            for j := 1 to m do Add_to_list(list, i, j);
            for j := 1 to non_zero do
            begin
                koords := Delete_node(list, Random(m - j + 1) + 1);
                FormAVL(tree, koords[1], koords[2], 1)
            end;
            Kill_list(list)
        end;
        Make_a_mat(tree, file_name, mat_type, n, m);
    end
    else if (mode = 2) then
    begin
        non_zero := Round(m * eps);
        list := nil;
        for i := 1 to n do
        begin
            for j := 1 to m do Add_to_list(list, i, j);
            for j := 1 to non_zero do
            begin
                koords := Delete_node(list, Random(m - j + 1) + 1);
                sign := Random(2);

                if (sign = 0) then
                    FormAVL(tree, koords[1], koords[2], Random(99999))
                else if (sign = 1) then
                    FormAVL(tree, koords[1], koords[2], -Random(99999))

                {if (sign = 0) then
                    FormAVL(tree, koords[1], koords[2], 
                            Random * exp(ln(10) * Random(308)))
                else if (sign = 1) then
                    FormAVL(tree, koords[1], koords[2], 
                            Random * exp(ln(10) * -Random(308) + 1))
                else if (sign = 2) then
                    FormAVL(tree, koords[1], koords[2], 
                            Random * -exp(ln(10) * Random(308) + 1))
                else if (sign = 3) then
                    FormAVL(tree, koords[1], koords[2], 
                            Random * -exp(ln(10) * -Random(308) + 1))}
            end;
            Kill_list(list)
        end;
        Make_a_mat(tree, file_name, mat_type, n, m);
    end
    else if (mode = 3) then
    begin
        min_nm := Min(n, m);
        non_zero := Round(min_nm * eps);
        list := nil;
        
        for i := 1 to min_nm do Add_to_list(list, i, i);
        for i := 1 to non_zero do
        begin
            koords := Delete_node(list, Random(min_nm - i + 1) + 1);
            FormAVL(tree, koords[1], koords[2], 1)
        end;
        Kill_list(list);
        Make_a_mat(tree, file_name, mat_type, n, m);
    end
    else Mode_error;

    // Если нужно, отправляем матрицу на печать в консоль с округлением

    if (to_console) then
    begin
        ClrScr;
        for i := 1 to n do
        begin
            for j := 1 to m do
            begin
                temp_tree := Find(tree, i, j);
                if (temp_tree <> nil) then
                    write(temp_tree^.element^.value:6:0, ' ')
                else 
                    write(double(0):6:0, ' ')
            end;
            Writeln
        end;
        Writeln
    end;

    Generator := tree

end;

{------------------------------------------------------------------------------}

begin

end.