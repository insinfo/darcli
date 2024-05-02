CREATE OR REPLACE FUNCTION "esic"."solicitacao_protocolo_trigger_func"()
  RETURNS "pg_catalog"."trigger" AS $BODY$
DECLARE 
	instancia_va text;
	ano_va integer;
	numero_va integer;
BEGIN

	
	SELECT instancia into instancia_va FROM esic.lda_tiposolicitacao WHERE idtiposolicitacao = NEW.idtiposolicitacao;

	if instancia_va = 'I' then
			 ano_va := date_part('year', current_date);

	SELECT numero into numero_va FROM esic.lda_numeracao
	WHERE ano = ano_va;

	if numero_va is null then
		  numero_va := 1;
		 insert into esic.lda_numeracao (ano, numero, dataalteracao)
		 values(ano_va, numero_va, NOW());
	else
		  numero_va := numero_va + 1;

		 update esic.lda_numeracao set
		 numero = numero_va,
		 dataalteracao = NOW()
		 where ano = ano_va;
	end if;

else
	SELECT numprotocolo, anoprotocolo into numero_va, ano_va FROM esic.lda_solicitacao
	WHERE idsolicitacao = NEW.idsolicitacaoorigem;

end if;

 NEW.numprotocolo := numero_va;
 NEW.anoprotocolo := ano_va; 
	
	RETURN new;
END;
 $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100

-- -----------------------------------
CREATE TRIGGER solicitacao_protocolo_trigger
  BEFORE INSERT
  ON lda_solicitacao
  FOR EACH ROW
  EXECUTE PROCEDURE solicitacao_protocolo_trigger_func();



