DROP EXTENSION  "unaccent";
CREATE EXTENSION "unaccent";

SELECT unaccent ( 'Hôtel'::text);

/*CREATE OR REPLACE FUNCTION "esic"."unaccent"(text)
  RETURNS "pg_catalog"."text" AS '$libdir/unaccent', 'unaccent_dict'
  LANGUAGE c STABLE STRICT
  COST 1;
	
	CREATE OR REPLACE FUNCTION "esic"."unaccent"(regdictionary, text)
  RETURNS "pg_catalog"."text" AS '$libdir/unaccent', 'unaccent_dict'
  LANGUAGE c STABLE STRICT
  COST 1;
	
	CREATE OR REPLACE FUNCTION "esic"."unaccent_init"(internal)
  RETURNS "pg_catalog"."internal" AS '$libdir/unaccent', 'unaccent_init'
  LANGUAGE c VOLATILE
  COST 1;
	
	CREATE OR REPLACE FUNCTION "esic"."unaccent_lexize"(internal, internal, internal, internal)
  RETURNS "pg_catalog"."internal" AS '$libdir/unaccent', 'unaccent_lexize'
  LANGUAGE c VOLATILE
  COST 1;*/