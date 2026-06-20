CLASS zcl_detail_idoc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
PRIVATE SECTION.

  TYPES:
    ""DATA DECLARATION
    BEGIN OF ty_header,
      idoc_number    TYPE edi_docnum,
      net_value      TYPE string,
      uom            TYPE string,
      status         TYPE string,
      sold_to        TYPE string,
      purchase_order TYPE string,
      sales_org      TYPE string,
      wf_status      TYPE string,
      po_date        TYPE string,
    END OF ty_header .
  TYPES:
    BEGIN OF ty_material,
      matnr TYPE matnr,
    END OF ty_material .
  TYPES:
    BEGIN OF ty_matnr,
      matnr TYPE matnr,
      maktx TYPE maktx,
    END OF ty_matnr .
  TYPES:
    BEGIN OF ty_customer,
      kunnr TYPE kunnr,
    END OF ty_customer .
  TYPES:
    BEGIN OF ty_kna1,
      kunnr TYPE kunnr,
      name1 TYPE name1,
    END OF ty_kna1 .
  TYPES:
    BEGIN OF ty_idoc_poc,
      idoc_number TYPE edi_docnum,
      status      TYPE c LENGTH 100,
      status_type TYPE c LENGTH 1,
    END OF ty_idoc_poc .

  DATA ls_e1adrm1 TYPE e1adrm1 .
  DATA:
    lt_data            TYPE TABLE OF zi_idoc_header .
  DATA:
    lt_item_data       TYPE TABLE OF zi_idoc_item .
  DATA:
    lt_header          TYPE TABLE OF ty_header .
  DATA:
    lt_edid4           TYPE TABLE OF edidd .
  DATA ls_edid4 TYPE edidd .
  DATA:
    lt_edids           TYPE TABLE OF edids .
  DATA:
    lt_e1edp01         TYPE TABLE OF e1edp01 .
  DATA ls_e1edp01 TYPE e1edp01 .
  DATA:
    lt_e1edk14         TYPE TABLE OF e1edk14 .
  DATA ls_e1edk14 TYPE e1edk14 .
  DATA:
    lt_e1edk03         TYPE TABLE OF e1edk03 .
  DATA ls_e1edk03 TYPE e1edk03 .
  DATA:
    lt_e1edp19         TYPE TABLE OF e1edp19 .
  DATA ls_e1edp19 TYPE e1edp19 .
  DATA ls_e1edp19_temp TYPE e1edp19 .
  DATA:
    lt_material        TYPE  TABLE OF ty_material .
  DATA ls_material TYPE ty_material .
  DATA:
    lt_matnr_desc      TYPE TABLE OF ty_matnr .
  DATA ls_matnr_desc TYPE ty_matnr .
  DATA:
    lt_customer        TYPE  TABLE OF ty_customer .
  DATA ls_customer TYPE ty_customer .
  DATA:
    lt_kna1            TYPE TABLE OF ty_kna1 .
  DATA ls_kna1 TYPE ty_kna1 .
  DATA ls_e1edka1 TYPE e1edka1 .
  DATA lv_sql_filter TYPE string .
  DATA lv_filter_data TYPE edi_docnum .
  DATA:
    lt_parts           TYPE TABLE OF string .
  DATA:
    lt_brf_status      TYPE TABLE OF zst_idoc_mestyp .
  DATA lv_part TYPE string .
  DATA lv_idoc_poc TYPE ty_idoc_poc .
  DATA:
    it_IDOC_POC        TYPE TABLE OF ty_idoc_poc .
  DATA ls_idoc_processing TYPE ty_idoc_poc .
  DATA ls_idoc_detail TYPE zi_idoc_mass_edit_details .
  DATA:
    lt_idoc_detail     TYPE TABLE OF zi_idoc_mass_edit_details .
  DATA:
    lt_segments        TYPE TABLE OF edi_iapi11 .
  DATA ls_segments TYPE edi_iapi11 .
  DATA:
    lt_fields          TYPE TABLE OF edi_iapi12 .
  DATA ls_fields TYPE edi_iapi12 .
  DATA:
    lt_field_value     TYPE TABLE OF edi_iapi14 .
  DATA ls_field_value TYPE edi_iapi14 .
  DATA lv_msg_type TYPE edi_iapi00-idoctyp .
  CONSTANTS lv_msg_typ_all TYPE string VALUE 'ZMSG_TYPE' ##NO_TEXT.
  CONSTANTS lv_status_all TYPE string VALUE 'MON_STATUSES' ##NO_TEXT.
  DATA ls_e1edl20 TYPE e1edl20 .
  DATA:
    lt_e1edl20 TYPE TABLE OF e1edl20 .
  DATA ls_e1edl24 TYPE e1edl24 .
  DATA:
    lt_e1edl24 TYPE TABLE OF e1edl24 .
  DATA ls_e1edl43 TYPE e1edl43 .
  DATA:
    lt_e1edl43 TYPE TABLE OF e1edl43 .
  DATA ls_e1edk02 TYPE e1edk02 .
  DATA:
    lt_e1edk02 TYPE TABLE OF e1edk02 .
  DATA ls_e1edp02 TYPE e1edp02 .
  DATA:
    lt_e1edp02 TYPE TABLE OF e1edp02 .
  DATA ls_e1edp26 TYPE e1edp26 .
  DATA lt_e1edp26 TYPE TABLE OF e1edp26.
ENDCLASS.



CLASS ZCL_DETAIL_IDOC IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    CASE io_request->get_entity_id( ).

      WHEN 'ZI_IDOC_HEADER'.

        IF io_request->is_data_requested(  ).

          ""PAGING

          DATA(lv_offset) = io_request->get_paging( )->get_offset( ).
          DATA(lv_page_size) = io_request->get_paging( )->get_page_size( ).
          DATA(lv_max_rows) = COND #( WHEN lv_page_size = if_rap_query_paging=>page_size_unlimited THEN 0
                                      ELSE lv_page_size ).

          ""FILTER
          lv_sql_filter = io_request->get_filter( )->get_as_sql_string( ).

          " Fetch the Status code i.e under monitoring from BRF+ configuration
          CALL FUNCTION 'ZFM_GET_ALL_STATUSES'
            EXPORTING
              la_zvar_name_idoc = lv_status_all
            IMPORTING
              et_result         = lt_brf_status.

          " Ensure filter string is not empty to prevent unintended queries
          IF lv_sql_filter IS INITIAL.
            RETURN.
          ENDIF.

          " Assuming the filter query is in the format ?$filter=IDOC_NUMBER eq '1100022000'
          IF lv_sql_filter IS NOT INITIAL.
            SPLIT lv_sql_filter AT `IDOC_NUMBER = '` INTO TABLE lt_parts.
            READ TABLE lt_parts INDEX 2 INTO lv_part.
            IF sy-subrc = 0.
              SPLIT lv_part AT `'` INTO lv_filter_data lv_part.
            ENDIF.
          ENDIF.

          IF lv_filter_data IS NOT INITIAL.
            DATA: ls_edidc TYPE edidc.

            ""LOGIC
            CALL FUNCTION 'IDOC_READ_COMPLETELY'
              EXPORTING
                document_number = lv_filter_data
              IMPORTING
                idoc_control    = ls_edidc
              TABLES
                int_edidd       = lt_edid4
                int_edids       = lt_edids.

          ENDIF.


          SORT lt_edids DESCENDING BY countr.
          SORT lt_edid4 ASCENDING BY segnum.

          IF ls_edidc-mestyp = 'ORDERS'.

            LOOP AT lt_edid4 INTO ls_edid4 WHERE docnum = lv_filter_data.

              IF ls_edid4-segnam = 'E1EDP01' AND ls_edid4 IS NOT INITIAL.

                ls_e1edp01 = ls_edid4-sdata.
                ls_material-matnr = ls_e1edp01-matnr.

                APPEND ls_material TO lt_material.
                APPEND ls_e1edp01 TO lt_e1edp01.
                CLEAR : ls_material, ls_e1edp01, ls_edid4.

              ELSEIF ls_edid4-segnam = 'E1EDK03' AND ls_edid4 IS NOT INITIAL.

                ls_e1edk03 = ls_edid4-sdata.

                APPEND ls_e1edk03 TO lt_e1edk03.
                CLEAR : ls_e1edk03,ls_edid4.

              ELSEIF ls_edid4-segnam = 'E1EDKA1' AND ls_edid4 IS NOT INITIAL.

                ls_e1edka1 = ls_edid4-sdata.
                ls_customer-kunnr = |{ ls_e1edka1-partn ALPHA = IN }|.
                APPEND ls_customer TO lt_customer.
                CLEAR : ls_customer, ls_edid4.

              ELSEIF ls_edid4-segnam = 'E1EDK14' AND ls_edid4 IS NOT INITIAL.

                IF ls_edid4-sdata IS NOT INITIAL.
                  ls_e1edk14 = ls_edid4-sdata.
                  APPEND ls_e1edk14 TO lt_e1edk14.
                  CLEAR: ls_e1edk14, ls_edid4.
                ENDIF.

              ENDIF.

            ENDLOOP.
*************************************************
          ELSEIF ls_edidc-mestyp = 'DESADV'.
            LOOP AT lt_edid4 INTO ls_edid4 WHERE docnum = lv_filter_data.

              IF ls_edid4-segnam = 'E1EDL20' AND ls_edid4 IS NOT INITIAL.

                ls_e1edl20 = ls_edid4-sdata.
*                ls_material-matnr = ls_e1edl20-matnr.

                APPEND ls_material TO lt_material.
                APPEND ls_e1edl20 TO lt_e1edl20.
                CLEAR : ls_material, ls_e1edl20, ls_edid4.

*              ELSEIF ls_edid4-segnam = 'E1EDL24' AND ls_edid4 IS NOT INITIAL.
*
*                ls_E1EDL24 = ls_edid4-sdata.
*
*                APPEND ls_e1edk03 TO lt_E1EDL24.
*                CLEAR : ls_E1EDL24,ls_edid4.

              ELSEIF ls_edid4-segnam = 'E1ADRM1' AND ls_edid4 IS NOT INITIAL.

                ls_e1adrm1 = ls_edid4-sdata.
                ls_customer-kunnr = |{ ls_e1adrm1-partner_id ALPHA = IN }|.
                APPEND ls_customer TO lt_customer.
                CLEAR : ls_customer, ls_edid4.

              ELSEIF ls_edid4-segnam = 'E1EDK14' AND ls_edid4 IS NOT INITIAL.

                IF ls_edid4-sdata IS NOT INITIAL.
                  ls_e1edk14 = ls_edid4-sdata.
                  APPEND ls_e1edk14 TO lt_e1edk14.
                  CLEAR: ls_e1edk14, ls_edid4.
                ENDIF.

              ENDIF.

            ENDLOOP.
          ELSEIF ls_edidc-mestyp = 'INVOIC'.
            LOOP AT lt_edid4 INTO ls_edid4 WHERE docnum = lv_filter_data.

              IF ls_edid4-segnam = 'E1EDP01' AND ls_edid4 IS NOT INITIAL.

                ls_e1edp01 = ls_edid4-sdata.
                ls_material-matnr = ls_e1edp01-matnr.

                APPEND ls_material TO lt_material.
                APPEND ls_e1edp01 TO lt_e1edp01.
                CLEAR : ls_material, ls_e1edp01, ls_edid4.

              ELSEIF ls_edid4-segnam = 'E1EDK02' AND ls_edid4 IS NOT INITIAL.

                ls_e1edk02 = ls_edid4-sdata.

                APPEND ls_e1edk02 TO lt_e1edk02.
                CLEAR : ls_e1edk02,ls_edid4.

              ELSEIF ls_edid4-segnam = 'E1EDKA1' AND ls_edid4 IS NOT INITIAL.

                LOOP AT  lt_edid4 INTO ls_edid4 WHERE segnam = 'E1EDKA1'.
                  ls_e1edka1 = ls_edid4-sdata.
                  IF ls_e1edka1-parvw = 'RG'.
                    ls_customer-kunnr = |{ ls_e1edka1-partn ALPHA = IN }|.
                    APPEND ls_customer TO lt_customer.
                    CLEAR : ls_customer.
                  ELSE.
                    DATA(l1) = sy-tabix.
                    DELETE lt_edid4 INDEX l1.
                  ENDIF.
                ENDLOOP.

              ELSEIF ls_edid4-segnam = 'E1EDK14' AND ls_edid4 IS NOT INITIAL.

                IF ls_edid4-sdata IS NOT INITIAL.
                  ls_e1edk14 = ls_edid4-sdata.
                  APPEND ls_e1edk14 TO lt_e1edk14.
                  CLEAR: ls_e1edk14, ls_edid4.
                ENDIF.

              ENDIF.

            ENDLOOP.

          ENDIF.

          IF lt_customer IS NOT INITIAL.
            SELECT kunnr,
                   name1
              FROM kna1
              INTO TABLE @lt_kna1
              FOR ALL ENTRIES IN @lt_customer
              WHERE kunnr = @lt_customer-kunnr.
          ENDIF.

          IF lv_filter_data IS NOT INITIAL.

            SELECT *
            FROM ztitr_wf_bpa_log
            WHERE ( idoc_number, sequence ) IN ( SELECT idoc_number, MAX( sequence )
                                               FROM ztitr_wf_bpa_log
                                               WHERE idoc_number = @lv_filter_data
                                               GROUP BY idoc_number ) INTO TABLE @DATA(lt_wf_status).

          ENDIF.

          IF ls_edidc-mestyp = 'ORDERS'.

            lt_data = VALUE #(
                         FOR lwa_e1edp01 IN lt_e1edp01

                          " Partner number from segment data - SDATA
                          LET ls_cust = COND e1edka1( WHEN line_exists( lt_edid4[ docnum = lv_filter_data segnam = 'E1EDKA1' ] )
                                                      THEN lt_edid4[ docnum = lv_filter_data segnam = 'E1EDKA1' ]-sdata
                                                  )

                              ls_po = COND e1edk02( WHEN line_exists( lt_edid4[ docnum = lv_filter_data segnam = 'E1EDK02' ] )
                                                      THEN lt_edid4[ docnum = lv_filter_data segnam = 'E1EDK02' ]-sdata
                                                )

                          IN
                          (
                              idoc_number = lv_filter_data  ""IDOC_NUMBER
                              net_value = lwa_e1edp01-netwr ""NET_VALUE
                              uom = lwa_e1edp01-menee ""UOM
                              status = COND #( WHEN line_exists( lt_brf_status[ status_codes = lt_edids[ 1 ]-status ] )
                                                   THEN lt_brf_status[ status_codes = lt_edids[ 1 ]-status ]-status_type
                                                  ELSE 'status code not monitored'
                                          )
                              sold_to = COND #( WHEN line_exists( lt_kna1[ kunnr = CONV kunnr( |{ ls_cust-partn ALPHA = IN }| ) ] )
                                                            THEN lt_kna1[ kunnr = CONV kunnr( |{ ls_cust-partn ALPHA = IN }| ) ]-name1
                                                            ELSE ' '
                                               ) ""SOLD_TO
                              purchase_order = ls_po-belnr ""PURCHASE_ORDER
                              message_type = ls_edidc-mestyp
                              sales_org = COND #( WHEN line_exists( lt_e1edk14[ qualf = '008' ] )
                                                      THEN lt_e1edk14[ qualf = '008' ]-orgid
                                                      ELSE ' '
                                              ) ""SALES_ORG
                              wf_status = COND #( WHEN lt_wf_status IS NOT INITIAL
                                                       THEN lt_wf_status[ 1 ]-status
                                                       ELSE ' '
                                                ) "BPA WF Status
                              po_date = COND #( WHEN line_exists( lt_e1edk03[ iddat = '003' ] )
                                                      THEN lt_e1edk03[ iddat = '003' ]-datum
                                                      ELSE ' '
                                              ) ""PO_DATE
                           )
                          ).
          ELSEIF ls_edidc-mestyp = 'DESADV'.
            lt_data = VALUE #(
             FOR lwa_e1edl20 IN lt_e1edl20

              " Partner number from segment data - SDATA
              LET ls_cust = COND e1edka1( WHEN line_exists( lt_edid4[ docnum = lv_filter_data segnam = 'E1ADRM1' ] )
                                          THEN lt_edid4[ docnum = lv_filter_data segnam = 'E1ADRM1' ]-sdata
                                      )

                  ls_po1 = COND e1edl24( WHEN line_exists( lt_edid4[ docnum = lv_filter_data segnam = 'E1EDL24' ] )
                                          THEN lt_edid4[ docnum = lv_filter_data segnam = 'E1EDL24' ]-sdata
                                    )

              IN
              (
                  idoc_number = lv_filter_data  ""IDOC_NUMBER
                  net_value = lwa_e1edl20-ntgew ""NET_VALUE
                  uom = ls_po1-vrkme ""UOM
                  status = COND #( WHEN line_exists( lt_brf_status[ status_codes = lt_edids[ 1 ]-status ] )
                                       THEN lt_brf_status[ status_codes = lt_edids[ 1 ]-status ]-status_type
                                      ELSE 'status code not monitored'
                              )
                  sold_to = COND #( WHEN line_exists( lt_kna1[ kunnr = CONV kunnr( |{ ls_cust-partn ALPHA = IN }| ) ] )
                                                            THEN lt_kna1[ kunnr = CONV kunnr( |{ ls_cust-partn ALPHA = IN }| ) ]-name1
                                                            ELSE ' '
                                               ) ""SOLD_TO
                  bol_number = lwa_e1edl20-bolnr ""PURCHASE_ORDER
                  message_type = ls_edidc-mestyp
                  sales_org = lwa_e1edl20-vkorg
                  wf_status = COND #( WHEN lt_wf_status IS NOT INITIAL
                                           THEN lt_wf_status[ 1 ]-status
                                           ELSE ' '
                                    ) "BPA WF Status
                  po_date = lwa_e1edl20-podat
               )
              ).

          ELSEIF ls_edidc-mestyp = 'INVOIC'.
            lt_data = VALUE #(
                         FOR lwa_e1edp01 IN lt_e1edp01

                          " Partner number from segment data - SDATA
                          LET ls_cust = COND e1edka1( WHEN line_exists( lt_edid4[ docnum = lv_filter_data segnam = 'E1EDKA1' ] )
                                                      THEN lt_edid4[ docnum = lv_filter_data segnam = 'E1EDKA1' ]-sdata
                                                  )

                              ls_po = COND e1edk02( WHEN line_exists( lt_edid4[ docnum = lv_filter_data segnam = 'E1EDK02' ] )
                                                      THEN lt_edid4[ docnum = lv_filter_data segnam = 'E1EDK02' ]-sdata
                                                )

                          IN
                          (
                              idoc_number = lv_filter_data  ""IDOC_NUMBER
                              net_value = lwa_e1edp01-ntgew ""NET_VALUE
                              uom = lwa_e1edp01-menee ""UOM
                              status = COND #( WHEN line_exists( lt_brf_status[ status_codes = lt_edids[ 1 ]-status ] )
                                                   THEN lt_brf_status[ status_codes = lt_edids[ 1 ]-status ]-status_type
                                                  ELSE 'status code not monitored'
                                          )
                              sold_to = COND #( WHEN line_exists( lt_kna1[ kunnr = CONV kunnr( |{ ls_cust-partn ALPHA = IN }| ) ] )
                                                            THEN lt_kna1[ kunnr = CONV kunnr( |{ ls_cust-partn ALPHA = IN }| ) ]-name1
                                                            ELSE ' '
                                               ) ""SOLD_TO
                              purchase_order = ls_po-belnr ""PURCHASE_ORDER
                              message_type = ls_edidc-mestyp
                              sales_org = COND #( WHEN line_exists( lt_e1edk14[ qualf = '008' ] )
                                                      THEN lt_e1edk14[ qualf = '008' ]-orgid
                                                      ELSE ' '
                                              ) ""SALES_ORG
                              wf_status = COND #( WHEN lt_wf_status IS NOT INITIAL
                                                       THEN lt_wf_status[ 1 ]-status
                                                       ELSE ' '
                                                ) "BPA WF Status
                              po_date = COND #( WHEN line_exists( lt_e1edk02[ qualf = '009' ] )
                                                      THEN lt_e1edk02[ qualf = '009' ]-datum
                                                      ELSE ' '
                                              ) ""PO_DATE
                           )
                          ).
          ENDIF.

          DELETE ADJACENT DUPLICATES FROM lt_data.
          io_response->set_data( lt_data ).

          ""Set Total Number of records in lt_data container
          IF io_request->is_total_numb_of_rec_requested( ).
            io_response->set_total_number_of_records( lines( lt_data ) ).
          ENDIF.

        ENDIF.

      WHEN 'ZI_IDOC_ITEM'.

        IF io_request->is_data_requested(  ).

          ""PAGING

          DATA(lv_offset1) = io_request->get_paging( )->get_offset( ).
          DATA(lv_page_size1) = io_request->get_paging( )->get_page_size( ).
          DATA(lv_max_rows1) = COND #( WHEN lv_page_size1 = if_rap_query_paging=>page_size_unlimited THEN 0
                                      ELSE lv_page_size1 ).

          ""FILTER
          lv_sql_filter = io_request->get_filter( )->get_as_sql_string( ).

          " Ensure filter string is not empty to prevent unintended queries
          IF lv_sql_filter IS INITIAL.
            RETURN.
          ENDIF.

          " Assuming the filter query is in the format ?$filter=IDOC_NUMBER eq '1100022000'
          IF lv_sql_filter IS NOT INITIAL.
            SPLIT lv_sql_filter AT `IDOC_NUMBER = '` INTO TABLE lt_parts.
            READ TABLE lt_parts INDEX 2 INTO lv_part.
            IF sy-subrc = 0.
              SPLIT lv_part AT `'` INTO lv_filter_data lv_part.
            ENDIF.
          ENDIF.

          ""LOGIC
          CALL FUNCTION 'IDOC_READ_COMPLETELY'
            EXPORTING
              document_number = lv_filter_data
            IMPORTING
              idoc_control    = ls_edidc
            TABLES
              int_edidd       = lt_edid4
              int_edids       = lt_edids.


          SORT lt_edids DESCENDING BY countr.
          SORT lt_edid4 ASCENDING BY segnum.

          IF ls_edidc-mestyp = 'ORDERS'.

            LOOP AT lt_edid4 INTO ls_edid4 WHERE docnum = lv_filter_data.

              IF ls_edid4-segnam = 'E1EDP01' AND ls_edid4 IS NOT INITIAL.

                ls_e1edp01 = ls_edid4-sdata.
                ls_material-matnr = ls_e1edp01-matnr.

                APPEND ls_material TO lt_material.
                APPEND ls_e1edp01 TO lt_e1edp01.
                CLEAR : ls_material, ls_e1edp01, ls_edid4.

              ELSEIF ls_edid4-segnam = 'E1EDK03' AND ls_edid4 IS NOT INITIAL.

                ls_e1edk03 = ls_edid4-sdata.

                APPEND ls_e1edk03 TO lt_e1edk03.
                CLEAR : ls_e1edk03,ls_edid4.

              ELSEIF ls_edid4-segnam = 'E1EDP19' AND ls_edid4 IS NOT INITIAL.

                IF ls_edid4-sdata IS NOT INITIAL.

                  ls_e1edp19 = ls_edid4-sdata.
                  APPEND ls_e1edp19 TO lt_e1edp19.
                  CLEAR : ls_e1edp19,ls_edid4.

                ENDIF.

              ENDIF.

            ENDLOOP.

            SELECT matnr maktx  FROM makt INTO TABLE lt_matnr_desc
                     FOR ALL ENTRIES IN lt_material WHERE matnr EQ lt_material-matnr.

            lt_item_data = VALUE #(
                             FOR lwa_e1edp01 IN lt_e1edp01

                             LET ls_po = COND e1edk02( WHEN line_exists( lt_edid4[ docnum = lv_filter_data segnam = 'E1EDK02' ] )
                                                  THEN lt_edid4[ docnum = lv_filter_data segnam = 'E1EDK02' ]-sdata
                                                    )
                                 ls_idtnr = COND e1edp19( WHEN line_exists( lt_edid4[ docnum = lv_filter_data segnam = 'E1EDP19' ] )
                                                  THEN lt_edid4[ docnum = lv_filter_data segnam = 'E1EDP19' ]-sdata
                                                    )
                             IN

                             (
                                idoc_number       = lv_filter_data  ""idoc_number
                                material_number   = lwa_e1edp01-matnr ""material_number
                                material_desc     = COND #( WHEN line_exists( lt_matnr_desc[ matnr = lwa_e1edp01-matnr ] )
                                                              THEN lt_matnr_desc[ matnr = lwa_e1edp01-matnr ]-maktx
                                                    ) ""material_desc
                                order_quantity    = lwa_e1edp01-menge ""order_quantity
                                uom               = lwa_e1edp01-menee ""uom
                                order_value       = lwa_e1edp01-netwr ""order_value
                                currency          = lwa_e1edp01-curcy ""currency
                                po_number         = ls_po-belnr ""po_number
                                item_number       = ls_po-posnr ""item_number
                                cust_part_number  = ls_idtnr-idtnr ""cust_part_number
                                delvery_date      = COND #( WHEN line_exists( lt_e1edk03[ iddat = '022' ] )
                                                              THEN lt_e1edk03[ iddat = '022' ]-datum
                                                              ELSE ' '
                                                    ) ""delvery_date
                              )
                          ).

          ELSEIF ls_edidc-mestyp = 'DESADV'.

            LOOP AT lt_edid4 INTO ls_edid4 WHERE docnum = lv_filter_data.

              IF ls_edid4-segnam = 'E1EDL24' AND ls_edid4 IS NOT INITIAL.

                ls_e1edl24 = ls_edid4-sdata.
                ls_material-matnr = ls_e1edl24-matnr.
                ls_e1edl24-matnr = ls_e1edl24-matnr.

                APPEND ls_material TO lt_material.
                APPEND ls_E1EDL24 TO lt_E1EDL24.
                CLEAR : ls_material, ls_E1EDL24, ls_edid4.

              ELSEIF ls_edid4-segnam = 'E1EDL43' AND ls_edid4 IS NOT INITIAL.

                ls_e1edl43 = ls_edid4-sdata.

                APPEND ls_e1edl43 TO lt_e1edl43.
                CLEAR : ls_e1edl43,ls_edid4.

              ELSEIF ls_edid4-segnam = 'E1EDL20' AND ls_edid4 IS NOT INITIAL.

                IF ls_edid4-sdata IS NOT INITIAL.

                  ls_e1edl20 = ls_edid4-sdata.
                  APPEND ls_e1edl20 TO lt_e1edl20.
                  CLEAR : ls_e1edl20,ls_edid4.

                ENDIF.

              ENDIF.

            ENDLOOP.

            SELECT vbeln,kdmat FROM lips INTO TABLE @DATA(lt_lips) FOR ALL ENTRIES IN @lt_e1edl20 WHERE vbeln = @lt_e1edl20-vbeln.



            SELECT matnr maktx  FROM makt INTO TABLE lt_matnr_desc
         FOR ALL ENTRIES IN lt_material WHERE matnr EQ lt_material-matnr.

            lt_item_data = VALUE #(
                             FOR lwa_E1EDL24 IN lt_E1EDL24

                             LET ls_po = COND e1edk02( WHEN line_exists( lt_edid4[ docnum = lv_filter_data segnam = 'E1EDK02' ] )
                                                  THEN lt_edid4[ docnum = lv_filter_data segnam = 'E1EDK02' ]-sdata
                                                    )
                                 ls_idtnr = COND e1edp19( WHEN line_exists( lt_edid4[ docnum = lv_filter_data segnam = 'E1EDP19' ] )
                                                  THEN lt_edid4[ docnum = lv_filter_data segnam = 'E1EDP19' ]-sdata
                                                    )
                                 ls_e1edl43 = COND e1edl43( WHEN line_exists( lt_edid4[ docnum = lv_filter_data segnam = 'E1EDL43' ] )
                                                  THEN lt_edid4[ docnum = lv_filter_data segnam = 'E1EDL43' ]-sdata
                                                    )
                                 ls_e1edl20 = COND e1edl20( WHEN line_exists( lt_edid4[ docnum = lv_filter_data segnam = 'E1EDL20' ] )
                                                  THEN lt_edid4[ docnum = lv_filter_data segnam = 'E1EDL20' ]-sdata
                                                    )
                             IN

                             (
                                idoc_number       = lv_filter_data  ""idoc_number
                                material_number   = lwa_E1EDL24-matnr""material_number
                                material_desc     = COND #( WHEN line_exists( lt_matnr_desc[ matnr = lwa_e1edl24-matnr ] )
                                                              THEN lt_matnr_desc[ matnr = lwa_E1EDL24-matnr ]-maktx
                                                    ) ""material_desc
                                order_quantity    = lwa_e1edl24-lgmng ""order_quantity
                                delivery_quantity    = lwa_e1edl24-lfimg ""Delivery_quantity
                                uom               = lwa_e1edl24-meins ""uom
                                order_value       = lwa_e1edl24-ntgew ""order_value
                                weight            = lwa_e1edl24-ntgew ""
                                wuom              = lwa_e1edl24-gewei ""
                                po_number         = lwa_e1edl24-vgbel ""po_number
                                item_number       = lwa_e1edl24-vgpos ""item_number
                                cust_part_number  = COND #( WHEN line_exists( lt_lips[ vbeln = ls_e1edl20-vbeln ] )
                                                              THEN lt_lips[ vbeln = ls_e1edl20-vbeln ]-kdmat
                                                    ) ""material_desc
                                delvery_date      = COND #( WHEN line_exists( lt_e1edl43[ qualf = 'C' ] )
                                                              THEN lt_e1edl43[ qualf = 'C' ]-datum
                                                              ELSE ' '
                                                    ) ""delvery_date
                              )
                          ).

          ELSEIF ls_edidc-mestyp = 'INVOIC'.
            LOOP AT lt_edid4 INTO ls_edid4 WHERE docnum = lv_filter_data.

              IF ls_edid4-segnam = 'E1EDP01' AND ls_edid4 IS NOT INITIAL.

                ls_e1edp01 = ls_edid4-sdata.
                ls_material-matnr = ls_e1edp01-matnr.

                APPEND ls_material TO lt_material.
                APPEND ls_e1edp01 TO lt_e1edp01.
                CLEAR : ls_material, ls_e1edp01, ls_edid4.

              ELSEIF ls_edid4-segnam = 'E1EDK03' AND ls_edid4 IS NOT INITIAL.

                ls_e1edk03 = ls_edid4-sdata.

                APPEND ls_e1edk03 TO lt_e1edk03.
                CLEAR : ls_e1edk03,ls_edid4.

              ELSEIF ls_edid4-segnam = 'E1EDP19' AND ls_edid4 IS NOT INITIAL.

                IF ls_edid4-sdata IS NOT INITIAL.

                  ls_e1edp19 = ls_edid4-sdata.
                  APPEND ls_e1edp19 TO lt_e1edp19.
                  CLEAR : ls_e1edp19,ls_edid4.

                ENDIF.
              ELSEIF ls_edid4-segnam = 'E1EDP02' AND ls_edid4 IS NOT INITIAL..
                IF ls_edid4-sdata IS NOT INITIAL.

                  ls_e1edp02 = ls_edid4-sdata.
                  APPEND ls_e1edp02 TO lt_e1edp02.
                  CLEAR : ls_e1edp02,ls_edid4.

                ENDIF.
              ELSEIF ls_edid4-segnam = 'E1EDP26' AND ls_edid4 IS NOT INITIAL..
                IF ls_edid4-sdata IS NOT INITIAL.

                  ls_e1edp26 = ls_edid4-sdata.
                  APPEND ls_e1edp26 TO lt_e1edp26.
                  CLEAR : ls_e1edp26,ls_edid4.

                ENDIF.
              ENDIF.

            ENDLOOP.

            SELECT matnr maktx  FROM makt INTO TABLE lt_matnr_desc
                     FOR ALL ENTRIES IN lt_material WHERE matnr EQ lt_material-matnr.

            lt_item_data = VALUE #(
                             FOR lwa_e1edp01 IN lt_e1edp01

                             LET ls_po = COND e1edk02( WHEN line_exists( lt_edid4[ docnum = lv_filter_data segnam = 'E1EDP26' ] )
                                                  THEN lt_edid4[ docnum = lv_filter_data segnam = 'E1EDP26' ]-sdata
                                                    )
                                 ls_idtnr = COND e1edp19( WHEN line_exists( lt_edid4[ docnum = lv_filter_data segnam = 'E1EDP19' ] )
                                                  THEN lt_edid4[ docnum = lv_filter_data segnam = 'E1EDP19' ]-sdata
                                                    )
                             IN

                             (
                                idoc_number       = lv_filter_data  ""idoc_number
                                material_number   = COND #( WHEN line_exists( lt_e1edp19[ qualf = '002' ] )
                                                              THEN lt_e1edp19[ qualf = '002' ]-idtnr
                                                              ELSE ' '
                                                    ) ""cust_part_number
                                material_desc     = COND #( WHEN line_exists( lt_e1edp19[ qualf = '002' ] )
                                                              THEN lt_e1edp19[ qualf = '002' ]-ktext
                                                              ELSE ' '
                                                    ) ""cust_part_number
                                order_quantity    = lwa_e1edp01-menge ""order_quantity
                                uom               = lwa_e1edp01-menee ""uom
                                order_value       = COND #( WHEN line_exists( lt_e1edp26[ qualf = '003' ] )
                                                              THEN lt_e1edp26[ qualf = '003' ]-betrg
                                                              ELSE ' '
                                                    ) ""order_value
                                currency          = lwa_e1edp01-pmene ""currency
                                po_number         = COND #( WHEN line_exists( lt_e1edp02[ qualf = '001' ] )
                                                              THEN lt_e1edp02[ qualf = '001' ]-belnr
                                                              ELSE ' '
                                                    ) ""po_number
                                item_number       = COND #( WHEN line_exists( lt_e1edp02[ qualf = '001' ] )
                                                              THEN lt_e1edp02[ qualf = '001' ]-zeile
                                                              ELSE ' '
                                                    ) ""item_number
                                cust_part_number  = COND #( WHEN line_exists( lt_e1edp19[ qualf = '001' ] )
                                                              THEN lt_e1edp19[ qualf = '001' ]-idtnr
                                                              ELSE ' '
                                                    ) ""cust_part_number
                                delvery_date      = COND #( WHEN line_exists( lt_e1edk03[ iddat = '001' ] )
                                                              THEN lt_e1edk03[ iddat = '001' ]-datum
                                                              ELSE ' '
                                                    ) ""delvery_date
                              )
                          ).

          ENDIF.

          io_response->set_data( lt_item_data ).

          ""Set Total Number of records in lt_data container
          IF io_request->is_total_numb_of_rec_requested( ).
            io_response->set_total_number_of_records( lines( lt_item_data ) ).
          ENDIF.

        ENDIF.

      WHEN 'ZI_IDOC_PROCESSING'.

        IF io_request->is_data_requested(  ).

          ""PAGING

          DATA(lv_offset2) = io_request->get_paging( )->get_offset( ).
          DATA(lv_page_size2) = io_request->get_paging( )->get_page_size( ).
          DATA(lv_max_rows2) = COND #( WHEN lv_page_size2 = if_rap_query_paging=>page_size_unlimited THEN 0
                                      ELSE lv_page_size2 ).

          ""FILTER

          lv_sql_filter = io_request->get_filter( )->get_as_sql_string( ).

          " Ensure filter string is not empty to prevent unintended queries
          IF lv_sql_filter IS INITIAL.
            RETURN.
          ENDIF.

          " Assuming the filter query is in the format ?$filter=IDOC_NUMBER eq '1100022000'
          IF lv_sql_filter IS NOT INITIAL.
            SPLIT lv_sql_filter AT `IDOC_NUMBER = ` INTO TABLE lt_parts.
            READ TABLE lt_parts INDEX 2 INTO lv_part.
            IF sy-subrc = 0.
              ls_idoc_processing-idoc_number = |{ lv_part ALPHA = IN }|.
            ENDIF.
          ENDIF.

          CALL FUNCTION 'ZFM_ITRS4_08_IDOC_PROCESSING'
            EXPORTING
              ls_processidoc = ls_idoc_processing
            IMPORTING
              er_entity      = lv_IDOC_POC.

          APPEND lv_IDOC_POC TO it_IDOC_POC.
          CLEAR lv_idoc_poc.

          io_response->set_data( it_IDOC_POC ).

          ""Set Total Number of records in lt_data container
          IF io_request->is_total_numb_of_rec_requested( ).
            io_response->set_total_number_of_records( lines( it_IDOC_POC ) ).
          ENDIF.

        ENDIF.

      WHEN 'ZI_IDOC_MASS_EDIT_DETAILS'.

        ""PAGING

        DATA(lv_offset3) = io_request->get_paging( )->get_offset( ).
        DATA(lv_page_size3) = io_request->get_paging( )->get_page_size( ).
        DATA(lv_max_rows3) = COND #( WHEN lv_page_size3 = if_rap_query_paging=>page_size_unlimited THEN 0
                                    ELSE lv_page_size3 ).

        ""FILTER

        TRY.

            DATA(lt_ranges) = io_request->get_filter( )->get_as_ranges( ).
            DATA(lt_msg_type) = COND #( WHEN line_exists( lt_ranges[ name = 'MSG_TYPE' ] )
                                THEN lt_ranges[ name = 'MSG_TYPE' ]-range
                                      ).

          CATCH cx_rap_query_filter_no_range INTO DATA(ex_ranges).

        ENDTRY.

        IF lt_msg_type IS NOT INITIAL.
          lv_msg_type = lt_msg_type[ 1 ]-low.
        ENDIF.

        CALL FUNCTION 'IDOCTYPE_READ_COMPLETE'
          EXPORTING
            pi_idoctyp         = lv_msg_type
            pi_release         = sy-saprl
            pi_version         = '3'
          TABLES
            pt_segments        = lt_segments
            pt_fields          = lt_fields
            pt_fvalues         = lt_field_value
          EXCEPTIONS
            object_unknown     = 1
            segment_unknown    = 2
            relation_not_found = 3
            OTHERS             = 4.

        IF lt_segments IS NOT INITIAL.

          LOOP AT lt_segments INTO ls_segments.
            ls_idoc_detail-msg_type = lv_msg_type.
            ls_idoc_detail-segment = ls_segments-segmenttyp.
            ls_idoc_detail-segment_desc = ls_segments-descrp.
            APPEND ls_idoc_detail TO lt_idoc_detail.
            CLEAR: ls_idoc_detail, ls_segments.
          ENDLOOP.

          IF lt_idoc_detail IS NOT INITIAL.
            SORT lt_idoc_detail ASCENDING BY segment.
            DELETE ADJACENT DUPLICATES FROM lt_idoc_detail.
          ENDIF.

          IF lt_fields IS NOT INITIAL.
            LOOP AT lt_fields INTO ls_fields.
              ls_idoc_detail-msg_type = lv_msg_type.
              ls_idoc_detail-segment = ls_fields-segmenttyp.
              ls_idoc_detail-sub_segment = ls_fields-fieldname.
              ls_idoc_detail-sub_seg_desc = ls_fields-descrp.
              APPEND ls_idoc_detail TO lt_idoc_detail.
              CLEAR:ls_idoc_detail, ls_fields.
            ENDLOOP.
            IF lt_idoc_detail IS NOT INITIAL.
              SORT lt_idoc_detail  ASCENDING BY segment sub_segment.
              DELETE ADJACENT DUPLICATES FROM lt_idoc_detail.
            ENDIF.
          ENDIF.

          IF lt_field_value IS NOT INITIAL.
            LOOP AT lt_field_value INTO ls_field_value.
              ls_idoc_detail-msg_type = lv_msg_type.
              ls_idoc_detail-segment = ls_field_value-strname.
              ls_idoc_detail-sub_segment = ls_field_value-fieldname.
              ls_idoc_detail-field_values = ls_field_value-fldvalue_l.
              APPEND ls_idoc_detail TO lt_idoc_detail.
            ENDLOOP.

            IF lt_idoc_detail IS NOT INITIAL.
              SORT lt_idoc_detail ASCENDING BY segment sub_segment field_values.
              DELETE ADJACENT DUPLICATES FROM lt_idoc_detail.
            ENDIF.

          ENDIF.

        ELSE.

        ENDIF.

        SORT lt_idoc_detail ASCENDING BY segment sub_segment field_values.

        SELECT * FROM @lt_idoc_detail AS idoc_detail
                 ORDER BY segment
                 INTO TABLE @DATA(lt_idoc_detail1)
                 OFFSET @lv_offset3 UP TO @lv_max_rows3 ROWS.

        io_response->set_data( lt_idoc_detail1 ).

        ""Set Total Number of records in lt_data container
        IF io_request->is_total_numb_of_rec_requested( ).
          io_response->set_total_number_of_records( lines( lt_idoc_detail1 ) ).
        ENDIF.

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
