CREATE OR REPLACE FUNCTION New_File_Type_Pattern(
_FileType   text,
_Variant    integer,
_ColumnPos  integer,
_Regexp     text,
_KnownValue text
)
RETURNS integer
LANGUAGE sql
AS $FUNC$
INSERT INTO FileTypePatterns (FileTypeID,        Variant, ColumnPos, Regexp, KnownValue)
VALUES                       (Get_File_Type($1), $2,      $3,        $4,     $5        )
RETURNING FileTypePatternID
$FUNC$;
