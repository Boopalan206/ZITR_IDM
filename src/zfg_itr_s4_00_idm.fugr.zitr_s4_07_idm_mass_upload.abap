FUNCTION zitr_s4_07_idm_mass_upload.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(LS_DATA) TYPE  ZST_MASS_UPLOAD
*"  EXPORTING
*"     REFERENCE(ER_ENTITY) TYPE  ZST_MASS_UPLOAD
*"----------------------------------------------------------------------
  DATA: idoc_num         TYPE  edidc-docnum,
        idoc_type        TYPE  edi_iapi00-idoctyp,
        idoc_seg_num     TYPE flag,
        idoc_segment     TYPE  edilsegtyp,
        idoc_sub_segment TYPE  fieldname,
        idoc_value       TYPE  string,
        msg              TYPE bapiret2.

*  io_data_provider<->read_entry_data( IMPORTING es_data = ls_data ).

  IF ls_data IS NOT INITIAL.
    idoc_num         = ls_data-idoc_number.
    idoc_type        = ls_data-idoc_type.
    idoc_seg_num     = ls_data-segment_num.
    idoc_segment     = ls_data-segment.
    idoc_sub_segment = ls_data-fields.
    idoc_value       = ls_data-field_values.

    CALL FUNCTION 'ZITR_IDM_F_IDOC_MASS_UPDATE'
      EXPORTING
        im_idoc_num         = idoc_num
        im_idoc_type        = idoc_type
        im_idoc_seg_num     = idoc_seg_num
        im_idoc_segment     = idoc_segment
        im_idoc_sub_segment = idoc_sub_segment
        im_idoc_value       = idoc_value
      IMPORTING
        ex_msg              = msg.
    IF msg IS NOT INITIAL.
      er_entity-idoc_number = ls_data-idoc_number.
      er_entity-idoc_type   = ls_data-idoc_type.
      er_entity-segment     = ls_data-segment.
      er_entity-segment_num = ls_data-segment_num.
      er_entity-fields      = ls_data-fields.
      er_entity-field_values  = ls_data-field_values.
      er_entity-msg_type = msg-type.
      er_entity-msg = msg-message.
      MOVE-CORRESPONDING er_entity TO er_entity.
    ENDIF.
  ENDIF.


ENDFUNCTION.
