*&---------------------------------------------------------------------*
*& Report ZTEST_ANALYTIC_IDM
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ztest_analytic_idm_03.
TABLES edidc.



TYPES : BEGIN OF ty_data,
          docnum         TYPE edidc-docnum,
          cust           TYPE kunnr,
          cust_name      TYPE name1_gp,
          year           TYPE char4,
          mon            TYPE char2,
          month_year     TYPE zitr_analytic_de_month,
          netwr          TYPE netwr,
          credat         TYPE sy-datum,
          cretim         TYPE sy-uzeit,
          ddate          TYPE sy-datum,
          Procss_time    TYPE zitr_analytic_de_time,
          dtime          TYPE  sy-uzeit,
          status         TYPE edi_status,
          delayed_values TYPE netwr,
          days           TYPE int8,
          flag           TYPE char1,
          Reason         TYPE string,
          reason_text    type string,
          net_Error_51   TYPE netwr,
          net_Success_53 TYPE netwr,
          net_Error_56   TYPE netwr,
          net_Ready_64   TYPE netwr,
        END OF ty_data.

DATA:
      lv_year     TYPE zitr_analytic_de_year,
      lv_month    TYPE zitr_analytic_de_month,
      lt_amount   TYPE TABLE OF e1edp01,
      lt_cust     TYPE TABLE OF e1edka1,
      ls_amount   TYPE e1edp01,
      ls_cust     TYPE e1edka1,
      lt_data     TYPE TABLE OF ty_data,
      ls_data     TYPE ty_data,
      lv_amount   TYPE netwr,
      lv_total    TYPE netwr,
      lv_ndelay   TYPE netwr,
      lv_delay    TYPE netwr,
      lt_edid4    TYPE TABLE OF edid4,
      ls_edid4    TYPE  edid4,
      lv_count    TYPE i,
      lv_cust     TYPE kunnr,
      lv_customer TYPE kunnr,
      lv_days     TYPE int8,
*      lv_from     TYPE sy-datum,
*      lv_to       TYPE sy-datum,
      lt_edidc    TYPE TABLE OF edidc,
      ls_edidc    TYPE  edidc,
      lt_edids    TYPE TABLE OF edids,
      ls_edids    TYPE  edids,
      lv_num      TYPE i.

DATA : lv_time  TYPE zitr_analytic_de_time,
       lt_final TYPE TABLE OF zitr_analytic,
       ls_final LIKE LINE OF lt_final.

DATA : lv_net_51 TYPE netwr,
       lv_net_53 TYPE netwr,
       lv_net_56 TYPE netwr,
       lv_net_64 TYPE netwr,
       lv_s_net  TYPE netwr.

PARAMETERS : lv_from TYPE sy-datum,
             lv_to   TYPE sy-datum.


if lv_to IS INITIAL and lv_from is INITIAL.

  lv_to = sy-datum.

  CALL FUNCTION 'HR_JP_ADD_MONTH_TO_DATE'
    EXPORTING
      iv_monthcount       = -3
      iv_date             = lv_to
   IMPORTING
     EV_DATE             = lv_from.

  ENDIF.

SELECT * FROM edidc INTO TABLE lt_edidc
        WHERE credat  BETWEEN lv_from AND lv_to
              AND mestyp = 'ORDERS'
              AND  status IN ( '51','53','64' ,'56' ).

CLEAR : lv_from, lv_to.



IF lt_edidc IS NOT INITIAL.

  SELECT * FROM edid4 INTO CORRESPONDING FIELDS OF TABLE  lt_edid4
          FOR ALL ENTRIES IN lt_edidc WHERE docnum EQ lt_edidc-docnum
                         AND segnam  IN ('E1EDP01' , 'E1EDKA1') .

  SELECT * FROM edids INTO TABLE lt_edids
      FOR ALL ENTRIES IN lt_edidc WHERE docnum EQ lt_edidc-docnum

                               AND status IN ('51','53','56','64').
  SELECT kunnr , name1 FROM kna1 INTO TABLE @DATA(lt_kna11).

ENDIF.

SORT : lt_edid4 BY docnum ,
       lt_edids BY docnum DESCENDING.
LOOP AT lt_edidc INTO ls_edidc.
  LOOP AT lt_edid4 INTO ls_edid4 WHERE docnum = ls_edidc-docnum AND segnam = 'E1EDP01' .

    ls_amount = ls_edid4-sdata.
    ls_data-netwr = ls_amount-netwr + ls_data-netwr.
    ls_data-year = ls_edidc-credat+0(4).
    ls_data-mon = ls_edidc-credat+4(2).
    ls_data-credat = ls_edidc-credat.
    ls_data-cretim = ls_edidc-cretim.
    ls_data-status = ls_edidc-status.
    ls_data-docnum   = ls_edidc-docnum.

  ENDLOOP.

  LOOP AT lt_edid4 INTO ls_edid4 WHERE docnum = ls_edidc-docnum AND
                                segnam EQ 'E1EDKA1'.
    IF sy-subrc EQ 0.
      ls_cust = ls_edid4-sdata.
      IF ls_cust-parvw = 'AG'.
        ls_data-cust = ls_cust-partn.
      ENDIF.
    ENDIF.
  ENDLOOP.
  READ TABLE lt_edids INTO ls_edids WITH KEY docnum = ls_edidc-docnum.
  IF sy-subrc EQ 0.
    DATA(lv_string) = ls_edids-statxt.

    REPLACE ALL OCCURRENCES OF '&1' IN lv_string WITH ls_edids-stapa1.
    REPLACE ALL OCCURRENCES OF '&2' IN lv_string WITH ls_edids-stapa2.
    REPLACE ALL OCCURRENCES OF '&3' IN lv_string WITH ls_edids-stapa3.
    REPLACE ALL OCCURRENCES OF '&4' IN lv_string WITH ls_edids-stapa4.

    ls_data-reason = lv_string.
    ls_data-ddate = ls_edids-credat.
    ls_data-dtime = ls_edids-cretim.

    CLEAR lv_string.

    DATA: lv_msg_text TYPE string.
*
*CALL FUNCTION 'MESSAGE_TEXT_BUILD'
*  EXPORTING
*    msgid               = ls_edids-STAMID
*    msgnr               = ls_edids-STAMNO
*    msgv1               = ls_edids-stapa1
*    msgv2               = ls_edids-stapa2
*    msgv3               = ls_edids-stapa3
*    msgv4               = ls_edids-stapa4
*  IMPORTING
*    message_text_output = lv_msg_text.
*
*ls_data-reason_text = lv_msg_text.

if ls_data-status = '51' or ls_data-status = '56'.

if   ls_data-reason_text cs 'Condition EDI2 is missing in pricing procedure A V Y17J01'
  or ls_data-reason_text cs 'Condition EDI1 is missing in pricing procedure A V Y17J01'
  or ls_data-reason_text cs 'Condition PPR0 is not allowed as header condition'
  or ls_data-reason_text cs 'EDI: Partner profile does not exist'
  or ls_data-reason_text cs 'No pricing procedure could be determined'.

  ls_data-reason = 'Pricing'.

ELSEIF ls_data-reason_text cs 'Material'.

ls_data-reason = 'MD - Material'.

ELSEIF ls_data-reason_text cs 'Sold-to party'
 or ls_data-reason_text cs 'customer'.

ls_data-reason = 'MD - Customer'.

ELSEIF ls_data-reason_text cs 'Order type'.

ls_data-reason = 'System Error'.

ELSE.

ls_data-reason = 'Others'.

ENDIF.

endif.

  ENDIF.
  lv_days = ls_data-ddate - ls_data-credat.
  IF lv_days NE 0 .
    ls_data-flag = 'X'.
    ls_data-days = lv_days.
    ls_data-procss_time =  ls_data-ddate - ls_data-cretim.
  ENDIF.

  IF ls_data-flag = 'X'.

    ls_data-delayed_values = ls_data-netwr.

  ENDIF.

  DATA(lv_kunnr1) =  |{ ls_data-cust ALPHA = IN }|.

  READ TABLE lt_kna11 INTO DATA(wa_kna11) WITH KEY kunnr = lv_kunnr1.
  IF sy-subrc = 0.

    ls_data-cust_name = wa_kna11-name1.

  ENDIF.
  CLEAR lv_kunnr1.


  CASE ls_data-status.
    WHEN '51'.
      ls_data-net_error_51 = ls_data-netwr.
    WHEN '53'.
      ls_data-net_success_53 = ls_data-netwr.
    WHEN '56'.
      ls_data-net_error_56 = ls_data-netwr.
    WHEN '64'.
      ls_data-net_ready_64 = ls_data-netwr.
  ENDCASE.

  CASE ls_data-mon.
    WHEN '01'.
      CONCATENATE 'Jan-' ls_data-year INTO ls_data-month_year.
    WHEN '02'.
      CONCATENATE 'FEB-' ls_data-year INTO ls_data-month_year.
    WHEN '03'.
      CONCATENATE 'MAR-' ls_data-year INTO ls_data-month_year.
    WHEN '04'.
      CONCATENATE 'APR-' ls_data-year INTO ls_data-month_year.
    WHEN '05'.
      CONCATENATE 'MAY-' ls_data-year INTO ls_data-month_year.
    WHEN '06'.
      CONCATENATE 'JUN-' ls_data-year INTO ls_data-month_year.
    WHEN '07'.
      CONCATENATE 'JUL-' ls_data-year INTO ls_data-month_year.
    WHEN '08'.
      CONCATENATE 'AUG-' ls_data-year INTO ls_data-month_year.
    WHEN '09'.
      CONCATENATE 'SEP-' ls_data-year INTO ls_data-month_year.
    WHEN '10'.
      CONCATENATE 'OCT-' ls_data-year INTO ls_data-month_year.
    WHEN '11'.
      CONCATENATE 'NOV-' ls_data-year INTO ls_data-month_year.
    WHEN '12'.
      CONCATENATE 'DEC-' ls_data-year INTO ls_data-month_year.

  ENDCASE.

  APPEND ls_data TO lt_data.
  CLEAR: ls_data,ls_cust,ls_amount.
ENDLOOP.




LOOP AT lt_data INTO ls_data.

  ls_final-mandt                = sy-mandt.
  ls_final-idoc_number         = ls_data-docnum.
  ls_final-idoc_year            = ls_data-year.
  ls_final-idoc_month           = ls_data-mon.
  ls_final-idoc_delayed         = ls_data-delayed_values.
  ls_final-average_days_delayed = ls_data-days.
 ls_final-monthyear             = ls_data-month_year.
  ls_final-customer             = ls_data-cust.
  ls_final-customername         = ls_data-cust_name.
  ls_final-reason               = ls_data-reason.
  ls_final-total_value          = ls_data-netwr.
  ls_final-idoc_net_error_51    = ls_data-net_error_51.
  ls_final-idoc_net_error_56    = ls_data-net_error_56.
  ls_final-idoc_net_ready_64    = ls_data-net_ready_64.
  ls_final-idoc_net_success_53  = ls_data-net_success_53.
  ls_final-IDOC_CREDAT          = ls_data-credat.
  ls_final-reason_text          = ls_data-reason_text.

  APPEND ls_final TO lt_final.
  CLEAR ls_final.

ENDLOOP.

MODIFY zitr_analytic FROM TABLE lt_final .

cl_demo_output=>display( lt_final ).
