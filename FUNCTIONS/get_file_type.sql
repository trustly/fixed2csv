CREATE OR REPLACE FUNCTION Get_File_Type(_FileType text)
RETURNS integer
LANGUAGE sql
AS $FUNC$
SELECT FileTypeID FROM FileTypes WHERE FileType = $1
$FUNC$;
