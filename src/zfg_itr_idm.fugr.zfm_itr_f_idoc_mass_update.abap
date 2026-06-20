FUNCTION zfm_itr_f_idoc_mass_update.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IM_IDOC_NUM) TYPE  EDIDC-DOCNUM
*"     VALUE(IM_IDOC_TYPE) TYPE  EDI_IAPI00-IDOCTYP
*"     VALUE(IM_IDOC_SEG_NUM) TYPE  FLAG OPTIONAL
*"     VALUE(IM_IDOC_SEGMENT) TYPE  EDILSEGTYP
*"     VALUE(IM_IDOC_SUB_SEGMENT) TYPE  FIELDNAME
*"     VALUE(IM_IDOC_VALUE) TYPE  STRING
*"  EXPORTING
*"     REFERENCE(EX_MSG) TYPE  BAPIRET2
*"  EXCEPTIONS
*"      CANT_MODIFY_IDOC
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

  DATA: it_edit_open TYPE TABLE OF edidd,
        is_edit_open TYPE edidd.

  DATA: ls_idoc_contrl TYPE edidc,
        ls_idoc_data   TYPE edidd,
        ls_e1edp19     TYPE e1edp19,
        lt_idoc_data   TYPE TABLE OF edidd.

  CALL FUNCTION 'EDI_DOCUMENT_OPEN_FOR_EDIT'
    EXPORTING
      document_number               = im_idoc_num
    TABLES
      idoc_data                     = it_edit_open
    EXCEPTIONS
      document_foreign_lock         = 1
      document_not_exist            = 2
      document_not_open             = 3
      status_is_unable_for_changing = 4
      OTHERS                        = 5.

  IF line_exists( it_edit_open[ docnum = im_idoc_num segnam = im_idoc_segment ] ).
    LOOP AT it_edit_open INTO DATA(ls_edit_open) WHERE docnum = im_idoc_num AND segnam = im_idoc_segment.
      CALL FUNCTION 'ZFM_ITR_F_IDOC_SEGMENTS'
        EXPORTING
          im_idoc_seg_num     = im_idoc_seg_num
          im_idoc_segment     = im_idoc_segment
          im_idoc_sub_segment = im_idoc_sub_segment
          im_idoc_value       = im_idoc_value
          im_idoc_segnum      = ls_edit_open-segnum
        IMPORTING
          ex_idoc_data        = is_edit_open
        TABLES
          gt_data             = it_edit_open.

      MODIFY it_edit_open FROM is_edit_open.
    ENDLOOP.

    IF sy-subrc = 0.

      CALL FUNCTION 'EDI_CHANGE_DATA_SEGMENTS'
        TABLES
          idoc_changed_data_range = it_edit_open
        EXCEPTIONS
          idoc_not_open           = 1
          data_record_not_exist   = 2
          OTHERS                  = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      IF sy-subrc = 0.
        CALL FUNCTION 'EDI_DOCUMENT_CLOSE_EDIT'
          EXPORTING
            document_number = im_idoc_num
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

  ELSE.
    ex_msg-type = 'E'.
    ex_msg-message = 'Segment Not available'.
  ENDIF.

ENDFUNCTION.
