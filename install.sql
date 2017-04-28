DROP SCHEMA fixed2csv CASCADE;

CREATE SCHEMA fixed2csv;

SET search_path TO fixed2csv, public, pg_temp;

\ir TABLES/filetypes.sql
\ir TABLES/filetypepatterns.sql
\ir TABLES/files.sql
\ir TABLES/fixedrows.sql
\ir TABLES/csvrows.sql

\ir FUNCTIONS/new_file_type.sql
\ir FUNCTIONS/get_file_type.sql
\ir FUNCTIONS/read_file.sql
\ir FUNCTIONS/new_file.sql
\ir FUNCTIONS/new_file_type_pattern.sql
\ir FUNCTIONS/find_offsets.sql
\ir FUNCTIONS/generate_parser_sql.sql
\ir FUNCTIONS/parse_file.sql
