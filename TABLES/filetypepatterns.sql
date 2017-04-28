CREATE TABLE FileTypePatterns (
FileTypePatternID serial  NOT NULL,
FileTypeID        integer NOT NULL REFERENCES FileTypes(FileTypeID),
Variant           integer NOT NULL,
ColumnPos         integer NOT NULL,
Regexp            text    NOT NULL,
KnownValue        text    NOT NULL,
RowOffset         integer,
ColOffset         integer,
PRIMARY KEY (FileTypePatternID),
UNIQUE (FileTypeID, Variant, ColumnPos),
CHECK (KnownValue ~ Regexp),
CHECK ((RowOffset IS NULL) = (ColOffset IS NULL))
);
