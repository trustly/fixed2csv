CREATE TABLE FixedRows (
FixedRowID bigserial NOT NULL,
FileID     integer   NOT NULL REFERENCES Files(FileID),
RowID      bigint    NOT NULL,
FixedRow   text      NOT NULL,
Converted  boolean   NOT NULL DEFAULT FALSE,
PRIMARY KEY (FixedRowID),
UNIQUE (FileID, RowID)
);
