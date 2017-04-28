CREATE OR REPLACE FUNCTION Find_Offsets(_FilePath text)
RETURNS boolean
LANGUAGE plpgsql
AS $FUNC$
DECLARE
_FileID            integer;
_FileTypeID        integer;
_Variant           integer;
_UniqueColumnPos   integer;
_UniqueKnownValue  text;
_UniqueColumnRowID bigint;
_ColumnPos         integer;
_KnownValue        text;
_RowID             bigint;
_ColOffset         integer;
_OK                boolean;
BEGIN

SELECT       FileID,  FileTypeID
INTO STRICT _FileID, _FileTypeID
FROM Files
WHERE FilePath = _FilePath;

FOR _Variant IN
SELECT DISTINCT Variant
FROM FileTypePatterns
WHERE FileTypeID = _FileTypeID
AND RowOffset IS NULL
AND ColOffset IS NULL
ORDER BY Variant
LOOP
    SELECT
        ColumnPos,
        KnownValue
    INTO
        _UniqueColumnPos,
        _UniqueKnownValue
    FROM FileTypePatterns
    WHERE FileTypeID = _FileTypeID
    AND   Variant    = _Variant
    AND   RowOffset  IS NULL
    AND   ColOffset  IS NULL
    AND (
        SELECT COUNT(*) FROM FixedRows
        WHERE FixedRows.FileID    = _FileID
        AND   FixedRows.Converted IS FALSE
        AND   FixedRows.FixedRow  LIKE '%'||FileTypePatterns.KnownValue||'%'
    ) = 1
    LIMIT 1;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No KnownValue is unique for Variant % FilePath %', _Variant, _FilePath;
    END IF;

    SELECT FixedRowID
    INTO STRICT _UniqueColumnRowID
    FROM FixedRows
    WHERE FileID   = _FileID
    AND   FixedRow LIKE '%'||_UniqueKnownValue||'%';

    UPDATE FileTypePatterns SET
        RowOffset = 0,
        ColOffset = strpos(
            (SELECT FixedRow FROM FixedRows WHERE FileID = _FileID AND FixedRow LIKE '%'||_UniqueKnownValue||'%'),
            _UniqueKnownValue
        )
    WHERE FileTypeID = _FileTypeID
    AND   Variant    = _Variant
    AND   ColumnPos  = _UniqueColumnPos
    AND   RowOffset  IS NULL
    AND   ColOffset  IS NULL
    RETURNING TRUE INTO STRICT _OK;

    FOR
        _ColumnPos,
        _KnownValue
    IN
    SELECT
        ColumnPos,
        KnownValue
    FROM FileTypePatterns
    WHERE FileTypeID = _FileTypeID
    AND   Variant    = _Variant
    AND   ColumnPos  < _UniqueColumnPos
    AND   RowOffset  IS NULL
    AND   ColOffset  IS NULL
    ORDER BY ColumnPos
    LOOP
        SELECT
            FixedRowID,
            strpos(FixedRow, _KnownValue)
        INTO STRICT
            _RowID,
            _ColOffset
        FROM FixedRows
        WHERE FileID      = _FileID
        AND   FixedRowID <= _UniqueColumnRowID
        AND   FixedRow   LIKE '%'||_KnownValue||'%'
        ORDER BY FixedRowID DESC
        LIMIT 1;

        UPDATE FileTypePatterns SET
            RowOffset = _RowID - _UniqueColumnRowID,
            ColOffset = _ColOffset
        WHERE FileTypeID = _FileTypeID
        AND   Variant    = _Variant
        AND   ColumnPos  = _ColumnPos
        AND   RowOffset  IS NULL
        AND   ColOffset  IS NULL
        RETURNING TRUE INTO STRICT _OK;
    END LOOP;

    FOR
        _ColumnPos,
        _KnownValue
    IN
    SELECT
        ColumnPos,
        KnownValue
    FROM FileTypePatterns
    WHERE FileTypeID = _FileTypeID
    AND   Variant    = _Variant
    AND   ColumnPos  > _UniqueColumnPos
    AND   RowOffset  IS NULL
    AND   ColOffset  IS NULL
    ORDER BY ColumnPos
    LOOP
        SELECT
            FixedRowID,
            strpos(FixedRow, _KnownValue)
        INTO STRICT
            _RowID,
            _ColOffset
        FROM FixedRows
        WHERE FileID      = _FileID
        AND   FixedRowID >= _UniqueColumnRowID
        AND   FixedRow   LIKE '%'||_KnownValue||'%'
        ORDER BY FixedRowID
        LIMIT 1;

        UPDATE FileTypePatterns SET
            RowOffset = _RowID - _UniqueColumnRowID,
            ColOffset = _ColOffset
        WHERE FileTypeID = _FileTypeID
        AND   Variant    = _Variant
        AND   ColumnPos  = _ColumnPos
        AND   RowOffset  IS NULL
        AND   ColOffset  IS NULL
        RETURNING TRUE INTO STRICT _OK;
    END LOOP;
END LOOP;

RETURN TRUE;
END
$FUNC$;
