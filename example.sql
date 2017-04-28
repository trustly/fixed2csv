SET search_path TO fixed2csv, public, pg_temp;

SELECT New_File_Type(_FileType := 'test');
SELECT New_File_Type_Pattern(_FileType := 'test', _Variant := 1, _ColumnPos := 1, _Regexp := '^[A-Za-z ]{20}$',        _KnownValue := 'Foo Bar             ');
SELECT New_File_Type_Pattern(_FileType := 'test', _Variant := 1, _ColumnPos := 2, _Regexp := '^\+[0-9 ]{14}$',         _KnownValue := '+46701234567   ');
SELECT New_File_Type_Pattern(_FileType := 'test', _Variant := 1, _ColumnPos := 3, _Regexp := '^[A-Za-z0-9_.@ -]{30}$',  _KnownValue := 'foo.bar@gmail.com             ');
SELECT New_File(_FileType := 'test', _FilePath := '/tmp/example.txt');
SELECT Find_Offsets(_FilePath := '/tmp/example.txt');
SELECT Parse_File(_FilePath := '/tmp/example.txt');
SELECT * FROM CSVRows;
