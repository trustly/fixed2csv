cp example.txt /tmp/
psql -X -f install.sql
psql -X -f example.sql
