CREATE OR REPLACE FUNCTION New_File(
_FileType text,
_FilePath text
)
RETURNS integer
LANGUAGE plpgsql
AS $FUNC$
DECLARE
_FileID     integer;
_FileTypeID integer;
BEGIN

_FileTypeID := Get_File_Type(_FileType);

INSERT INTO Files ( FileTypeID,  FilePath)
VALUES            (_FileTypeID, _FilePath)
RETURNING    FileID
INTO STRICT _FileID;

INSERT INTO FixedRows (FileID, RowID, FixedRow)
SELECT                _FileID, RowID, RowData
FROM Read_File(_FilePath);

RETURN _FileID;
END
$FUNC$;
