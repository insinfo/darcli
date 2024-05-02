CREATE OR REPLACE FUNCTION "remove_acentos"(int4)
  RETURNS "pg_catalog"."varchar" AS $BODY$
SELECT TRANSLATE(($1::text),

                 'áéíóúàèìòùãõâêîôôäëïöüçÁÉÍÓÚÀÈÌÒÙÃÕÂÊÎÔÛÄËÏÖÜÇ',
                 'aeiouaeiouaoaeiooaeioucAEIOUAEIOUAOAEIOOAEIOUC')
$BODY$
  LANGUAGE sql VOLATILE
  COST 100