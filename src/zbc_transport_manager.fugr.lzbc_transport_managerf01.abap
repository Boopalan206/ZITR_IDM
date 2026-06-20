*----------------------------------------------------------------------*
***INCLUDE LZSTGEF008F01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  transport_text_read
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PE_TRKORR  text
*      -->PE_TIPO    text
*----------------------------------------------------------------------*
FORM transport_text_read USING  pe_trkorr TYPE e070-trkorr
                                pe_tipo   TYPE c.

  DATA: l_as4text TYPE e07t-as4text.

  IF pe_tipo = ' '.
    CLEAR g_as4text.
  ELSE.
    CLEAR g_as4text_f.
  ENDIF.

  SELECT SINGLE as4text INTO l_as4text
    FROM e07t
   WHERE trkorr = pe_trkorr
     AND langu  = sy-langu.

  IF sy-subrc NE 0.
    SELECT as4text INTO l_as4text
      FROM e07t UP TO 1 ROWS
     WHERE trkorr = pe_trkorr.
      EXIT.
    ENDSELECT.
  ENDIF.

  IF pe_tipo = ' '.
    g_as4text   = l_as4text.
  ELSE.
    g_as4text_f = l_as4text.
  ENDIF.

ENDFORM.                    " transport_text_read

*&---------------------------------------------------------------------*
*&      Form  transport_log_read
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PE_TRKORR  text
*----------------------------------------------------------------------*
FORM transport_log_read USING pe_trkorr TYPE e070-trkorr.

  CLEAR: st_transport_log-dt_qas, st_transport_log-hr_qas, st_transport_log-rc_qas,
         st_transport_log-dt_prd, st_transport_log-hr_prd, st_transport_log-rc_prd,
         st_transport_log-status, st_transport_log-trkorr.

  CALL FUNCTION 'ZBC_TRANSPORT_STATUS'
    EXPORTING
      pe_trkorr = pe_trkorr
    CHANGING
      ps_status = st_transport_log-status
      ps_dt_qas = st_transport_log-dt_qas
      ps_hr_qas = st_transport_log-hr_qas
      ps_rc_qas = st_transport_log-rc_qas
      ps_dt_prd = st_transport_log-dt_prd
      ps_hr_prd = st_transport_log-hr_prd
      ps_rc_prd = st_transport_log-rc_prd.

  st_transport_log-trkorr = pe_trkorr.

ENDFORM.                    " transport_log_read
