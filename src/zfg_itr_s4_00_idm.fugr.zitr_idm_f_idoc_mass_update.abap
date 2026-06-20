FUNCTION ZITR_IDM_F_IDOC_MASS_UPDATE.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IM_IDOC_NUM) TYPE  EDIDC-DOCNUM
*"     REFERENCE(IM_IDOC_TYPE) TYPE  EDI_IAPI00-IDOCTYP
*"     REFERENCE(IM_IDOC_SEG_NUM) TYPE  FLAG
*"     REFERENCE(IM_IDOC_SEGMENT) TYPE  EDILSEGTYP
*"     REFERENCE(IM_IDOC_SUB_SEGMENT) TYPE  FIELDNAME
*"     REFERENCE(IM_IDOC_VALUE) TYPE  STRING
*"  EXPORTING
*"     REFERENCE(EX_MSG) TYPE  BAPIRET2
*"----------------------------------------------------------------------

  DATA: lt_sdata  TYPE TABLE OF edidd,
        ls_sdata1 TYPE edidd.
  DATA: lv_char1(15)     TYPE c, " VALUE '3',
        lv_char2(15)     TYPE c, " VALUE '1',
        lv_char3(15)     TYPE c, " VALUE '1',
        lv_char(15)      TYPE c, " VALUE '1',
        lv_sub_value(15) TYPE c, " VALUE '1',
        lt_e1edk01       TYPE TABLE OF e1edk01,
        ls_e1edk01       TYPE e1edk01,
        ls_e1edk02       TYPE e1edk02,
        ls_e1edk03       TYPE e1edk03,
        ls_e1edk04       TYPE e1edk04,
        ls_e1edk05       TYPE e1edk05,
        ls_e1edk14       TYPE e1edk14,
        ls_e1edka1       TYPE e1edka1,
        ls_e1edka3       TYPE e1edka3,
        ls_e1edk17       TYPE e1edk17,
        ls_e1edk18       TYPE e1edk18,
        lv_e1edk01       TYPE string,
        lv_cnt           TYPE i,
        lt_close_idoc    TYPE TABLE OF edi_ds40.

  DATA : ls_eledk01 TYPE e1edk01.
  FIELD-SYMBOLS: <fs_mara> TYPE any.
  CALL FUNCTION 'EDI_DOCUMENT_OPEN_FOR_READ'
    EXPORTING
      document_number         = im_idoc_num
*     DB_READ_OPTION          = DB_READ
* IMPORTING
*     IDOC_CONTROL            =
    EXCEPTIONS
      document_foreign_lock   = 1
      document_not_exist      = 2
      document_number_invalid = 3
      OTHERS                  = 4.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ELSE.



    CALL FUNCTION 'EDI_SEGMENTS_GET_ALL'
      EXPORTING
        document_number         = im_idoc_num
      TABLES
        idoc_containers         = lt_sdata
      EXCEPTIONS
        document_number_invalid = 1
        end_of_document         = 2
        OTHERS                  = 3.
    IF sy-subrc <> 0.
** Implement suitable error handling here
    ELSE.
      DATA: it_edit_open TYPE TABLE OF edidd,
            is_edit_open TYPE edidd.

      CALL FUNCTION 'ZITR_S4_07_IDM_F_IDOC_SEGMENTS'
        EXPORTING
          im_idoc_seg_num     = im_idoc_seg_num
          im_idoc_segment     = im_idoc_segment
          im_idoc_sub_segment = im_idoc_sub_segment
          im_idoc_value       = im_idoc_value
        IMPORTING
          ex_idoc_data        = is_edit_open
        TABLES
          gt_data             = lt_sdata.

      CALL FUNCTION 'EDI_DOCUMENT_OPEN_FOR_EDIT'
        EXPORTING
          document_number               = im_idoc_num
*         ALREADY_OPEN                  = 'N'
* IMPORTING
*         IDOC_CONTROL                  =
        TABLES
          idoc_data                     = it_edit_open
        EXCEPTIONS
          document_foreign_lock         = 1
          document_not_exist            = 2
          document_not_open             = 3
          status_is_unable_for_changing = 4
          OTHERS                        = 5.
      IF sy-subrc = 0.
**** JP test on 14.03.2022
        DATA: ls_idoc_contrl TYPE edidc,                    "#EC NEEDED
              ls_idoc_data   TYPE edidd,
              ls_e1edp19     TYPE e1edp19,
              lt_idoc_data   TYPE TABLE OF edidd.
        IF im_idoc_segment = 'E1EDP19'.
          LOOP AT it_edit_open INTO ls_idoc_data WHERE segnam = 'E1EDP19'.
*    ls_e1edp19 = is_edit_open-sdata.
**    IF ls_e1edk02-qualf = c_qual_on.
**      ls_e1edk02-belnr = lv_order_number.
            ls_idoc_data-sdata = is_edit_open-sdata.
*      MODIFY lt_idoc_data FROM ls_idoc_data.
            APPEND ls_idoc_data TO lt_idoc_data.
            CLEAR: ls_idoc_data.
*    ENDIF.
          ENDLOOP.

          CALL FUNCTION 'EDI_CHANGE_DATA_SEGMENTS'
            TABLES
              idoc_changed_data_range = lt_idoc_data
            EXCEPTIONS
              idoc_not_open           = 1
              data_record_not_exist   = 2
              OTHERS                  = 3.
          IF sy-subrc <> 0.
            RAISE cant_modify_idoc.
          ENDIF.
        ELSE.
          CALL FUNCTION 'EDI_CHANGE_DATA_SEGMENT'
            EXPORTING
              idoc_changed_data_record = is_edit_open
            EXCEPTIONS
              idoc_not_open            = 1
              data_record_not_exist    = 2
              OTHERS                   = 3.
        ENDIF.
        IF sy-subrc = 0.
          CALL FUNCTION 'EDI_DOCUMENT_CLOSE_EDIT'
            EXPORTING
              document_number = im_idoc_num
*             DO_COMMIT       = 'X'
*             DO_UPDATE       = 'X'
*             WRITE_ALL_STATUS       = 'X'
*             STATUS_75       = ' '
            TABLES
              status_records  = lt_close_idoc
            EXCEPTIONS
              idoc_not_open   = 1
              db_error        = 2
              OTHERS          = 3.
          IF sy-subrc = 0.
            ex_msg-type = 'S'.
            ex_msg-message = 'Updated Successfully'.
          ELSE.
* Implement suitable error handling here
          ENDIF.
        ELSE.
* Implement suitable error handling here
        ENDIF.
*    ELSE.
* Implement suitable error handling here
      ENDIF.

    ENDIF.
  ENDIF.




ENDFUNCTION.
