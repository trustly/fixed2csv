CREATE TABLE Files (
FileID     serial  NOT NULL,
FileTypeID integer NOT NULL REFERENCES FileTypes(FileTypeID),
FilePath   text    NOT NULL,
PRIMARY KEY (FileID),
UNIQUE (FilePath)
);
