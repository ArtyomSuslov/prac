{$CODEPAGE UTF8}
{$I+}

program calculator;
uses Crt, Math;

const
	Max_number_of_digits = 100;

var
	f: text;
	i: integer;
	alphabet: array [0..69] of char; {Алфавит}
	accuracy: integer;
	epsilon: real;
	num_base: smallint; {Место хранения очередного осн. СС из ParamStr}
	input_str: string;
	sign: char;
	res: double;
	res_str: string;
	code: integer;
	is_zero: boolean;

{----------------------------------------------------------------------}

{
	Проверяем знаменатель на попадания в границы типа
}
	
function Is_den_longword(
	a: longword; 
	b: longword): boolean;

var
	code: integer;
	is_it: boolean;
	
begin
	if (a >= 4294967290) and (b > 5) then is_it := False
	else is_it := True;
	if is_it then Is_den_longword := True
	else Is_den_longword := False
end;

{----------------------------------------------------------------------}

{
	Проверяем числитель на попадания в границы типа
}
	
function Is_numer_longint(
	a: longint; 
	b: longint;
	negative: boolean): boolean;

var
	code: integer;
	is_it: boolean;
	
begin
	if (a >= 2147483640) and not(negative) and (b > 7) then is_it := False
	else
		if (a >= 2147483640) and negative and (b > 8) then is_it := False
		else is_it := True;
	if is_it then Is_numer_longint := True
	else Is_numer_longint := False
end;

{---------------------------------------------------------------------}

{
	Функция перевода числа из 10-ой СС в n-ную СС
}

function From_ten_to_n(
	n: integer; 
	a: double) : string;

var
	integer_part: integer;
	fractional_part: double;
	temp_frac: double;
	line_int, line_frac: string;
	temp: char;
	len: integer;
	j: integer;
	is_int_zero: boolean;
	
begin
	integer_part := trunc(a);
	fractional_part := frac(a);
	line_int := '';
	line_frac := '';
	if integer_part = 0 then is_int_zero := True
	else is_int_zero := False;
	
	while integer_part <> 0 do
	begin
		line_int := line_int + alphabet[integer_part mod n];
		integer_part := integer_part div n;
	end;

	len := length(line_int);
	
	for j := 1 to len div 2 do
	begin
		temp := line_int[j];
		line_int[j] := line_int[len - j + 1];
		line_int[len - j + 1] := temp;
	end;
	
	if (epsilon = 1) or (fractional_part = 0) 
		then From_ten_to_n := line_int
	else
	begin
		j := 0;
		repeat
		begin
			fractional_part := fractional_part * n;
			line_frac := line_frac + alphabet[trunc(fractional_part)];
			temp_frac := trunc(fractional_part);
			fractional_part := frac(fractional_part);
			j := j + 1;
		end
		until ((j > -(ln(epsilon)/ln(n)) + 1) and (temp_frac <> 0))
			or (j > Max_number_of_digits);
		
		if is_int_zero then From_ten_to_n := '0.' + line_frac
		else From_ten_to_n := line_int + '.' + line_frac
	end
end;

{---------------------------------------------------------------------}

{
	Функция перевода числа из n-ой СС в 10-ую с проверкой
	попадания в границы типа
}

function From_n_to_ten_longint(
	n: integer;
	a: string;
	negative: boolean): longint;

var
	len: integer;
	num_ten: longint;
	k: integer;

begin
	num_ten := 0;
	len := length(a);
	
	for k := 1 to len do
	begin
		if len > 10 then
		begin
			Writeln('Wrong type of input data');
			Halt
		end;
		if not(Is_numer_longint(num_ten, (pos(a[k], alphabet) - 1) * 
			round(power(n, len - k)), negative)) then 
		begin
			Writeln('Wrong type of input data');
			Halt
		end;
		if (pos(a[k], alphabet)) > n then
		begin
			Writeln('You used the wrong number for base ', n);
			Halt
		end;
		num_ten := num_ten + 
			(pos(a[k], alphabet) - 1) * round(power(n, len - k))
	end;
	
	if negative then From_n_to_ten_longint := (-1) * num_ten
	else From_n_to_ten_longint := num_ten;
end;

{---------------------------------------------------------------------}

{
	Функция перевода числа из n-ой СС в 10-ую с проверкой
	попадания в границы типа
}

function From_n_to_ten_longword(
	n: integer;
	a: string): longword;

var
	len: integer;
	num_ten: longword;
	k: integer;

begin
	num_ten := 0;
	len := length(a);
	
	for k := 1 to len do
	begin
		if len > 10 then
		begin
			Writeln('Wrong type of input data');
			Halt
		end;
		if not(Is_den_longword(num_ten, (pos(a[k], alphabet) - 1) * 
			round(power(n, len - k)))) then 
		begin
			Writeln('Wrong type of input data');
			Halt
		end;
		if (pos(a[k], alphabet)) > n then
		begin
			Writeln('You used the wrong number for base ', n);
			Halt
		end;
		num_ten := num_ten + 
			(pos(a[k], alphabet) - 1) * round(power(n, len - k))
	end;
	
	From_n_to_ten_longword := num_ten;
end;

{---------------------------------------------------------------------}

{
	Основная процедура, производящая разбиение строки на части и
	производящая операции на результатом
}

procedure Math_operation(
	input_str: string);

var
	sign: char;
	flag: 0..2;
	flag_num: boolean;
	numerator: longint;
	denominator: longword;
	base: smallint;
	base_str, numerator_str, denominator_str: string;
	
begin
	sign := input_str[1];
	flag := 0;
	flag_num := False;
		
	base_str := ''; 
	numerator_str := ''; 
	denominator_str := '';
		
	numerator := 0;
	denominator := 0;
		
    for i := 2 to length(input_str) do
    begin
		if input_str[i] = ';' then break;
			
		if input_str[i] = ':' then 
		begin 
			flag := 1;
			continue; 
		end;
			
		if (input_str[i] = #32) or (input_str[i] = #9) or
			(input_str[i] = #10) or (input_str[i] = #13) then 
			continue;
				
		if input_str[i] = '/' then 
		begin
			flag := 2;
			continue; 
		end;
				
		if flag = 0 then 
			base_str := base_str + input_str[i];
				
		if flag = 1 then 
		begin
			if input_str[i] = '-' then flag_num := True
			else numerator_str := numerator_str + input_str[i]
		end;

		if flag = 2 then 
		begin
			if input_str[i] = '-' then 
			begin
				Writeln('Wrong type of input data');
				Halt
			end;
			denominator_str := denominator_str + input_str[i];
		end;
	end;
		
	val(base_str, base, code);
	
	if (base < 2) or (base > 70) then
	begin
		Writeln('One of the bases, ', base, ', is out of range');
		Writeln('Base of the number system may be only in [0, 70]');
		Halt
	end;
		
	numerator := From_n_to_ten_longint(base, numerator_str, flag_num);
	denominator := From_n_to_ten_longword(base, denominator_str);
		
	case sign of
		'+': res := res + (numerator / denominator);
		'-': res := res - (numerator / denominator);
		'*': res := res * (numerator / denominator);
		'/': if (numerator <> 0) and (denominator <> 0) then
				res := res / (numerator / denominator)
			 else
			 begin
				write('You can not divide by zero');
				Halt
			 end
	end;
end;

{---------------------------------------------------------------------}

begin
	ClrScr;
	
	Assign(f, 'input.txt');
	reset(f);
	
	res := 0;
	accuracy := length(ParamStr(1)) - 2;
	if accuracy = -1 then val(ParamStr(1), epsilon, code)
	else epsilon := power(10, (-1) * accuracy);
	
	{задаём алфавит}
	
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
	
	//Readln(input_str);
	readln(f, input_str);
	
	while input_str <> 'finish' do 
    begin
		if Length(input_str) <> 0 then 
		begin
			Math_operation(input_str);
			//Readln(input_str);
			readln(f, input_str);
		end
		else readln(f, input_str);
    end;
    
    if res >= 0 then sign := '+'
	else sign := '-';
	
	res := abs(res);
	str(res:0:accuracy, res_str);
	val(res_str, res, code);
	
	if frac(res) = 0 then is_zero := True
	else is_zero := False;
	
	for i := 2 to ParamCount do
	begin
		val(ParamStr(i), num_base, code);
		
		if (num_base < 2) or (num_base > 70) then
		begin
			Writeln('One of the bases, ', num_base, ', is out of range');
			Writeln('Base of the number system may be only in [0, 70]');
			continue
		end;
		
		if res = 0 then
		begin
			if num_base < 10 then
				writeln(num_base, '  ', 0)
			else
				writeln(num_base, ' ', 0);
			continue
		end;
		
		if num_base < 10 then
		begin
			if sign = '+' then
				writeln(num_base, '  ', From_ten_to_n(num_base, res))
			else
				writeln(num_base, '  -', From_ten_to_n(num_base, res))
		end;
		if num_base > 10 then
		begin
			if sign = '+' then
				writeln(num_base, ' ', From_ten_to_n(num_base, res))
			else
				writeln(num_base, ' -', From_ten_to_n(num_base, res))
		end;
		if num_base = 10 then
		begin
			if sign = '+' then
				if epsilon = 1 then 
					if is_zero then writeln(num_base, ' ', trunc(res))
					else writeln(num_base, ' ', round(res))
				else 
					if is_zero then writeln(num_base, ' ', trunc(res))
					else writeln(num_base, ' ', res_str)
			else
				if epsilon = 1 then 
					if is_zero then writeln(num_base, ' -', trunc(res))
					else writeln(num_base, ' -', round(res))
				else
					if is_zero then writeln(num_base, ' -', trunc(res))
					else writeln(num_base, ' -', res_str)
		end
	end
end.
