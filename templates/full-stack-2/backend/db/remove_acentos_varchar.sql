CREATE OR REPLACE FUNCTION "remove_acentos"(varchar)
  RETURNS "pg_catalog"."varchar" AS $BODY$
SELECT TRANSLATE(($1),

                 'áéíóúàèìòùãõâêîôôäëïöüçÁÉÍÓÚÀÈÌÒÙÃÕÂÊÎÔÛÄËÏÖÜÇ',
                 'aeiouaeiouaoaeiooaeioucAEIOUAEIOUAOAEIOOAEIOUC')
$BODY$
  LANGUAGE sql VOLATILE
  COST 100

--  CREATE EXTENSION IF NOT EXISTS "unaccent";
--SELECT unaccent ('unaccent', 'Hôtel');

-- Postgres 12 or later
-- https://stackoverflow.com/questions/11005036/does-postgresql-support-accent-insensitive-collations/11007216#11007216
CREATE COLLATION ignore_accent (provider = icu, locale = 'und-u-ks-level1-kc-true', deterministic = false);
CREATE INDEX users_name_ignore_accent_idx ON users(name COLLATE ignore_accent);
SELECT * FROM users WHERE name = 'João' COLLATE ignore_accent;