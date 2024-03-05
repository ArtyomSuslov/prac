unit Trees;

{------------------------------------------------------------------------------}

interface

uses 
    MatType;

type
    list_t = ^node_t;
    node_t = record
        node: mat_tree_t;
        next: list_t
    end;

procedure Print_list(list: list_t);

procedure Add_to_list(var list: list_t; x: mat_tree_t);

procedure Kill_list(var list: list_t);

function Ba(p: mat_tree_t): integer;

procedure xDepth(p: mat_tree_t);

procedure Take(var a, b, c: mat_tree_t);

procedure Link(var a, b, c: mat_tree_t);

function RR(var p: mat_tree_t): Boolean;

function RL(var p: mat_tree_t): Boolean;

function LL(var p: mat_tree_t): Boolean;

function LR(var p: mat_tree_t): Boolean;

procedure MDF(var p: mat_tree_t);

procedure BRN(var p: mat_tree_t; i, j: longword; num: double);

procedure FormAVL(var p: mat_tree_t; i, j: longword; num: double);

function DeleteNode(s: mat_tree_t; var p: mat_tree_t): mat_tree_t;

function Kill_ij(s: mat_tree_t; var p: mat_tree_t; i, j: longword): mat_tree_t;

procedure KillAVL(var p: mat_tree_t; i, j: longword);

function Find(p: mat_tree_t; i, j: Longword): mat_tree_t;

function Mat_edit(var p: mat_tree_t; i, j: LongWord; num: Double): Boolean;

function Find_max_j(p: mat_tree_t): mat_tree_t;

function Find_max_elem(p: mat_tree_t): mat_tree_t;

procedure Obhod(p: mat_tree_t; var f: Text);

procedure Find_dimensions(p: mat_tree_t; var n, m: LongWord);

procedure Print_a_tree(p: mat_tree_t; mode: integer);

procedure Kill_tree(var p: mat_tree_t);

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

function Ba(p: mat_tree_t): integer; {Ba - balance vershini p}
var
    l, r: longword;

begin
    l:=0;
    r:=0;
    
    if p <> nil then with p^ do 
    begin
        if left  <> nil then l := left^.depth;
        if right <> nil then r := right^.depth
    end;
    
    Ba := R - L
end;

procedure xDepth(p: mat_tree_t);
var 
    l, r : longword;

begin   
    if p <> nil then with p^ do 
    begin
        l := 0;
        r := 0;
        
        if left  <> nil then l := left^.depth;
        if right <> nil then r := right^.depth;
        if (l < r) then depth := r + 1
        else depth := l + 1
    end
end;

procedure Take(var a, b, c: mat_tree_t);
begin   
    b := a^.left;
    c := a^.right
end;

procedure Link(var a, b, c: mat_tree_t);
begin   
    a^.left := b;
    a^.right := c
end;

function RR(var p: mat_tree_t): Boolean;
var 
    a, a1, b, b1, c: mat_tree_t;

begin    
    RR := false;
    if Ba(P) = 2 then
        if Ba(p^.right) = 1 then 
        begin
            a := p;                                (* Левая часть *)
            Take(a, a1, b);
            Take(b, b1, c);
            Link(a, a1, b1); xDepth(a);            (* Правая часть *)
            Link(b, a,  c ); xDepth(b);
            p := b;
            RR := true
        end
end;

function RL(var p: mat_tree_t): Boolean;
var 
    a, a1, b, b1, b2, c, c1: mat_tree_t;

begin    
    RL := false;
    if Ba(p) =  2 then
        if Ba(p^.right) = -1 then 
        begin
            a := p;                                (* Левая часть *)
            Take(a, a1, c );
            Take(c, b,  c1);
            Take(b, b1, b2);
            Link(a, a1, b1); xDepth(a);            (* Правая часть *)
            Link(c, b2, c1); xDepth(c);
            Link(b, a,  c ); xDepth(b);
            p := b;
            RL := true
        end
end;

function LL(var p: mat_tree_t): Boolean;
var 
    a, b, b1, c, c1: mat_tree_t;

begin    
    LL := false;
    if Ba(p) = -2 then
        if Ba(p^.left) = -1 then 
        begin
            c := p;                                (* Левая часть *)
            Take(c, b,  c1);
            Take(b, a,  b1);
            Link(c, b1, c1); xDepth(c);            (* Правая часть *)
            Link(b, a,  c ); xDepth(b);
            p := b;
            LL := true
        end
end;

function LR(var p: mat_tree_t): Boolean;
var 
    a, a1, b, b1, b2, c, c1: mat_tree_t;

begin    
    LR := false;
    if Ba(p) = -2 then
        if Ba(p^.left) =  1 then 
        begin
            c := p;                                (* Левая часть *)
            Take(c, a,  c1);
            Take(a, a1, b );
            Take(b, b1, b2);
            Link(a, a1, b1); xDepth(a);            (* Правая часть *)
            Link(c, b2, c1); xDepth(c);
            Link(b, a,  c ); xDepth(b);
            p := b;
            LR := true
        end
end;

procedure MDF(var p: mat_tree_t);

begin         
          if RR(p) then
    else  if RL(p) then
    else  if LL(p) then
    else  if LR(p) then
    else xDepth(p)
end;

{BRN, more like born}

procedure BRN(var p: mat_tree_t; i, j: longword; num: double);

begin
    new(p);
    with p^ do begin
        row := i; 
        column := j;
        left := Nil;
        right := Nil;
        depth := 1;
        new(element);
        element^.value := num
    end
end;

procedure FormAVL(var p: mat_tree_t; i, j: longword; num: double);

procedure Fo(var p: mat_tree_t);
begin   
    if p = nil then BRN(p, i, j, num)
    else with p^ do
        if (row = i) and (column = j) then
        else if (row < i) or ((row = i) and (column < j)) then Fo(right)
        else Fo(left);
    
    MDF(p)
end;

begin
    if (num <> 0.0) then Fo(p)
end;

function DeleteNode(s: mat_tree_t; var p: mat_tree_t): mat_tree_t;
var
    x, y, u, w: mat_tree_t;

begin
    x := p^.left;
    y := p^.right;
    if (p^.element <> Nil) then 
    begin 
        Dispose(p^.element); 
        p^.element := nil 
    end;
    dispose(p); p := nil;
    if (x = nil) and (y = nil) then 
    begin 
        p := nil; 
        DeleteNode := s 
    end
    else if (x = nil) then 
    begin 
        p := y; 
        DeleteNode := s 
    end
    else if (y = nil) then 
    begin 
        p := x; 
        DeleteNode := s 
    end
    else if (x^.right = nil) then 
    begin 
        p := x; 
        DeleteNode := s; 
        p^.right := y 
    end
    else
    begin
        u := x;
        while (u^.right^.right <> nil) do u := u^.right;
        p := u^.right;
        w := p^.left; u^.right := w;
        p^.left := x; p^.right := y;
        DeleteNode := u
    end
end;

function Kill_ij(s: mat_tree_t; var p: mat_tree_t; i, j: longword): mat_tree_t;

begin
    if (p = nil) then Kill_ij := nil
    else with p^ do
        if (row = i) and (column = j) then 
            Kill_ij := DeleteNode(s, p)
        else if (row < i) or ((row = i) and (column < j) ) then
            Kill_ij := Kill_ij(p, right, i, j)
        else
            Kill_ij := Kill_ij(p, left, i, j)
end;

procedure KillAVL(var p: mat_tree_t; i, j: longword);
var 
    e, fict: mat_tree_t;

begin
    if (p = nil) then Exit;
    New(fict);
    e := Kill_ij(fict, p, i, j);
    if p <> nil then
        if e <> nil then
            if e = fict then 
                FormAVL(p, p^.row, p^.column, p^.element^.value)
            else 
                FormAVL(p, e^.row, e^.column, e^.element^.value);
    Dispose(fict); fict := nil
end;

function Find(p: mat_tree_t; i, j: LongWord): mat_tree_t;
begin        
    if p = nil then 
        Find := nil
    else with p^ do
        if (row = i) and (column = j) then 
            Find := p
        else 
            if (row < i) or ((row = i) and (column < j)) then 
                Find := Find(right, i, j)
        else                 
            Find := Find(left, i, j)
end;

function Mat_edit(var p: mat_tree_t; i, j: LongWord; num: Double): Boolean;
var
    temp: mat_tree_t;

begin
    Mat_edit := False;
    temp := Find(p, i, j);
    if temp <> nil then
    begin
        if num = 0 then KillAVL(p, i, j)
        else
        begin
            temp^.element^.value := num;
            Mat_edit := False
        end
    end
    else
    begin
        if num <> 0 then
        begin
            FormAVL(p, i, j, num);
            Mat_edit := True
        end
    end
end;



function Find_max_j(p: mat_tree_t): mat_tree_t;
var
    x, y: mat_tree_t;

begin
    x := p;
    if (p <> nil) then
    begin
        y := Find_max_j(p^.left);
        if (y <> nil) and (y^.column > x^.column) then
            x := y;
        y := Find_max_j(p^.right);
        if (y <> nil) and (y^.column > x^.column) then
            x := y;
    end;
    Find_max_j := x
end;

function Find_max_elem(p: mat_tree_t): mat_tree_t;
var
    x, y: mat_tree_t;

begin
    x := p;
    if (p <> nil) then
    begin
        y := Find_max_j(p^.left);
        if (y <> nil) and (y^.element^.value > x^.element^.value) then
            x := y;
        y := Find_max_j(p^.right);
        if (y <> nil) and (y^.element^.value > x^.element^.value) then
            x := y;
    end;
    Find_max_elem := x
end;

procedure Obhod(p: mat_tree_t; var f: Text);
begin
    if (p <> nil) then
    begin
        if (p^.left <> nil) then obhod(p^.left, f);
        writeln(f, p^.row, ' ',p^.column, ' ', p^.element^.value);
        if (p^.right <> nil) then obhod(p^.right, f);
    end;
end;

procedure Find_dimensions(p: mat_tree_t; var n, m: LongWord);
var
    find_max: mat_tree_t;

begin
    if (n = 0) and (m = 0) then
    begin 
        find_max := p;
        while (find_max^.right <> nil) do
            find_max := find_max^.right;
        n := find_max^.row;
        m := Find_max_j(p)^.column
    end
end;

procedure Print_a_tree(
    p: mat_tree_t; 
    mode: integer           // Режимы печати индекса (АВЛ-дерева)
                            //   1. Корень, затем левое пд, затем правое пд
                            //   2. По уровням: от корня к листьям
                            //      (пд = поддерево)
    );

var
    list, list_1, list_2: list_t;

begin   
    if      (mode = 1) then
    begin
        if (p = nil) then write('nil')
        else 
            with p^ do
                if (left  = nil) and (right = nil) then 
                    write('[', row, '|', column,'\', element^.value:4:0, ']') 
                else 
                begin
                    write('([', row, '|', column,'\', element^.value:4:0, '] '); 
                    Print_a_tree(left, mode);
                    write(' ');
                    Print_a_tree(right, mode); 
                    write(')')
                end
    end
    else if (mode = 2) then
    begin
        list_1 := nil; list_2 := nil;
        Add_to_list(list_1, p);
        while (list_1 <> nil) do
        begin
            list := list_1;
            while (list <> nil) do
            begin
                if (list^.node^.left <> nil) then 
                    Add_to_list(list_2, list^.node^.left);
                if (list^.node^.right <> nil) then 
                    Add_to_list(list_2, list^.node^.right);
                
                Write('[', list^.node^.row, '|', list^.node^.column, '/', 
                      list^.node^.element^.value:4:0, ']');

                list := list^.next
            end;
            Writeln;
            Kill_list(list_1);
            list_1 := list_2; list_2 := nil;
        end;
        Kill_list(list_1)
    end
    else
    begin
    end
end;

procedure Kill_tree(var p: mat_tree_t);
begin
    if (p <> nil) then
    begin
        if p^.left <> nil then
            Kill_tree(p^.left);
        if p^.right <> nil then
            Kill_tree(p^.right);
        if (p^.element <> Nil) then 
        begin 
            Dispose(p^.element); 
            p^.element := nil 
        end;
        dispose(p); p := nil
    end
end;

{------------------------------------------------------------------------------}

end.
