SELECT 
       BEN.HANDLE                                                                         AS ID_BENEFICIARIO
      ,FAM.HANDLE                                                                         AS ID_FAMILIA
      ,CON.HANDLE                                                                         AS ID_CONTRATANTE
      ,NVL(LOT.HANDLE,0)                                                                  AS ID_CONTRATANTE_LOT
      ,PLA.HANDLE                                                                         AS ID_PLANO
      ,(SELECT MAX(BEN_TIT.HANDLE) 
        FROM   SAM_BENEFICIARIO BEN_TIT 
        WHERE  BEN_TIT.FAMILIA   = BEN.FAMILIA 
        AND    BEN_TIT.EHTITULAR = 'S')                                                   AS ID_BENEFICIARIO_RESP
      ,CASE
         WHEN CON.LOCALFATURAMENTO = 'C' THEN CPES.HANDLE --CPES
         WHEN CON.LOCALFATURAMENTO = 'L' THEN LPES.HANDLE --LPES
         WHEN CON.LOCALFATURAMENTO = 'F' THEN
           CASE
             WHEN FAM.TITULARRESPONSAVEL IS NOT NULL THEN FBEN.HANDLE --FBEN
             WHEN FAM.PESSOARESPONSAVEL  IS NOT NULL THEN SFNP.HANDLE --SFNP
           END
       END                                                                                AS ID_RESP_FINANCEIRO
      ,CASE
        WHEN BEN.DATACANCELAMENTO < SYSDATE THEN BEN.MOTIVOCANCELAMENTO
        WHEN MCAN.CODIGO = 101 AND (BEN.TABORIGEM = 3 OR (BEN.TABORIGEM = 2 AND CON.ESPELHO = 'S')) THEN NULL
        ELSE BEN.MOTIVOCANCELAMENTO
       END                                                                                 AS ID_MOTIVO_CANC
       --Dados Beneficiario
      ,SUBSTR(BEN.BENEFICIARIO,1,4)                                                        AS CODIGO_UNI_PAG
      ,BEN.CODIGODEAFINIDADE                                                               AS CODIGO_AFINIDADE
      ,BEN.BENEFICIARIO                                                                    AS CODIGO_BENEFICIARIO
      ,BEN.CODIGODEORIGEM                                                                  AS CODIGO_ORIGEM
      ,BEN.CODIGOANS                                                                       AS COD_BENEFICIARIO_ANS -- Código que deve ser utilizado - RN da ANS nº 250
      ,BEN.DATAADESAO                                                                      AS DATA_ADESAO
      ,BEN.DATAPRIMEIRAADESAO                                                              AS DATA_PRIM_ADESAO_BENEF
      ,BEN.ATENDIMENTOATE                                                                  AS DATA_ATENDIMENTO_ATE
      ,BEN.DATAULTIMAATUCADASTRAL                                                          AS DATA_ULTIMA_ATU_CADASTRAL
      ,BEN.DATAADAPTACAO                                                                   AS DATA_ADAPTACAO 
      ,BEN.IDADEADAPTACAO                                                                  AS IDADE_ADAPTACAO
      ,BEN.DIASCOMPRACARENCIA                                                              AS DIAS_COMPRA_CARENCIA
      ,BEN.EMAIL                                                                           AS EMAIL
      ,BEN.SEQUENCIA                                                                       AS SEQUENCIA
      ,BEN.CCO                                                                             AS CCO
      ,BEN.CCODV                                                                           AS CCO_DV
      ,BEN.K_EMAIL                                                                         AS K_EMAIL_ZENITE
      ,BEN.K_TELEFONE1                                                                     AS K_TELEFONE1_ZENITE
      ,BEN.K_TELEFONE2                                                                     AS K_TELEFONE2_ZENITE
      ,BEN.K_EMAILIRIS                                                                     AS K_EMAIL_IRIS
      ,BEN.K_EMAILIW                                                                       AS K_EMAIL_IW
      ,BEN.K_TELEFONE1IW                                                                   AS K_TELEFONE1_IW
      ,BEN.K_TELEFONE2IW                                                                   AS K_TELEFONE2_IW
      ,BEN.K_TELEFONE3IW                                                                   AS K_TELEFONE3_IW
      ,BEN.K_TELEFONE4IW                                                                   AS K_TELEFONE4_IW
      ,BEN.K_EMAILSAC                                                                      AS K_EMAIL_SAC
      ,BEN.K_TELEFONERESSAC                                                                AS K_TELEFONE_RES_SAC
      ,BEN.K_TELEFONECONTATOSAC                                                            AS K_TELEFONE_CONTATO_SAC
      ,BEN.K_CELULARSAC                                                                    AS K_TELEFONE_CELULAR_SAC
      ,NVL(TRIM(BEN.Z_NOME),TRIM(BEN.NOME))                                                AS BENEFICIARIO     
      ,DECODE(BEN.NAOTEMCARENCIA, 'S','Sim','N','Não')                                     AS NAO_TEM_CARENCIA
      ,DECODE(BEN.SOFREUADAPTACAO, 1,'Não',2,'Sim')                                        AS SOFREU_ADAPTACAO
      ,DECODE(BEN.TABORIGEM, 1,'Próprio',2,'Assumido',3,'Assumido-Eventual')               AS ORIGEM
      ,DECODE(BEN.BLOQUEIARECADBIOAUTORIZADORWEB,'S','Sim','N','Não')                      AS BLOQUEAR_RECAD_BIO_AUT_WEB
      ,DECODE(FAM.COBRANCANOMESSEGUINTE,'S','Sim','N','Não')                               AS COBRANCA_MES_SEGUINTE
      ,CASE 
          WHEN BEN.DATACANCELAMENTO > REATIVACAO.DATA_REATIVACAO THEN NULL
          ELSE REATIVACAO.DATA_REATIVACAO
       END                                                                                 AS DATA_REATIVACAO
      ,CASE
          WHEN BEN.DATACANCELAMENTO < SYSDATE THEN BEN.DATACANCELAMENTO
          WHEN MCAN.CODIGO = 101 AND 
              (BEN.TABORIGEM = 3 OR 
              (BEN.TABORIGEM = 2 
              AND CON.ESPELHO = 'S')) THEN NULL
          ELSE BEN.DATACANCELAMENTO
       END                                                                                 AS DATA_CANCELAMENTO
      ,CASE
        WHEN CON.INTERCAMBIO = 1 THEN 'Sim'
        WHEN CON.INTERCAMBIO = 2 THEN 'Não'
       END                                                                                 AS INTERCAMBIO

       --Matricula
      ,MAT.CPF                                                                             AS CPF_BENEFICIARIO
      ,MAT.DATAINGRESSO                                                                    AS DATA_INGRESSO
      ,MAT.CARTAONACIONALSAUDE                                                             AS CARTAO_NACIONAL_SAUDE
      ,MAT.DNV                                                                             AS DNV
      ,MAT.DATAEXPEDICAORG                                                                 AS DATA_EXPED_RG
      ,MAT.DATANASCIMENTO                                                                  AS DATA_NASCIMENTO
      ,MAT.DATAINGRESSO                                                                    AS DATA_PRIMEIRA_ADESAO
      ,MAT.RG                                                                              AS RG_BENEFICIARIO
      ,MAT.SEXO                                                                            AS SEXO
      ,MAT.MATRICULA                                                                       AS MATRICULA_UNICA
      ,MAT.ORGAOEMISSOR                                                                    AS ORGAO_EMISSOR_RG
      ,MAT.DATAFALECIMENTO                                                                 AS DATA_FALECIMENTO
      ,MAT.PISPASEP                                                                        AS PISPASEP
      ,MAT.NOMEMAE                                                                         AS NOME_MAE
       --Família
      ,FAM.FAMILIA                                                                         AS CODIGO_FAMILIA
      ,FAM.DATAADESAO                                                                      AS DATA_ADESAO_FAMILIA
      ,FAM.DATAVENDA                                                                       AS DATA_VENDA_FAMILIA      
      ,FAM.DATAINICIOINATIVIDADE                                                           AS DATA_INICIO_INAT_FAMILIA
      ,FAM.DATACANCELAMENTO                                                                AS DATA_CANCELAMENTO_FAMILIA
      ,FAM.DATAINCLUSAO                                                                    AS DATA_INCLUSAO_FAMILIA
      ,FAM.DATAULTIMOREAJUSTE                                                              AS DATA_ULTIMO_REAJUSTE_FAMILIA
      ,FAM.NUMEROPROPOSTA                                                                  AS NUM_PROPOSTA_FAMILIA
      ,FAM.DIACOBRANCA                                                                     AS DIA_COBRANCA
      ,CASE
         WHEN FAM.LEIDEMITIDOSAPOSENTADOS = 1 THEN 'Ativo'
         WHEN FAM.LEIDEMITIDOSAPOSENTADOS = 2 THEN 'Demitido'
         WHEN FAM.LEIDEMITIDOSAPOSENTADOS = 3 THEN 'Aposentado'
       END                                                                                 AS SITUACAO_FAMILIA
       --Contrato
      ,CON.CONTRATO                                                                        AS CONTRATO
      ,CON.CONTRATANTE                                                                     AS CONTRATANTE
      ,CON.DATAADESAO                                                                      AS DATA_ADESAO_CONTRATO
      ,CON.DATACANCELAMENTO                                                                AS DATA_CANC_CONTRATO
      ,LOT.DESCRICAO                                                                       AS LOTACAO
      ,CONTTPDEP.IDADEMAXIMA                                                               AS IDADE_MAXIMA
      ,CBO.ESTRUTURA||' - '||CBO.DESCRICAO                                                 AS CBO
      ,CONV.DESCRICAO                                                                      AS CONVENIO
      ,PLA.CODIGO                                                                          AS CODIGO_PLANO
      ,TPDEP.DESCRICAO                                                                     AS TIPO_DEPENDENTE
      ,TPDEP.CODIGOANS                                                                     AS COD_GRAU_DEPEND_ANS
      ,ESTCIV.DESCRICAO                                                                    AS ESTADO_CIVIL
      ,PAI.GENTILICO                                                                       AS NACIONALIDADE
      ,PAIRG.NOME                                                                          AS PAIS_RG
      ,PAISRG.CODIGOANS                                                                    AS COD_PAIS_RG_ANS      
      ,ESTR.SIGLA                                                                          AS UF
      ,ESTRG.SIGLA                                                                         AS UF_RG
      ,NVL(ESTUNIO.SIGLA,'PR')                                                             AS UF_UNI_ORIGEM
      ,NVL(UNIO.CODIGO,'0032')                                                             AS UNI_ORIGEM
      ,NVL(POL.DESCRICAO,'Estadual')                                                       AS UNI_ORIGEM_DESC_POLITICA
      ,DECODE(BAS.UNIMEDEMCASA,'N','Não','S','Sim',BAS.UNIMEDEMCASA)                      AS UNIMED_EM_CASA
      ,DECODE(BAS.BEMESTARESAUDE,'N','Não','S','Sim',BAS.BEMESTARESAUDE)                  AS BEM_ESTAR_E_SAUDE
      ,(SELECT USU.NOME FROM Z_GRUPOUSUARIOS USU WHERE USU.HANDLE = FAM.USUARIOINCLUSAO)  AS USUARIO_INCLUSAO_FAMILIA
      ,NVL(UNIDES.UNIMED_DESTINO,'0032')                                                  AS UNI_DESTINO
      ,NVL(NVL(UNIO_PES.NOME,UNIO.RAZAOSOCIAL),'UNIMED CURITIBA SOC COOPERATIVA MEDICOS') AS UNI_ORIGEM_RAZAOSOCIAL
      ,NVL(UNIDES.UNIMED_DESTINO_RAZAOSOCIAL,'UNIMED CURITIBA SOC COOPERATIVA MEDICOS')   AS UNI_DESTINO_RAZAOSOCIAL
      ,MUNR.NOME                                                                          AS CIDADE
      ,MUNR.CODIGOIBGE                                                                    AS CODIGO_IBGE
      ,ENDR.BAIRRO                                                                        AS BAIRRO
      ,ENDR.CEP                                                                           AS CEP
      ,ENDR.COMPLEMENTO                                                                   AS COMPLEMENTO
      ,ENDR.DDD1                                                                          AS DDD
      ,ENDR.LOGRADOURO                                                                    AS ENDERECO
      ,ENDR.NUMERO                                                                        AS NUMERO
      ,'('||ENDR.DDD2||') '||ENDR.PREFIXO2||'-'||ENDR.NUMERO2                             AS TELEFONE2
      ,'('||ENDR.DDDCELULAR||') '||ENDR.PREFIXOCELULAR||'-'||ENDR.NUMEROCELULAR           AS CELULAR
      ,MUNC.NOME                                                                          AS CIDADE_CORRESP
      ,ENDC.CEP                                                                           AS CEP_CORRESP
      ,ENDC.BAIRRO                                                                        AS BAIRRO_CORRESP
      ,ENDC.COMPLEMENTO                                                                   AS COMPLEMENTO_CORRESP
      ,ENDC.LOGRADOURO                                                                    AS ENDERECO_CORRESP
      ,ENDC.NUMERO                                                                        AS NUMERO_CORRESP
      ,ESTC.SIGLA                                                                         AS UF_CORRESP
      ,'('||ENDC.DDD1||') '||ENDC.PREFIXO1||'-'||ENDC.NUMERO1                             AS TELEFONE1_CORRESP
      ,'('||ENDC.DDD2||') '||ENDC.PREFIXO2||'-'||ENDC.NUMERO2                             AS TELEFONE2_CORRESP
      ,'('||ENDC.DDDCELULAR||') '||ENDC.PREFIXOCELULAR||'-'||ENDC.NUMEROCELULAR           AS CELULAR_CORRESP
       --Cartão Benef
      ,CARTIDENTIF.TIPO_CARTAO                                                            AS TIPO_CARTAO
      ,CARTIDENTIF.DV                                                                     AS DV_CARTAO_BENEF
      ,CARTIDENTIF.VIA_CARTAO                                                             AS VIA_CARTAO
      ,CARTIDENTIF.DATA_VALID_CARTEIRA                                                    AS DATA_VALID_CARTEIRA
      ,CARTIDENTIF.DATA_GERAC_CARTEIRA                                                    AS DATA_GERAC_CARTEIRA
      ,CARTIDENTIF.DATA_EMISS_CARTEIRA                                                    AS DATA_EMISS_CARTEIRA
      ,CARTIDENTIF.DATA_INICIAL_VALIDADE                                                  AS DATA_INICIAL_VALIDADE
      ,CARTIDENTIF.DATA_FINAL_VALIDADE                                                    AS DATA_FINAL_VALIDADE
      ,CARTIDENTIF.SITUACAO_CARTAO                                                        AS SITUACAO_CARTAO
      ,CARTIDENTIF.VALOR_FATURADO                                                         AS VALOR_FATURADO
      ,CARTIDENTIF.NUMERO_FATURA                                                          AS NUMERO_FATURA
      ,CARTIDENTIF.SITUACAO_ATUALIZACAO_DADOS                                             AS SITUACAO_ATUALIZACAO_DADOS
      ,CARTIDENTIF.DESCRICAO_ROTINA_CARTAO                                                AS DESCRICAO_ROTINA_CARTAO
      ,REPASSE.DATA_INICIO_REPASSE                                                        AS DATA_INICIO_REPASSE
      ,REPASSE.DATA_FINAL_REPASSE                                                         AS DATA_FINAL_REPASSE
       --
      ,CASE  
        WHEN ((SELECT MAX(CID.QTDCPT) FROM SAM_BENEFICIARIO_CID CID       WHERE CID.BENEFICIARIO = BEN.HANDLE) > SYSDATE - CON.DATAADESAO) OR
             ((SELECT MAX(EVE.QTDCPT) FROM SAM_BENEFICIARIO_EVENTO EVE    WHERE EVE.BENEFICIARIO = BEN.HANDLE) > SYSDATE - CON.DATAADESAO) OR
             ((SELECT MAX(PAT.QTDCPT) FROM SAM_BENEFICIARIO_PATOLOGIA PAT WHERE PAT.BENEFICIARIO = BEN.HANDLE) > SYSDATE - CON.DATAADESAO)
        THEN           'S'
        ELSE           'N'
       END                                                                                AS CPT
      ,CASE
        WHEN CON.LOCALFATURAMENTO = 'C' THEN 'P'
        WHEN CON.LOCALFATURAMENTO = 'L' THEN 'P'
        WHEN CON.LOCALFATURAMENTO = 'F' THEN
          CASE
            WHEN FAM.TITULARRESPONSAVEL IS NOT NULL THEN 'B'
            WHEN FAM.PESSOARESPONSAVEL IS NOT NULL THEN 'P'
          END
       END                                                                                AS TIPO_RESPONSAVEL
      ,CASE
        WHEN CON.CONTRATO = 53478 AND 
             TPDEP.DESCRICAO = 'Titular' THEN LPAD(BEN.MATRICULAFUNCIONAL,6,0)
        ELSE BEN.MATRICULAFUNCIONAL
       END                                                                                AS MATRIC_BEN_EMPRESA
      ,CASE
        WHEN BEN.DATACANCELAMENTO < SYSDATE THEN MCAN.DESCRICAO
        WHEN MCAN.CODIGO = 101 AND 
            (BEN.TABORIGEM = 3 OR (BEN.TABORIGEM = 2 AND CON.ESPELHO = 'S')) THEN NULL
        ELSE MCAN.DESCRICAO
       END                                                                                AS MOTIVO_CANC
      ,CASE
        WHEN BEN.MOTIVOINCLUSAO = 5 THEN 'Novo beneficiário'
        WHEN BEN.MOTIVOINCLUSAO = 6 THEN 'Transferência voluntária de carteira'
        WHEN BEN.MOTIVOINCLUSAO = 7 THEN 'Transferência compulsória de carteira'
        ELSE NULL
       END                                                                                AS MOTIVO_INCLUSAO
      ,CASE
        WHEN NVL(UNIO.CODIGO,'0032') = '0032' AND NVL(UNIDES.UNIMED_DESTINO,'0032') = '0032' THEN 'Próprio'
        WHEN NVL(UNIDES.UNIMED_DESTINO,'0032') <> '0032' THEN 'Repassado'
        WHEN NVL(UNIO.CODIGO,'0032') <> '0032' THEN
             CASE
               WHEN BEN.TABORIGEM = 2 THEN 'Assumido'
               WHEN BEN.TABORIGEM = 3 THEN 'Assumido-Eventual'
               ELSE 'Assumido'
             END
       END                                                                                AS TIPO_BENEFICIARIO
      ,CASE
        WHEN UNIO.HANDLE IS NULL THEN 'Estadual'
        WHEN CAMCOM.DESCRICAO IS NULL THEN 'Sem Informação'
        ELSE CAMCOM.DESCRICAO
       END                                                                                AS UNI_ORIGEM_CAMARA_COMPENSACAO
      ,CASE
        WHEN UNIO.HANDLE IS NULL THEN '2-Federativa'
        WHEN CAMCOM.TIPOCAMARA IS NULL THEN 'Sem Informação'
        ELSE DECODE(CAMCOM.TIPOCAMARA ,1,'1-Intra-Federativa'
                                      ,2,'2-Federativa'
                                      ,3,'3-Inter-Federativa'
                                      ,4,'4-Nacional')
       END                                                                                AS UNI_ORIGEM_TIPO_CAMARA_COMP
      ,CASE
        WHEN UNIDES.UNIMED_DESTINO IS NOT NULL THEN
          ( SELECT TIP.DESCRICAO
              FROM SIS_TIPOFATURAMENTO  TIP
                 , SAM_UNIMED           UNI
                 , SAM_REPASSEINTER     REP
             WHERE TIP.HANDLE       = REP.TIPOFATURAMENTO
               AND UNI.CODIGO       = UNIDES.UNIMED_DESTINO
               AND UNI.HANDLE       = REP.UNIMEDDESTINO
               AND REP.DATAINICIAL <= TRUNC(SYSDATE)
               AND ( REP.DATAFINAL IS NULL
                  OR REP.DATAFINAL >= TRUNC(SYSDATE)
                   )
               AND REP.CONTRATO      = CON.HANDLE
               AND ROWNUM            = 1 )
        ELSE
          NULL
       END                                                                                AS TIPO_FATURAMENTO_REP
     ,(SELECT LISTAGG(SUBSTR('('||TO_CHAR(F.DATA,'DD/MM/YYYY')||') '||A.DESCRICAO||': '||SUBSTR(F.OBSERVACAO,0,255),0,4000), '; ') WITHIN GROUP (ORDER BY 1)
       FROM   SAM_FAMILIA_ANOTADM F
       LEFT   JOIN SAM_ANOTACAOADMINISTRATIVA A ON F.ANOTACAO = A.HANDLE
       WHERE   F.FAMILIA = BEN.FAMILIA)                                                   AS ANOTACAO_ADM_FAMILIA
     ,CASE
        WHEN EXISTS (SELECT 1 
                     FROM   AWE_BIOMETRIA BIO 
                     WHERE  BIO.TIPO = 'B'
                     AND    BIO.OPERADORA||SUBSTR(BIO.CODIGO,1,LENGTH(BIO.CODIGO)-1) = BEN.BENEFICIARIO) THEN 'Sim'
        ELSE 'Não'
      END                                                                                 AS POSSUI_BIOMETRIA
     ,(SELECT OCA.DESCRICAO
       FROM   SAM_CONTRATO_ORIGEMCARENCIA  COC
       JOIN   SAM_ORIGEMCARENCIA           OCA ON (OCA.HANDLE = COC.ORIGEMCARENCIA)
       WHERE  COC.HANDLE = BEN.ORIGEMCARENCIA )                                           AS ORIGEM_CARENCIA
       --Handles
      ,NVL(FAM.HANDLE,0)                                                                  AS HANDLE_FAMILIA
      ,BEN.CONTRATO                                                                       AS HANDLE_CONTRATO
      ,FAM.TITULARRESPONSAVEL                                                             AS HANDLE_TITULARRESPONSAVEL
      ,FAM.PESSOARESPONSAVEL                                                              AS HANDLE_PESSOARESPONSAVEL
      ,FAM.LOTACAO                                                                        AS HANDLE_LOTACAO
      ,CON.LOCALFATURAMENTO                                                               AS LOCAL_FATURAMENTO
      ,SYSDATE                                                                            AS DW_INC
      ,SYSDATE                                                                            AS DW_ALT
FROM   SAM_BENEFICIARIO                     BEN
LEFT JOIN SAM_CONTRATO                      CON ON (CON.HANDLE       = BEN.CONTRATO)
LEFT JOIN SAM_FAMILIA                       FAM ON (FAM.HANDLE       = BEN.FAMILIA AND FAM.CONTRATO = BEN.CONTRATO)
LEFT JOIN SAM_MATRICULA                     MAT ON (MAT.HANDLE       = BEN.MATRICULA)
LEFT JOIN SAM_CONTRATO_LOTACAO              LOT ON (LOT.HANDLE       = FAM.LOTACAO)
LEFT JOIN PAISES                            PAI ON (PAI.HANDLE       = MAT.NACIONALIDADE)
LEFT JOIN PAISES                          PAIRG ON (PAIRG.HANDLE     = MAT.PAISEMISSOR)
LEFT JOIN PAISES                         PAISRG ON (PAISRG.HANDLE    = MAT.PAISEMISSOR)
LEFT JOIN ESTADOS                         ESTRG ON (ESTRG.HANDLE     = MAT.ESTADOEMISSOR)
LEFT JOIN SFN_PESSOA                       SFNP ON (SFNP.HANDLE      = FAM.PESSOARESPONSAVEL)
LEFT JOIN SAM_BENEFICIARIO                 FBEN ON (FBEN.HANDLE      = FAM.TITULARRESPONSAVEL)
LEFT JOIN SAM_CBO                           CBO ON (CBO.HANDLE       = BEN.CBO)
LEFT JOIN SAM_CONVENIO                     CONV ON (CONV.HANDLE      = BEN.CONVENIO)
LEFT JOIN SAM_ESTADOCIVIL                ESTCIV ON (ESTCIV.HANDLE    = BEN.ESTADOCIVIL)
LEFT JOIN SAM_CONTRATO_TPDEP          CONTTPDEP ON (CONTTPDEP.HANDLE = BEN.TIPODEPENDENTE)
LEFT JOIN SAM_TIPODEPENDENTE              TPDEP ON (TPDEP.HANDLE     = CONTTPDEP.TIPODEPENDENTE)
LEFT JOIN SAM_MOTIVOCANCELAMENTO           MCAN ON (MCAN.HANDLE      = BEN.MOTIVOCANCELAMENTO)
LEFT JOIN SAM_PLANO                         PLA ON (PLA.HANDLE       = BENPROD.PLANO_OBRIGATORIO(BEN.HANDLE))
LEFT JOIN SAM_ENDERECO                     ENDR ON (ENDR.HANDLE      = BEN.ENDERECORESIDENCIAL)
LEFT JOIN SAM_ENDERECO                     ENDC ON (ENDC.HANDLE      = BEN.ENDERECOCORRESPONDENCIA)
LEFT JOIN K_SAM_BENEFICIARIO_APOIOSAUDE     BAS ON (BAS.BENEFICIARIO = BEN.HANDLE)
LEFT JOIN MUNICIPIOS                       MUNR ON (MUNR.HANDLE      = ENDR.MUNICIPIO)
LEFT JOIN MUNICIPIOS                       MUNC ON (MUNC.HANDLE      = ENDC.MUNICIPIO)
LEFT JOIN ESTADOS                          ESTR ON (ESTR.HANDLE      = ENDR.ESTADO)
LEFT JOIN ESTADOS                          ESTC ON (ESTC.HANDLE      = ENDC.ESTADO)
LEFT JOIN SAM_UNIMED                       UNIO ON (UNIO.HANDLE      = NVL(CON.UNIMEDORIGEM,360))
LEFT JOIN SFN_PESSOA                   UNIO_PES ON (UNIO_PES.HANDLE  = UNIO.PESSOA)
LEFT JOIN SAM_POLITICA                      POL ON (POL.HANDLE       = UNIO.POLITICA)
LEFT JOIN SFN_PESSOA                       CPES ON (CPES.HANDLE      = CON.PESSOA)
LEFT JOIN SFN_PESSOA                       LPES ON (LPES.HANDLE      = LOT.PESSOAFATURAMENTO)
LEFT JOIN SAM_ENDERECO                  ENDUNIO ON (ENDUNIO.HANDLE   = UNIO.ENDERECO)
LEFT JOIN ESTADOS                       ESTUNIO ON (ESTUNIO.HANDLE   = ENDUNIO.ESTADO)
LEFT JOIN SAM_CAMARACOMPENSACAO_PREST CAMCOMPRE ON (CAMCOMPRE.UNIMED = UNIO.HANDLE)
LEFT JOIN SAM_CAMARACOMPENSACAO          CAMCOM ON (CAMCOM.HANDLE    = CAMCOMPRE.CAMARACOMPENSACAO)
LEFT JOIN (SELECT SBMO1.BENEFICIARIO  AS BENEFICIARIO
                 ,SBMR1.DATAINICIAL   AS DATA_INICIO_REPASSE
                 ,SBMR1.DATAFINAL     AS DATA_FINAL_REPASSE
           FROM   SAM_BENEFICIARIO_MOD_REPASSE  SBMR1
           JOIN   SAM_BENEFICIARIO_MOD          SBMO1 ON (SBMO1.HANDLE = SBMR1.BENEFICIARIOMOD)
           WHERE SBMR1.HANDLE          = (SELECT MAX(SBMR2.HANDLE)
                                          FROM   SAM_BENEFICIARIO_MOD_REPASSE  SBMR2
                                          JOIN   SAM_BENEFICIARIO_MOD          SBMO2 ON (SBMO2.HANDLE = SBMR2.BENEFICIARIOMOD)
                                          WHERE  SBMO2.BENEFICIARIO = SBMO1.BENEFICIARIO)) REPASSE ON (REPASSE.BENEFICIARIO = BEN.HANDLE)
LEFT JOIN (SELECT BHI.DATAATIVACAO AS DATA_REATIVACAO
                 ,BHI.BENEFICIARIO AS BENEFICIARIO
           FROM   SAM_BENEFICIARIO_HISTORICO BHI
           WHERE  BHI.HANDLE = (SELECT MAX(BHI2.HANDLE)
                                FROM   SAM_BENEFICIARIO_HISTORICO BHI2
                                WHERE  BHI2.ORIGEM       = 'R'
                                AND    BHI2.BENEFICIARIO = BHI.BENEFICIARIO
                                AND    BHI2.DATAATIVACAO = (SELECT MAX(BHI3.DATAATIVACAO)
                                                            FROM   SAM_BENEFICIARIO_HISTORICO BHI3
                                                            WHERE  BHI3.ORIGEM = 'R'
                                                            AND    BHI3.BENEFICIARIO = BHI.BENEFICIARIO))) REATIVACAO ON (REATIVACAO.BENEFICIARIO = BEN.HANDLE)

LEFT JOIN (SELECT UNIDESI.CODIGO                            AS UNIMED_DESTINO
                 ,BENMODI.BENEFICIARIO                      AS BENEFICIARIO_UNIDES
                 ,NVL(UNIDES_PESI.NOME,UNIDESI.RAZAOSOCIAL) AS UNIMED_DESTINO_RAZAOSOCIAL
           FROM   SAM_BENEFICIARIO_MOD            BENMODI
           JOIN   SAM_BENEFICIARIO_MOD_REPASSE BENMODREPI ON (BENMODREPI.BENEFICIARIOMOD = BENMODI.HANDLE)
           JOIN   SAM_UNIMED                      UNIDESI ON (UNIDESI.HANDLE             = BENMODREPI.UNIMEDDESTINO)
           LEFT JOIN SFN_PESSOA               UNIDES_PESI ON (UNIDES_PESI.HANDLE         = UNIDESI.PESSOA)
           WHERE  BENMODREPI.HANDLE = (SELECT MAX(BENMODREPI2.HANDLE)
                                       FROM   SAM_BENEFICIARIO_MOD            BENMODI2
                                       JOIN   SAM_BENEFICIARIO_MOD_REPASSE BENMODREPI2 ON (BENMODREPI2.BENEFICIARIOMOD = BENMODI2.HANDLE)
                                       JOIN   SAM_UNIMED                      UNIDESI2 ON (UNIDESI2.HANDLE             = BENMODREPI2.UNIMEDDESTINO)
                                       WHERE  BENMODI2.BENEFICIARIO = BENMODI.BENEFICIARIO
                                       AND    UNIDESI2.CODIGO <> '0032')) UNIDES ON (UNIDES.BENEFICIARIO_UNIDES = BEN.HANDLE)
LEFT JOIN (SELECT BC.HANDLE,BC.BENEFICIARIO        AS BENEFICIARIO_CARTIDENTIF
                 ,BC.DATAFINALVALIDADE   AS DATA_VALID_CARTEIRA
                 ,BC.DATAGERACAO         AS DATA_GERAC_CARTEIRA
                 ,BC.DATAEMISSAO         AS DATA_EMISS_CARTEIRA
                 ,TP.DESCRICAO           AS TIPO_CARTAO
                 ,BC.DV                  AS DV
                 ,BC.VIA                 AS VIA_CARTAO
                 ,BC.DATAINICIALVALIDADE AS DATA_INICIAL_VALIDADE
                 ,BC.DATAFINALVALIDADE   AS DATA_FINAL_VALIDADE
                 ,BC.VALORFATURADO       AS VALOR_FATURADO
                 ,FAT.NUMERO             AS NUMERO_FATURA
                 ,DECODE(BC.SITUACAO, 'B', 'Bloqueado','C','Cancelado','N','Normal')    AS SITUACAO_CARTAO
                 ,DECODE(BC.SITUACAOATUALIZADADOS, 'B','Bloqueado','D', 'Desbloqueado') AS SITUACAO_ATUALIZACAO_DADOS
                 ,RC.DESCRICAO                                                          AS DESCRICAO_ROTINA_CARTAO
           FROM   SAM_BENEFICIARIO_CARTAOIDENTIF BC
           LEFT JOIN SAM_CONTRATO_TIPOCARTAO    CTP ON (BC.TIPOCARTAO           = CTP.HANDLE)
           LEFT JOIN SAM_TIPOCARTAO              TP ON (CTP.TIPOCARTAO          = TP.HANDLE)
           LEFT JOIN SFN_FATURA                 FAT ON (FAT.HANDLE              = BC.FATURA)
           LEFT JOIN SAM_ROTINACARTAO_CARTAO    RCC ON (RCC.CARTAOIDENTIFICACAO = BC.HANDLE)
           LEFT JOIN SAM_ROTINACARTAO            RC ON (RC.HANDLE               = RCC.ROTINACARTAO)
           WHERE  BC.HANDLE = (SELECT MAX(BCI.HANDLE)
                               FROM   SAM_BENEFICIARIO_CARTAOIDENTIF BCI
                               WHERE  BCI.BENEFICIARIO      = BC.BENEFICIARIO
                               AND   (BCI.DATAFINALVALIDADE = (SELECT MAX(BCI2.DATAFINALVALIDADE)
                                                               FROM   SAM_BENEFICIARIO_CARTAOIDENTIF BCI2
                                                               WHERE  BCI2.BENEFICIARIO = BCI.BENEFICIARIO
                                                               AND    BCI2.SITUACAO    <> 'C')
                                  OR BCI.DATAFINALVALIDADE = (SELECT MAX(BCI2.DATAFINALVALIDADE)
                                                               FROM   SAM_BENEFICIARIO_CARTAOIDENTIF BCI2
                                                               WHERE  BCI2.BENEFICIARIO = BCI.BENEFICIARIO)))) CARTIDENTIF ON (CARTIDENTIF.BENEFICIARIO_CARTIDENTIF = BEN.HANDLE)
WHERE  BEN.HANDLE = ?