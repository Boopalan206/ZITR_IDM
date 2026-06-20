FUNCTION zmaterial_create_extend.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(P_MATNR) TYPE  MATNR
*"     REFERENCE(P_VKORG) TYPE  VKORG DEFAULT '1000'
*"     REFERENCE(P_WERKS) TYPE  WERKS_D DEFAULT '1710'
*"     REFERENCE(P_VTWEG) TYPE  VTWEG DEFAULT '10'
*"     REFERENCE(P_MESTYP) TYPE  EDIDC-MESTYP
*"     REFERENCE(P_STATUS) TYPE  EDIDC-STATUS
*"     REFERENCE(P_WFSTAT) TYPE  EDIDC-STATUS
*"     REFERENCE(P_CREDAT) TYPE  EDIDC-CREDAT
*"     REFERENCE(P_MAT_TYPE) TYPE  MARA-MTART DEFAULT 'FERT'
*"     REFERENCE(P_IND_SECTOR) TYPE  MBRSH DEFAULT 'M'
*"     REFERENCE(P_ITEM_CAT) TYPE  MTPOS DEFAULT 'CBOR'
*"     REFERENCE(P_MATL_DESC) TYPE  MAKTX DEFAULT 'TEST 123'
*"  TABLES
*"      I_MATNR TYPE  TYP_R_MATNR
*"      I_VKORG TYPE  SD_VKORG_RANGES
*"      I_WERKS TYPE  TYP_R_WERKS
*"      I_VTWEG TYPE  SHP_VTWEG_RANGE_T
*"      E_RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------

  TYPES : BEGIN OF ty_data,
            idoc_number    TYPE String,
            customer_name  TYPE String,
            idoc_status    TYPE String,
            po_number      TYPE String,
            bol_number     TYPE String,
            creation_date  TYPE String,
            description    TYPE String,
            wf_status      TYPE String,
            invoice_number TYPE String,
            message_type   TYPE String,
            msgtyp_desc    TYPE String,
            basic_type     TYPE String,
            bsctyp_desc    TYPE String,
            shipping       TYPE String,
            delivery_date  TYPE String,
          END OF ty_data.

  TYPES: BEGIN OF ty_customer,
           kunnr TYPE kunnr,
         END OF ty_customer .

  TYPES: BEGIN OF ty_idoc_msg,
           docnum      TYPE edi_docnum,
           status_code TYPE edids-status,
           message     TYPE idoc_msg,
         END OF ty_idoc_msg .

  TYPES: BEGIN OF ty_range,
           sign   TYPE c LENGTH 1,
           option TYPE c LENGTH 2,
           low    TYPE char10,
           high   TYPE char10,
         END OF ty_range.

  DATA: lt_direct    TYPE STANDARD TABLE OF ty_range WITH EMPTY KEY,
        lt_credat    TYPE STANDARD TABLE OF ty_range WITH EMPTY KEY,
        lt_msg_typ   TYPE STANDARD TABLE OF ty_range WITH EMPTY KEY,
        lt_basic_typ TYPE STANDARD TABLE OF ty_range WITH EMPTY KEY,
        lt_idoc_sts  TYPE STANDARD TABLE OF ty_range WITH EMPTY KEY,
        lt_wf_sts    TYPE STANDARD TABLE OF ty_range WITH EMPTY KEY,
        lt_idoc_no   TYPE STANDARD TABLE OF ty_range WITH EMPTY KEY.


  DATA: it_filter_select_options TYPE /iwbep/t_mgw_select_option WITH HEADER LINE.

  DATA : ls_data          TYPE ty_data,
         lt_data          TYPE TABLE OF ty_data,
         ls_data1         TYPE ty_data,
         lt_data1         TYPE TABLE OF ty_data,
         lt_customer      TYPE TABLE OF ty_customer,
         ls_customer      TYPE ty_customer,
         lt_brf_msg       TYPE TABLE OF zst_idoc_msg_types,
         lt_brf_status    TYPE TABLE OF zst_idoc_mestyp,
         lt_filter_result TYPE ztt_idoc_filter_values,
         lt_status_custom TYPE ztt_idoc_status_desc,
         ls_e1edka1       TYPE e1edka1,
         ls_idoc_msg      TYPE ty_idoc_msg,
         lv_idoc_msg      TYPE idoc_msg,
         lt_idoc_msg      TYPE TABLE OF ty_idoc_msg,
*           lt_edid4         TYPE TABLE OF edidd,
         lt_edid4_temp    TYPE TABLE OF edidd,
         lt_edids_temp    TYPE TABLE OF edids.

  CONSTANTS : lv_msg_typ_all TYPE string VALUE 'ZMSG_TYPE' ##NO_TEXT,
              lv_status_all  TYPE string VALUE 'MON_STATUSES' ##NO_TEXT.
*  BREAK-POINT.

  DATA: gr_alv TYPE REF TO cl_salv_table.

*      " Fetch the Message types i.e under monitoring from BRF+ configuration
  CALL FUNCTION 'ZFM_GET_MSG_TYPES'
    EXPORTING
      iv_input  = lv_msg_typ_all
    IMPORTING
      et_result = lt_brf_msg.

  IF p_mestyp IS NOT INITIAL.
    APPEND VALUE #( sign   = 'I'
                  option = 'EQ'
                  low    = p_mestyp
                  high   = '' ) TO lt_msg_typ.
  ENDIF.

  IF p_status IS NOT INITIAL.
    APPEND VALUE #( sign   = 'I'
                  option = 'EQ'
                  low    = p_status
                  high   = '' ) TO lt_idoc_sts.
  ENDIF.

  IF p_wfstat IS NOT INITIAL.
    APPEND VALUE #( sign   = 'I'
                  option = 'EQ'
                  low    = p_wfstat
                  high   = '' ) TO lt_wf_sts.
  ENDIF.

  IF p_credat IS NOT INITIAL.
    APPEND VALUE #( sign   = 'I'
                  option = 'EQ'
                  low    = p_credat
                  high   = '' ) TO lt_credat.
  ENDIF.

  DELETE lt_brf_msg WHERE msg_type NE p_mestyp.

  lt_msg_typ = VALUE #(
                  FOR ls_brf_msg IN lt_brf_msg
                  LET s = 'I' o = 'EQ' h = ''
                  IN
                  ( sign = s option = o low = ls_brf_msg-msg_type high = h )
               ).

  lt_direct = VALUE #(
            FOR ls_brf_msg IN lt_brf_msg
            LET s = 'I' o = 'EQ' h = ''
            IN
            ( sign = s option = o low = ls_brf_msg-direct high = h )
         ).

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
    a~direct IN @lt_direct AND
    wf~status IN @lt_wf_sts
    ORDER BY ( 'primary key' ) ASCENDING
    INTO TABLE @DATA(lt_edidc).

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

    SELECT docnum,countr,stamid,stamno,credat,cretim,stapa1,stapa2,stapa3,stapa4 FROM edids INTO TABLE @DATA(lt_edids)
       FOR ALL ENTRIES IN @lt_edidc WHERE docnum = @lt_edidc-docnum.

    SORT lt_edids BY docnum countr DESCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_edids COMPARING docnum.

    SELECT * FROM edid4
                FOR ALL ENTRIES IN @lt_edidc WHERE docnum = @lt_edidc-docnum
                INTO TABLE @DATA(lt_edid4).

    SORT lt_edid4 BY docnum counter segnum ASCENDING.

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

  ENDIF.

**********************************************************************

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
                                                  ELSE 'No Values Found'
                                             )

                      idoc_status = COND #( WHEN line_exists( lt_brf_status[ status_codes = ls_edidc-status ] )
                                             THEN lt_brf_status[ status_codes = ls_edidc-status ]-status_type
                                            ELSE 'status code not monitored'
                                    )
                      po_number = COND #( WHEN ls_po-belnr IS NOT INITIAL
                                          THEN ls_po-belnr
                                          ELSE 'No Values Found'
                                          )
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

  DATA: ls_headdata           TYPE bapimathead,
        ls_client             TYPE bapi_mara,
        ls_clientx            TYPE BAPI_MARAx,
        ls_plant              TYPE bapi_marc,
        ls_plantx             TYPE bapi_marcx,
        ls_salesdata          TYPE bapi_mvke,
        ls_salesdatax         TYPE bapi_mvkex,
        lt_materialdesc       TYPE TABLE OF bapi_makt,
        ls_materialdesc       TYPE bapi_makt,
        lt_taxclassifications TYPE TABLE OF bapi_mlan,
        ls_taxclassifications TYPE bapi_mlan,
        lt_return             TYPE TABLE OF bapi_matreturn2.

********************

  LOOP AT lt_data INTO ls_data.
    READ TABLE lt_edids INTO ls_edids WITH KEY stamid = 'V1' stamno = '382' docnum = ls_data-idoc_number stapa1 = 'A204'.
    IF sy-subrc = 0.
      ls_data1 = ls_data.
*************
      BREAK-POINT.
* Fill header data
      ls_headdata-material     = ls_edids-stapa1.
      ls_headdata-ind_sector   = p_ind_sector.
      ls_headdata-matl_type    = p_mat_type.
      ls_headdata-basic_view   = 'X'.
      ls_headdata-sales_view   = 'X'.

* Fill Client data
      ls_client-matl_group = ''.
      ls_client-base_uom = 'ST'.
      ls_client-base_uom_iso = 'ST'.

      ls_clientx-matl_group = 'X'.
      ls_clientx-base_uom = 'X'.
      ls_clientx-base_uom_iso = 'X'.

* Fill Plant data
      ls_plant-plant = p_werks.
      ls_plant-pur_group = '001'.

      ls_plantx-plant = p_werks.
      ls_plantx-pur_group = 'X'.

* Fill sales data (MVKE)
      ls_salesdata-sales_org   = ls_edids-stapa2.
      ls_salesdata-distr_chan  = ls_edids-stapa3.
      ls_salesdata-item_cat    = p_item_cat.

* Change flags
      ls_salesdatax-sales_org   = ls_edids-stapa2.
      ls_salesdatax-distr_chan  = ls_edids-stapa3.
      ls_salesdatax-item_cat  = 'X'.

      ls_materialdesc-langu = 'EN'.
      ls_materialdesc-langu_iso = 'EN'.
      ls_materialdesc-matl_desc = p_matl_desc.

      APPEND ls_materialdesc TO lt_materialdesc.
      CLEAR ls_materialdesc.

      ls_taxclassifications-depcountry = 'DE'.
      ls_taxclassifications-depcountry_iso = 'DE'.
      ls_taxclassifications-tax_type_1 = 'TTX1'.
      ls_taxclassifications-taxclass_1 = '1'.

      APPEND ls_taxclassifications TO lt_taxclassifications.
      CLEAR ls_taxclassifications.

      ls_taxclassifications-depcountry = 'US'.
      ls_taxclassifications-depcountry_iso = 'US'.
      ls_taxclassifications-tax_type_1 = 'UTXJ'.
      ls_taxclassifications-taxclass_1 = '1'.

      APPEND ls_taxclassifications TO lt_taxclassifications.
      CLEAR ls_taxclassifications.


      CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
        EXPORTING
          headdata            = ls_headdata
          clientdata          = ls_client
          clientdatax         = ls_clientx
          plantdata           = ls_plant
          plantdatax          = ls_plantx
          salesdata           = ls_salesdata
          salesdatax          = ls_salesdatax
          flag_online         = ' '
          flag_cad_call       = ' '
        TABLES
          materialdescription = lt_materialdesc
          taxclassifications  = lt_taxclassifications
          returnmessages      = lt_return.
      CLEAR: ls_taxclassifications,
             lt_materialdesc,
             lt_return.

* Check for errors
*      LOOP AT lt_return INTO ls_return WHERE type = 'E' OR type = 'A'.
*        WRITE: / 'Error:', ls_return-message.
*        EXIT.
*      ENDLOOP.

      IF sy-subrc = 0.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
        WRITE: / 'Material extended successfully to Sales Org:', p_vkorg.
      ENDIF.
*************
      APPEND ls_data1 TO lt_data1.
      CLEAR ls_data1.
    ENDIF.
  ENDLOOP.

*  cl_salv_table=>factory(
*  IMPORTING r_salv_table = gr_alv
*  CHANGING  t_table      = lt_data1 ).
*
*  gr_alv->display( ).

ENDFUNCTION.
