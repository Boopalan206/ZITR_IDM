*&---------------------------------------------------------------------*
*& Report ZBC_TRANSPORT_CHECK
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbc_transport_check MESSAGE-ID zstrequest.

*----------------------------------------------------------------------*
* ArcelorMittal USA - Project Arc                                      *
*----------------------------------------------------------------------*
* Módulo    : xx                                                       *
* Programa  : xxxxxxxxx                                                *
* Transação : xxxxxxxx                                                 *
* Tipo Prog : xxxxxxxxxxx                                              *
* Descrição : xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  *
* Objetivo  : xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  *
*----------------------------------------------------------------------*
* Data       | Solicitante/         | Descrição da alteração           *
* Request    | Responsável          |                                  *
*----------------------------------------------------------------------*
* xx.xx.xxxx | Jason Melo           | Codificação Inicial              *
* xxxxxxxxxx | Jason Melo           |                                  *
*----------------------------------------------------------------------*

TABLES: e070.

TYPES: BEGIN OF ty_tasks,
         trkorr     TYPE e070-trkorr,
         as4user    TYPE e070-as4user,
         trfunction TYPE e070-trfunction,
         trstatus   TYPE e070-trstatus,
       END OF ty_tasks,

       BEGIN OF ty_log_req,
         dt_qas TYPE d,
         hr_qas TYPE t,
         rc_qas TYPE i,
         dt_prd TYPE d,
         hr_prd TYPE t,
         rc_prd TYPE i,
       END OF ty_log_req.

DATA: it_requests   TYPE cts_trkorrs,
      it_veriftr    TYPE zstgec001,
      it_veriftr_ok TYPE zstgec001. "Vítor Quintão - 10.07.2009 - R168010-001

DATA wa_veriftr_ok TYPE zstgee018. "Vítor Quintão - 10.07.2009 - R168010-001

DATA: st_veriftr TYPE zstgee018.

DATA: g_filename    TYPE string,
      g_path        TYPE string,
      g_fullpath    TYPE string,
      g_user_action TYPE i.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  SELECT-OPTIONS s_trkorr FOR e070-trkorr.

SELECTION-SCREEN END OF BLOCK b1.

*----------------------------------------------------------------------*
* Seleção de dados
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM selecionar_dados.

  PERFORM processar_dados.

END-OF-SELECTION.
  "Se as requests estiverem ok.
  IF it_veriftr[] IS INITIAL
     AND it_veriftr_ok[] IS NOT INITIAL. "Vítor Quintão - 10.07.2009 - R168010-001

    LOOP AT it_veriftr_ok INTO wa_veriftr_ok.
      DATA l_texto TYPE string.
      CONCATENATE 'Request'(002) wa_veriftr_ok-trkorr 'sem problemas de objetos.'(003)
                  INTO l_texto SEPARATED BY space.
      WRITE / l_texto.
    ENDLOOP.

*    MESSAGE i024. "Vítor Quintão - 10.07.2009 - R168010-001
  ELSE.
    "Se as requests não estiverem ok.
    PERFORM imprimir_alv.

  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  selecionar_dados
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM selecionar_dados .

  SELECT trkorr INTO TABLE it_requests
    FROM e070
   WHERE trkorr IN s_trkorr.

ENDFORM.                    " selecionar_dados

*&---------------------------------------------------------------------*
*&      Form  processar_dados
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM processar_dados.

  DATA: it_return TYPE zstgec001.

  REFRESH it_veriftr.
  REFRESH it_veriftr_ok.

  CALL FUNCTION 'ZBC_TRANSPORT_CHECK'
    CHANGING
      it_requests_orig = it_requests
      it_return        = it_return.

  IF it_return[] IS INITIAL.
    APPEND LINES OF it_requests TO it_veriftr_ok.
  ELSE.
    APPEND LINES OF it_return TO it_veriftr.
  ENDIF.

*  APPEND LINES OF it_return TO it_veriftr.

ENDFORM.                    " processar_arquivo

*&---------------------------------------------------------------------*
*&      Form  imprimir_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM imprimir_alv .
  DATA: it_events TYPE zbc_alv_events.

  APPEND 'HOTSPOT_CLICK' TO it_events.
  APPEND 'TOP_OF_PAGE'   TO it_events.

  CALL FUNCTION 'ZBC_ALV_GENERATE'
    EXPORTING
      pe_program  = 'ZBC_TRANSPORT_CHECK'
      pe_table    = 'IT_VERIFTR'
      pe_events   = it_events
    TABLES
      te_outtab   = it_veriftr
    EXCEPTIONS
      cancel_exit = 1
      OTHERS      = 2.


ENDFORM.                    " imprimir_alv

*&---------------------------------------------------------------------*
*&      Form  alv_fieldcat_update
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM alv_fieldcat_update CHANGING it_fieldcat TYPE lvc_t_fcat.

  DATA: st_fieldcat TYPE lvc_s_fcat.

  LOOP AT it_fieldcat INTO st_fieldcat.
    CASE st_fieldcat-fieldname.
      WHEN 'TRKORR'.
        st_fieldcat-hotspot = 'X'.
      WHEN 'TRKORR_F'.
        st_fieldcat-hotspot = 'X'.
    ENDCASE.
    MODIFY it_fieldcat FROM st_fieldcat.
  ENDLOOP.
ENDFORM.                    "alv_fieldcat_update
*&---------------------------------------------------------------------*
*&      Form  alv_hotspot_click
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->E_ROW_ID     text
*      -->E_COLUMN_ID  text
*----------------------------------------------------------------------*
FORM alv_hotspot_click USING e_row_id    STRUCTURE lvc_s_row
                             e_column_id STRUCTURE lvc_s_col.

  READ TABLE it_veriftr INDEX e_row_id-index INTO st_veriftr.

  CASE e_column_id.
    WHEN 'TRKORR'.
      CALL FUNCTION 'TR_PRESENT_REQUEST'
        EXPORTING
          iv_trkorr = st_veriftr-trkorr.

    WHEN 'TRKORR_F'.
      CALL FUNCTION 'TR_PRESENT_REQUEST'
        EXPORTING
          iv_trkorr = st_veriftr-trkorr_f.
  ENDCASE.
ENDFORM.                    "alv_hotspot_click
