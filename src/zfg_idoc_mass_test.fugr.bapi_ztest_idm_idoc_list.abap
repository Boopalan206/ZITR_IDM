FUNCTION bapi_ztest_idm_idoc_list .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     VALUE(RETURN) TYPE  BAPIRET2
*"  TABLES
*"      ET_IDOC_LIST STRUCTURE  ZBAPI_ZST_IDOC_LIST
*"----------------------------------------------------------------------
  "----------------------------------------------------------------------
  "*"Local Interface:
  "  EXPORTING
  "     REFERENCE(ET_IDOC_LIST) TYPE  ZTT_IDOC_LIST
  "----------------------------------------------------------------------
  TYPES : BEGIN OF ty_customer,
            kunnr TYPE kunnr,
          END OF ty_customer,

          BEGIN OF ty_idoc_msg,
            docnum  TYPE edi_docnum,
            message TYPE idoc_msg,
          END OF ty_idoc_msg
          .

  DATA: lt_data       TYPE STANDARD TABLE OF ztest_idoc,
        lt_idoc_msg   TYPE STANDARD TABLE OF ty_idoc_msg,
        lt_edid4      TYPE STANDARD TABLE OF edidd,
        lt_edid4_temp TYPE STANDARD TABLE OF edidd,
        lt_edids      TYPE STANDARD  TABLE OF edids,
        lt_edids_temp TYPE STANDARD TABLE OF edids,
        lt_customer   TYPE STANDARD TABLE OF ty_customer,
        lt_brf_msg    TYPE STANDARD TABLE OF zst_idoc_msg_types,
        lt_brf_status TYPE STANDARD TABLE OF zst_idoc_mestyp,
        ls_customer   TYPE ty_customer,
        ls_e1edka1    TYPE e1edka1,
        ls_idoc_msg   TYPE ty_idoc_msg,
        lv_idoc_msg   TYPE idoc_msg,
        ls_data       TYPE ztest_idoc.


  DATA :lt_credat TYPE RANGE OF edidc-credat,
        ls_credat LIKE LINE OF lt_credat.
  DATA ls_return TYPE bapiret2.


  ls_credat-option = 'BT'.
  ls_credat-sign = 'I'.
  ls_credat-low = sy-datum - 15.
  ls_credat-high = sy-datum.

  APPEND ls_credat TO lt_credat.
  CLEAR ls_credat.


  SELECT
         docnum,
         status,
         direct,
         credat,
         cretim,
         mestyp,
         idoctp,
         maxsegnum
  FROM edidc
  WHERE mestyp in ( 'ORDERS' , 'DESADV' ) AND
  status in ( '51','56' ) AND
  credat IN @lt_credat
  ORDER BY ( 'primary key' ) ASCENDING
  INTO TABLE @DATA(lt_edidc).

  IF sy-subrc = 0.

    SORT lt_edidc ASCENDING BY docnum idoctp credat.

    " Description of Message Types
    SELECT * FROM edimsgt
      WHERE mestyp in ( 'ORDERS' , 'DESADV' )
        AND langua = 'E'
       INTO TABLE @DATA(lt_msgtyp_desc) .

    " Description of basic types
    SELECT * FROM edbast
      FOR ALL ENTRIES IN @lt_edidc
      WHERE idoctyp = @lt_edidc-idoctp
        AND langua = 'E'
     INTO TABLE @DATA(lt_basic_desc).

    LOOP AT lt_edidc INTO DATA(ls_edidc1).

      " Begin of  Taking the status description of IDOC number

      CALL FUNCTION 'IDOC_GET_MESSAGE_ATTRIBUTE'
        EXPORTING
          idoc_number  = ls_edidc1-docnum
        IMPORTING
          idoc_message = lv_idoc_msg.


      ls_idoc_msg-docnum = ls_edidc1-docnum.
      ls_idoc_msg-message = lv_idoc_msg.
      APPEND ls_idoc_msg TO lt_idoc_msg.
      " End of  Taking the status description of IDOC number

      " Begin of Taking the EDIDS and EDID4 Data of IDOC Number
      CALL FUNCTION 'IDOC_READ_COMPLETELY'
        EXPORTING
          document_number = ls_edidc1-docnum
        TABLES
          int_edidd       = lt_edid4_temp
          int_edids       = lt_edids_temp.
      IF lt_edid4_temp IS NOT INITIAL.
        APPEND LINES OF lt_edid4_temp TO lt_edid4.
      ENDIF.
      IF lt_edids_temp IS NOT INITIAL.
        APPEND LINES OF lt_edids_temp TO lt_edids.
      ENDIF.
      " End of Taking the EDIDS and EDID4 Data of IDOC Number

      CLEAR : ls_edidc1,lt_edid4_temp,lt_edids_temp.
    ENDLOOP.

    ""Customer Name - lt_edidc
    IF lt_edid4 IS NOT INITIAL.
      " E1EDKA1 - Document Header Partner Information
      LOOP AT  lt_edid4 INTO DATA(ls_edid4) WHERE segnam = 'E1EDKA1'.
        ls_e1edka1 = ls_edid4-sdata.
        ls_customer-kunnr = |{ ls_e1edka1-partn ALPHA = IN }|.
        APPEND ls_customer TO lt_customer.
        CLEAR : ls_customer.
      ENDLOOP.
    ENDIF.

    IF lt_customer IS NOT INITIAL.
      SELECT kunnr,
             name1
        FROM kna1
        FOR ALL ENTRIES IN @lt_customer
        WHERE kunnr = @lt_customer-kunnr
                INTO TABLE @DATA(lt_kna1).
    ENDIF.

    ""TODO: wf_status - from BPA
    ""TODO: invoice no - for orders null - Applicable for Invoice msg type

    lt_data = VALUE #(
                  FOR ls_edidc IN lt_edidc
                      " Partner number from segment data - SDATA
                  LET ls_cust = COND e1edka1( WHEN line_exists( lt_edid4[ docnum = ls_edidc-docnum segnam = 'E1EDKA1' ] )
                                              THEN lt_edid4[ docnum = ls_edidc-docnum segnam = 'E1EDKA1' ]-sdata
                                      )
                      " PO Number from segment data - SDATA
                      ls_po = COND e1edk02( WHEN line_exists( lt_edid4[ docnum = ls_edidc-docnum segnam = 'E1EDK02' ] )
                                              THEN lt_edid4[ docnum = ls_edidc-docnum segnam = 'E1EDK02' ]-sdata
                                      )
                  IN
                  (
                      idoc_number = |{ ls_edidc-docnum ALPHA = OUT }|
                      customer_name = COND #( WHEN line_exists( lt_kna1[ kunnr = CONV kunnr( |{ ls_cust-partn ALPHA = IN }| ) ] )
                                                  THEN lt_kna1[ kunnr = CONV kunnr( |{ ls_cust-partn ALPHA = IN }| ) ]-name1
                                             )

                      idoc_status = COND #( WHEN line_exists( lt_brf_status[ status_codes = ls_edidc-status ] )
                                             THEN lt_brf_status[ status_codes = ls_edidc-status ]-status_type
                                            ELSE 'status code not monitored'
                                    )
                      po_number = ls_po-belnr
                      creation_date = ls_edidc-credat
                      description = COND #( WHEN line_exists( lt_idoc_msg[ docnum = ls_edidc-docnum ] )
                                                 THEN lt_idoc_msg[ docnum = ls_edidc-docnum ]-message
                                           )
                      " TODO: Need to include the custom status message from BRF+ table based on status code
*                    wf_status = ls_edidc-wf_status
                      invoice_number = ''
                      message_type = ls_edidc-mestyp
                      msgtyp_desc = COND #( WHEN line_exists( lt_msgtyp_desc[ mestyp = ls_edidc-mestyp ] )
                                               THEN lt_msgtyp_desc[ mestyp = ls_edidc-mestyp ]-descrp
                                     )
                      basic_type = ls_edidc-idoctp
                      bsctyp_desc = COND #( WHEN line_exists( lt_basic_desc[ idoctyp = ls_edidc-idoctp ] )
                                               THEN lt_basic_desc[ idoctyp = ls_edidc-idoctp ]-descrp
                                     )
                  )
              ).



  ENDIF.

  MOVE-CORRESPONDING lt_data TO ET_idoc_list[].

  IF sy-subrc <> 0.

    ls_return-id = '01'.
    ls_return-message = 'E'.
    ls_return-message_v1 = 'IDOC DETAILS NOT FOUND'.

    MOVE-CORRESPONDING ls_return TO return.
    CLEAR ls_return.

  ENDIF.


ENDFUNCTION.
