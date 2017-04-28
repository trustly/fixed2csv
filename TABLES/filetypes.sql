CREATE TABLE FileTypes (
FileTypeID serial NOT NULL,
FileType   text   NOT NULL,
PRIMARY KEY (FileTypeID),
UNIQUE (FileType)
);
