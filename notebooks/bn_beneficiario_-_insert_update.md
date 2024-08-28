# Transformation: BN_BENEFICIARIO - insert/update

## Execution Order

- ('Switch / Case LOCAL FATURAMENTO', 'Switch / Case TITULAR RESPONSÁVEL')
- ('Switch / Case PESSOA RESPONSÁVEL', 'Dummy (do nothing) 2')
- ('Switch / Case PESSOA RESPONSÁVEL', 'FAMILIA PESSOA RESPONSÁVEL')
- ('Switch / Case TITULAR RESPONSÁVEL', 'FAMILIA TITULAR RESPONSÁVEL')
- ('Switch / Case TITULAR RESPONSÁVEL', 'Switch / Case PESSOA RESPONSÁVEL')
- ('Dummy (do nothing)', 'Remover colunas')
- ('Remover colunas', 'Switch / Case LOCAL FATURAMENTO')
- ('BENEFICIÁRIO', 'SAM_FAMILIA_TETO_PF')
- ('SAM_FAMILIA_TETO_PF', 'Dummy (do nothing)')
- ('SEM SETOR', 'Insert / Update - BN_BENEFICIARIO')
- ('Insert / Update - BN_BENEFICIARIO', 'QTD_INCATU_BN_BENEFICIARIO')
- ('Filter rows', 'BUSCA MICROSIGA')
- ('BUSCA MICROSIGA', 'Insert / Update - BN_BENEFICIARIO')
- ('HANDLE_BENEFICIARIO', 'BENEFICIÁRIO')
- ('Filter rows', 'SEM SETOR')
- ('Blocking Step', 'Set Variables')
- ('QTD_INCATU_BN_BENEFICIARIO', 'Blocking Step')
- ('Dummy (do nothing)', 'Filter rows')
- ('Blocking Step 2', 'Set Variables 2')
- ('CONTRATO', 'Insert / Update - BN_RESP_FINANCEIRO')
- ('FAMILIA PESSOA RESPONSÁVEL', 'Insert / Update - BN_RESP_FINANCEIRO')
- ('FAMILIA TITULAR RESPONSÁVEL', 'Insert / Update - BN_RESP_FINANCEIRO')
- ('Insert / Update - BN_RESP_FINANCEIRO', 'QTD_INCATU_BN_RESP_FINANCEIRO')
- ('LOTAÇÃO', 'Insert / Update - BN_RESP_FINANCEIRO')
- ('QTD_INCATU_BN_RESP_FINANCEIRO', 'Blocking Step 2')
- ('Switch / Case LOCAL FATURAMENTO', 'CONTRATO')
- ('Switch / Case LOCAL FATURAMENTO', 'LOTAÇÃO')

## Steps

## Step: BENEFICIÁRIO

Type: DBJoin

### SQL Query

```sql
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
```

Parameters:
- HANDLE_BENEFICIARIO (Number)

## Step: BUSCA MICROSIGA

Type: DBJoin

### SQL Query

```sql
SELECT TRIM(B.CTT_DESC01) AS SETOR_UNIMED,
        TRIM(A.RA_TELEFON) AS TELEFONE/*,
        TRIM(A.RA_EMAIL)   AS EMAIL*/
  FROM SIGA.VW_SRA010 A,
        SIGA.CTT010 B
 WHERE A.RA_MAT = ?
   AND B.CTT_CUSTO = A.RA_CC
```

Parameters:
- MATRIC_BEN_EMPRESA (String)

## Step: Blocking Step

Type: BlockingStep


## Step: Blocking Step 2

Type: BlockingStep


## Step: CONTRATO

Type: DBJoin

### SQL Query

```sql
SELECT --DISTINCT 
  'P' AS TIPO_RESPONSAVEL,
  CPES.HANDLE AS ID_RESP_FINANCEIRO,
  CPES_ENDC.BAIRRO AS BAIRRO,
  CPES_ENDC.CEP AS CEP,
  CPES_MUNENDC.NOME AS CIDADE,
  CPES.CNPJCPF AS CNPJ_CPF,
  CPES_ENDC.COMPLEMENTO AS COMPLEMENTO,
  CPES.NOME AS CONTRAT_PAGADOR_NOME,
  CPES.DATASAIDA AS DATA_EXCLUSAO,
  CPES.DATAENTRADA AS DATA_INCLUSAO,
  CPES.DATANASCIMENTO AS DATA_NASCIMENTO,
  CPES_ENDC.DDDCELULAR AS DDD_CELULAR,
  CPES_ENDC.DDD1 AS DDD,
  CPES_ENDC.DDD1 AS DDD_COMERCIAL,
  CASE
    WHEN (SELECT 1 FROM SFN_CONTAFIN CPES_CFIN, SFN_CONTAFIN_COMPLEMENTO CPES_CFIC WHERE CPES_CFIN.PESSOA = CPES.HANDLE AND CPES_CFIN.HANDLE = CPES_CFIC.CONTAFINANCEIRA AND CPES_CFIC.DATAINICIAL <= TRUNC(SYSDATE) AND ( CPES_CFIC.DATAFINAL IS NULL OR CPES_CFIC.DATAFINAL >= TRUNC(SYSDATE) ) AND NVL(CPES_CFIC.CONTACORRENTE, '0') <> '0' AND ROWNUM = 1) = 1 THEN 'S' 
    ELSE 'N'
  END AS DEBITO_AUT,
  (SELECT CPES_AGE.AGENCIA FROM SFN_AGENCIA CPES_AGE, SFN_CONTAFIN CPES_CFIN, SFN_CONTAFIN_COMPLEMENTO CPES_CFIC WHERE CPES_CFIN.PESSOA = CPES.HANDLE AND CPES_CFIN.HANDLE = CPES_CFIC.CONTAFINANCEIRA AND CPES_CFIC.DATAINICIAL <= TRUNC(SYSDATE) AND ( CPES_CFIC.DATAFINAL IS NULL OR CPES_CFIC.DATAFINAL >= TRUNC(SYSDATE) ) AND NVL(CPES_CFIC.CONTACORRENTE, '0') <> '0' AND CPES_CFIC.AGENCIA = CPES_AGE.HANDLE AND ROWNUM = 1) AS DEBITO_AUT_AGENCIA,
  (SELECT CPES_BAN.CODIGO FROM SFN_BANCO CPES_BAN, SFN_CONTAFIN CPES_CFIN, SFN_CONTAFIN_COMPLEMENTO CPES_CFIC WHERE CPES_CFIN.PESSOA = CPES.HANDLE AND CPES_CFIN.HANDLE = CPES_CFIC.CONTAFINANCEIRA AND CPES_CFIC.DATAINICIAL <= TRUNC(SYSDATE) AND ( CPES_CFIC.DATAFINAL IS NULL OR CPES_CFIC.DATAFINAL >= TRUNC(SYSDATE) ) AND NVL(CPES_CFIC.CONTACORRENTE, '0') <> '0' AND CPES_CFIC.BANCO = CPES_BAN.HANDLE AND ROWNUM = 1) AS DEBITO_AUT_BANCO,
  (SELECT CPES_CFIC.CONTACORRENTE FROM SFN_CONTAFIN CPES_CFIN, SFN_CONTAFIN_COMPLEMENTO CPES_CFIC WHERE CPES_CFIN.PESSOA = CPES.HANDLE AND CPES_CFIN.HANDLE = CPES_CFIC.CONTAFINANCEIRA AND CPES_CFIC.DATAINICIAL <= TRUNC(SYSDATE) AND ( CPES_CFIC.DATAFINAL IS NULL OR CPES_CFIC.DATAFINAL >= TRUNC(SYSDATE) ) AND NVL(CPES_CFIC.CONTACORRENTE, '0') <> '0' AND ROWNUM = 1) AS DEBITO_AUT_CONTA,
  (SELECT CPES_CFIC.DV FROM SFN_CONTAFIN CPES_CFIN, SFN_CONTAFIN_COMPLEMENTO CPES_CFIC WHERE CPES_CFIN.PESSOA = CPES.HANDLE AND CPES_CFIN.HANDLE = CPES_CFIC.CONTAFINANCEIRA AND CPES_CFIC.DATAINICIAL <= TRUNC(SYSDATE) AND ( CPES_CFIC.DATAFINAL IS NULL OR CPES_CFIC.DATAFINAL >= TRUNC(SYSDATE) ) AND NVL(CPES_CFIC.CONTACORRENTE, '0') <> '0' AND ROWNUM = 1) AS DEBITO_AUT_DIGITO,
  CPES.EMAIL AS EMAIL,
  '('||CPES_ENDC.DDD1||') '||CPES_ENDC.PREFIXO1||'-'||CPES_ENDC.NUMERO1 AS FONE,
  '('||CPES_ENDC.DDDCELULAR||') '||CPES_ENDC.PREFIXOCELULAR||'-'||CPES_ENDC.NUMEROCELULAR AS FONE_CELULAR,
  '('||CPES_ENDC.DDD1||') '||CPES_ENDC.PREFIXO1||'-'||CPES_ENDC.NUMERO1 AS FONE_COMERCIAL,
  CPES_ENDC.LOGRADOURO AS LOGRADOURO,
  CPES_ENDC.NUMERO AS NUMERO,
  CASE
     WHEN (SELECT 1 FROM SFN_CONTAFIN_COMPLEMENTO COM, SFN_CONTAFIN FIN WHERE NVL(COM.CONTACORRENTE, '0') <> '0' AND COM.DATAINICIAL <= TRUNC(SYSDATE) AND ( COM.DATAFINAL IS NULL OR COM.DATAFINAL >= TRUNC(SYSDATE) ) AND COM.CONTAFINANCEIRA = FIN.HANDLE AND FIN.PESSOA = CPES.HANDLE AND ROWNUM = 1) = 1 THEN
       'DEBITO AUTOMATICO'
     WHEN (SELECT 1 FROM SFN_CONTAFIN_TIPODOCUMENTO DOC, SFN_CONTAFIN FIN WHERE DOC.CONTAFINANCEIRA = FIN.HANDLE AND FIN.PESSOA = CPES.HANDLE AND ROWNUM = 1) = 1 THEN
       'BOLETO'
     ELSE
       (SELECT DECODE(FIN.TABGERACAOREC, 1, 'CONTA CORRENTE', 2, 'CARTAO CREDITO', 3, 'BOLETO') FROM SFN_CONTAFIN FIN WHERE FIN.PESSOA = CPES.HANDLE AND ROWNUM = 1)
  END AS TIPO_COBRANCA,
  CASE WHEN CPES.TABFISICAJURIDICA = 1 THEN 'F' WHEN CPES.TABFISICAJURIDICA = 2 THEN 'J' END AS TIPO_PESSOA,
  (SELECT SIGLA FROM ESTADOS WHERE HANDLE = CPES_ENDC.ESTADO) AS UF,
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
  JOIN SFN_PESSOA CPES ON CON.PESSOA = CPES.HANDLE
  LEFT OUTER JOIN SAM_ENDERECO CPES_ENDC ON CPES.ENDERECOCORRESPONDENCIA = CPES_ENDC.HANDLE
  LEFT OUTER JOIN MUNICIPIOS CPES_MUNENDC ON CPES_ENDC.MUNICIPIO = CPES_MUNENDC.HANDLE
  LEFT JOIN SAM_RAMOATIVIDADE RAMATI ON CPES.RAMOATIVIDADE = RAMATI.HANDLE
  
  LEFT JOIN SFN_CONTAFIN CONFIN ON CPES.HANDLE = CONFIN.PESSOA
  LEFT JOIN SFN_TIPODOCUMENTO     TIPDOC ON TIPDOC.HANDLE                = CONFIN.TIPODOCUMENTOREC
  LEFT JOIN SFN_CONTAFIN_COMPLEMENTO CFC ON (CFC.CONTAFINANCEIRA = CONFIN.HANDLE AND CFC.DATAFINAL IS NULL AND CFC.FAMILIA = FAM.HANDLE)
WHERE BEN.HANDLE = ?
```

Parameters:
- HANDLE_BENEFICIARIO (Number)

## Step: Dummy (do nothing)

Type: Dummy


## Step: Dummy (do nothing) 2

Type: Dummy


## Step: FAMILIA PESSOA RESPONSÁVEL

Type: DBJoin

### SQL Query

```sql
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
```

Parameters:
- HANDLE_BENEFICIARIO (Number)

## Step: FAMILIA TITULAR RESPONSÁVEL

Type: DBJoin

### SQL Query

```sql
SELECT --DISTINCT
  'B' AS TIPO_RESPONSAVEL,
  FBEN.HANDLE AS ID_RESP_FINANCEIRO,
  FBEN_ENDC.BAIRRO AS BAIRRO,
  FBEN_ENDC.CEP AS CEP,
  FBEN_MUNENDC.NOME AS CIDADE,
  FBEN_MAT.CPF AS CNPJ_CPF,
  FBEN_ENDC.COMPLEMENTO AS COMPLEMENTO,
  FBEN.NOME AS CONTRAT_PAGADOR_NOME,
  FBEN.DATACANCELAMENTO AS DATA_EXCLUSAO,
  FBEN.DATAADESAO AS DATA_INCLUSAO,
  FBEN_MAT.DATANASCIMENTO AS DATA_NASCIMENTO,
  FBEN_ENDC.DDDCELULAR AS DDD_CELULAR,
  FBEN_ENDC.DDD1 AS DDD,
  FBEN_ENDC.DDD1 AS DDD_COMERCIAL,
  CASE
    WHEN (SELECT 1 FROM SFN_CONTAFIN FBEN_CFIN, SFN_CONTAFIN_COMPLEMENTO FBEN_CFIC WHERE FBEN_CFIN.BENEFICIARIO = FBEN.HANDLE AND FBEN_CFIN.HANDLE = FBEN_CFIC.CONTAFINANCEIRA AND FBEN_CFIC.DATAINICIAL <= TRUNC(SYSDATE) AND ( FBEN_CFIC.DATAFINAL IS NULL OR FBEN_CFIC.DATAFINAL >= TRUNC(SYSDATE) ) AND NVL(FBEN_CFIC.CONTACORRENTE, '0') <> '0' AND ROWNUM = 1) = 1 THEN 'S'
    ELSE 'N'
  END AS DEBITO_AUT,
  (SELECT FBEN_AGE.AGENCIA FROM SFN_AGENCIA FBEN_AGE, SFN_CONTAFIN FBEN_CFIN, SFN_CONTAFIN_COMPLEMENTO FBEN_CFIC WHERE FBEN_CFIN.BENEFICIARIO = FBEN.HANDLE AND FBEN_CFIN.HANDLE = FBEN_CFIC.CONTAFINANCEIRA AND FBEN_CFIC.DATAINICIAL <= TRUNC(SYSDATE) AND ( FBEN_CFIC.DATAFINAL IS NULL OR FBEN_CFIC.DATAFINAL >= TRUNC(SYSDATE) ) AND NVL(FBEN_CFIC.CONTACORRENTE, '0') <> '0' AND FBEN_CFIC.AGENCIA = FBEN_AGE.HANDLE AND ROWNUM = 1) AS DEBITO_AUT_AGENCIA,
  (SELECT FBEN_BAN.CODIGO FROM SFN_BANCO FBEN_BAN, SFN_CONTAFIN FBEN_CFIN, SFN_CONTAFIN_COMPLEMENTO FBEN_CFIC WHERE FBEN_CFIN.BENEFICIARIO = FBEN.HANDLE AND FBEN_CFIN.HANDLE = FBEN_CFIC.CONTAFINANCEIRA AND FBEN_CFIC.DATAINICIAL <= TRUNC(SYSDATE) AND ( FBEN_CFIC.DATAFINAL IS NULL OR FBEN_CFIC.DATAFINAL >= TRUNC(SYSDATE) ) AND NVL(FBEN_CFIC.CONTACORRENTE, '0') <> '0' AND FBEN_CFIC.BANCO = FBEN_BAN.HANDLE AND ROWNUM = 1) AS DEBITO_AUT_BANCO,
  (SELECT FBEN_CFIC.CONTACORRENTE FROM SFN_CONTAFIN FBEN_CFIN, SFN_CONTAFIN_COMPLEMENTO FBEN_CFIC WHERE FBEN_CFIN.BENEFICIARIO = FBEN.HANDLE AND FBEN_CFIN.HANDLE = FBEN_CFIC.CONTAFINANCEIRA AND FBEN_CFIC.DATAINICIAL <= TRUNC(SYSDATE) AND ( FBEN_CFIC.DATAFINAL IS NULL OR FBEN_CFIC.DATAFINAL >= TRUNC(SYSDATE) ) AND NVL(FBEN_CFIC.CONTACORRENTE, '0') <> '0' AND ROWNUM = 1) AS DEBITO_AUT_CONTA,
  (SELECT FBEN_CFIC.DV FROM SFN_CONTAFIN FBEN_CFIN, SFN_CONTAFIN_COMPLEMENTO FBEN_CFIC WHERE FBEN_CFIN.BENEFICIARIO = FBEN.HANDLE AND FBEN_CFIN.HANDLE = FBEN_CFIC.CONTAFINANCEIRA AND FBEN_CFIC.DATAINICIAL <= TRUNC(SYSDATE) AND ( FBEN_CFIC.DATAFINAL IS NULL OR FBEN_CFIC.DATAFINAL >= TRUNC(SYSDATE) ) AND NVL(FBEN_CFIC.CONTACORRENTE, '0') <> '0' AND ROWNUM = 1) AS DEBITO_AUT_DIGITO,
  NULL AS EMAIL,
  '('||FBEN_ENDC.DDD1||') '||FBEN_ENDC.PREFIXO1||'-'||FBEN_ENDC.NUMERO1 AS FONE,
  '('||FBEN_ENDC.DDDCELULAR||') '||FBEN_ENDC.PREFIXOCELULAR||'-'||FBEN_ENDC.NUMEROCELULAR AS FONE_CELULAR,
  NULL AS FONE_COMERCIAL,
  FBEN_ENDC.LOGRADOURO AS LOGRADOURO,
  FBEN_ENDC.NUMERO AS NUMERO,
  CASE
    WHEN (SELECT 1 FROM SFN_CONTAFIN_COMPLEMENTO COM, SFN_CONTAFIN FIN WHERE NVL(COM.CONTACORRENTE, '0') <> '0' AND COM.DATAINICIAL <= TRUNC(SYSDATE) AND ( COM.DATAFINAL IS NULL OR COM.DATAFINAL >= TRUNC(SYSDATE) ) AND COM.CONTAFINANCEIRA = FIN.HANDLE AND FIN.BENEFICIARIO = FBEN.HANDLE AND ROWNUM = 1) = 1 THEN
      'DEBITO AUTOMATICO'
    WHEN (SELECT 1 FROM SFN_CONTAFIN_TIPODOCUMENTO DOC, SFN_CONTAFIN FIN WHERE DOC.CONTAFINANCEIRA = FIN.HANDLE AND FIN.BENEFICIARIO = FBEN.HANDLE AND ROWNUM = 1) = 1 THEN
      'BOLETO'
    ELSE
      (SELECT DECODE(FIN.TABGERACAOREC, 1, 'CONTA CORRENTE', 2, 'CARTAO CREDITO', 3, 'BOLETO') FROM SFN_CONTAFIN FIN WHERE FIN.BENEFICIARIO = FBEN.HANDLE AND ROWNUM = 1)
  END AS TIPO_COBRANCA,
  'F' AS TIPO_PESSOA,
  (SELECT SIGLA FROM ESTADOS WHERE HANDLE = FBEN_ENDC.ESTADO) AS UF,
  CBO.DESCRICAO AS RAMO_DE_ATIVIDADE,
  TIPDOC.DESCRICAO AS TIPO_DOCUMENTO,
  SYSDATE AS DW_INC,
  SYSDATE AS DW_ALT,
  CFC.DATAINICIAL AS DATA_INICIAL_DEBITO_AUT
,NVL(FAM.HANDLE,0) AS ID_FAMILIA
FROM
  SAM_BENEFICIARIO BEN
  JOIN SAM_FAMILIA FAM ON BEN.FAMILIA = FAM.HANDLE
  JOIN SAM_CONTRATO CON ON FAM.CONTRATO = CON.HANDLE
  JOIN SAM_BENEFICIARIO FBEN ON FAM.TITULARRESPONSAVEL = FBEN.HANDLE
  LEFT JOIN SAM_MATRICULA FBEN_MAT ON FBEN.MATRICULA = FBEN_MAT.HANDLE
  LEFT JOIN SAM_ENDERECO FBEN_ENDC ON FBEN.ENDERECOCORRESPONDENCIA = FBEN_ENDC.HANDLE
  LEFT JOIN MUNICIPIOS FBEN_MUNENDC ON FBEN_ENDC.MUNICIPIO = FBEN_MUNENDC.HANDLE
  LEFT JOIN SAM_CBO CBO ON FBEN.CBO = CBO.HANDLE
  LEFT JOIN SFN_CONTAFIN CONFIN ON CONFIN.BENEFICIARIO = BEN.HANDLE
  LEFT JOIN SFN_TIPODOCUMENTO     TIPDOC ON TIPDOC.HANDLE                = CONFIN.TIPODOCUMENTOREC
  LEFT JOIN SFN_CONTAFIN_COMPLEMENTO CFC ON (CFC.CONTAFINANCEIRA = CONFIN.HANDLE AND CFC.DATAFINAL IS NULL AND CFC.FAMILIA = FAM.HANDLE)
WHERE
  BEN.HANDLE = ?
```

Parameters:
- HANDLE_BENEFICIARIO (Number)

## Step: Filter rows

Type: FilterRows

Send True To: BUSCA MICROSIGA
Send False To: SEM SETOR

Conditions:

## Step: HANDLE_BENEFICIARIO

Type: TableInput

### SQL Query

```sql
SELECT BEN.HANDLE AS HANDLE_BENEFICIARIO 
FROM   SAM_BENEFICIARIO BEN
ORDER BY 1 DESC
```


## Step: Insert / Update - BN_BENEFICIARIO

Type: InsertUpdate

Table: BN_BENEFICIARIO

Keys:
- ID_BENEFICIARIO: ID_BENEFICIARIO

Values:
- ID_BENEFICIARIO: ID_BENEFICIARIO
- ID_BENEFICIARIO_RESP: ID_BENEFICIARIO_RESP
- ID_CONTRATANTE: ID_CONTRATANTE
- ID_CONTRATANTE_LOT: ID_CONTRATANTE_LOT
- ID_FAMILIA: ID_FAMILIA
- ID_MOTIVO_CANC: ID_MOTIVO_CANC
- ID_PLANO: ID_PLANO
- ID_RESP_FINANCEIRO: ID_RESP_FINANCEIRO
- BAIRRO: BAIRRO
- BENEFICIARIO: BENEFICIARIO
- CBO: CBO
- CEP: CEP
- CIDADE: CIDADE
- COD_BENEFICIARIO_ANS: COD_BENEFICIARIO_ANS
- COD_PAIS_RG_ANS: COD_PAIS_RG_ANS
- CODIGO_BENEFICIARIO: CODIGO_BENEFICIARIO
- CODIGO_ORIGEM: CODIGO_ORIGEM
- CODIGO_FAMILIA: CODIGO_FAMILIA
- COD_GRAU_DEPEND_ANS: COD_GRAU_DEPEND_ANS
- CODIGO_PLANO: CODIGO_PLANO
- CODIGO_UNI_PAG: CODIGO_UNI_PAG
- COMPLEMENTO: COMPLEMENTO
- CONTRATANTE: CONTRATANTE
- CONVENIO: CONVENIO
- CPF_BENEFICIARIO: CPF_BENEFICIARIO
- CPT: CPT
- DATA_INGRESSO: DATA_INGRESSO
- DATA_ADESAO: DATA_ADESAO
- DATA_ADESAO_CONTRATO: DATA_ADESAO_CONTRATO
- DATA_ADESAO_FAMILIA: DATA_ADESAO_FAMILIA
- DATA_CANCELAMENTO: DATA_CANCELAMENTO
- DATA_CANC_CONTRATO: DATA_CANC_CONTRATO
- DATA_EXPED_RG: DATA_EXPED_RG
- DATA_NASCIMENTO: DATA_NASCIMENTO
- DATA_PRIMEIRA_ADESAO: DATA_PRIMEIRA_ADESAO
- DATA_REATIVACAO: DATA_REATIVACAO
- DATA_VALID_CARTEIRA: DATA_VALID_CARTEIRA
- DATA_GERAC_CARTEIRA: DATA_GERAC_CARTEIRA
- DATA_EMISS_CARTEIRA: DATA_EMISS_CARTEIRA
- DDD: DDD
- EMAIL: EMAIL
- ENDERECO: ENDERECO
- ESTADO_CIVIL: ESTADO_CIVIL
- NUM_PROPOSTA_FAMILIA: NUM_PROPOSTA_FAMILIA
- INTERCAMBIO: INTERCAMBIO
- SITUACAO_FAMILIA: SITUACAO_FAMILIA
- TIPO_RESPONSAVEL: TIPO_RESPONSAVEL
- LOTACAO: LOTACAO
- MATRICULA_UNICA: MATRICULA_UNICA
- MATRIC_BEN_EMPRESA: MATRIC_BEN_EMPRESA
- MOTIVO_CANC: MOTIVO_CANC
- MOTIVO_INCLUSAO: MOTIVO_INCLUSAO
- NACIONALIDADE: NACIONALIDADE
- NOME_MAE: NOME_MAE
- NUMERO: NUMERO
- ORGAO_EMISSOR_RG: ORGAO_EMISSOR_RG
- PAIS_RG: PAIS_RG
- PISPASEP: PISPASEP
- RG_BENEFICIARIO: RG_BENEFICIARIO
- SEQUENCIA: SEQUENCIA
- SEXO: SEXO
- TELEFONE: TELEFONE
- CELULAR: CELULAR
- TIPO_BENEFICIARIO: TIPO_BENEFICIARIO
- TIPO_DEPENDENTE: TIPO_DEPENDENTE
- UF: UF
- UF_RG: UF_RG
- UNI_ORIGEM: UNI_ORIGEM
- UNI_DESTINO: UNI_DESTINO
- UNI_ORIGEM_RAZAOSOCIAL: UNI_ORIGEM_RAZAOSOCIAL
- UNI_DESTINO_RAZAOSOCIAL: UNI_DESTINO_RAZAOSOCIAL
- CODIGO_AFINIDADE: CODIGO_AFINIDADE
- TIPO_FATURAMENTO_REP: TIPO_FATURAMENTO_REP
- UF_UNI_ORIGEM: UF_UNI_ORIGEM
- UNI_ORIGEM_CAMARA_COMPENSACAO: UNI_ORIGEM_CAMARA_COMPENSACAO
- UNI_ORIGEM_DESC_POLITICA: UNI_ORIGEM_DESC_POLITICA
- UNI_ORIGEM_TIPO_CAMARA_COMP: UNI_ORIGEM_TIPO_CAMARA_COMP
- DNV: DNV
- DATA_CANCELAMENTO_FAMILIA: DATA_CANCELAMENTO_FAMILIA
- DATA_INICIO_REPASSE: DATA_INICIO_REPASSE
- DATA_FINAL_REPASSE: DATA_FINAL_REPASSE
- DATA_INICIO_INAT_FAMILIA: DATA_INICIO_INAT_FAMILIA
- DIA_COBRANCA: DIA_COBRANCA
- CARTAO_NACIONAL_SAUDE: CARTAO_NACIONAL_SAUDE
- CCO: CCO
- CCO_DV: CCO_DV
- CODIGO_IBGE: CODIGO_IBGE
- DATA_VENDA_FAMILIA: DATA_VENDA_FAMILIA
- ANOTACAO_ADM_FAMILIA: ANOTACAO_ADM_FAMILIA
- DATA_PRIM_ADESAO_BENEF: DATA_PRIM_ADESAO_BENEF
- POSSUI_BIOMETRIA: POSSUI_BIOMETRIA
- DATA_INICIAL_TETO_COBRANCA: DATA_INICIAL_TETO_COBRANCA
- DATA_FINAL_TETO_COBRANCA: DATA_FINAL_TETO_COBRANCA
- VALOR_TETO_COBRANCA: VALOR_TETO_COBRANCA
- TIPO_CARTAO: TIPO_CARTAO
- BLOQUEAR_RECAD_BIO_AUT_WEB: BLOQUEAR_RECAD_BIO_AUT_WEB
- TELEFONE1_CORRESP: TELEFONE1_CORRESP
- TELEFONE2_CORRESP: TELEFONE2_CORRESP
- CELULAR_CORRESP: CELULAR_CORRESP
- ENDERECO_CORRESP: ENDERECO_CORRESP
- NUMERO_CORRESP: NUMERO_CORRESP
- COMPLEMENTO_CORRESP: COMPLEMENTO_CORRESP
- BAIRRO_CORRESP: BAIRRO_CORRESP
- CEP_CORRESP: CEP_CORRESP
- CIDADE_CORRESP: CIDADE_CORRESP
- UF_CORRESP: UF_CORRESP
- TELEFONE2: TELEFONE2
- SETOR_UNIMED: SETOR_UNIMED
- COBRANCA_MES_SEGUINTE: COBRANCA_MES_SEGUINTE
- DW_INC: DW_INC
- DW_ALT: DW_ALT
- SOFREU_ADAPTACAO: SOFREU_ADAPTACAO
- DATA_ADAPTACAO: DATA_ADAPTACAO
- IDADE_ADAPTACAO: IDADE_ADAPTACAO
- NAO_TEM_CARENCIA: NAO_TEM_CARENCIA
- DIAS_COMPRA_CARENCIA: DIAS_COMPRA_CARENCIA
- ORIGEM_CARENCIA: ORIGEM_CARENCIA
- IDADE_MAXIMA: IDADE_MAXIMA
- DATA_INCLUSAO_FAMILIA: DATA_INCLUSAO_FAMILIA
- USUARIO_INCLUSAO_FAMILIA: USUARIO_INCLUSAO_FAMILIA
- UNIMED_EM_CASA: UNIMED_EM_CASA
- BEM_ESTAR_E_SAUDE: BEM_ESTAR_E_SAUDE
- SITUACAO_ATUALIZACAO_DADOS: SITUACAO_ATUALIZACAO_DADOS
- DV_CARTAO_BENEF: DV_CARTAO_BENEF
- K_EMAIL_ZENITE: K_EMAIL_ZENITE
- K_TELEFONE1_ZENITE: K_TELEFONE1_ZENITE
- K_TELEFONE2_ZENITE: K_TELEFONE2_ZENITE
- K_EMAIL_IRIS: K_EMAIL_IRIS
- K_EMAIL_IW: K_EMAIL_IW
- K_TELEFONE1_IW: K_TELEFONE1_IW
- K_TELEFONE2_IW: K_TELEFONE2_IW
- K_TELEFONE3_IW: K_TELEFONE3_IW
- K_TELEFONE4_IW: K_TELEFONE4_IW
- K_EMAIL_SAC: K_EMAIL_SAC
- K_TELEFONE_RES_SAC: K_TELEFONE_RES_SAC
- K_TELEFONE_CONTATO_SAC: K_TELEFONE_CONTATO_SAC
- K_TELEFONE_CELULAR_SAC: K_TELEFONE_CELULAR_SAC
- DATA_ULTIMA_ATU_CADASTRAL: DATA_ULTIMA_ATU_CADASTRAL
- DATA_ULTIMO_REAJUSTE_FAMILIA: DATA_ULTIMO_REAJUSTE_FAMILIA
- ORIGEM: ORIGEM
- DATA_FALECIMENTO: DATA_FALECIMENTO
- DATA_ATENDIMENTO_ATE: DATA_ATENDIMENTO_ATE
- DATA_INICIAL_VALIDADE: DATA_INICIAL_VALIDADE
- DATA_FINAL_VALIDADE: DATA_FINAL_VALIDADE
- SITUACAO_CARTAO: SITUACAO_CARTAO
- VALOR_FATURADO: VALOR_FATURADO
- NUMERO_FATURA: NUMERO_FATURA
- VIA_CARTAO: VIA_CARTAO
- DESCRICAO_ROTINA_CARTAO: DESCRICAO_ROTINA_CARTAO

## Step: Insert / Update - BN_RESP_FINANCEIRO

Type: InsertUpdate

Table: BN_RESP_FINANCEIRO

Keys:
- TIPO_RESPONSAVEL: TIPO_RESPONSAVEL
- ID_RESP_FINANCEIRO: ID_RESP_FINANCEIRO
- ID_FAMILIA: ID_FAMILIA

Values:
- TIPO_RESPONSAVEL: TIPO_RESPONSAVEL
- ID_RESP_FINANCEIRO: ID_RESP_FINANCEIRO
- ID_FAMILIA: ID_FAMILIA
- BAIRRO: BAIRRO
- CEP: CEP
- CIDADE: CIDADE
- CNPJ_CPF: CNPJ_CPF
- COMPLEMENTO: COMPLEMENTO
- CONTRAT_PAGADOR_NOME: CONTRAT_PAGADOR_NOME
- DATA_EXCLUSAO: DATA_EXCLUSAO
- DATA_INCLUSAO: DATA_INCLUSAO
- DATA_NASCIMENTO: DATA_NASCIMENTO
- DDD_CELULAR: DDD_CELULAR
- DDD: DDD
- DDD_COMERCIAL: DDD_COMERCIAL
- DEBITO_AUT: DEBITO_AUT
- DEBITO_AUT_AGENCIA: DEBITO_AUT_AGENCIA
- DEBITO_AUT_BANCO: DEBITO_AUT_BANCO
- DEBITO_AUT_CONTA: DEBITO_AUT_CONTA
- DEBITO_AUT_DIGITO: DEBITO_AUT_DIGITO
- EMAIL: EMAIL
- FONE: FONE
- FONE_CELULAR: FONE_CELULAR
- FONE_COMERCIAL: FONE_COMERCIAL
- LOGRADOURO: LOGRADOURO
- NUMERO: NUMERO
- TIPO_COBRANCA: TIPO_COBRANCA
- TIPO_PESSOA: TIPO_PESSOA
- UF: UF
- RAMO_DE_ATIVIDADE: RAMO_DE_ATIVIDADE
- TIPO_DOCUMENTO: TIPO_DOCUMENTO
- DATA_INICIAL_DEBITO_AUT: DATA_INICIAL_DEBITO_AUT
- DW_INC: DW_INC
- DW_ALT: DW_ALT

## Step: LOTAÇÃO

Type: DBJoin

### SQL Query

```sql
SELECT -- DISTINCT 
  'P' AS TIPO_RESPONSAVEL,
  LPES.HANDLE AS ID_RESP_FINANCEIRO,
  LPES_ENDC.BAIRRO AS BAIRRO,
  LPES_ENDC.CEP AS CEP,
  LPES_MUNENDC.NOME AS CIDADE,
  LPES.CNPJCPF AS CNPJ_CPF,
  LPES_ENDC.COMPLEMENTO AS COMPLEMENTO,
  LPES.NOME AS CONTRAT_PAGADOR_NOME,
  LPES.DATASAIDA AS DATA_EXCLUSAO,
  LPES.DATAENTRADA AS DATA_INCLUSAO,
  LPES.DATANASCIMENTO AS DATA_NASCIMENTO,
  LPES_ENDC.DDDCELULAR AS DDD_CELULAR,
  LPES_ENDC.DDD1 AS DDD,
  LPES_ENDC.DDD1 AS DDD_COMERCIAL,
  CASE
    WHEN (SELECT 1 FROM SFN_CONTAFIN LPES_CFIN, SFN_CONTAFIN_COMPLEMENTO LPES_CFIC WHERE LPES_CFIN.PESSOA = LPES.HANDLE AND LPES_CFIN.HANDLE = LPES_CFIC.CONTAFINANCEIRA AND LPES_CFIC.DATAINICIAL <= TRUNC(SYSDATE) AND ( LPES_CFIC.DATAFINAL IS NULL OR LPES_CFIC.DATAFINAL >= TRUNC(SYSDATE) ) AND NVL(LPES_CFIC.CONTACORRENTE, '0') <> '0' AND ROWNUM = 1) = 1 THEN 'S' 
    ELSE 'N'
  END AS DEBITO_AUT,
  (SELECT LPES_AGE.AGENCIA FROM SFN_AGENCIA LPES_AGE, SFN_CONTAFIN LPES_CFIN, SFN_CONTAFIN_COMPLEMENTO LPES_CFIC WHERE LPES_CFIN.PESSOA = LPES.HANDLE AND LPES_CFIN.HANDLE = LPES_CFIC.CONTAFINANCEIRA AND LPES_CFIC.DATAINICIAL <= TRUNC(SYSDATE) AND ( LPES_CFIC.DATAFINAL IS NULL OR LPES_CFIC.DATAFINAL >= TRUNC(SYSDATE) ) AND NVL(LPES_CFIC.CONTACORRENTE, '0') <> '0' AND LPES_CFIC.AGENCIA = LPES_AGE.HANDLE AND ROWNUM = 1) AS DEBITO_AUT_AGENCIA,
  (SELECT LPES_BAN.CODIGO FROM SFN_BANCO LPES_BAN, SFN_CONTAFIN LPES_CFIN, SFN_CONTAFIN_COMPLEMENTO LPES_CFIC WHERE LPES_CFIN.PESSOA = LPES.HANDLE AND LPES_CFIN.HANDLE = LPES_CFIC.CONTAFINANCEIRA AND LPES_CFIC.DATAINICIAL <= TRUNC(SYSDATE) AND ( LPES_CFIC.DATAFINAL IS NULL OR LPES_CFIC.DATAFINAL >= TRUNC(SYSDATE) ) AND NVL(LPES_CFIC.CONTACORRENTE, '0') <> '0' AND LPES_CFIC.BANCO = LPES_BAN.HANDLE AND ROWNUM = 1) AS DEBITO_AUT_BANCO,
  (SELECT LPES_CFIC.CONTACORRENTE FROM SFN_CONTAFIN LPES_CFIN, SFN_CONTAFIN_COMPLEMENTO LPES_CFIC WHERE LPES_CFIN.PESSOA = LPES.HANDLE AND LPES_CFIN.HANDLE = LPES_CFIC.CONTAFINANCEIRA AND LPES_CFIC.DATAINICIAL <= TRUNC(SYSDATE) AND ( LPES_CFIC.DATAFINAL IS NULL OR LPES_CFIC.DATAFINAL >= TRUNC(SYSDATE) ) AND NVL(LPES_CFIC.CONTACORRENTE, '0') <> '0' AND ROWNUM = 1) AS DEBITO_AUT_CONTA,
  (SELECT LPES_CFIC.DV FROM SFN_CONTAFIN LPES_CFIN, SFN_CONTAFIN_COMPLEMENTO LPES_CFIC WHERE LPES_CFIN.PESSOA = LPES.HANDLE AND LPES_CFIN.HANDLE = LPES_CFIC.CONTAFINANCEIRA AND LPES_CFIC.DATAINICIAL <= TRUNC(SYSDATE) AND ( LPES_CFIC.DATAFINAL IS NULL OR LPES_CFIC.DATAFINAL >= TRUNC(SYSDATE) ) AND NVL(LPES_CFIC.CONTACORRENTE, '0') <> '0' AND ROWNUM = 1) AS DEBITO_AUT_DIGITO,
  LPES.EMAIL AS EMAIL,
  '('||LPES_ENDC.DDD1||') '||LPES_ENDC.PREFIXO1||'-'||LPES_ENDC.NUMERO1 AS FONE,
  '('||LPES_ENDC.DDDCELULAR||') '||LPES_ENDC.PREFIXOCELULAR||'-'||LPES_ENDC.NUMEROCELULAR AS FONE_CELULAR,
  '('||LPES_ENDC.DDD1||') '||LPES_ENDC.PREFIXO1||'-'||LPES_ENDC.NUMERO1 AS FONE_COMERCIAL,
  LPES_ENDC.LOGRADOURO AS LOGRADOURO,
  LPES_ENDC.NUMERO AS NUMERO,
  CASE
     WHEN (SELECT 1 FROM SFN_CONTAFIN_COMPLEMENTO COM, SFN_CONTAFIN FIN WHERE NVL(COM.CONTACORRENTE, '0') <> '0' AND COM.DATAINICIAL <= TRUNC(SYSDATE) AND ( COM.DATAFINAL IS NULL OR COM.DATAFINAL >= TRUNC(SYSDATE) ) AND COM.CONTAFINANCEIRA = FIN.HANDLE AND FIN.PESSOA = LPES.HANDLE AND ROWNUM = 1) = 1 THEN
       'DEBITO AUTOMATICO'
     WHEN (SELECT 1 FROM SFN_CONTAFIN_TIPODOCUMENTO DOC, SFN_CONTAFIN FIN WHERE DOC.CONTAFINANCEIRA = FIN.HANDLE AND FIN.PESSOA = LPES.HANDLE AND ROWNUM = 1) = 1 THEN
       'BOLETO'
     ELSE
       (SELECT DECODE(FIN.TABGERACAOREC, 1, 'CONTA CORRENTE', 2, 'CARTAO CREDITO', 3, 'BOLETO') FROM SFN_CONTAFIN FIN WHERE FIN.PESSOA = LPES.HANDLE AND ROWNUM = 1)
  END AS TIPO_COBRANCA,
  CASE WHEN LPES.TABFISICAJURIDICA = 1 THEN 'F' WHEN LPES.TABFISICAJURIDICA = 2 THEN 'J' END AS TIPO_PESSOA,
  (SELECT SIGLA FROM ESTADOS WHERE HANDLE = LPES_ENDC.ESTADO) AS UF,
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
  JOIN SAM_CONTRATO_LOTACAO CLOT ON FAM.LOTACAO = CLOT.HANDLE
  JOIN SFN_PESSOA LPES ON CLOT.PESSOAFATURAMENTO = LPES.HANDLE
  LEFT OUTER JOIN SAM_ENDERECO LPES_ENDC ON LPES.ENDERECOCORRESPONDENCIA = LPES_ENDC.HANDLE
  LEFT OUTER JOIN MUNICIPIOS LPES_MUNENDC ON LPES_ENDC.MUNICIPIO = LPES_MUNENDC.HANDLE
  LEFT JOIN SAM_RAMOATIVIDADE RAMATI ON LPES.RAMOATIVIDADE = RAMATI.HANDLE
  
  LEFT JOIN SFN_CONTAFIN CONFIN ON LPES.HANDLE = CONFIN.PESSOA
  LEFT JOIN SFN_TIPODOCUMENTO     TIPDOC ON TIPDOC.HANDLE                = CONFIN.TIPODOCUMENTOREC
  LEFT JOIN SFN_CONTAFIN_COMPLEMENTO CFC ON (CFC.CONTAFINANCEIRA = CONFIN.HANDLE AND CFC.DATAFINAL IS NULL AND CFC.FAMILIA = FAM.HANDLE)
WHERE
  BEN.HANDLE = ?
```

Parameters:
- HANDLE_BENEFICIARIO (Number)

## Step: QTD_INCATU_BN_BENEFICIARIO

Type: Sequence


## Step: QTD_INCATU_BN_RESP_FINANCEIRO

Type: Sequence


## Step: Remover colunas

Type: SelectValues


## Step: SAM_FAMILIA_TETO_PF

Type: DBJoin

### SQL Query

```sql
SELECT FT.DATAINICIAL AS DATA_INICIAL_TETO_COBRANCA
      ,FT.DATAFINAL   AS DATA_FINAL_TETO_COBRANCA
      ,FT.VALORTETOPF AS VALOR_TETO_COBRANCA
FROM   SAM_FAMILIA_TETO_PF FT 
WHERE  FT.FAMILIA = ?
AND    FT.HANDLE  = (SELECT MAX(FT1.HANDLE) FROM SAM_FAMILIA_TETO_PF FT1 WHERE FT1.FAMILIA = FT.FAMILIA)
```

Parameters:
- ID_FAMILIA (Integer)

## Step: SEM SETOR

Type: DBJoin

### SQL Query

```sql
SELECT  NULL AS SETOR_UNIMED,
        '('||ENDR.DDD1||') '||ENDR.PREFIXO1||'-'||ENDR.NUMERO1 AS TELEFONE
FROM    SAM_BENEFICIARIO BEN
LEFT JOIN SAM_ENDERECO ENDR ON BEN.ENDERECORESIDENCIAL = ENDR.HANDLE
WHERE   BEN.HANDLE = ?
```

Parameters:
- HANDLE_BENEFICIARIO (Number)

## Step: Set Variables

Type: SetVariable


## Step: Set Variables 2

Type: SetVariable


## Step: Switch / Case LOCAL FATURAMENTO

Type: SwitchCase


## Step: Switch / Case PESSOA RESPONSÁVEL

Type: SwitchCase


## Step: Switch / Case TITULAR RESPONSÁVEL

Type: SwitchCase


