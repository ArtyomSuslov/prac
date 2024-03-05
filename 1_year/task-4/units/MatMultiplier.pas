unit MatMultiplier;

{------------------------------------------------------------------------------}

interface

uses
    MatType,
    MatRead,
    MatMake,
    Crt,
    Trees;

procedure Copy_tree(var p: mat_tree_t; tree: mat_tree_t);

procedure  Check_for_eps(var p: mat_tree_t; mat_copy: mat_tree_t; eps: Double);

function Mat_multi(eps: double; mat_type: shortint; file_name: string; 
                   mat_1, mat_2: mat_tree_t;
                   dim_1, dim_2: dimensions_t): mat_tree_t;

{------------------------------------------------------------------------------}

implementation

procedure Copy_tree(var p: mat_tree_t; tree: mat_tree_t);
begin
    if (tree <> nil) then
    begin
        if (tree^.left <> nil) then Copy_tree(p, tree^.left);
        
        FormAVL(p, tree^.row, tree^.column, tree^.element^.value);

        if (tree^.right <> nil) then Copy_tree(p, tree^.right);
    end;
end;

procedure  Check_for_eps(var p: mat_tree_t; mat_copy: mat_tree_t; eps: Double);
begin
    if (mat_copy <> nil) then
    begin
        if (mat_copy^.left <> nil) then 
            Check_for_eps(p, mat_copy^.left, eps);
        
        if mat_copy^.element^.value < eps then 
            KillAVL(p, mat_copy^.row, mat_copy^.column);

        if (mat_copy^.right <> nil) then 
            Check_for_eps(p, mat_copy^.right, eps);
    end;
end;

function Mat_multi(
    eps:                    double;     // точность умножения
    mat_type:               shortint;   // Тип результирующей матрицы
                                        //    1) Разреженная
                                        //    2) Плотная
    file_name:              string;     // Имя файла для сохранения результата
    mat_1, mat_2:           mat_tree_t; // Множители
    dim_1, dim_2:           dimensions_t
    ): mat_tree_t;

var
    n1, m1, n2, m2: LongWord;
    mat_copy:       mat_tree_t = nil;
    mat_res:        mat_tree_t = nil;

procedure Traversal(p: mat_tree_t);

var
    i1, j1, j2: Longword;
    temp_node:  mat_tree_t = nil;
    temp:       Double;

begin
    if (p <> nil) then
    begin
        if (p^.left <> nil) then Traversal(p^.left);
        
        i1 := p^.row;
        j1 := p^.column;

        for j2 := 1 to m2 do
        begin
            temp_node := Find(mat_2, j1, j2);
            if (temp_node <> Nil) then
            begin
                temp := p^.element^.value * temp_node^.element^.value;
                temp_node := Find(mat_res, i1, j2);
                if (temp_node = nil) then
                    FormAVL(mat_res, i1, j2, temp)
                else
                    if temp_node^.element^.value + temp = 0 then
                        KillAVL(mat_res, i1, j2)
                    else
                        Mat_edit(mat_res, i1, j2,
                                 temp_node^.element^.value + temp)
            end;
        end;    

        if (p^.right <> nil) then Traversal(p^.right);
    end;
end;

begin
    n1 := dim_1[1]; m1 := dim_1[2];
    n2 := dim_2[1]; m2 := dim_2[2];

    if (m1 <> n2) then
    begin
        ClrScr;
        Writeln('Размеры матриц не соотносятся');
        Writeln('Умножение невозможно');
        Halt(0)
    end
    else if (mat_1 = nil) or (mat_2 = nil) then
    begin
        Mat_multi := nil;
        mat_res := nil
    end
    else 
    begin
        Traversal(mat_1);
        Copy_tree(mat_copy, mat_res);
        Check_for_eps(mat_res, mat_copy, eps);
        Mat_multi := mat_res;
        Kill_tree(mat_copy)
    end;

    Make_a_mat(mat_res, file_name, mat_type, n1, m2);

end;

{------------------------------------------------------------------------------}

begin

end.
