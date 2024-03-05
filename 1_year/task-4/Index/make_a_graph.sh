echo Введите имя дот-файла
read x
dot -Tpdf -o $x.pdf $x.dot
echo Создан пдф файл указанного индекса
