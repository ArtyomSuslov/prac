unit MatMake;

{$mode objfpc}

{------------------------------------------------------------------------------}

interface

uses 
    MatType,
    Crt,
    Sysutils,
    Trees;

procedure Make_a_mat(tree: mat_tree_t; file_name: String; mode: SmallInt;
                     n: LongWord = 0; m: Longword = 0);

{------------------------------------------------------------------------------}

implementation

procedure Make_a_mat(
    tree:      mat_tree_t; 
    file_name: String; 
    mode:      SmallInt;
    n:         LongWord = 0; 
    m:         Longword = 0
    );
var
    mat_file:   Text;
    i:          longword = 1;
    j:          longword = 1;
    temp:       mat_tree_t;
    path:       string;

begin
    path := './Matrix/';
    
    if (mode = SPARSE) then
        Assign(mat_file, path + file_name + '.smtr')
    else
        Assign(mat_file, path + file_name + '.dmtr');
    
    //нужно достать из дерева масимальные размеры матрицы

    Find_dimensions(tree, n, m);

    rewrite(mat_file);                      //открывем файл для записи

    //пишем заголовок файла
    if (mode = DENCE) then Write(mat_file, 'dence_matrix ')
    else                   Write(mat_file, 'sparse_matrix ');
    
    write(mat_file, n, ' ', m); Writeln(mat_file);
    Writeln(mat_file);

    //записываем саму матрицу
    if (mode = SPARSE) then                 //разреженная матрицы
        Obhod(tree, mat_file)
    else                                    //плотная матрица
    begin
        for i := 1 to n do
        begin
            for j := 1 to m do
            begin
                temp := Find(tree, i, j);
                if (temp <> nil) then
                    write(mat_file, temp^.element^.value : 7, ' ')
                else 
                    write(mat_file, double(0) : 7, ' ')
            end;
            Writeln(mat_file)
        end
    end;

    Close(mat_file);                        //закрываем файл

end;

{------------------------------------------------------------------------------}

begin

end.