program main;

uses 
    cthreads, 
    ptcgraph, 
    ptccrt;

const
    COEF = 80;
    EPS = 0.001;

type
    func_t = function(x: real): real;

var
    x_1, x_2, x_3, s: real;
    nr_1, nr_2, nr_3: integer;
    ni_1, ni_2, ni_3: integer;

{------------------------------------------------------------------------------}

function Sign(x: real): SmallInt;
begin
    if x > 0 then Sign := 1
    else if x < 0 then Sign := -1
    else Sign := 0
end;

{==============================================================================}

function F_test_1(x: real): real; begin F_test_1 := x + 5 end;

function F_test_2(x: real): real; begin F_test_2 := sin(x - 5) + ln(x + 2) end;

{==============================================================================}

function F_1(x: real): real; begin F_1 := ln(x) end;

function F_2(x: real): real; begin F_2 := (-2 * x) + 14 end;

function F_3(x: real): real; begin F_3 := 1 / (2 - x) + 6 end;

{------------------------------------------------------------------------------}

procedure Root(f, g: func_t; a, b, eps: real; var x: real; var n: Integer);
var
    c: real;

begin
    n := 0;
    repeat
        n := n + 1;
        if Sign(f(a) - g(a)) <> Sign(f(b) - g(b)) then
        begin
            c := (a + b) / 2;
            if Sign(f(a) - g(a)) <> Sign(f(c) - g(c)) then 
                b := c 
            else 
                a := c
        end
    until ((abs(a - b) / 2)  <= eps) or ((a - b) = 0);
    x := c
end;

{------------------------------------------------------------------------------}

function Integral(f: func_t; a, b, eps: real; var nn: Integer): real;
var
    cur, prev, xi, xii, btw, summand: real;
    n, counter: integer;
    temp: real;

begin
    if b < a then begin temp := b; b := a; a := temp end;
    
    prev := (f(b) + f(a)) / 2 * (b - a);
    n := 1;
    cur := 0;
    nn := 1;

    repeat
        nn := nn + 1;
        if cur <> 0 then prev := cur;
        cur := 0;
        n := n * 2;
        for counter := 0 to (n - 1) do
        begin
            if not(odd(counter)) then
            begin
                xi := a + counter * ((b - a) / n);
                xii := xi + ((b - a) / n) * 2;
                btw := xii - xi;
                summand := (btw / 6) * (f(xi) + 4 * f((xi + xii) / 2) + f(xii));
                cur := cur + summand
            end;
        end;
    until abs(cur - prev) <= eps;

    Integral := cur
end;

{------------------------------------------------------------------------------}

procedure Graphics(x_1, x_2, x_3: real);
var
    GraphDriver, GraphMode: integer;
    max_x, max_y, centre_x, centre_y: integer;

function Scale(x: integer): integer;
begin
    Scale := x
end;

procedure DrawCoords;
begin
    SetColor(7);
    SetLineStyle(SolidLn, 0, ThickWidth);

    {Рисуем оси координат}
    MoveTo(centre_x, 0);
    LineTo(centre_x, max_y);
    MoveTo(0, centre_y);
    LineTo(max_x, centre_y);

    {Рисуем стрелки осей}
    MoveTo(centre_x, 0);
    LineTo(centre_x - Scale(5), Scale(10));
    MoveTo(centre_x, 0);
    LineTo(centre_x + Scale(5), Scale(10));

    MoveTo(max_x, centre_y);
    LineTo(max_x - Scale(10), centre_y + Scale(5));
    MoveTo(max_x, centre_y);
    LineTo(max_x - Scale(10), centre_y - Scale(5));

    {Подписываем оси}
    SetTextStyle(DefaultFont, HorizDir, Scale(2));
    MoveTo(centre_x - Scale(30), Scale(15));
    OutText('y');
    MoveTo(centre_x - Scale(25), centre_y + Scale(15));
    OutText('0');
    MoveTo(max_x - Scale(30), centre_y + Scale(15));
    OutText('x');

    MoveTo(centre_x + 1 * COEF, centre_y + Scale(5));
    LineTo(centre_x + 1 * COEF, centre_y - Scale(5));
    MoveTo(centre_x + 1 * COEF - Scale(5), centre_y + Scale(15));
    OutText('1');

    MoveTo(centre_x - Scale(5), centre_y - 1 * COEF);
    LineTo(centre_x + Scale(5), centre_y - 1 * COEF);
    MoveTo(centre_x - Scale(25), centre_y - 1 * COEF - Scale(5));
    OutText('1');

end;

procedure DrawFunc;
var
    counter: integer;
    x, y: real;

begin
    SetLineStyle(SolidLn, 0, NormWidth);
    SetTextStyle(DefaultFont, HorizDir, Scale(1));

    {рисуем первый график - логарифм}
    SetColor(9);
    MoveTo(centre_x + 1, centre_y - round(F_1(1 / COEF) * COEF));

    for counter := centre_x + 1 to max_x do
    begin
        x := counter - centre_x;
        y := F_1(x / COEF);
        LineTo(counter, centre_y - round(y * COEF));

        if (counter = (centre_x + round(x_2 * COEF) + Scale(10))) then
            OutTextXY(
                counter, 
                centre_y - round(y * COEF) + Scale(5), 
                'y_1 = ln(x)'
                )
    end;

    {рисуем второй график - прямая}
    SetColor(3);
    MoveTo(0, centre_y - round(F_2(-centre_x / COEF) * COEF));

    for counter := 0 to max_x do
    begin
        x := counter - centre_x;
        y := F_2(x / COEF);
        LineTo(counter, centre_y - round(y * COEF));

        if (counter = (centre_x + round(x_1 * COEF) + Scale(10))) then
            OutTextXY(
                counter + Scale(10), 
                centre_y - round(y * COEF), 
                'y_2 = -2x + 14'
                )
    end;

    {рисуем третий график - гипербола}
    SetColor(12);
    MoveTo(0, centre_y - round(F_3(-centre_x / COEF) * COEF));

    for counter := 0 to (centre_x + 2 * COEF - 2) do
    begin
        x := counter - centre_x;
        y := F_3(x / COEF);
        LineTo(counter, centre_y - round(y * COEF))
    end;

    LineTo(centre_x + 2 * COEF, -1);

    MoveTo(centre_x + 2 * COEF + 2, max_y + 1);

    for counter := (centre_x + 2 * COEF + 2) to max_x do
    begin
        x := counter - centre_x;
        y := F_3(x / COEF);
        LineTo(counter, centre_y - round(y * COEF));

        if (counter = (centre_x + round(x_3 * COEF) + Scale(10))) then
            OutTextXY(
                counter + Scale(10), 
                centre_y - round(y * COEF) + Scale(3), 
                'y_3 = 1/(2 - x) + 6'
                )
    end

end;

procedure DrawNumLines;
begin

    SetColor(15);
    SetLineStyle(DashedLn, 0, NormWidth);

    {for x_1}
    MoveTo(centre_x + round(x_1 * COEF), centre_y);
    LineTo(
        centre_x + round(x_1 * COEF), 
        centre_y - round(F_1(round(x_1 * COEF) / COEF) * COEF)
        );
    MoveTo(centre_x, centre_y - round(F_1(round(x_1 * COEF) / COEF) * COEF));
    LineTo(
        centre_x + round(x_1 * COEF), 
        centre_y - round(F_1(round(x_1 * COEF) / COEF) * COEF)
        );
    
    {for x_2}
    MoveTo(centre_x + round(x_2 * COEF), centre_y);
    LineTo(
        centre_x + round(x_2 * COEF), 
        centre_y - round(F_1(round(x_2 * COEF) / COEF) * COEF)
        );
    MoveTo(centre_x, centre_y - round(F_1(round(x_2 * COEF) / COEF) * COEF));
    LineTo(
        centre_x + round(x_2 * COEF), 
        centre_y - round(F_1(round(x_2 * COEF) / COEF) * COEF)
        );
    
    {for x_2}
    MoveTo(centre_x + round(x_3 * COEF), centre_y);
    LineTo(
        centre_x + round(x_3 * COEF), 
        centre_y - round(F_3(round(x_3 * COEF) / COEF) * COEF)
        );
    MoveTo(centre_x, centre_y - round(F_3(round(x_3 * COEF) / COEF) * COEF));
    LineTo(
        centre_x + round(x_3 * COEF), 
        centre_y - round(F_3(round(x_3 * COEF) / COEF) * COEF)
        )
end;

procedure FillTheFigure;
var
    counter_x, counter_y, x, y: integer;

begin
    for counter_x := (centre_x + 2 * COEF) + 2 to max_x do
        for counter_y := 0 to max_y do
        begin
            x := counter_x - centre_x;
            y := centre_y - counter_y;
            if (y > (F_1(x / COEF) * COEF)) 
                and (y < (F_2(x / COEF) * COEF))
                and (y < (F_3(x / COEF) * COEF))
            then 
                PutPixel(counter_x, counter_y, 7)
        end
end;

begin
    GraphDriver := D8bit;
    GraphMode := m1024x768;
    InitGraph(GraphDriver, GraphMode, '');

    max_x := GetMaxX;
    max_y := GetMaxY;
    centre_x := max_x div 5;
    centre_y := max_y - max_y div 5;

    FillTheFigure;
    DrawCoords;
    DrawFunc;
    DrawNumLines;
    
    Readkey;
    CloseGraph

end;

{------------------------------------------------------------------------------}

begin
    nr_1 := 0; nr_2 := 0; nr_3 := 0;
    ni_1 := 0; ni_2 := 0; ni_3 := 0;

    Root(@F_1, @F_2, 1,   8, EPS / 2, x_1, nr_1);
    Root(@F_1, @F_3, 2.1, 8, EPS / 2, x_2, nr_2);
    Root(@F_2, @F_3, 3,   6,  EPS / 2, x_3, nr_3);

    s := 0;
    s := s + Integral(@F_2, x_1, x_3, EPS / 40, ni_1);
    s := s + Integral(@F_3, x_2, x_3, EPS / 40, ni_2);
    s := s - Integral(@F_1, x_1, x_2, EPS / 40, ni_3);

    ClrScr;
    TextColor(Yellow);
    Writeln('Точки пересечения графиков:');
    Writeln;
    Writeln('x        y        f(x)        Кол-во итераций');
    TextColor(White);
    Write(x_1:5:5); Write('  '); Write(F_1(x_1):5:5); 
    Write('  '); Write('F_1 - F_2'); Write('   '); Writeln(nr_1);

    Write(x_2:5:5); Write('  '); Write(F_3(x_2):5:5);
    Write('  '); Write('F_1 - F_3'); Write('   '); Writeln(nr_1);

    Write(x_3:5:5); Write('  '); Write(F_2(x_3):5:5);
    Write('  '); Write('F_2 - F_3'); Write('   '); Writeln(nr_1);

    Writeln;
    TextColor(Yellow);
    Writeln('Площадь фигуры:     Кол-во итераций:');
    TextColor(White);
    Writeln;
    Write(s:6:6); Write('           '); Writeln(ni_1 + ni_2 + ni_3);
    Writeln;

    Graphics(x_1, x_2, x_3)

end.