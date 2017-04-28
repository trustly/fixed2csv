CREATE OR REPLACE FUNCTION Parse_File(_FilePath text)
RETURNS boolean
LANGUAGE plpgsql
AS $FUNC$
DECLARE
_FileID     integer;
_FileTypeID integer;
_FileType   text;
_SQL        text;
_FromRowID  bigint;
_ToRowID    bigint;
_CSVColumns text[];
_OK         boolean;
BEGIN

SELECT
    Files.FileID,
    Files.FileTypeID,
    FileTypes.FileType
INTO STRICT
    _FileID,
    _FileTypeID,
    _FileType
FROM Files
INNER JOIN FileTypes ON FileTypes.FileTypeID = Files.FileTypeID
WHERE Files.FilePath = _FilePath;

FOR _SQL IN
SELECT Generate_Parser_SQL(_FileID)
LOOP
    EXECUTE format('CREATE TEMP TABLE ParsedRows AS (%s)', _SQL);
    FOR   _FromRowID, _ToRowID, _CSVColumns IN
    SELECT FromRowID,  ToRowID,  CSVColumns
    FROM ParsedRows
    LOOP
        IF EXISTS (SELECT 1 FROM FixedRows WHERE FileID = _FileID AND Converted IS TRUE AND RowID BETWEEN _FromRowID AND _ToRowID)
        THEN
            RAISE EXCEPTION 'Rows between % and % for FileID % have already been converted', _FromRowID, _ToRowID, _FileID;
        END IF;
        UPDATE FixedRows SET Converted = TRUE WHERE FileID = _FileID AND RowID BETWEEN _FromRowID AND _ToRowID;
        INSERT INTO CSVRows ( FileID,  CSVColumns)
        VALUES              (_FileID, _CSVColumns)
        RETURNING TRUE INTO STRICT _OK;
    END LOOP;
    DROP TABLE pg_temp.ParsedRows;
END LOOP;

RETURN TRUE;
END
$FUNC$;
