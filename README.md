# Fixed2CSV

## What is it?

Fixed2CSV converts fixed width formatted data into CSV
by automatically computing the row/column offsets
based on examples of known values given as input by the user.

## Example

```
ADDRESS BOOK

page 1:

Foo Bar             +46701234567   
foo.bar@gmail.com             

John Doe            +150512345678  
cooldude@mail.com             

page 2:

Foo Bar             +3581293773    
foo.bar@hotmail.com           
```

```sql
SELECT New_File_Type(_FileType := 'test');
SELECT New_File_Type_Pattern(_FileType := 'test', _Variant := 1, _ColumnPos := 1, _Regexp := '^[A-Za-z ]{20}$',        _KnownValue := 'Foo Bar             ');
SELECT New_File_Type_Pattern(_FileType := 'test', _Variant := 1, _ColumnPos := 2, _Regexp := '^\+[0-9 ]{14}$',         _KnownValue := '+46701234567   ');
SELECT New_File_Type_Pattern(_FileType := 'test', _Variant := 1, _ColumnPos := 3, _Regexp := '^[A-Za-z0-9_.@ -]{30}$',  _KnownValue := 'foo.bar@gmail.com             ');
SELECT New_File(_FileType := 'test', _FilePath := '/tmp/example.txt');
SELECT Find_Offsets(_FilePath := '/tmp/example.txt');
SELECT Parse_File(_FilePath := '/tmp/example.txt');
SELECT * FROM CSVRows;

 csvrowid | fileid |                                 csvcolumns                                  
----------+--------+-----------------------------------------------------------------------------
        1 |      1 | {"Foo Bar             ","+46701234567   ","foo.bar@gmail.com             "}
        2 |      1 | {"John Doe            ","+150512345678  ","cooldude@mail.com             "}
        3 |      1 | {"Foo Bar             ","+3581293773    ","foo.bar@hotmail.com           "}
        4 |      1 | {"Sven Svensson       ","+471020304050  ","svennis@hotmail.se            "}
(4 rows)

SELECT Variant,ColumnPos,Regexp,KnownValue,RowOffset,ColOffset FROM FileTypePatterns;

 variant | columnpos |         regexp         |           knownvalue           | rowoffset | coloffset 
---------+-----------+------------------------+--------------------------------+-----------+-----------
       1 |         2 | ^\+[0-9 ]{14}$         | +46701234567                   |         0 |        21
       1 |         1 | ^[A-Za-z ]{20}$        | Foo Bar                        |         0 |         1
       1 |         3 | ^[A-Za-z0-9_.@ -]{30}$ | foo.bar@gmail.com              |         1 |         1
(3 rows)

```
