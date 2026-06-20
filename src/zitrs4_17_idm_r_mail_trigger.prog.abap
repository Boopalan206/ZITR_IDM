*&---------------------------------------------------------------------*
*& Program                : ZITRS4_17_IDM_R_MAIL_TRIGGER
*& Author                 : Sakthi
*& Functional Consultant  : Shanker/jaya
*& Tcode                  : VF01/VF21
*& TR                     : S4HK902781
*& RICEF Object ID        : S4_17
*& Description            : Batch program for triggering mail for failed idocs
*&---------------------------------------------------------------------*
*&                M O D I F I C A T I O N  L O G
*&---------------------------------------------------------------------*
*&  Date      SD4K#     | Initials     |        Description
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
REPORT ZITRS4_17_IDM_R_MAIL_TRIGGER.

include zitr_idm_r_mail_trigger_01.
DATA : lv_from_m TYPE ad_smtpadr .
TABLES : sood,edidc.
SELECTION-SCREEN : BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
SELECT-OPTIONS : s_date FOR sy-datum MODIF ID ee,
                 s_msg FOR edidc-mestyp NO INTERVALS,
                 s_status FOR edidc-status NO INTERVALS.
PARAMETERS :p_mail TYPE sood-objnam OBLIGATORY.
SELECTION-SCREEN : END OF BLOCK  b2.
SELECTION-SCREEN : BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001 NO INTERVALS.
PARAMETERS : rb1 RADIOBUTTON GROUP rg DEFAULT 'X' USER-COMMAND uc,
             rb2 RADIOBUTTON GROUP rg.
SELECTION-SCREEN : END OF BLOCK  b1.
SELECTION-SCREEN : BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-003 NO INTERVALS.
PARAMETERS : ch1 AS CHECKBOX.
SELECTION-SCREEN : END OF BLOCK  b3.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF rb2 EQ 'X'.
      IF screen-group1 = 'EE'.
        screen-active = '1'.
        MODIFY SCREEN.
      ENDIF.
    ELSE.
      IF screen-group1 = 'EE'.
        screen-active = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

START-OF-SELECTION .
  IF rb1 EQ 'X'.
    DATA : time      TYPE char15,
           timestamp TYPE rstimestmp,
           lv_date   TYPE sy-datum,
           lv_time   TYPE sy-uzeit,
           lv_time1  TYPE sy-uzeit.
    CONCATENATE sy-datum sy-uzeit INTO time.
    timestamp = time.
    CALL FUNCTION 'RSSM_SUBST_SECS_FROM_TIMESTMP'
      EXPORTING
        i_timestamp = timestamp
        i_secs      = 3600
      IMPORTING
        e_timestamp = timestamp.

    CLEAR : time.
    time = timestamp.
    lv_date = time+0(8).
*    lv_time = time+8(7).
    CONCATENATE time+8(2) '00' '00' INTO lv_time.
    CONCATENATE sy-uzeit+0(2) '00' '00' INTO lv_time1.

    SELECT mestyp,docnum,status,direct,credat,cretim FROM ztitr_edidc INTO TABLE @DATA(lt_final)
               WHERE credat EQ @lv_date AND ( cretim BETWEEN @lv_time AND @lv_time1 )
         AND status IN @s_status AND mestyp IN @s_msg AND zmandt EQ '900'.

    LOOP AT lt_final INTO DATA(ls_final).
      ls_edidc-mestyp = ls_final-mestyp.
      ls_edidc-docnum = ls_final-docnum.
      ls_edidc-status = ls_final-status.
      ls_edidc-direct = ls_final-direct.
      APPEND ls_edidc TO lt_edidc.
      CLEAR : ls_edidc.
    ENDLOOP.
    IF lt_edidc IS NOT INITIAL.
      SELECT zmandt,docnum,logdat,logtim,countr,statxt,stapa1,stapa2,stapa3,stapa4 FROM ztitr_edids
             INTO TABLE @lt_edids FOR ALL ENTRIES IN @lt_edidc WHERE docnum EQ @lt_edidc-docnum AND
               zmandt EQ '900'.
    ENDIF.
  ENDIF.
  IF rb2 EQ 'X'.
    date = sy-datum.
    CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
      EXPORTING
        date      = date
        days      = 01
        months    = 00
        signum    = '-'
        years     = 00
      IMPORTING
        calc_date = date.
    SELECT mestyp,docnum,status,direct,credat FROM ztitr_edidc INTO TABLE @lt_edidc
              WHERE credat EQ @date AND status IN @s_status AND mestyp IN @s_msg AND zmandt EQ '900'.
    IF lt_edidc IS NOT INITIAL.
      SELECT zmandt,docnum,logdat,logtim,countr,statxt,stapa1,stapa2,stapa3,stapa4 FROM ztitr_edids
             INTO TABLE @lt_edids FOR ALL ENTRIES IN @lt_edidc WHERE docnum EQ @lt_edidc-docnum AND
               zmandt EQ '900'.
    ENDIF.
    SELECT   mestyp,docnum,status,direct,credat, cretim FROM ztitr_edidc INTO TABLE @lt_edidc1
            WHERE status IN @s_status AND zmandt EQ '900' AND credat IN @s_date AND mestyp IN @s_msg.
    IF ch1 EQ ''.
      DELETE lt_edidc1 WHERE credat NE date.
    ENDIF.
    IF lt_edidc1 IS NOT INITIAL.
      SELECT zmandt,docnum,logdat,logtim,countr,statxt,stapa1,stapa2,stapa3,stapa4 FROM ztitr_edids
             INTO TABLE @lt_edids FOR ALL ENTRIES IN @lt_edidc1 WHERE docnum EQ @lt_edidc1-docnum AND
               zmandt EQ '900'.
    ENDIF.
  ENDIF.
  SORT : lt_edidc BY mestyp.
  LOOP AT lt_edidc INTO ls_edidc.
    lv_count = lv_count + 1 .
    AT END OF mestyp.
      ls_count-mestyp = ls_edidc-mestyp.
      ls_count-count = lv_count.
      IF rb2 EQ 'X'.
        ls_count-date = sy-datum - 1.
      ELSE.
        ls_count-date = sy-datum.
      ENDIF.

      IF ls_count-direct EQ '1'.
        ls_count-direct = 'Inbound'.
      ELSE.
        ls_count-direct = 'Outbound'.
      ENDIF.
      APPEND ls_count TO lt_count.
      CLEAR : lv_count,ls_count.
    ENDAT.
  ENDLOOP.

  SORT : lt_count BY mestyp.
  ls_table1-mestyp = 'DESADV'.
  ls_table1-direct = 'Outbound'.
  READ TABLE lt_count INTO ls_count WITH KEY mestyp = 'DESADV'
                                              BINARY SEARCH.
  IF sy-subrc EQ 0.
    ls_table1-date = ls_count-date.
    ls_table1-count = ls_count-count.
  ELSE.
    IF rb2 EQ 'X'.
      ls_table1-date = date.
    ELSE.
      ls_table1-date = sy-datum.
    ENDIF.
  ENDIF.

  APPEND ls_table1 TO lt_table1.
  CLEAR :ls_table1.
  ls_table1-mestyp = 'INVOIC'.
  ls_table1-direct = 'Outbound'.
  READ TABLE lt_count INTO ls_count WITH KEY mestyp = 'INVOIC'
                                              BINARY SEARCH.
  IF sy-subrc EQ 0.
    ls_table1-date = ls_count-date.
    ls_table1-count = ls_count-count.
  ELSE.
    IF rb2 EQ 'X'.
      ls_table1-date = date.
    ELSE.
      ls_table1-date = sy-datum.
    ENDIF.
  ENDIF.
  APPEND ls_table1 TO lt_table1.
  CLEAR :ls_table1.
  ls_table1-mestyp = 'ORDRSP'.
  ls_table1-direct = 'Outbound'.
  READ TABLE lt_count INTO ls_count WITH KEY mestyp = 'ORDRSP'
                                              BINARY SEARCH.
  IF sy-subrc EQ 0.
    ls_table1-date = ls_count-date.
    ls_table1-count = ls_count-count.
  ELSE.
    IF rb2 EQ 'X'.
      ls_table1-date = date.
    ELSE.
      ls_table1-date = sy-datum.
    ENDIF.
  ENDIF.
  APPEND ls_table1 TO lt_table1.
  CLEAR :ls_table1.
  ls_table1-mestyp = 'ORDERS'.
  ls_table1-direct = 'Inbound'.
  READ TABLE lt_count INTO ls_count WITH KEY mestyp = 'ORDERS'
                                              BINARY SEARCH.
  IF sy-subrc EQ 0.
    ls_table1-date = ls_count-date.
    ls_table1-count = ls_count-count.
  ELSE.
    IF rb2 EQ 'X'.
      ls_table1-date = date.
    ELSE.
      ls_table1-date = sy-datum.
    ENDIF.
  ENDIF.
  APPEND ls_table1 TO lt_table1.
  CLEAR :ls_table1.
  ls_table1-mestyp = 'SHPCON'.
  ls_table1-direct = 'Inbound'.
  READ TABLE lt_count INTO ls_count WITH KEY mestyp = 'SHPCON'
                                              BINARY SEARCH.
  IF sy-subrc EQ 0.
    ls_table1-date = ls_count-date.
    ls_table1-count = ls_count-count.
  ELSE.
    IF rb2 EQ 'X'.
      ls_table1-date = date.
    ELSE.
      ls_table1-date = sy-datum.
    ENDIF.
  ENDIF.
  APPEND ls_table1 TO lt_table1.
*** WMMBXY Addition
  CLEAR :ls_table1.
  ls_table1-mestyp = 'WMMBXY'.
  ls_table1-direct = 'Inbound'.
  READ TABLE lt_count INTO ls_count WITH KEY mestyp = 'WMMBXY'
                                              BINARY SEARCH.
  IF sy-subrc EQ 0.
    ls_table1-date = ls_count-date.
    ls_table1-count = ls_count-count.
  ELSE.
    IF rb2 EQ 'X'.
      ls_table1-date = date.
    ELSE.
      ls_table1-date = sy-datum.
    ENDIF.
  ENDIF.
  APPEND ls_table1 TO lt_table1.

  ls_html_x-line = text-004.
  APPEND ls_html_x TO t_html_x1 .
  CLEAR:ls_html_x1.

  ls_html_x1-line = text-005.
  APPEND ls_html_x1 TO t_html_x1.
  CLEAR:ls_html_x1.

  ls_html_x1-line = text-006.
  APPEND ls_html_x1 TO t_html_x1.
  CLEAR:ls_html_x1.
  IF rb2 EQ 'X'.
    ls_html_x1-line = text-007.
    APPEND ls_html_x1 TO t_html_x1.
    CLEAR:ls_html_x1.
  ENDIF.
  IF rb1 EQ 'X'.
    ls_html_x1-line = text-008.
    APPEND ls_html_x1 TO t_html_x1.
    CLEAR:ls_html_x1.
  ENDIF.

  DATA: lv_sdate TYPE char10.
  CLEAR : lv_day,lv_month,lv_year.
  lv_day = sy-datum+6(2).
  lv_month = sy-datum+4(2).
  lv_year = sy-datum+0(4).
  CONCATENATE  lv_month '/'lv_day '/' lv_year INTO lv_sdate.
  IF rb1 EQ 'X'.
    DATA : lv_stime TYPE char8.
    CLEAR : lv_hrs,lv_min,lv_sec.
    lv_hrs = sy-uzeit+0(2).
    lv_min = sy-uzeit+2(2).
    lv_sec = sy-uzeit+4(2).
    CONCATENATE lv_hrs ':' lv_min ':' lv_sec INTO lv_stime.
    CONCATENATE 'Hourly Failed IDOC Status -' lv_sdate lv_stime  INTO ld_subject SEPARATED BY space .
  ENDIF.
  IF rb2 EQ 'X'.
    CONCATENATE 'Daily Failed IDOC Details - ' lv_sdate INTO ld_subject SEPARATED BY space .
  ENDIF.

*  IF rb1 EQ 'X'.
*    *-Populate Fieldcatalog
  it_fcat-coltext = 'IDOC TYPE'.
  APPEND it_fcat.
  it_fcat-coltext = 'Error Count'.
  APPEND it_fcat.
  it_fcat-coltext = 'Date'.
  APPEND it_fcat.
  it_fcat-coltext = 'Type'.
  APPEND it_fcat.
  LOOP AT it_fcat.
    w_head-text = it_fcat-coltext.
*-Populate the Column Headings
    CALL FUNCTION 'WWW_ITAB_TO_HTML_HEADERS'
      EXPORTING
        field_nr = sy-tabix
        text     = w_head-text
        fgcolor  = text-009
        bgcolor  = text-010
      TABLES
        header   = t_header.
*-Populate Column Properties
    CALL FUNCTION 'WWW_ITAB_TO_HTML_LAYOUT'
      EXPORTING
        field_nr = sy-tabix
        fgcolor  = text-009
        size     = '3'
      TABLES
        fields   = t_fields.
  ENDLOOP.
  REFRESH t_html.
  CALL FUNCTION 'WWW_ITAB_TO_HTML'
    EXPORTING
      table_header = wa_header
    TABLES
      html         = t_html_x
      fields       = t_fields
      row_header   = t_header
      itable       = lt_table1.
*
*  ENDIF.
  IF rb2 EQ 'X'.
    SORT : lt_edids BY docnum countr DESCENDING.
    SORT : lt_edidc1 BY mestyp.
    LOOP AT lt_edidc1 INTO ls_edidc1.
      ls_att-docnum = ls_edidc1-docnum.
      ls_att-mestyp = ls_edidc1-mestyp.
      ls_att-odate = ls_edidc1-credat.
      ls_att-rdate = sy-datum.
      ls_att-time = ls_edidc1-cretim.
      ls_att-status  = ls_edidc1-status.
      ls_att-comm = 'RED'.
      IF ls_edidc1-direct EQ '2'.
        ls_att-mode = 'Inbound'.
      ELSE.
        ls_att-mode = 'Outbound'.
      ENDIF.
      READ TABLE lt_edids INTO ls_edids WITH KEY docnum = ls_edidc1-docnum.
      IF sy-subrc EQ 0.
        SPLIT ls_edids-statxt AT '&' INTO lv_para1 lv_para2 lv_para3 lv_para4.
        CONCATENATE lv_para1 ls_edids-stapa1 lv_para2 ls_edids-stapa2
                     lv_para3 ls_edids-stapa3 lv_para4 ls_edids-stapa4 INTO ls_att-reason SEPARATED BY space.
      ENDIF.
      APPEND ls_att TO lt_att.
      CLEAR : ls_att.
      lv_count = lv_count + 1 .
      AT END OF mestyp.
        ls_count1-mestyp = ls_edidc1-mestyp.
        ls_count1-count = lv_count.
        IF ls_count1-direct EQ '2'.
          ls_count1-direct = 'Inbound'.
        ELSE.
          ls_count1-direct = 'Outbound'.
        ENDIF.
        APPEND ls_count1 TO lt_count1.
        CLEAR : lv_count1,ls_count1,lv_count.
      ENDAT.
    ENDLOOP.
  ENDIF.
  IF ch1 EQ 'X' AND rb2 EQ 'X'.
    SORT : lt_count BY mestyp.
    ls_table2-mestyp = 'DESADV'.
    ls_table2-direct = 'Outbound'.
    READ TABLE lt_count1 INTO ls_count1 WITH KEY mestyp = 'DESADV'
                                                BINARY SEARCH.
    IF sy-subrc EQ 0.
      ls_table2-count = ls_count1-count.
    ENDIF.
    APPEND ls_table2 TO lt_table2.
    CLEAR :ls_table2.

    ls_table2-mestyp = 'INVOIC'.
    ls_table2-direct = 'Outbound'.
    READ TABLE lt_count1 INTO ls_count1 WITH KEY mestyp = 'INVOIC'
                                                BINARY SEARCH.
    IF sy-subrc EQ 0.
      ls_table2-count = ls_count1-count.
    ENDIF.
    APPEND ls_table2 TO lt_table2.
    CLEAR :ls_table2.

    ls_table2-mestyp = 'ORDRSP'.
    ls_table2-direct = 'Outbound'.
    READ TABLE lt_count1 INTO ls_count1 WITH KEY mestyp = 'ORDRSP'
                                                BINARY SEARCH.
    IF sy-subrc EQ 0.
      ls_table2-count = ls_count1-count.
    ENDIF.
    APPEND ls_table2 TO lt_table2.
    CLEAR :ls_table2.

    ls_table2-mestyp = 'ORDERS'.
    ls_table2-direct = 'Inbound'.
    READ TABLE lt_count1 INTO ls_count1 WITH KEY mestyp = 'ORDERS'
                                                BINARY SEARCH.
    IF sy-subrc EQ 0.
      ls_table2-count = ls_count1-count.
    ENDIF.
    APPEND ls_table2 TO lt_table2.
    CLEAR :ls_table2.

    ls_table2-mestyp = 'SHPCON'.
    ls_table2-direct = 'Inbound'.
    READ TABLE lt_count1 INTO ls_count1 WITH KEY mestyp = 'SHPCON'
                                                BINARY SEARCH.
    IF sy-subrc EQ 0.
      ls_table2-count = ls_count1-count.
    ENDIF.
    APPEND ls_table2 TO lt_table2.

*** WMMBXY Addition
    ls_table2-mestyp = 'WMMBXY'.
    ls_table2-direct = 'Inbound'.
    READ TABLE lt_count1 INTO ls_count1 WITH KEY mestyp = 'WMMBXY'
                                                BINARY SEARCH.
    IF sy-subrc EQ 0.
      ls_table2-count = ls_count1-count.
    ENDIF.
    APPEND ls_table2 TO lt_table2.


    it_fcat1-coltext = 'IDOC TYPE'.
    APPEND it_fcat1.
    it_fcat1-coltext = 'Error Count'.
    APPEND it_fcat1.
    it_fcat1-coltext = 'Type'.
    APPEND it_fcat1.
    LOOP AT it_fcat1.
      w_head1-text = it_fcat1-coltext.

*-Populate the Column Headings
      CALL FUNCTION 'WWW_ITAB_TO_HTML_HEADERS'
        EXPORTING
          field_nr = sy-tabix
          text     = w_head1-text
          fgcolor  = text-009
          bgcolor  = text-010
        TABLES
          header   = t_header1.
*-Populate Column Properties
      CALL FUNCTION 'WWW_ITAB_TO_HTML_LAYOUT'
        EXPORTING
          field_nr = sy-tabix
          fgcolor  = text-009
          size     = '3'
        TABLES
          fields   = t_fields1.
    ENDLOOP.
*  * -Title of the Display
    wa_header1-text = text-011 .
    wa_header-font = text-012.
    wa_header-size = '2'.
*  *-Preparing the HTML from Intenal Table
    REFRESH t_html.
    CALL FUNCTION 'WWW_ITAB_TO_HTML'
      EXPORTING
        table_header = wa_header1
      TABLES
        html         = t_html_x2
        fields       = t_fields1
        row_header   = t_header1
        itable       = lt_table2.
  ENDIF.
  IF rb1 EQ 'X'.
    SORT : lt_edids BY docnum countr DESCENDING.
    LOOP AT lt_final INTO ls_final.
      ls_att-docnum = ls_final-docnum.
      ls_att-mestyp = ls_final-mestyp.
      ls_att-odate = ls_final-credat.
      ls_att-time = ls_final-cretim.
      CLEAR : lv_hrs,lv_min,lv_sec.
      ls_att-status  = ls_final-status.
      ls_att-comm = 'RED'.
      IF ls_final-direct EQ '1'.
        ls_att-mode = 'Outbound'.
      ELSE.
        ls_att-mode = 'Inbound'.
      ENDIF.
      READ TABLE lt_edids INTO ls_edids WITH KEY docnum = ls_final-docnum.
      IF sy-subrc EQ 0.
        SPLIT ls_edids-statxt AT '&' INTO lv_para1 lv_para2 lv_para3 lv_para4.
        CONCATENATE lv_para1 ls_edids-stapa1 lv_para2 ls_edids-stapa2
                     lv_para3 ls_edids-stapa3 lv_para4 ls_edids-stapa4 INTO ls_att-reason SEPARATED BY space.
      ENDIF.
      APPEND ls_att TO lt_att.
      CLEAR : ls_att.
    ENDLOOP.
  ENDIF.

  LOOP AT t_html_x INTO ls_html_x.
    APPEND  ls_html_x TO t_html_x1.
    CLEAR : ls_html_x.
  ENDLOOP.

  IF rb2 EQ 'X' AND ch1 EQ 'X'.
    ls_html_x1-line = text-013.
    APPEND ls_html_x1 TO t_html_x1.
    CLEAR:ls_html_x1.
    LOOP AT t_html_x2 INTO ls_html_x2.
      APPEND  ls_html_x2 TO t_html_x1.
      CLEAR : ls_html_x2.
    ENDLOOP.
  ENDIF.
  ls_html_x1-line = '<p>Thanks & Regards<br>Thittappan<br>SAP BASIS CONSULTANT<br>M: +91  805 646 1169 | T: +1 630 219 1467 | F: 630 428 3650 | EM: tgunasekaran@grom.com</p>'.
  APPEND ls_html_x1 TO t_html_x1.
  CLEAR:ls_html_x1.
  SELECT SINGLE low FROM tvarvc INTO @DATA(lv_reply) WHERE name EQ 'ZITR_REPLY_BACK'.
  DATA : lv_reply_mail TYPE char50.
  CONCATENATE text-014
  text-015
  text-016 lv_reply text-017 INTO ls_html_x1-line SEPARATED BY space.
  APPEND ls_html_x1 TO t_html_x1.
  CLEAR:ls_html_x1.
*perform get_data.
*perform mail_body.
  SORT : lt_att BY odate time DESCENDING.
  LOOP AT lt_att INTO ls_att.
    CLEAR : lv_day,lv_month,lv_year.
    lv_day = ls_att-odate+6(2).
    lv_month = ls_att-odate+4(2).
    lv_year = ls_att-odate+0(4).
    CONCATENATE  lv_month '/'lv_day '/' lv_year INTO ls_doc-odate.
    CLEAR : lv_day,lv_month,lv_year.
    lv_day = sy-datum+6(2).
    lv_month = sy-datum+4(2).
    lv_year = sy-datum+0(4).
    CONCATENATE  lv_month '/'lv_day '/' lv_year INTO ls_doc-rdate.

    lv_sno = lv_sno + 1.
    ls_doc-sno = lv_sno .
    ls_doc-docnum = ls_att-docnum.
    ls_doc-mestyp = ls_att-mestyp.
    CLEAR : lv_hrs,lv_min,lv_sec.
    lv_hrs = ls_att-time+0(2).
    lv_min = ls_att-time+2(2).
    lv_sec = ls_att-time+4(2).
    CONCATENATE lv_hrs ':' lv_min ':' lv_sec INTO ls_doc-time.
    ls_doc-status  = ls_att-status.
    ls_doc-mode = ls_att-mode.
    ls_doc-reason = ls_att-reason.
    APPEND ls_doc TO lt_doc.
    CLEAR : ls_doc.
  ENDLOOP.
  TRY.
      IF lt_doc IS NOT INITIAL .
        DATA : text_content TYPE string.
        DATA : text_string TYPE string.
*        SORT : lt_doc BY odate DESCENDING.
        SORT : lt_edids BY docnum countr DESCENDING.
        LOOP AT lt_doc INTO ls_doc.
          CONCATENATE  ls_doc-mode ls_doc-mestyp ls_doc-docnum ls_doc-status ls_doc-odate
            ls_doc-time ls_doc-rdate  ls_doc-reason
            INTO text_string  SEPARATED BY cl_abap_char_utilities=>horizontal_tab.
          CONCATENATE text_string text_content INTO text_content SEPARATED BY cl_abap_char_utilities=>newline.
          CLEAR : text_string.

        ENDLOOP.
        CONCATENATE   'Mode' 'Idoc Type' 'Idoc Number' 'Status' 'Occurred date' 'Occurred Time' 'Reported date'  'Reason'
     INTO text_string SEPARATED BY cl_abap_char_utilities=>horizontal_tab.
        CONCATENATE text_string text_content INTO text_content SEPARATED BY cl_abap_char_utilities=>newline.
        CLEAR : text_string.
        cl_bcs_convert=>string_to_solix(
              EXPORTING
                iv_string   = text_content
                iv_codepage = '4103'  "suitable for MS Excel, leave empty
                iv_add_bom  = 'X'     "for other doc types
              IMPORTING
                et_solix  = lv_xlscont
                ev_size   = lv_xls_size ).
      ENDIF.
      send_email = cl_bcs=>create_persistent( ).
* Create email document inc type, subject and boby text
      document = cl_document_bcs=>create_document(
      i_type = 'HTM'
      i_subject = ld_subject
      i_text = t_html_x1 ).

      CONCATENATE p_mail '_TO' INTO lv_to.
      CONCATENATE p_mail  '_CC' INTO lv_cc.
      CONCATENATE p_mail  '_FROM' INTO lv_from.
      CONCATENATE p_mail  '_BCC' INTO lv_bcc.
      IF lt_doc IS NOT INITIAL .
        DATA: lv_subj  TYPE c LENGTH 50,
              lv_yy    TYPE char04,
              lv_mon   TYPE char02,
              lv_dd    TYPE char02,
              lv_datum TYPE char10.
        lv_yy = sy-datum+0(4).
        lv_mon = sy-datum+4(2).
        lv_dd = sy-datum+6(2).
        CONCATENATE lv_mon '_' lv_dd '_' lv_yy INTO lv_datum.
        IF rb1 EQ 'X'.
          CONCATENATE 'Hourly Virtus IDOC tracker ' lv_datum INTO lv_subj SEPARATED BY space.
        ENDIF.
        IF rb2 EQ 'X'.
          CONCATENATE 'Daily Virtus IDOC tracker' lv_datum INTO lv_subj SEPARATED BY space.
        ENDIF.

        CALL METHOD document->add_attachment
          EXPORTING
            i_attachment_type    = 'XLS'
            i_attachment_subject = lv_subj
            i_attachment_size    = lv_xls_size
            i_att_content_hex    = lv_xlscont.
      ENDIF.

      IF lt_final IS NOT INITIAL  AND rb1 EQ 'X'.

        SELECT * FROM tvarvc INTO TABLE lt_to WHERE name EQ lv_to.
        SELECT * FROM tvarvc INTO TABLE lt_cc WHERE name EQ lv_cc.
*          select single * from tvarvc into ls_from where NAME EQ lv_from.
        SELECT  * FROM tvarvc INTO TABLE lt_bcc WHERE name EQ lv_bcc.


        LOOP AT lt_to INTO ls_to.
* Assign document and all its details to the email
          CALL METHOD send_email->set_document( document ).
* Setup email recipient
          wa_receivers-email = ls_to-low.
          recipient = cl_cam_address_bcs=>create_internet_address( wa_receivers-email ).
*Assign recipient to email
          CALL METHOD send_email->add_recipient
            EXPORTING
              i_recipient = recipient
              i_express   = 'X'.
        ENDLOOP.
        LOOP AT lt_cc INTO ls_cc.
* Assign document and all its details to the email
          CALL METHOD send_email->set_document( document ).
* Setup email recipient
          wa_receivers-email = ls_cc-low.
          recipient = cl_cam_address_bcs=>create_internet_address( wa_receivers-email ).
*Assign recipient to email
          CALL METHOD send_email->add_recipient
            EXPORTING
              i_recipient = recipient
              i_express   = 'X'
              i_copy      = 'X'.
        ENDLOOP.
        LOOP AT lt_bcc INTO ls_bcc.
* Assign document and all its details to the email
          CALL METHOD send_email->set_document( document ).
* Setup email recipient
          wa_receivers-email = ls_bcc-low.
          recipient = cl_cam_address_bcs=>create_internet_address( wa_receivers-email ).
*Assign recipient to email
          CALL METHOD send_email->add_recipient
            EXPORTING
              i_recipient  = recipient
              i_express    = 'X'
              i_blind_copy = 'X'.
        ENDLOOP.
        lv_from_m = ls_from-low.
        IF p_mail NE 'ZTEST'.
          sender   = cl_cam_address_bcs=>create_internet_address(
                                                "'ashraph@grom.com' ).
                                                'tgunasekaran@grom.com').
        ENDIF.

        IF p_mail EQ 'ZTEST'.
          sender   = cl_cam_address_bcs=>create_internet_address(
                                                'srikanth.a@itresonance.com' ).
        ENDIF.
*          sender   = cl_cam_address_bcs=>create_internet_address(
*                                     lv_from_m ) .
*          CLEAR wa_receivers-email.

        CALL METHOD send_email->set_sender
          EXPORTING
            i_sender = sender.
*Send email
        CALL METHOD send_email->set_send_immediately
          EXPORTING
            i_send_immediately = 'X'.   " 'X' = Activate, ' ' = Deactivate
*            CATCH cx_send_req_bcs.    "
        CALL METHOD send_email->send
          EXPORTING
            i_with_error_screen = 'X'
          RECEIVING
            result              = sent_to_all.
        IF sent_to_all = 'X'.
          WRITE : text-018.
        ENDIF.
        COMMIT WORK.
      ENDIF.
      IF rb2 EQ 'X'.
        SELECT * FROM tvarvc INTO TABLE lt_to WHERE name EQ lv_to.
        SELECT * FROM tvarvc INTO TABLE lt_cc WHERE name EQ lv_cc.
        SELECT * FROM tvarvc INTO TABLE lt_bcc WHERE name EQ lv_bcc.
        LOOP AT lt_to INTO ls_to.
* Assign document and all its details to the email
          CALL METHOD send_email->set_document( document ).
* Setup email recipient
          wa_receivers-email = ls_to-low.
          recipient = cl_cam_address_bcs=>create_internet_address( wa_receivers-email ).
*Assign recipient to email
          CALL METHOD send_email->add_recipient
            EXPORTING
              i_recipient = recipient
              i_express   = 'X'.
        ENDLOOP.
        LOOP AT lt_cc INTO ls_cc.
* Assign document and all its details to the email
          CALL METHOD send_email->set_document( document ).
* Setup email recipient
          wa_receivers-email = ls_cc-low.
          recipient = cl_cam_address_bcs=>create_internet_address( wa_receivers-email ).
*Assign recipient to email
          CALL METHOD send_email->add_recipient
            EXPORTING
              i_recipient = recipient
              i_copy      = 'X'.
        ENDLOOP.
        LOOP AT lt_bcc INTO ls_bcc.
          CALL METHOD send_email->set_document( document ).
* Setup email recipient
          wa_receivers-email = ls_bcc-low.
          recipient = cl_cam_address_bcs=>create_internet_address( wa_receivers-email ).
*Assign recipient to email
          CALL METHOD send_email->add_recipient
            EXPORTING
              i_recipient  = recipient
              i_blind_copy = 'X'.
        ENDLOOP.
        IF p_mail NE 'ZTEST'.
          sender   = cl_cam_address_bcs=>create_internet_address(
                                                "'mnauman@grom.com' ).
                                               " 'ashraph@grom.com' ).    "yugesh
                                               'tgunasekaran@grom.com').
        ENDIF.

        IF p_mail EQ 'ZTEST'.
          sender   = cl_cam_address_bcs=>create_internet_address(
                                                'srikanth.a@itresonance.com' ).

        ENDIF.
*        ENDIF.
*            sender   = cl_cam_address_bcs=>create_internet_address(
*                                      'mnauman@grom.com' ).
        lv_from_m = ls_from-low.
*
*          sender   = cl_cam_address_bcs=>create_internet_address(
*                                      lv_from_m ).
*           CLEAR wa_receivers-email.
        CALL METHOD send_email->set_sender
          EXPORTING
            i_sender = sender.

*Send email
        CALL METHOD send_email->send
          EXPORTING
            i_with_error_screen = 'X'
          RECEIVING
            result              = sent_to_all.
        IF sent_to_all = 'X'.
          WRITE : text-018.
        ENDIF.
        COMMIT WORK.

      ENDIF.
    CATCH cx_bcs INTO bcs_exception.
      RAISE sms_sending_failed.
      EXIT.
  ENDTRY.
