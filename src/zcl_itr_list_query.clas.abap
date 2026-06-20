CLASS zcl_itr_list_query DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
private section.

  types:
    BEGIN OF ty_customer,
              kunnr TYPE kunnr,
            END OF ty_customer .
  types:
    BEGIN OF ty_idoc_msg,
              docnum      TYPE edi_docnum,
              status_code TYPE edids-status,
              message     TYPE idoc_msg,
            END OF ty_idoc_msg .

  data LT_FILTER_RESULT type ZTT_IDOC_FILTER_VALUES .
  data:
    lt_data       TYPE TABLE OF ztest_idoc .
  data:
    lt_idoc_msg   TYPE TABLE OF ty_idoc_msg .
  data:
    lt_edid4      TYPE TABLE OF edidd .
  data:
    lt_edid4_temp TYPE TABLE OF edidd .
  data:
    lt_edids      TYPE TABLE OF edids .
  data:
    lt_edids_temp TYPE TABLE OF edids .
  data:
    lt_customer   TYPE TABLE OF ty_customer .
  data:
    lt_brf_msg    TYPE TABLE OF zst_idoc_msg_types .
  data:
    lt_brf_status TYPE TABLE OF zst_idoc_mestyp .
  data LS_CUSTOMER type TY_CUSTOMER .
  data LS_E1EDKA1 type E1EDKA1 .
  data LS_IDOC_MSG type TY_IDOC_MSG .
  data LV_IDOC_MSG type IDOC_MSG .
  data LS_DATA type ZTEST_IDOC .
  constants LV_MSG_TYP_ALL type STRING value 'ZMSG_TYPE' ##NO_TEXT.
  constants LV_STATUS_ALL type STRING value 'MON_STATUSES' ##NO_TEXT.
  data LT_STATUS_CUSTOM type ZTT_IDOC_STATUS_DESC .
ENDCLASS.



CLASS ZCL_ITR_LIST_QUERY IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    IF io_request->is_data_requested(  ).

********************************************************************** Pagination
      DATA(lv_offset) = io_request->get_paging( )->get_offset( ).
      DATA(lv_page_size) = io_request->get_paging( )->get_page_size( ).
      DATA(lv_max_rows) = COND #( WHEN lv_page_size = if_rap_query_paging=>page_size_unlimited THEN 0
                                  ELSE lv_page_size ).

********************************************************************** Filter
      TRY.
          DATA(lt_ranges) = io_request->get_filter( )->get_as_ranges( ).
          ""filter manipulation

          " Look for IDOC_NUMBER filter
          DATA(lt_idoc_no) = COND #( WHEN line_exists( lt_ranges[ name = 'IDOC_NUMBER' ] )
                                      THEN lt_ranges[ name = 'IDOC_NUMBER' ]-range
                            ).

          " Look for CREATION_DATE filter
          DATA(lt_credat) = COND #( WHEN line_exists( lt_ranges[ name = 'CREATION_DATE' ] )
                                      THEN lt_ranges[ name = 'CREATION_DATE' ]-range
                            ).

          " Look for MESSAGE_TYPE field filter
          DATA(lt_msg_typ) = COND #( WHEN line_exists( lt_ranges[ name = 'MESSAGE_TYPE' ] )
                                        THEN lt_ranges[ name = 'MESSAGE_TYPE' ]-range
                              ).

          " Look for BASIC_TYPE field filter
          DATA(lt_basic_typ) = COND #( WHEN line_exists( lt_ranges[ name = 'BASIC_TYPE' ] )
                                        THEN lt_ranges[ name = 'BASIC_TYPE' ]-range
                              ).

          " Look for IDOC_STATUS field filter
          DATA(lt_idoc_sts) = COND #( WHEN line_exists( lt_ranges[ name = 'IDOC_STATUS' ] )
                                        THEN lt_ranges[ name = 'IDOC_STATUS' ]-range
                              ).

          " TODO: data to be filtered at the end based on custom table.
          " Look for WF_STATUS field filter
          DATA(lt_wf_sts) = COND #( WHEN line_exists( lt_ranges[ name = 'WF_STATUS' ] )
                                        THEN lt_ranges[ name = 'WF_STATUS' ]-range
                              ).

          " Look for PO_NUMBER field filter
          DATA(lt_po_number) = COND #( WHEN line_exists( lt_ranges[ name = 'PO_NUMBER' ] )
                                        THEN lt_ranges[ name = 'PO_NUMBER' ]-range
                              ).

          " Look for WF_STATUS field filter
          DATA(lt_cust_name) = COND #( WHEN line_exists( lt_ranges[ name = 'CUSTOMER_NAME' ] )
                                        THEN lt_ranges[ name = 'CUSTOMER_NAME' ]-range
                              ).

        CATCH cx_rap_query_filter_no_range INTO DATA(ex_ranges).
          ""error handling
      ENDTRY.

      IF lt_msg_typ IS INITIAL.
        " Fetch the Message types i.e under monitoring from BRF+ configuration
        CALL FUNCTION 'ZFM_GET_MSG_TYPES'
          EXPORTING
            iv_input  = lv_msg_typ_all
          IMPORTING
            et_result = lt_brf_msg.

        lt_msg_typ = VALUE #(
                        FOR ls_brf_msg IN lt_brf_msg
                        LET s = 'I' o = 'EQ' h = ''
                        IN
                        ( sign = s option = o low = ls_brf_msg-msg_type high = h )
                     ).
      ENDIF.

      " Fetch the Status code i.e under monitoring from BRF+ configuration
      CALL FUNCTION 'ZFM_GET_ALL_STATUSES'
        EXPORTING
          la_zvar_name_idoc = lv_status_all
        IMPORTING
          et_result         = lt_brf_status.

      IF sy-subrc = 0 AND lt_idoc_sts IS INITIAL.
        " Include all the status codes
        lt_idoc_sts = VALUE #(
                           FOR ls_brf_status IN lt_brf_status
                           LET s = 'I' o = 'EQ' h = ''
                           IN
                           ( sign = s option = o low = ls_brf_status-status_codes high = h )
                      ).
      ELSEIF sy-subrc = 0 AND lt_idoc_sts IS NOT INITIAL.
        " Include only the requested status codes
        DATA(lt_flt_sts) = lt_idoc_sts.
        lt_idoc_sts = VALUE #(
                           FOR ls_flt_sts IN lt_flt_sts
                               FOR ls_brf_status IN lt_brf_status WHERE ( status_type = ls_flt_sts-low )
                               LET s = 'I' o = 'EQ' h = ''
                               IN
                               ( sign = s option = o low = ls_brf_status-status_codes high = h )
                      ).
      ENDIF.

      IF lt_credat IS INITIAL.
        " Logic to include the dates for 30 days back from the current date
        DATA(lv_from) = sy-datum.
        lv_from = lv_from - 30.
        APPEND VALUE #( sign = 'I' option = 'BT'
                        low = lv_from high = sy-datum )
               TO lt_credat.
      ENDIF.

      SELECT *
        FROM ztitr_wf_bpa_log
        WHERE ( idoc_number, sequence ) IN ( SELECT idoc_number, MAX( sequence )
                                           FROM ztitr_wf_bpa_log
                                           WHERE idoc_number IN @lt_idoc_no
                                           GROUP BY idoc_number ) INTO TABLE @DATA(lt_wf_status).

********************************************************************** Business Logic

      SELECT
             a~docnum,
             a~status,
             a~direct,
             a~credat,
             a~cretim,
             a~mestyp,
             a~idoctp,
             a~maxsegnum,
             wf~status AS wf_status
      FROM edidc AS a LEFT OUTER JOIN @lt_wf_status AS wf
      ON a~docnum = wf~idoc_number
      WHERE a~mestyp IN @lt_msg_typ AND
      a~status IN @lt_idoc_sts AND
      a~credat IN @lt_credat AND
      a~idoctp IN @lt_basic_typ AND
      a~docnum IN @lt_idoc_no AND
      wf~status IN @lt_wf_sts
      ORDER BY ( 'primary key' ) ASCENDING
      INTO TABLE @DATA(lt_edidc)
      OFFSET @lv_offset UP TO @lv_max_rows ROWS.
      IF sy-subrc = 0.

        SORT lt_edidc ASCENDING BY docnum idoctp credat.

        CALL FUNCTION 'ZFM_GET_FILTER_VALUES'
          IMPORTING
            et_result = lt_filter_result.

        DELETE lt_filter_result WHERE filter_id NE 'ZF_IDOC_TYPE'.


        " Description of Message Types
        SELECT * FROM edimsgt
          INTO TABLE @DATA(lt_msgtyp_desc)
          WHERE mestyp IN @lt_msg_typ
            AND langua = 'E'
          .

        " Description of basic types
        SELECT * FROM edbast
          INTO TABLE @DATA(lt_basic_desc)
          FOR ALL ENTRIES IN @lt_edidc
          WHERE idoctyp = @lt_edidc-idoctp
            AND langua = 'E'.

        CALL FUNCTION 'ZFM_GET_STATUS_DESCRIPTION'
          IMPORTING
            et_result = lt_status_custom.

        SELECT docnum,countr,stamid,stamno,credat,cretim FROM edids INTO TABLE @DATA(lt_edids)
           FOR ALL ENTRIES IN @lt_edidc WHERE docnum = @lt_edidc-docnum.

        SORT lt_edids BY docnum countr DESCENDING.
        DELETE ADJACENT DUPLICATES FROM lt_edids COMPARING docnum.

        LOOP AT lt_edidc INTO DATA(ls_edidc1).

          " Begin of  Taking the status description of IDOC number
          CALL FUNCTION 'IDOC_GET_MESSAGE_ATTRIBUTE'
            EXPORTING
              idoc_number  = ls_edidc1-docnum
            IMPORTING
              idoc_message = lv_idoc_msg.

          ls_idoc_msg-docnum = ls_edidc1-docnum.
          ls_idoc_msg-status_code = ls_edidc1-status.

          READ TABLE lt_edids INTO DATA(ls_edids) WITH KEY docnum = ls_edidc1-docnum.
          IF sy-subrc = 0.
            READ TABLE lt_status_custom INTO DATA(ls_status_custom) WITH KEY stamid = ls_edids-stamid stamno = ls_edids-stamno.
            IF sy-subrc = 0.
              ls_idoc_msg-message = ls_status_custom-status_des.
            ELSE.
              ls_idoc_msg-message = lv_idoc_msg.
            ENDIF.
          ELSE.
            ls_idoc_msg-message = lv_idoc_msg.
          ENDIF.
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

          CLEAR : ls_edidc1.
        ENDLOOP.

        READ TABLE lt_msg_typ INTO DATA(ls_msg_typ) INDEX 1.
        IF sy-subrc = 0.
          DATA(lv_msg_typ) = ls_msg_typ-low.
        ENDIF.

        IF lv_msg_typ = 'ORDERS'.
          ""Customer Name - lt_edidc
          IF lt_edid4 IS NOT INITIAL.
            " E1EDKA1 - Document Header Partner Information
            LOOP AT  lt_edid4 INTO DATA(ls_edid4) WHERE segnam = 'E1EDKA1'.
              ls_e1edka1 = ls_edid4-sdata.
              IF ls_e1edka1-parvw = 'AG'.
                ls_customer-kunnr = |{ ls_e1edka1-partn ALPHA = IN }|.
                APPEND ls_customer TO lt_customer.
                CLEAR : ls_customer.
              ELSE.
                DATA(l1) = sy-tabix.
                DELETE lt_edid4 INDEX l1.
              ENDIF.
            ENDLOOP.
          ENDIF.

        ELSEIF lv_msg_typ = 'DESADV'.
          ""Customer Name - lt_edidc
          IF lt_edid4 IS NOT INITIAL.
            " E1EDKA1 - Document Header Partner Information
            LOOP AT  lt_edid4 INTO ls_edid4 WHERE segnam = 'E1ADRM1'.
              ls_e1edka1 = ls_edid4-sdata.
              ls_customer-kunnr = |{ ls_e1edka1-partn ALPHA = IN }|.
              APPEND ls_customer TO lt_customer.
              CLEAR : ls_customer.
            ENDLOOP.
          ENDIF.

        ELSEIF lv_msg_typ = 'INVOIC'.
          IF lt_edid4 IS NOT INITIAL.
            " E1EDKA1 - Document Header Partner Information
            LOOP AT  lt_edid4 INTO ls_edid4 WHERE segnam = 'E1EDKA1'.
              ls_e1edka1 = ls_edid4-sdata.
              IF ls_e1edka1-parvw = 'RG'.
                ls_customer-kunnr = |{ ls_e1edka1-partn ALPHA = IN }|.
                APPEND ls_customer TO lt_customer.
                CLEAR : ls_customer.
              ELSE.
                l1 = sy-tabix.
                DELETE lt_edid4 INDEX l1.
              ENDIF.
            ENDLOOP.
          ENDIF.

        ENDIF.

        IF lt_customer IS NOT INITIAL.
          SELECT kunnr,
                 name1
            FROM kna1
            INTO TABLE @DATA(lt_kna1)
            FOR ALL ENTRIES IN @lt_customer
            WHERE kunnr = @lt_customer-kunnr.
        ENDIF.


        ""TODO: wf_status - from BPA
        ""TODO: invoice no - for orders null - Applicable for Invoice msg type

        IF lv_msg_typ = 'ORDERS'.
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
                            " Shipping from segment data - SDATA
                            ls_ship = COND e1edl20( WHEN line_exists( lt_edid4[ docnum = ls_edidc-docnum segnam = 'E1EDL20' ] )
                                                    THEN lt_edid4[ docnum = ls_edidc-docnum segnam = 'E1EDL20' ]-sdata
                                            )

                                                      " Shipping from segment data - SDATA
                            ls_del_date = COND e1edt13( WHEN line_exists( lt_edid4[ docnum = ls_edidc-docnum segnam = 'E1EDT13' ] )
                                                    THEN lt_edid4[ docnum = ls_edidc-docnum segnam = 'E1EDT13' ]-sdata
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
                            wf_status = ls_edidc-wf_status
                            invoice_number = ''
                            message_type = ls_edidc-mestyp
                            msgtyp_desc = COND #( WHEN line_exists( lt_filter_result[ filter_value = ls_edidc-mestyp ] )
                                                     THEN lt_filter_result[ filter_value = ls_edidc-mestyp ]-filter_description
                                           )
                            basic_type = ls_edidc-idoctp
                            bsctyp_desc = COND #( WHEN line_exists( lt_filter_result[ filter_value = ls_edidc-mestyp ] )
                                                     THEN lt_filter_result[ filter_value = ls_edidc-mestyp ]-filter_description
                                           )
                            shipping = ls_ship-vstel
                            delivery_date = ls_del_date-ntanf
                        )
                    ).

        ELSEIF lv_msg_typ = 'DESADV'.
          lt_data = VALUE #(
              FOR ls_edidc IN lt_edidc
                  " Partner number from segment data - SDATA
              LET ls_cust = COND e1edka1( WHEN line_exists( lt_edid4[ docnum = ls_edidc-docnum segnam = 'E1ADRM1' ] )
                                          THEN lt_edid4[ docnum = ls_edidc-docnum segnam = 'E1ADRM1' ]-sdata
                                  )
                  " PO Number from segment data - SDATA
                  ls_po = COND e1edk02( WHEN line_exists( lt_edid4[ docnum = ls_edidc-docnum segnam = 'E1EDK02' ] )
                                          THEN lt_edid4[ docnum = ls_edidc-docnum segnam = 'E1EDK02' ]-sdata
                                  )
                  " Shipping from segment data - SDATA
                  ls_ship = COND e1edl20( WHEN line_exists( lt_edid4[ docnum = ls_edidc-docnum segnam = 'E1EDL20' ] )
                                          THEN lt_edid4[ docnum = ls_edidc-docnum segnam = 'E1EDL20' ]-sdata
                                  )

                                            " Shipping from segment data - SDATA
                  ls_del_date = COND e1edt13( WHEN line_exists( lt_edid4[ docnum = ls_edidc-docnum segnam = 'E1EDT13' ] )
                                          THEN lt_edid4[ docnum = ls_edidc-docnum segnam = 'E1EDT13' ]-sdata
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
                  bol_number = ls_ship-bolnr
                  creation_date = ls_edidc-credat
                  description = COND #( WHEN line_exists( lt_idoc_msg[ docnum = ls_edidc-docnum ] )
                                             THEN lt_idoc_msg[ docnum = ls_edidc-docnum ]-message
                                       )
                  " TODO: Need to include the custom status message from BRF+ table based on status code
                  wf_status = ls_edidc-wf_status
                  invoice_number = ''
                  message_type = ls_edidc-mestyp
                  msgtyp_desc = COND #( WHEN line_exists( lt_filter_result[ filter_value = ls_edidc-mestyp ] )
                                                     THEN lt_filter_result[ filter_value = ls_edidc-mestyp ]-filter_description
                                           )
                  basic_type = ls_edidc-idoctp
                            bsctyp_desc = COND #( WHEN line_exists( lt_filter_result[ filter_value = ls_edidc-mestyp ] )
                                                     THEN lt_filter_result[ filter_value = ls_edidc-mestyp ]-filter_description
                                           )
                  shipping = ls_ship-vstel
                  delivery_date = ls_del_date-ntanf
              )
          ).
        ELSEIF lv_msg_typ = 'INVOIC'.
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
                            " Shipping from segment data - SDATA
                            ls_ship = COND e1edl20( WHEN line_exists( lt_edid4[ docnum = ls_edidc-docnum segnam = 'E1EDL20' ] )
                                                    THEN lt_edid4[ docnum = ls_edidc-docnum segnam = 'E1EDL20' ]-sdata
                                            )

                                                      " Shipping from segment data - SDATA
                            ls_del_date = COND e1edt13( WHEN line_exists( lt_edid4[ docnum = ls_edidc-docnum segnam = 'E1EDT13' ] )
                                                    THEN lt_edid4[ docnum = ls_edidc-docnum segnam = 'E1EDT13' ]-sdata
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
                            wf_status = ls_edidc-wf_status
                            invoice_number = ''
                            message_type = ls_edidc-mestyp
                            msgtyp_desc = COND #( WHEN line_exists( lt_filter_result[ filter_value = ls_edidc-mestyp ] )
                                                     THEN lt_filter_result[ filter_value = ls_edidc-mestyp ]-filter_description
                                           )
                            basic_type = ls_edidc-idoctp
                            bsctyp_desc = COND #( WHEN line_exists( lt_filter_result[ filter_value = ls_edidc-mestyp ] )
                                                     THEN lt_filter_result[ filter_value = ls_edidc-mestyp ]-filter_description
                                           )
                            shipping = ls_ship-vstel
                            delivery_date = ls_del_date-ntanf
                        )
                    ).

        ENDIF.

        READ TABLE lt_po_number INTO DATA(ls_po_number) INDEX 1.
        IF sy-subrc = 0 AND ls_po_number-low IS NOT INITIAL.
          DATA: lt_data1 LIKE lt_data.

          LOOP AT lt_data INTO ls_data WHERE po_number = ls_po_number-low.
            DATA(ls_data1) = ls_data.
            APPEND ls_data1 TO lt_data1.
          ENDLOOP.

          io_response->set_data( lt_data1 ).

          ""Set Total Number of records in lt_data container
          IF io_request->is_total_numb_of_rec_requested( ).
            io_response->set_total_number_of_records( lines( lt_data1 ) ).
          ENDIF.
        ELSE.
          io_response->set_data( lt_data ).

          ""Set Total Number of records in lt_data container
          IF io_request->is_total_numb_of_rec_requested( ).
            io_response->set_total_number_of_records( lines( lt_data ) ).
          ENDIF.
        ENDIF.




      ELSE.

        io_response->set_data( lt_data ).

        ""Set Total Number of records in lt_data container
        IF io_request->is_total_numb_of_rec_requested( ).
          io_response->set_total_number_of_records( lines( lt_data ) ).
        ENDIF.

      ENDIF.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
