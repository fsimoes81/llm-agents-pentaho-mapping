SELECT  NULL AS SETOR_UNIMED,
        '('||ENDR.DDD1||') '||ENDR.PREFIXO1||'-'||ENDR.NUMERO1 AS TELEFONE
FROM    SAM_BENEFICIARIO BEN
LEFT JOIN SAM_ENDERECO ENDR ON BEN.ENDERECORESIDENCIAL = ENDR.HANDLE
WHERE   BEN.HANDLE = ?