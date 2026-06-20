FUNCTION zfm_itrs4_08_idoc_processing.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(LS_PROCESSIDOC) TYPE  ZST_ITR_S4_08_IDOC_PROC
*"  EXPORTING
*"     VALUE(ER_ENTITY) TYPE  ZST_ITR_S4_08_IDOC_PROC
*"----------------------------------------------------------------------
  TYPES : BEGIN OF outtab,
            docnum(50),
            first_stat(50),
            curr_stat(50),
          END OF outtab.
  TYPES: BEGIN OF outtab_struc,
           docnum         TYPE edi_docnum,
           mestyp         TYPE edi_mestyp,
           status         TYPE edi_status,
           statusicon(60),
           statxt         TYPE edi_statxt,
         END OF outtab_struc.
  TYPES : BEGIN OF outtab_struc1,
            docnum TYPE edi_docnum,
            mestyp TYPE edi_mestyp,
            status TYPE edi_status,
            statxt TYPE edi_statxt,
          END OF outtab_struc1.
  TYPES : BEGIN OF outtab_strc3,
            message TYPE string,
          END OF outtab_strc3.
  DATA  :it_selection TYPE TABLE OF rsparams,
         wa_selection LIKE LINE OF it_selection,
         ls_tab       TYPE outtab,
         ls_tab1      TYPE outtab_struc,
         ls_tab2      TYPE outtab_struc1,
         ls_tab3      TYPE outtab_strc3.
  DATA : lv_direction TYPE edi_direct,
         lv_status    TYPE edi_status.

  DATA list_tab TYPE TABLE OF abaplist.
  FIELD-SYMBOLS  : <lt_pay_data>   TYPE ANY TABLE .
  FIELD-SYMBOLS : <lt_test> TYPE any . "LIKE LINE OF  it_tab .

  DATA lr_pay_data              TYPE REF TO data.

  DATA : ls_edids   TYPE edids,
         lv_message TYPE String,
         lv_idoc_no TYPE edi_docnum.

*    io_data_provider->read_entry_data( IMPORTING es_data  = ls_processidoc  ).
  IF ls_processidoc-idoc_number IS INITIAL.
    er_entity-status = 'Idoc not received for Processing'.
  ELSE.
    er_entity-idoc_number  = ls_processidoc-idoc_number.
    SELECT SINGLE direct,status FROM edidc INTO (@lv_direction, @lv_status)
                         WHERE docnum = @ls_processidoc-idoc_number.
    IF lv_status = '51' OR lv_status = '52'.

      wa_selection-selname = 'SO_DOCNU'.
      wa_selection-kind    = 'S'.  "S-Select-options P-Parameters
      wa_selection-sign    = 'I'.
      wa_selection-option  = 'EQ'.
      wa_selection-low     = ls_processidoc-idoc_number.
      APPEND wa_selection TO it_selection.
      cl_salv_bs_runtime_info=>set(    EXPORTING display  = abap_false
                                              metadata = abap_false
                                              data     = abap_true ).
      SUBMIT rbdmani2    WITH SELECTION-TABLE it_selection
      " EXPORTING LIST TO MEMORY
        AND RETURN.
    ELSEIF lv_status = '64' OR lv_status = '66'.
      wa_selection-selname = 'DOCNUM'.
      wa_selection-kind    = 'S'.  "S-Select-options P-Parameters
      wa_selection-sign    = 'I'.
      wa_selection-option  = 'EQ'.
      wa_selection-low     = ls_processidoc-idoc_number.
      APPEND wa_selection TO it_selection.
      cl_salv_bs_runtime_info=>set(    EXPORTING display  = abap_false
                                              metadata = abap_false
                                              data     = abap_true ).
      SUBMIT  rbdapp01    WITH SELECTION-TABLE it_selection
      " EXPORTING LIST TO MEMORY
        AND RETURN.
    ELSEIF lv_status = '32' OR lv_status = '69'.
      wa_selection-selname = 'P_IDOC'.
      wa_selection-kind    = 'S'.  "S-Select-options P-Parameters
      wa_selection-sign    = 'I'.
      wa_selection-option  = 'EQ'.
      wa_selection-low     = ls_processidoc-idoc_number.
      APPEND wa_selection TO it_selection.

      wa_selection-selname = 'P_DIRECT'.
      wa_selection-kind    = 'S'. "S-Select-options P-Parameters
      wa_selection-sign    = 'I'.
      wa_selection-option  = 'EQ'.
      wa_selection-low     = lv_direction .
      APPEND wa_selection TO it_selection.

      cl_salv_bs_runtime_info=>set(    EXPORTING display  = abap_false
                                                 metadata = abap_false
                                                 data     = abap_true ).
      SUBMIT rbdagaie    WITH SELECTION-TABLE it_selection
      " EXPORTING LIST TO MEMORY
        AND RETURN.

    ELSEIF lv_status = '26'.
      wa_selection-selname = 'SO_DOCNU'.
      wa_selection-kind    = 'S'.  "S-Select-options P-Parameters
      wa_selection-sign    = 'I'.
      wa_selection-option  = 'EQ'.
      wa_selection-low     = ls_processidoc-idoc_number.
      APPEND wa_selection TO it_selection.

      wa_selection-selname = 'P_DIRECT'.
      wa_selection-kind    = 'S'. "S-Select-options P-Parameters
      wa_selection-sign    = 'I'.
      wa_selection-option  = 'EQ'.
      wa_selection-low     = lv_direction .
      APPEND wa_selection TO it_selection.

      cl_salv_bs_runtime_info=>set(    EXPORTING display  = abap_false
                                                 metadata = abap_false
                                                 data     = abap_true ).
      SUBMIT rbdsyner    WITH SELECTION-TABLE it_selection
      " EXPORTING LIST TO MEMORY
        AND RETURN.
    ELSEIF lv_status = '30'.
      wa_selection-selname = 'DOCNUM'.
      wa_selection-kind    = 'S'.  "S-Select-options P-Parameters
      wa_selection-sign    = 'I'.
      wa_selection-option  = 'EQ'.
      wa_selection-low     = ls_processidoc-idoc_number.
      APPEND wa_selection TO it_selection.
      cl_salv_bs_runtime_info=>set(    EXPORTING display  = abap_false
                                              metadata = abap_false
                                              data     = abap_true ).
      SUBMIT rseout00    WITH SELECTION-TABLE it_selection
        " EXPORTING LIST TO MEMORY
          AND RETURN.
    ELSEIF lv_status = '29'.

      wa_selection-selname = 'SO_DOCNU'.
      wa_selection-kind    = 'S'.  "S-Select-options P-Parameters
      wa_selection-sign    = 'I'.
      wa_selection-option  = 'EQ'.
      wa_selection-low     = ls_processidoc-idoc_number.
      APPEND wa_selection TO it_selection.
      cl_salv_bs_runtime_info=>set(    EXPORTING display  = abap_false
                                              metadata = abap_false
                                              data     = abap_true ).
      SUBMIT rbdagain    WITH SELECTION-TABLE it_selection
                " EXPORTING LIST TO MEMORY
                  AND RETURN.
    ENDIF.

    TRY.
        cl_salv_bs_runtime_info=>get_data_ref( IMPORTING r_data = lr_pay_data ).
        ASSIGN lr_pay_data->* TO <lt_pay_data>.
      CATCH cx_salv_bs_sc_runtime_info.
        er_entity-status = 'Unable to process Idoc'.
*        MESSAGE `Unable to retrieve ALV data` TYPE 'E'.
    ENDTRY.
    cl_salv_bs_runtime_info=>clear_all( ).

    lv_idoc_no  = |{ ls_processidoc-idoc_number ALPHA = IN }|.

    CALL FUNCTION 'EDI_DOCUMENT_OPEN_FOR_READ'
      EXPORTING
        document_number = lv_idoc_no.
    IF sy-subrc = 0.

      CALL FUNCTION 'EDI_DOCUMENT_READ_LAST_STATUS'
        EXPORTING
          document_number        = lv_idoc_no
        IMPORTING
          status                 = ls_edids
        EXCEPTIONS
          document_not_open      = 1
          no_status_record_found = 2
          OTHERS                 = 3.
      IF sy-subrc = 0.

        CALL FUNCTION 'MESSAGE_TEXT_BUILD'
          EXPORTING
            msgid               = ls_edids-stamid
            msgnr               = ls_edids-stamno
            msgv1               = ls_edids-stapa1
            msgv2               = ls_edids-stapa2
            msgv3               = ls_edids-stapa3
            msgv4               = ls_edids-stapa4
          IMPORTING
            message_text_output = lv_message.

        CALL FUNCTION 'EDI_DOCUMENT_CLOSE_READ'
          EXPORTING
            document_number = lv_idoc_no.

      ENDIF.

    ENDIF.


    IF <lt_pay_data> IS ASSIGNED.
      LOOP AT  <lt_pay_data> ASSIGNING <lt_test>.
        IF lv_status = '51' OR lv_status = '52' OR lv_status = '64'
           OR lv_status = '66' OR lv_status = '29'.
          MOVE-CORRESPONDING <lt_test> TO ls_tab1.
        ELSEIF  lv_status = '32' OR lv_status = '69'.
          MOVE-CORRESPONDING <lt_test> TO ls_tab.
        ELSEIF lv_status = '26'.
          MOVE-CORRESPONDING <lt_test> TO ls_tab2.
        ELSEIF lv_status = '30'.
          MOVE-CORRESPONDING <lt_test> TO ls_tab3.
        ENDIF.
      ENDLOOP.


        IF lv_status = '51' OR lv_status = '52' OR lv_status = '64'
           OR lv_status = '66' OR lv_status = '29'.
          er_entity-status_type = ls_edids-statyp.
          er_entity-status = ls_tab1-statxt.
          CONCATENATE er_entity-status '-' lv_message INTO er_entity-status SEPARATED BY space.
        ELSEIF lv_status = '32' OR lv_status = '69'.
          er_entity-status_type = ls_edids-statyp.
          er_entity-status = ls_tab-curr_stat.
          CONCATENATE er_entity-status '-' lv_message INTO er_entity-status SEPARATED BY space.
        ELSEIF lv_status = '26'.
          er_entity-status_type = ls_edids-statyp.
          er_entity-status = ls_tab2-statxt.
          CONCATENATE er_entity-status '-' lv_message INTO er_entity-status SEPARATED BY space.
        ELSEIF lv_status = '30'.
          er_entity-status_type = ls_edids-statyp.
          er_entity-status = ls_tab3-message.
          CONCATENATE er_entity-status '-' lv_message INTO er_entity-status SEPARATED BY space.
        ENDIF.

      ELSE.
        er_entity-status_type = 'W'.
        er_entity-status = 'Unable to process non-editable IDOC '.
        CONCATENATE er_entity-status '-' lv_message INTO er_entity-status SEPARATED BY space.

    ENDIF.
  ENDIF.



ENDFUNCTION.
