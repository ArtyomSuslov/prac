unit MatIndex;

{------------------------------------------------------------------------------}

interface

uses
    MatType,
    Trees;

type
    list_t = ^node_t;
    node_t = record
        node: mat_tree_t;
        next: list_t
    end;

procedure Print_list(list: list_t);

procedure Add_to_list(var list: list_t; x: mat_tree_t);

procedure Kill_list(var list: list_t);

procedure Num_nodes(var tree: mat_tree_t; var f: text);

procedure Connections(tree: mat_tree_t; var f: text);

procedure Make_an_index(tree: mat_tree_t; file_name: string);

procedure Index_read(var tree: mat_tree_t; file_name: string);

procedure Print_index(file_name: string; mode: ShortInt);


{------------------------------------------------------------------------------}

implementation

procedure Print_list(list: list_t);
var 
    p: list_t;

begin
    p := list;
    while (p <> nil) do
    begin
        write('[', p^.node^.row, ' ', p^.node^.column, ']');
        p := p^.next
    end
end;

procedure Add_to_list(var list: list_t; x: mat_tree_t);
var 
    p, q: list_t;

begin
    p := list;
    new(q); q^.node := x; q^.next := nil;
    if (p = nil) then list := q
    else
    begin
        q^.next := p;
        list := q
    end
end;

procedure Kill_list(var list: list_t);
begin
    if (list <> nil) then Kill_list(list^.next);
    Dispose(list); list := nil
end;

procedure Num_nodes(var tree: mat_tree_t; var f: text);
var
    list_1, list_2: list_t;
    p:              list_t;
    n:              longword;

begin
    n := 1;
    list_1 := nil; list_2 := nil;
    Add_to_list(list_1, tree);
    while (list_1 <> nil) do
    begin
        p := list_1;
        while (p <> nil) do
        begin
            if (p^.node^.right <> nil) then Add_to_list(list_2, p^.node^.right);
            if (p^.node^.left <> nil) then Add_to_list(list_2, p^.node^.left);
            p^.node^.element^.node_num := n;

            writeln(f, n, ' [label="', p^.node^.row, ' ', p^.node^.column, 
                    '\n', p^.node^.element^.value:5, '"];');

            Inc(n);
            p := p^.next
        end;
        Kill_list(list_1);
        list_1 := list_2; list_2 := nil;
    end;
    Kill_list(list_1)
end;

procedure Connections(tree: mat_tree_t; var f: text);

var
    list_1, list_2: list_t;
    p:              list_t;

begin
    list_1 := nil; list_2 := nil;
    Add_to_list(list_1, tree);
    while (list_1 <> nil) do
    begin
        p := list_1;
        while (p <> nil) do
        begin
            if (p^.node^.right <> nil) then 
            begin
                Add_to_list(list_2, p^.node^.right);
                writeln(f, p^.node^.element^.node_num, ' -> ', 
                        p^.node^.right^.element^.node_num,
                        ' [label="R"];')
            end;
            if (p^.node^.left <> nil) then 
            begin
                Add_to_list(list_2, p^.node^.left);
                writeln(f, p^.node^.element^.node_num, ' -> ', 
                        p^.node^.left^.element^.node_num,
                        ' [label="L"];')
            end;

            p := p^.next
        end;
        Kill_list(list_1);
        list_1 := list_2; list_2 := nil;
    end;
    Kill_list(list_1)
end;


procedure Make_an_index(
    tree: mat_tree_t; 
    file_name: string
    );
var
    index_file: text;

begin
    
    Assign(index_file, './Index/' + file_name + '.dot');
    Rewrite(index_file);

    Writeln(index_file, 'digraph');
    Writeln(index_file, '{');

    //Нумеруем все вершины

    Num_nodes(tree, index_file);

    //Описываем все связи
    
    writeLn(index_file);
    writeLn(index_file, '//edges');
    writeLn(index_file);

    Connections(tree, index_file);
    Writeln(index_file, '}');

    Close(index_file)
end;

procedure Index_read(
    var tree: mat_tree_t; 
    file_name: string
    );
begin

end;

procedure Print_index(
    file_name: string; 
    mode: ShortInt
    );
begin

end;

{------------------------------------------------------------------------------}

begin

end.