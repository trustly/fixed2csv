CREATE TABLE CSVRows (
CSVRowID   bigserial NOT NULL,
FileID     integer   NOT NULL REFERENCES Files(FileID),
CSVColumns text[]    NOT NULL,
PRIMARY KEY (CSVRowID)
);
