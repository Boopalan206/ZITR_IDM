FUNCTION bapi_ztest_idm_mail_list.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     VALUE(RETURN) TYPE  BAPIRET2
*"  TABLES
*"      EXPORT STRUCTURE  ZBAPI_ZST_MAIL_LIST_EX OPTIONAL
*"----------------------------------------------------------------------

  CONSTANTS : lc_idoc_status_ip_value TYPE String VALUE 'MON_STATUSES',
              lc_msg_types_ip_value   TYPE String VALUE 'ZMSG_TYPE'.

  DATA : lt_idoc_status_result TYPE ztt_idoc_mestyp,
         lt_msg_type_result    TYPE ztt_idoc_msg_types,
         lt_email_list_result  TYPE ztt_idoc_email_list,
         lv_dep_name           TYPE String,
         lv_msg_type           TYPE String.

  DATA :  ls_return TYPE bapiret2.


  lv_dep_name = 'Sales'.

  lv_msg_type = 'Orders'.


  CALL FUNCTION 'ZFM_GET_DIST_MAILS'
    EXPORTING
      iv_mes_type  = lv_msg_type
      iv_dept_name = lv_dep_name
    IMPORTING
      et_result    = lt_email_list_result.

  MOVE-CORRESPONDING lt_email_list_result TO export[].

  IF sy-subrc <> 0.

    ls_return-id = '01'.
    ls_return-message = 'E'.
    ls_return-message_v1 = 'IDOC DETAILS NOT FOUND'.

    MOVE-CORRESPONDING ls_return TO return.
    CLEAR ls_return.

  ENDIF.




ENDFUNCTION.
