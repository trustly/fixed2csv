CREATE OR REPLACE FUNCTION Generate_Parser_SQL(_FileID integer)
RETURNS SETOF text
LANGUAGE plpgsql
AS $FUNC$
DECLARE
_FileTypeID  integer;
_FileType    text;
_Variant     integer;
_SQL         text;
_SQLRowIDs   text;
_SQLArray    text;
_SQLJOIN     text;
_SQLWHERE    text;
BEGIN

SELECT
    Files.FileTypeID,
    FileTypes.FileType
INTO STRICT
    _FileTypeID,
    _FileType
FROM Files
INNER JOIN FileTypes ON FileTypes.FileTypeID = Files.FileTypeID
WHERE Files.FileID = _FileID;

_FileTypeID := Get_File_Type(_FileType);

IF _FileTypeID IS NULL THEN
    RAISE EXCEPTION 'No such file type %', _FileType;
END IF;

IF EXISTS (SELECT 1 FROM FileTypePatterns WHERE FileTypeID = _FileTypeID AND (RowOffset IS NULL OR ColOffset IS NULL)) THEN
    RAISE EXCEPTION 'Row/col offsets not determined for all patterns for file type %', _FileType;
END IF;

IF NOT EXISTS (SELECT 1 FROM FileTypePatterns WHERE FileTypeID = _FileTypeID) THEN
    RAISE EXCEPTION 'No file type patterns defined for file type %', _FileType;
END IF;

FOR _Variant IN
SELECT DISTINCT Variant FROM FileTypePatterns WHERE FileTypeID = _FileTypeID ORDER BY Variant
LOOP

    _SQLRowIDs := '';
    _SQLArray  := '';
    _SQLJOIN   := '';
    _SQLWHERE  := '';

    SELECT array_to_string(array_agg, E',')
    INTO STRICT _SQLRowIDs
    FROM (
        SELECT array_agg(format('C%s.FixedRowID', ColumnPos) ORDER BY ColumnPos)
        FROM FileTypePatterns
        WHERE FileTypeID = _FileTypeID
        AND   Variant    = _Variant
    ) AS X;

    SELECT array_to_string(array_agg, E',\n                ')
    INTO STRICT _SQLArray
    FROM (
        SELECT
            array_agg(
                format('substr(C%s.FixedRow, %s, %s)',
                    ColumnPos,
                    ColOffset,
                    length(KnownValue)
                )
                ORDER BY ColumnPos
            )
        FROM FileTypePatterns
        WHERE FileTypeID = _FileTypeID
        AND   Variant    = _Variant
    ) AS X;

    SELECT array_to_string(array_agg, E'\n        ')
    INTO STRICT _SQLJOIN
    FROM (
        SELECT
            array_agg(
                format('INNER JOIN FixedRows AS C%1$s ON C%1$s.FileID = %5$s AND C%1$s.Converted IS FALSE AND C%1$s.FixedRowID + %2$s = C%3$s.FixedRowID + %4$s',
                    C2.ColumnPos,
                    -C2.RowOffset,
                    C1.ColumnPos,
                    -C1.RowOffset,
                    _FileID
                )
                ORDER BY C2.ColumnPos
            )
        FROM FileTypePatterns AS C1
        INNER JOIN FileTypePatterns AS C2 ON C2.ColumnPos = C1.ColumnPos + 1
        WHERE C1.FileTypeID = _FileTypeID AND C1.Variant = _Variant
        AND   C2.FileTypeID = _FileTypeID AND C2.Variant = _Variant
    ) AS X;

    SELECT array_to_string(array_agg, E'\n        ')
    INTO STRICT _SQLWHERE
    FROM (
        SELECT
            array_agg(
                format('AND   substr(C%s.FixedRow, %s, %s) ~ %L',
                    ColumnPos,
                    ColOffset,
                    length(KnownValue),
                    Regexp
                )
                ORDER BY ColumnPos
            )
        FROM FileTypePatterns
        WHERE FileTypeID = _FileTypeID AND Variant = _Variant
    ) AS X;

    _SQL := format('
        SELECT
            LEAST(%1$s)    AS FromRowID,
            GREATEST(%1$s) AS   ToRowID,
            ARRAY[
                %2$s
            ] AS CSVColumns
        FROM FixedRows       AS C1
        %3$s
        WHERE C1.FileID = %5$s AND C1.Converted IS FALSE
        %4$s
    ',
        _SQLRowIDs,
        _SQLArray,
        _SQLJOIN,
        _SQLWHERE,
        _FileID
    );

    RETURN NEXT _SQL;

END LOOP;

RETURN;
END
$FUNC$;
