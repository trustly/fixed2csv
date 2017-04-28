CREATE OR REPLACE FUNCTION Read_File(_FilePath text) RETURNS TABLE (RowID bigint, RowData text)
LANGUAGE plpgsql
AS $FUNC$
DECLARE
_FakeDelimiterASCIIChar integer;
BEGIN

-- DROP TABLE IF EXISTS doesn't work if pg_temp doesn't exist
-- so this hack is necessary to make sure it always works
CREATE TEMP TABLE Tmp ();
DROP TABLE Tmp;

DROP TABLE IF EXISTS TmpRows;

CREATE TEMP TABLE TmpRows (
RowID   bigserial NOT NULL,
Data    text      NOT NULL,
PRIMARY KEY (RowID)
) ON COMMIT DROP;

_FakeDelimiterASCIIChar := 1;
LOOP
    BEGIN
        EXECUTE format($$COPY TmpRows (Data) FROM %L WITH DELIMITER %L$$, _FilePath, chr(_FakeDelimiterASCIIChar));
        EXIT;
    EXCEPTION
    WHEN OTHERS THEN
        IF _FakeDelimiterASCIIChar = 255 THEN
            RAISE EXCEPTION 'No non-existing character found, cannot trick COPY to import the file.';
        END IF;
        _FakeDelimiterASCIIChar := _FakeDelimiterASCIIChar + 1;
    END;
END LOOP;

RETURN QUERY SELECT TmpRows.RowID, TmpRows.Data FROM TmpRows;

RETURN;
END
$FUNC$;
