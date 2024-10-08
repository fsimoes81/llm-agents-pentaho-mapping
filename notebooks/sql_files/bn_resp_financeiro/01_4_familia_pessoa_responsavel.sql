SELECT --DISTINCT
  'P' AS TIPO_RESPONSAVEL,
  FPES.HANDLE AS ID_RESP_FINANCEIRO,
  FPES_ENDC.BAIRRO AS BAIRRO,
  FPES_ENDC.CEP AS CEP,
  FPES_MUNENDC.NOME AS CIDADE,
  FPES.CNPJCPF AS CNPJ_CPF,
  FPES_ENDC.COMPLEMENTO AS COMPLEMENTO,
  FPES.NOME AS CONTRAT_PAGADOR_NOME,
  FPES.DATASAIDA AS DATA_EXCLUSAO,
  FPES.DATAENTRADA AS DATA_INCLUSAO,
  FPES.DATANASCIMENTO AS DATA_NASCIMENTO,
  FPES_ENDC.DDDCELULAR AS DDD_CELULAR,
  FPES_ENDC.DDD1 AS DDD,
  FPES_ENDC.DDD1 AS DDD_COMERCIAL,
  CASE
    WHEN (SELECT 1 FROM SFN_CONTAFIN FPES_CFIN, SFN_CONTAFIN_COMPLEMENTO FPES_CFIC WHERE FPES_CFIN.PESSOA = FPES.HANDLE AND FPES_CFIN.HANDLE = FPES_CFIC.CONTAFINANCEIRA AND FPES_CFIC.DATAINICIAL <= TRUNC(SYSDATE) AND ( FPES_CFIC.DATAFINAL IS NULL OR FPES_CFIC.DATAFINAL >= TRUNC(SYSDATE) ) AND NVL(FPES_CFIC.CONTACORRENTE, '0') <> '0' AND ROWNUM = 1) = 1 THEN 'S' 
    ELSE 'N'
  END AS DEBITO_AUT,
  (SELECT FPES_AGE.AGENCIA FROM SFN_AGENCIA FPES_AGE, SFN_CONTAFIN FPES_CFIN, SFN_CONTAFIN_COMPLEMENTO FPES_CFIC WHERE FPES_CFIN.PESSOA = FPES.HANDLE AND FPES_CFIN.HANDLE = FPES_CFIC.CONTAFINANCEIRA AND FPES_CFIC.DATAINICIAL <= TRUNC(SYSDATE) AND ( FPES_CFIC.DATAFINAL IS NULL OR FPES_CFIC.DATAFINAL >= TRUNC(SYSDATE) ) AND NVL(FPES_CFIC.CONTACORRENTE, '0') <> '0' AND FPES_CFIC.AGENCIA = FPES_AGE.HANDLE AND ROWNUM = 1) AS DEBITO_AUT_AGENCIA,
  (SELECT FPES_BAN.CODIGO FROM SFN_BANCO FPES_BAN, SFN_CONTAFIN FPES_CFIN, SFN_CONTAFIN_COMPLEMENTO FPES_CFIC WHERE FPES_CFIN.PESSOA = FPES.HANDLE AND FPES_CFIN.HANDLE = FPES_CFIC.CONTAFINANCEIRA AND FPES_CFIC.DATAINICIAL <= TRUNC(SYSDATE) AND ( FPES_CFIC.DATAFINAL IS NULL OR FPES_CFIC.DATAFINAL >= TRUNC(SYSDATE) ) AND NVL(FPES_CFIC.CONTACORRENTE, '0') <> '0' AND FPES_CFIC.BANCO = FPES_BAN.HANDLE AND ROWNUM = 1) AS DEBITO_AUT_BANCO,
  (SELECT FPES_CFIC.CONTACORRENTE FROM SFN_CONTAFIN FPES_CFIN, SFN_CONTAFIN_COMPLEMENTO FPES_CFIC WHERE FPES_CFIN.PESSOA = FPES.HANDLE AND FPES_CFIN.HANDLE = FPES_CFIC.CONTAFINANCEIRA AND FPES_CFIC.DATAINICIAL <= TRUNC(SYSDATE) AND ( FPES_CFIC.DATAFINAL IS NULL OR FPES_CFIC.DATAFINAL >= TRUNC(SYSDATE) ) AND NVL(FPES_CFIC.CONTACORRENTE, '0') <> '0' AND ROWNUM = 1) AS DEBITO_AUT_CONTA,
  (SELECT FPES_CFIC.DV FROM SFN_CONTAFIN FPES_CFIN, SFN_CONTAFIN_COMPLEMENTO FPES_CFIC WHERE FPES_CFIN.PESSOA = FPES.HANDLE AND FPES_CFIN.HANDLE = FPES_CFIC.CONTAFINANCEIRA AND FPES_CFIC.DATAINICIAL <= TRUNC(SYSDATE) AND ( FPES_CFIC.DATAFINAL IS NULL OR FPES_CFIC.DATAFINAL >= TRUNC(SYSDATE) ) AND NVL(FPES_CFIC.CONTACORRENTE, '0') <> '0' AND ROWNUM = 1) AS DEBITO_AUT_DIGITO,
  FPES.EMAIL AS EMAIL,
  '('||FPES_ENDC.DDD1||') '||FPES_ENDC.PREFIXO1||'-'||FPES_ENDC.NUMERO1 AS FONE,
  '('||FPES_ENDC.DDDCELULAR||') '||FPES_ENDC.PREFIXOCELULAR||'-'||FPES_ENDC.NUMEROCELULAR AS FONE_CELULAR,
  '('||FPES_ENDC.DDD1||') '||FPES_ENDC.PREFIXO1||'-'||FPES_ENDC.NUMERO1 AS FONE_COMERCIAL,
  FPES_ENDC.LOGRADOURO AS LOGRADOURO,
  FPES_ENDC.NUMERO AS NUMERO,
  CASE
     WHEN (SELECT 1 FROM SFN_CONTAFIN_COMPLEMENTO COM, SFN_CONTAFIN FIN WHERE NVL(COM.CONTACORRENTE, '0') <> '0' AND COM.DATAINICIAL <= TRUNC(SYSDATE) AND ( COM.DATAFINAL IS NULL OR COM.DATAFINAL >= TRUNC(SYSDATE) ) AND COM.CONTAFINANCEIRA = FIN.HANDLE AND FIN.PESSOA = FPES.HANDLE AND ROWNUM = 1) = 1 THEN
       'DEBITO AUTOMATICO'
     WHEN (SELECT 1 FROM SFN_CONTAFIN_TIPODOCUMENTO DOC, SFN_CONTAFIN FIN WHERE DOC.CONTAFINANCEIRA = FIN.HANDLE AND FIN.PESSOA = FPES.HANDLE AND ROWNUM = 1) = 1 THEN
       'BOLETO'
     ELSE
       (SELECT DECODE(FIN.TABGERACAOREC, 1, 'CONTA CORRENTE', 2, 'CARTAO CREDITO', 3, 'BOLETO') FROM SFN_CONTAFIN FIN WHERE FIN.PESSOA = FPES.HANDLE AND ROWNUM = 1)
  END AS TIPO_COBRANCA,
  CASE WHEN FPES.TABFISICAJURIDICA = 1 THEN 'F' WHEN FPES.TABFISICAJURIDICA = 2 THEN 'J' END AS TIPO_PESSOA,
  (SELECT SIGLA FROM ESTADOS WHERE HANDLE = FPES_ENDC.ESTADO) AS UF,
  RAMATI.DESCRICAO AS RAMO_DE_ATIVIDADE,
  TIPDOC.DESCRICAO AS TIPO_DOCUMENTO,
  SYSDATE AS DW_INC,
  SYSDATE AS DW_ALT,
  CFC.DATAINICIAL AS DATA_INICIAL_DEBITO_AUT
,NVL(FAM.HANDLE,0) AS ID_FAMILIA
FROM
  SAM_BENEFICIARIO BEN
  JOIN SAM_FAMILIA FAM ON BEN.FAMILIA = FAM.HANDLE
  JOIN SAM_CONTRATO CON ON FAM.CONTRATO = CON.HANDLE
  JOIN SFN_PESSOA FPES ON FAM.PESSOARESPONSAVEL = FPES.HANDLE
  LEFT OUTER JOIN SAM_ENDERECO FPES_ENDC ON FPES.ENDERECOCORRESPONDENCIA = FPES_ENDC.HANDLE
  LEFT OUTER JOIN MUNICIPIOS FPES_MUNENDC ON FPES_ENDC.MUNICIPIO = FPES_MUNENDC.HANDLE
  LEFT JOIN SAM_RAMOATIVIDADE RAMATI ON FPES.RAMOATIVIDADE = RAMATI.HANDLE
  LEFT JOIN SFN_CONTAFIN CONFIN ON FPES.HANDLE = CONFIN.PESSOA
  LEFT JOIN SFN_TIPODOCUMENTO     TIPDOC ON TIPDOC.HANDLE                = CONFIN.TIPODOCUMENTOREC
  LEFT JOIN SFN_CONTAFIN_COMPLEMENTO CFC ON (CFC.CONTAFINANCEIRA = CONFIN.HANDLE AND CFC.DATAFINAL IS NULL AND CFC.FAMILIA = FAM.HANDLE)
WHERE
  BEN.HANDLE = ?