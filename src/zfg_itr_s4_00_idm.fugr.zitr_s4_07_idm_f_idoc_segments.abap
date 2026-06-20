FUNCTION zitr_s4_07_idm_f_idoc_segments.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IM_IDOC_SEG_NUM) TYPE  FLAG
*"     REFERENCE(IM_IDOC_SEGMENT) TYPE  EDILSEGTYP
*"     REFERENCE(IM_IDOC_SUB_SEGMENT) TYPE  FIELDNAME
*"     REFERENCE(IM_IDOC_VALUE) TYPE  STRING
*"  EXPORTING
*"     REFERENCE(EX_IDOC_DATA) TYPE  EDIDD
*"  TABLES
*"      GT_DATA TYPE  ZTT_EDIDD
*"----------------------------------------------------------------------
  FIELD-SYMBOLS: <fs_sdata> TYPE any.


  IF im_idoc_segment IS NOT INITIAL.
    DATA: lv_split_qual  TYPE string,
          lv_split_value TYPE string,
          lv_data_qual   TYPE string,
          lv_data_value  TYPE string,
          lv_data_sdata  TYPE edidd.
    DATA: it_edit_open TYPE TABLE OF edidd,
          it_change    TYPE TABLE OF edidd,
          is_edit_open TYPE edidd.
    DATA: lt_sdata  TYPE TABLE OF edidd,
          ls_sdata1 TYPE edidd.
    DATA: ls_e1edk01           TYPE e1edk01,
          ls_e1edk14           TYPE e1edk14,
          ls_e1edk03           TYPE e1edk03,
          ls_e1edk04           TYPE e1edk04,
          ls_e1edk05           TYPE e1edk05,
          ls_e1edka1           TYPE e1edka1,
          ls_e1edka3           TYPE e1edka3,
          ls_e1edk02           TYPE e1edk02,
          ls_e1edk17           TYPE e1edk17,
          ls_e1edk18           TYPE e1edk18,
          ls_e1edk35           TYPE e1edk35,
          ls_e1edk36           TYPE e1edk36,
          ls_e1edkt1           TYPE e1edkt1,
          ls_e1edkt2           TYPE e1edkt2,
          ls_e1edp01           TYPE e1edp01,
          ls_e1edp02           TYPE e1edp02,
          ls_e1curef           TYPE e1curef,
          ls_e1addi1           TYPE e1addi1,
          ls_e1edp03           TYPE e1edp03,
          ls_e1edp04           TYPE e1edp04,
          ls_e1edp05           TYPE e1edp05,
          ls_e1edps5           TYPE e1edps5,
          ls_e1edp20           TYPE e1edp20,
          ls_e1edpa1           TYPE e1edpa1,
          ls_e1edpa3           TYPE e1edpa3,
          ls_e1edp19           TYPE e1edp19,
          ls_e1edpad           TYPE e1edpad,
          ls_e1txth1           TYPE e1txth1,
          ls_e1txtp1           TYPE e1txtp1,
          ls_e1edp17           TYPE e1edp17,
          ls_e1edp18           TYPE e1edp18,
          ls_e1edp35           TYPE e1edp35,
          ls_e1edpt1           TYPE e1edpt1,
          ls_e1edpt2           TYPE e1edpt2,
          ls_e1edc01           TYPE e1edc01,
          ls_e1edc02           TYPE e1edc02,
          ls_e1edc03           TYPE e1edc03,
          ls_e1edc04           TYPE e1edc04,
          ls_e1edc05           TYPE e1edc05,
          ls_e1edc06           TYPE e1edc06,
          ls_e1edc07           TYPE e1edc07,
          ls_e1edca1           TYPE e1edca1,
          ls_e1edc19           TYPE e1edc19,
          ls_e1edc17           TYPE e1edc17,
          ls_e1edc18           TYPE e1edc18,
          ls_e1edct1           TYPE e1edct1,
          ls_e1edct2           TYPE e1edct2,
          ls_e1cucfg           TYPE e1cucfg,
          ls_e1cuins           TYPE e1cuins,
          ls_e1cuprt           TYPE e1cuprt,
          ls_e1cuval           TYPE e1cuval,
          ls_e1cublb           TYPE e1cublb,
          ls_e1edl37           TYPE e1edl37,
          ls_e1edl39           TYPE e1edl39,
          ls_e1edl38           TYPE e1edl38,
          ls_e1edl44           TYPE e1edl44,
          ls_e1eds01           TYPE e1eds01,
          ls_e1idocenhancement TYPE e1idocenhancement.

    IF gt_data[] IS NOT INITIAL.

      READ TABLE gt_data INTO DATA(ls_sdata) WITH KEY "segnum = im_idoc_seg_num
                                                               segnam = im_idoc_segment.
    ENDIF.

    CASE im_idoc_segment.
      WHEN 'E1EDK01'.
        ls_e1edk01 = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edk01 TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1edk01.
      WHEN 'E1EDK02'.
*        ls_e1edk02 = ls_sdata-sdata.
*        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edk02 TO <fs_sdata>.
*        MOVE im_idoc_value TO <fs_sdata>.
        IF im_idoc_seg_num = 'X'.
          SPLIT im_idoc_value AT ',' INTO lv_data_qual lv_data_value."im_idoc_value
          LOOP AT gt_data INTO ls_sdata1 WHERE segnam = im_idoc_segment.
            IF ls_sdata1-sdata IS NOT INITIAL .
              ls_e1edk02 = ls_sdata1-sdata.
              IF lv_data_qual IS NOT INITIAL.
                IF ls_e1edk02-qualf = lv_data_qual.
                  SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
                  ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edk02 TO <fs_sdata>.
                  MOVE lv_data_value TO <fs_sdata>.
                  ls_sdata1-sdata = ls_e1edk02.
                  EXIT.
                ENDIF.
              ENDIF.
              CLEAR: ls_sdata1.
            ELSE.
              SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
              ASSIGN COMPONENT lv_split_qual OF STRUCTURE ls_e1edk02 TO <fs_sdata>.
              MOVE lv_data_qual TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edk02.

              ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edk02 TO <fs_sdata>.
              MOVE lv_data_value TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edk02.
            ENDIF.

          ENDLOOP.
        ELSE.
          MESSAGE 'QUALF flag not found.' TYPE 'E'.
        ENDIF.
      WHEN 'E1EDK03'.
*        ls_e1edk03 = ls_sdata-sdata.
*        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edk03 TO <fs_sdata>.
*        MOVE im_idoc_value TO <fs_sdata>.
*        ls_sdata1-sdata = ls_e1edk03.

        IF im_idoc_seg_num = 'X'.
          SPLIT im_idoc_value AT ',' INTO lv_data_qual lv_data_value."im_idoc_value
          LOOP AT gt_data INTO ls_sdata1 WHERE segnam = im_idoc_segment.
            IF ls_sdata1-sdata IS NOT INITIAL .
              ls_e1edk03 = ls_sdata1-sdata.
              IF lv_data_qual IS NOT INITIAL.
                IF ls_e1edk03-iddat = lv_data_qual.
                  SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
                  ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edk03 TO <fs_sdata>.
                  MOVE lv_data_value TO <fs_sdata>.
                  ls_sdata1-sdata = ls_e1edk03.
                  EXIT.
                ENDIF.
              ENDIF.
              CLEAR: ls_sdata1.
            ELSE.
              SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
              ASSIGN COMPONENT lv_split_qual OF STRUCTURE ls_e1edk03 TO <fs_sdata>.
              MOVE lv_data_qual TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edk03.

              ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edk03 TO <fs_sdata>.
              MOVE lv_data_value TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edk03.
            ENDIF.

          ENDLOOP.
        ELSE.
          MESSAGE 'QUALF flag not found.' TYPE 'E'.
        ENDIF.
      WHEN 'E1EDK04'.
        ls_e1edk04 = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edk04 TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1edk04.
      WHEN 'E1EDK05'.
        ls_e1edk05 = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edk05 TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1edk05.
      WHEN 'E1EDK14'.
*        ls_e1edk14 = ls_sdata-sdata.
*        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edk14 TO <fs_sdata>.
*        MOVE im_idoc_value TO <fs_sdata>.
        IF im_idoc_seg_num = 'X'.
          SPLIT im_idoc_value AT ',' INTO lv_data_qual lv_data_value."im_idoc_value
          LOOP AT gt_data INTO ls_sdata1 WHERE segnam = im_idoc_segment.
            IF ls_sdata1-sdata IS NOT INITIAL.

              ls_e1edk14 = ls_sdata1-sdata.
              IF lv_data_qual IS NOT INITIAL.
                IF ls_e1edk14-qualf = lv_data_qual.
                  SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
                  ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edk14 TO <fs_sdata>.
                  MOVE lv_data_value TO <fs_sdata>.
                  ls_sdata1-sdata = ls_e1edk14.
*                ex_idoc_data = ls_sdata1.
*                  CLEAR: ls_sdata1.  " change on 10.02.2022... this code is commented
                  EXIT.
                ENDIF.
              ENDIF.
              CLEAR: ls_sdata1.
            ELSE.
              SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
              ASSIGN COMPONENT lv_split_qual OF STRUCTURE ls_e1edk14 TO <fs_sdata>.
              MOVE lv_data_qual TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edk14.
*              ex_idoc_data = ls_sdata1.

*              SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
              ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edk14 TO <fs_sdata>.
              MOVE lv_data_value TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edk14.
            ENDIF.
          ENDLOOP.
        ELSE.
          MESSAGE 'QUALF flag not found.' TYPE 'E'.
        ENDIF.

      WHEN 'E1EDKA1'.
        ls_e1edka1 = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edka1 TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1edka1.
      WHEN 'E1EDKA3'.

*        ls_e1edka3 = ls_sdata-sdata.
*        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edka3 TO <fs_sdata>.
*        MOVE im_idoc_value TO <fs_sdata>.
*        ls_sdata1-sdata = ls_e1edka3.

        IF im_idoc_seg_num = 'X'.
          SPLIT im_idoc_value AT ',' INTO lv_data_qual lv_data_value."im_idoc_value
          LOOP AT gt_data INTO ls_sdata1 WHERE segnam = im_idoc_segment.
            IF ls_sdata1-sdata IS NOT INITIAL .
              ls_e1edka3 = ls_sdata1-sdata.
              IF lv_data_qual IS NOT INITIAL.
                IF ls_e1edka3-qualp = lv_data_qual.
                  SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
                  ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edka3 TO <fs_sdata>.
                  MOVE lv_data_value TO <fs_sdata>.
                  ls_sdata1-sdata = ls_e1edka3.
                  EXIT.
                ENDIF.
              ENDIF.
              CLEAR: ls_sdata1.
            ELSE.
              SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
              ASSIGN COMPONENT lv_split_qual OF STRUCTURE ls_e1edka3 TO <fs_sdata>.
              MOVE lv_data_qual TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edka3.

              ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edka3 TO <fs_sdata>.
              MOVE lv_data_value TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edka3.
            ENDIF.

          ENDLOOP.
        ELSE.
          MESSAGE 'QUALF flag not found.' TYPE 'E'.
        ENDIF.

      WHEN 'E1EDK17'.
*        ls_e1edk17 = ls_sdata-sdata.
*        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edk17 TO <fs_sdata>.
*        MOVE im_idoc_value TO <fs_sdata>.
        IF im_idoc_seg_num = 'X'.
          SPLIT im_idoc_value AT ',' INTO lv_data_qual lv_data_value."im_idoc_value
          LOOP AT gt_data INTO ls_sdata1 WHERE segnam = im_idoc_segment.
            IF ls_sdata1-sdata IS NOT INITIAL .
              ls_e1edk17 = ls_sdata1-sdata.
              IF lv_data_qual IS NOT INITIAL.
                IF ls_e1edk17-qualf = lv_data_qual.
                  SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
                  ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edk17 TO <fs_sdata>.
                  MOVE lv_data_value TO <fs_sdata>.
                  ls_sdata1-sdata = ls_e1edk17.
*                ex_idoc_data = ls_sdata1.
                  CLEAR: ls_sdata1.
                  EXIT.
                ENDIF.
              ENDIF.
              CLEAR: ls_sdata1.
            ELSE.
              SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
              ASSIGN COMPONENT lv_split_qual OF STRUCTURE ls_e1edk17 TO <fs_sdata>.
              MOVE lv_data_qual TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edk17.
*              ex_idoc_data = ls_sdata1.

*              SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
              ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edk17 TO <fs_sdata>.
              MOVE lv_data_value TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edk17.
            ENDIF.

          ENDLOOP.
        ELSE.
          MESSAGE 'QUALF flag not found.' TYPE 'E'.
        ENDIF.
      WHEN 'E1EDK18'.
*        ls_e1edk18 = ls_sdata-sdata.
*        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edk18 TO <fs_sdata>.
*        MOVE im_idoc_value TO <fs_sdata>.
        IF im_idoc_seg_num = 'X'.
          SPLIT im_idoc_value AT ',' INTO lv_data_qual lv_data_value."im_idoc_value
          LOOP AT gt_data INTO ls_sdata1 WHERE segnam = im_idoc_segment.
            IF ls_sdata1-sdata IS NOT INITIAL.
              ls_e1edk18 = ls_sdata1-sdata.
              IF lv_data_qual IS NOT INITIAL.
                IF ls_e1edk18-qualf = lv_data_qual.
                  SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
                  ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edk18 TO <fs_sdata>.
                  MOVE lv_data_value TO <fs_sdata>.
                  ls_sdata1-sdata = ls_e1edk18.
*                ex_idoc_data = ls_sdata1.
                  CLEAR: ls_sdata1.
                  EXIT.
                ENDIF.
              ENDIF.
              CLEAR: ls_sdata1.
            ELSE.

              SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
              ASSIGN COMPONENT lv_split_qual OF STRUCTURE ls_e1edk18 TO <fs_sdata>.
              MOVE lv_data_qual TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edk18.
*              ex_idoc_data = ls_sdata1.

*              SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
              ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edk18 TO <fs_sdata>.
              MOVE lv_data_value TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edk18.
            ENDIF.

          ENDLOOP.
        ELSE.
          MESSAGE 'QUALF flag not found.' TYPE 'E'.
        ENDIF.
      WHEN 'E1EDK35'.
*        ls_e1edk35 = ls_sdata-sdata.
*        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edk35 TO <fs_sdata>.
*        MOVE im_idoc_value TO <fs_sdata>.
*        ls_sdata1-sdata = ls_e1edk35.


        IF im_idoc_seg_num = 'X'.
          SPLIT im_idoc_value AT ',' INTO lv_data_qual lv_data_value."im_idoc_value
          LOOP AT gt_data INTO ls_sdata1 WHERE segnam = im_idoc_segment.
            IF ls_sdata1-sdata IS NOT INITIAL.
              ls_e1edk35 = ls_sdata1-sdata.
              IF lv_data_qual IS NOT INITIAL.
                IF ls_e1edk35-qualz = lv_data_qual.
                  SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
                  ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edk35 TO <fs_sdata>.
                  MOVE lv_data_value TO <fs_sdata>.
                  ls_sdata1-sdata = ls_e1edk35.
*                ex_idoc_data = ls_sdata1.
                  CLEAR: ls_sdata1.
                  EXIT.
                ENDIF.
              ENDIF.
              CLEAR: ls_sdata1.
            ELSE.

              SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
              ASSIGN COMPONENT lv_split_qual OF STRUCTURE ls_e1edk35 TO <fs_sdata>.
              MOVE lv_data_qual TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edk35.
*              ex_idoc_data = ls_sdata1.

*              SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
              ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edk35 TO <fs_sdata>.
              MOVE lv_data_value TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edk35.
            ENDIF.

          ENDLOOP.
        ELSE.
          MESSAGE 'QUALF flag not found.' TYPE 'E'.
        ENDIF.
      WHEN 'E1EDK36'.
        ls_e1edk36 = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edk36 TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1edk36.
      WHEN 'E1EDKT1'.
        ls_e1edkt1 = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edkt1 TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1edkt1.
      WHEN 'E1EDKT2'.
        ls_e1edkt2 = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edkt2 TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1edkt2.
      WHEN 'E1EDP01'.
        ls_e1edp01 = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edp01 TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1edp01.
      WHEN 'E1EDP02'.
*        ls_e1edp01 = ls_sdata-sdata.
*        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edp01 TO <fs_sdata>.
*        MOVE im_idoc_value TO <fs_sdata>.
        IF im_idoc_seg_num = 'X'.
          SPLIT im_idoc_value AT ',' INTO lv_data_qual lv_data_value."im_idoc_value
          LOOP AT gt_data INTO ls_sdata1 WHERE segnam = im_idoc_segment.
            IF ls_sdata1-sdata IS NOT INITIAL.
              ls_e1edp02 = ls_sdata1-sdata.
              IF lv_data_qual IS NOT INITIAL.
                IF ls_e1edp02-qualf = lv_data_qual.
                  SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
                  ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edp02 TO <fs_sdata>.
                  MOVE lv_data_value TO <fs_sdata>.
                  ls_sdata1-sdata = ls_e1edp02.
*                ex_idoc_data = ls_sdata1.
                  CLEAR: ls_sdata1.
                  EXIT.
                ELSE.

                  SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
                  ASSIGN COMPONENT lv_split_qual OF STRUCTURE ls_e1edp02 TO <fs_sdata>.
                  MOVE lv_data_qual TO <fs_sdata>.
                  ls_sdata1-sdata = ls_e1edp02.
*              ex_idoc_data = ls_sdata1.

*              SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
                  ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edp02 TO <fs_sdata>.
                  MOVE lv_data_value TO <fs_sdata>.
                  ls_sdata1-sdata = ls_e1edp02.

                ENDIF.

              ENDIF.
            ENDIF.
            CLEAR: ls_sdata1.
          ENDLOOP.
        ELSE.
          MESSAGE 'QUALF flag not found.' TYPE 'E'.
        ENDIF.
      WHEN 'E1CUREF'.
        ls_e1curef = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1curef TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1curef.
      WHEN 'E1ADDI1'.
        ls_e1addi1 = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1addi1 TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1addi1.
      WHEN 'E1EDP03'.
*        ls_e1edp03 = ls_sdata-sdata.
*        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edk35 TO <fs_sdata>.
*        MOVE im_idoc_value TO <fs_sdata>.
*        ls_sdata1-sdata = ls_e1edk35.

        IF im_idoc_seg_num = 'X'.
          SPLIT im_idoc_value AT ',' INTO lv_data_qual lv_data_value."im_idoc_value
          LOOP AT gt_data INTO ls_sdata1 WHERE segnam = im_idoc_segment.
            IF ls_sdata1-sdata IS NOT INITIAL .
              ls_e1edp03 = ls_sdata1-sdata.
              IF lv_data_qual IS NOT INITIAL.
                IF ls_e1edp03-iddat = lv_data_qual.
                  SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
                  ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edp03 TO <fs_sdata>.
                  MOVE lv_data_value TO <fs_sdata>.
                  ls_sdata1-sdata = ls_e1edp03.
                  EXIT.
                ENDIF.
              ENDIF.
              CLEAR: ls_sdata1.
            ELSE.
              SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
              ASSIGN COMPONENT lv_split_qual OF STRUCTURE ls_e1edp03 TO <fs_sdata>.
              MOVE lv_data_qual TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edp03.

              ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edp03 TO <fs_sdata>.
              MOVE lv_data_value TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edp03.
            ENDIF.

          ENDLOOP.
        ELSE.
          MESSAGE 'QUALF flag not found.' TYPE 'E'.
        ENDIF.

      WHEN 'E1EDP04'.
        ls_e1edp04 = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edp04 TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1edp04.
      WHEN 'E1EDP05'.
        ls_e1edp05 = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edp05 TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1edp05.
      WHEN 'E1EDPS5'.
        ls_e1edps5 = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edps5 TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1edps5.
      WHEN 'E1EDP20'.
        ls_e1edp20 = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edp20 TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1edp20.
      WHEN 'E1EDPA1'.
        ls_e1edpa1 = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edpa1 TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1edpa1.
      WHEN 'E1EDPA3'.
*        ls_e1edpa3 = ls_sdata-sdata.
*        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edpa3 TO <fs_sdata>.
*        MOVE im_idoc_value TO <fs_sdata>.
*        ls_sdata1-sdata = ls_e1edpa3.

        IF im_idoc_seg_num = 'X'.
          SPLIT im_idoc_value AT ',' INTO lv_data_qual lv_data_value."im_idoc_value
          LOOP AT gt_data INTO ls_sdata1 WHERE segnam = im_idoc_segment.
            IF ls_sdata1-sdata IS NOT INITIAL .
              ls_e1edpa3 = ls_sdata1-sdata.
              IF lv_data_qual IS NOT INITIAL.
                IF ls_e1edpa3-qualp = lv_data_qual.
                  SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
                  ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edpa3 TO <fs_sdata>.
                  MOVE lv_data_value TO <fs_sdata>.
                  ls_sdata1-sdata = ls_e1edpa3.
                  EXIT.
                ENDIF.
              ENDIF.
              CLEAR: ls_sdata1.
            ELSE.
              SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
              ASSIGN COMPONENT lv_split_qual OF STRUCTURE ls_e1edpa3 TO <fs_sdata>.
              MOVE lv_data_qual TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edpa3.

              ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edpa3 TO <fs_sdata>.
              MOVE lv_data_value TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edpa3.
            ENDIF.

          ENDLOOP.
        ELSE.
          MESSAGE 'QUALF flag not found.' TYPE 'E'.
        ENDIF.

      WHEN 'E1EDP19'.
*        ls_e1edp19 = ls_sdata-sdata.
*        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edp19 TO <fs_sdata>.
*        MOVE im_idoc_value TO <fs_sdata>.
        IF im_idoc_seg_num = 'X'.
          SPLIT im_idoc_value AT ',' INTO lv_data_qual lv_data_value."im_idoc_value
          LOOP AT gt_data INTO ls_sdata1 WHERE segnam = im_idoc_segment.
            IF ls_sdata1-sdata IS NOT INITIAL.
              ls_e1edp19 = ls_sdata1-sdata.
              IF lv_data_qual IS NOT INITIAL.
                IF ls_e1edp19-qualf = lv_data_qual OR ls_e1edp19-qualf EQ space.
                  SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
*                  ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edp19 TO <fs_sdata>.
*                  MOVE lv_data_value TO <fs_sdata>.
*                  MOVE lv_data_qual TO <fs_sdata>.
                  MOVE lv_data_value TO ls_e1edp19-idtnr.
                  MOVE lv_data_qual TO ls_e1edp19-qualf.
                  ls_sdata1-sdata = ls_e1edp19.
                  ex_idoc_data = ls_sdata1.
                  CLEAR: ls_sdata1.
                  EXIT.
                ENDIF.
              ENDIF.
              CLEAR: ls_sdata1.
            ELSE.
              SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
              ASSIGN COMPONENT lv_split_qual OF STRUCTURE ls_e1edp19 TO <fs_sdata>.
              MOVE lv_data_qual TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edp19.
*              ex_idoc_data = ls_sdata1.

*              SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
              ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edp19 TO <fs_sdata>.
              MOVE lv_data_value TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edp19.
*              ex_idoc_data = ls_sdata1.
            ENDIF.

          ENDLOOP.
        ELSE.
          MESSAGE 'QUALF flag not found.' TYPE 'E'.
        ENDIF.
      WHEN 'E1EDPAD'.
*        ls_e1edpad = ls_sdata-sdata.
*        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edpad TO <fs_sdata>.
*        MOVE im_idoc_value TO <fs_sdata>.
        IF im_idoc_seg_num = 'X'.
          SPLIT im_idoc_value AT ',' INTO lv_data_qual lv_data_value."im_idoc_value
          LOOP AT gt_data INTO ls_sdata1 WHERE segnam = im_idoc_segment.
            IF ls_sdata1-sdata IS NOT INITIAL.
              ls_e1edpad = ls_sdata1-sdata.
              IF lv_data_qual IS NOT INITIAL.
                IF ls_e1edpad-qualf = lv_data_qual.
                  SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
                  ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edpad TO <fs_sdata>.
                  MOVE lv_data_value TO <fs_sdata>.
                  ls_sdata1-sdata = ls_e1edpad.
                  ex_idoc_data = ls_sdata1.
                  CLEAR: ls_sdata1.
                  EXIT.
                ENDIF.
              ENDIF.
              CLEAR: ls_sdata1.
            ELSE.
              SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
              ASSIGN COMPONENT lv_split_qual OF STRUCTURE ls_e1edpad TO <fs_sdata>.
              MOVE lv_data_qual TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edpad.
*              ex_idoc_data = ls_sdata1.

*              SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
              ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edpad TO <fs_sdata>.
              MOVE lv_data_value TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edpad.
            ENDIF.

          ENDLOOP.
        ELSE.
          MESSAGE 'QUALF flag not found.' TYPE 'E'.
        ENDIF.
      WHEN 'E1TXTH1'.
        ls_e1txth1 = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1txth1 TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1txth1.
      WHEN 'E1TXTP1'.
        ls_e1txtp1 = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1txtp1 TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1txtp1.
      WHEN 'E1EDP17'.
*        ls_e1edp17 = ls_sdata-sdata.
*        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edp17 TO <fs_sdata>.
*        MOVE im_idoc_value TO <fs_sdata>.
        IF im_idoc_seg_num = 'X'.
          SPLIT im_idoc_value AT ',' INTO lv_data_qual lv_data_value."im_idoc_value
          LOOP AT gt_data INTO ls_sdata1 WHERE segnam = im_idoc_segment.
            IF ls_sdata1-sdata IS NOT INITIAL.
              ls_e1edp17 = ls_sdata1-sdata.
              IF lv_data_qual IS NOT INITIAL.
                IF ls_e1edp17-qualf = lv_data_qual.
                  SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
                  ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edp17 TO <fs_sdata>.
                  MOVE lv_data_value TO <fs_sdata>.
                  ls_sdata1-sdata = ls_e1edp17.
                  ex_idoc_data = ls_sdata1.
                  CLEAR: ls_sdata1.
                  EXIT.
                ENDIF.
              ENDIF.
              CLEAR: ls_sdata1.
            ELSE.
              SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
              ASSIGN COMPONENT lv_split_qual OF STRUCTURE ls_e1edp17 TO <fs_sdata>.
              MOVE lv_data_qual TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edp17.
*              ex_idoc_data = ls_sdata1.

*              SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
              ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edp17 TO <fs_sdata>.
              MOVE lv_data_value TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edp17.
            ENDIF.

          ENDLOOP.
        ELSE.
          MESSAGE 'QUALF flag not found.' TYPE 'E'.
        ENDIF.
      WHEN 'E1EDP18'.
*        ls_e1edp18 = ls_sdata-sdata.
*        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edp18 TO <fs_sdata>.
*        MOVE im_idoc_value TO <fs_sdata>.
        IF im_idoc_seg_num = 'X'.
          SPLIT im_idoc_value AT ',' INTO lv_data_qual lv_data_value."im_idoc_value
          LOOP AT gt_data INTO ls_sdata1 WHERE segnam = im_idoc_segment.
            IF ls_sdata1-sdata IS NOT INITIAL.
              ls_e1edp18 = ls_sdata1-sdata.
              IF lv_data_qual IS NOT INITIAL.
                IF ls_e1edp18-qualf = lv_data_qual.
                  SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
                  ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edp18 TO <fs_sdata>.
                  MOVE lv_data_value TO <fs_sdata>.
                  ls_sdata1-sdata = ls_e1edp18.
                  ex_idoc_data = ls_sdata1.
                  CLEAR: ls_sdata1.
                  EXIT.
                ENDIF.
              ENDIF.
              CLEAR: ls_sdata1.
            ELSE.
              SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
              ASSIGN COMPONENT lv_split_qual OF STRUCTURE ls_e1edp18 TO <fs_sdata>.
              MOVE lv_data_qual TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edp18.
*              ex_idoc_data = ls_sdata1.

*              SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
              ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edp18 TO <fs_sdata>.
              MOVE lv_data_value TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edp18.
            ENDIF.

          ENDLOOP.
        ELSE.
          MESSAGE 'QUALF flag not found.' TYPE 'E'.
        ENDIF.
      WHEN 'E1EDP35'.
*        ls_e1edp35 = ls_sdata-sdata.
*        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edp35 TO <fs_sdata>.
*        MOVE im_idoc_value TO <fs_sdata>.
*        ls_sdata1-sdata = ls_e1edp35.


        IF im_idoc_seg_num = 'X'.
          SPLIT im_idoc_value AT ',' INTO lv_data_qual lv_data_value."im_idoc_value
          LOOP AT gt_data INTO ls_sdata1 WHERE segnam = im_idoc_segment.
            IF ls_sdata1-sdata IS NOT INITIAL.
              ls_e1edp35 = ls_sdata1-sdata.
              IF lv_data_qual IS NOT INITIAL.
                IF ls_e1edp35-qualz = lv_data_qual.
                  SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
                  ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edp35 TO <fs_sdata>.
                  MOVE lv_data_value TO <fs_sdata>.
                  ls_sdata1-sdata = ls_e1edp35.
*                ex_idoc_data = ls_sdata1.
                  CLEAR: ls_sdata1.
                  EXIT.
                ENDIF.
              ENDIF.
              CLEAR: ls_sdata1.
            ELSE.

              SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
              ASSIGN COMPONENT lv_split_qual OF STRUCTURE ls_e1edp35 TO <fs_sdata>.
              MOVE lv_data_qual TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edp35.
*              ex_idoc_data = ls_sdata1.

*              SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
              ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edp35 TO <fs_sdata>.
              MOVE lv_data_value TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edp35.
            ENDIF.

          ENDLOOP.
        ELSE.
          MESSAGE 'QUALF flag not found.' TYPE 'E'.
        ENDIF.
      WHEN 'E1EDPT1'.
        ls_e1edpt1 = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edpt1 TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1edpt1.
      WHEN 'E1EDPT2'.
        ls_e1edpt2 = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edpt2 TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1edpt2.
      WHEN 'E1EDC01'.
        ls_e1edc01 = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edc01 TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1edc01.
      WHEN 'E1EDC02'.
*        ls_e1edc02 = ls_sdata-sdata.
*        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edc02 TO <fs_sdata>.
*        MOVE im_idoc_value TO <fs_sdata>.
        IF im_idoc_seg_num = 'X'.
          SPLIT im_idoc_value AT ',' INTO lv_data_qual lv_data_value."im_idoc_value
          LOOP AT gt_data INTO ls_sdata1 WHERE segnam = im_idoc_segment.
            IF ls_sdata1-sdata IS NOT INITIAL.
              ls_e1edc02 = ls_sdata1-sdata.
              IF lv_data_qual IS NOT INITIAL.
                IF ls_e1edc02-qualf = lv_data_qual.
                  SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
                  ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edc02 TO <fs_sdata>.
                  MOVE lv_data_value TO <fs_sdata>.
                  ls_sdata1-sdata = ls_e1edc02.
                  ex_idoc_data = ls_sdata1.
                  CLEAR: ls_sdata1.
                  EXIT.
                ENDIF.
              ENDIF.
              CLEAR: ls_sdata1.
            ELSE.
              SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
              ASSIGN COMPONENT lv_split_qual OF STRUCTURE ls_e1edc02 TO <fs_sdata>.
              MOVE lv_data_qual TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edc02.
*              ex_idoc_data = ls_sdata1.

*              SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
              ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edc02 TO <fs_sdata>.
              MOVE lv_data_value TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edc02.
            ENDIF.
          ENDLOOP.
        ELSE.
          MESSAGE 'QUALF flag not found.' TYPE 'E'.
        ENDIF.
      WHEN 'E1EDC03'.
*        ls_e1edc03 = ls_sdata-sdata.
*        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edc03 TO <fs_sdata>.
*        MOVE im_idoc_value TO <fs_sdata>.
*        ls_sdata1-sdata = ls_e1edc03.

        IF im_idoc_seg_num = 'X'.
          SPLIT im_idoc_value AT ',' INTO lv_data_qual lv_data_value."im_idoc_value
          LOOP AT gt_data INTO ls_sdata1 WHERE segnam = im_idoc_segment.
            IF ls_sdata1-sdata IS NOT INITIAL .
              ls_e1edc03 = ls_sdata1-sdata.
              IF lv_data_qual IS NOT INITIAL.
                IF ls_e1edc03-iddat = lv_data_qual.
                  SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
                  ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edc03 TO <fs_sdata>.
                  MOVE lv_data_value TO <fs_sdata>.
                  ls_sdata1-sdata = ls_e1edc03.
                  EXIT.
                ENDIF.
              ENDIF.
              CLEAR: ls_sdata1.
            ELSE.
              SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
              ASSIGN COMPONENT lv_split_qual OF STRUCTURE ls_e1edc03 TO <fs_sdata>.
              MOVE lv_data_qual TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edc03.

              ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edc03 TO <fs_sdata>.
              MOVE lv_data_value TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edc03.
            ENDIF.

          ENDLOOP.
        ELSE.
          MESSAGE 'QUALF flag not found.' TYPE 'E'.
        ENDIF.

      WHEN 'E1EDC04'.
        ls_e1edc04 = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edc04 TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1edc04.
      WHEN 'E1EDC05'.
        ls_e1edc05 = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edc05 TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1edc05.
      WHEN 'E1EDC06'.
        ls_e1edc06 = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edc06 TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1edc06.
      WHEN 'E1EDC07'.
        ls_e1edc07 = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edc07 TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1edc07.
      WHEN 'E1EDCA1'.
        ls_e1edca1 = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edca1 TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1edca1.
      WHEN 'E1EDC19'.
*        ls_e1edc19 = ls_sdata-sdata.
*        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edc19 TO <fs_sdata>.
*        MOVE im_idoc_value TO <fs_sdata>.
        IF im_idoc_seg_num = 'X'.
          SPLIT im_idoc_value AT ',' INTO lv_data_qual lv_data_value."im_idoc_value
          LOOP AT gt_data INTO ls_sdata1 WHERE segnam = im_idoc_segment.
            IF ls_sdata1-sdata IS NOT INITIAL.
              ls_e1edc19 = ls_sdata1-sdata.
              IF lv_data_qual IS NOT INITIAL.
                IF ls_e1edc19-qualf = lv_data_qual OR ls_e1edc19-qualf EQ space.
                  SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
                  ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edc19 TO <fs_sdata>.
                  MOVE lv_data_value TO <fs_sdata>.
                  ls_sdata1-sdata = ls_e1edc19.
                  ex_idoc_data = ls_sdata1.
                  CLEAR: ls_sdata1.
                  EXIT.
                ENDIF.
              ENDIF.
              CLEAR: ls_sdata1.
            ELSE.
              SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
              ASSIGN COMPONENT lv_split_qual OF STRUCTURE ls_e1edc19 TO <fs_sdata>.
              MOVE lv_data_qual TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edc19.
*              ex_idoc_data = ls_sdata1.

*              SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
              ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edc19 TO <fs_sdata>.
              MOVE lv_data_value TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edc19.
            ENDIF.

          ENDLOOP.
        ELSE.
          MESSAGE 'QUALF flag not found.' TYPE 'E'.
        ENDIF.
      WHEN 'E1EDC17'.
*        ls_e1edc17 = ls_sdata-sdata.
*        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edc17 TO <fs_sdata>.
*        MOVE im_idoc_value TO <fs_sdata>.
        IF im_idoc_seg_num = 'X'.
          SPLIT im_idoc_value AT ',' INTO lv_data_qual lv_data_value."im_idoc_value
          LOOP AT gt_data INTO ls_sdata1 WHERE segnam = im_idoc_segment.
            IF ls_sdata1-sdata IS NOT INITIAL.
              ls_e1edc17 = ls_sdata1-sdata.
              IF lv_data_qual IS NOT INITIAL.
                IF ls_e1edc17-qualf = lv_data_qual.
                  SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
                  ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edc17 TO <fs_sdata>.
                  MOVE lv_data_value TO <fs_sdata>.
                  ls_sdata1-sdata = ls_e1edc17.
                  ex_idoc_data = ls_sdata1.
                  CLEAR: ls_sdata1.
                  EXIT.
                ENDIF.
              ENDIF.
              CLEAR: ls_sdata1.
            ELSE.
              SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
              ASSIGN COMPONENT lv_split_qual OF STRUCTURE ls_e1edc19 TO <fs_sdata>.
              MOVE lv_data_qual TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edc19.
*              ex_idoc_data = ls_sdata1.

*              SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
              ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edc19 TO <fs_sdata>.
              MOVE lv_data_value TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edc19.
            ENDIF.
*          ENDIF.

          ENDLOOP.
        ELSE.
          MESSAGE 'QUALF flag not found.' TYPE 'E'.
        ENDIF.
      WHEN 'E1EDC18'.
*        ls_e1edc18 = ls_sdata-sdata.
*        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edc18 TO <fs_sdata>.
*        MOVE im_idoc_value TO <fs_sdata>.
        IF im_idoc_seg_num = 'X'.
          SPLIT im_idoc_value AT ',' INTO lv_data_qual lv_data_value."im_idoc_value
          LOOP AT gt_data INTO ls_sdata1 WHERE segnam = im_idoc_segment.
            IF ls_sdata1-sdata IS NOT INITIAL.
              ls_e1edc18 = ls_sdata1-sdata.
              IF lv_data_qual IS NOT INITIAL.
                IF ls_e1edc18-qualf = lv_data_qual.
                  SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
                  ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edc18 TO <fs_sdata>.
                  MOVE lv_data_value TO <fs_sdata>.
                  ls_sdata1-sdata = ls_e1edc18.
                  ex_idoc_data = ls_sdata1.
                  CLEAR: ls_sdata1.
                  EXIT.
                ENDIF.
              ENDIF.
              CLEAR: ls_sdata1.
            ELSE.
              SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
              ASSIGN COMPONENT lv_split_qual OF STRUCTURE ls_e1edc18 TO <fs_sdata>.
              MOVE lv_data_qual TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edc18.
*              ex_idoc_data = ls_sdata1.

*              SPLIT im_idoc_sub_segment AT ',' INTO lv_split_qual lv_split_value.
              ASSIGN COMPONENT lv_split_value OF STRUCTURE ls_e1edc18 TO <fs_sdata>.
              MOVE lv_data_value TO <fs_sdata>.
              ls_sdata1-sdata = ls_e1edc18.
            ENDIF.
*        ENDIF.

          ENDLOOP.
        ELSE.
          MESSAGE 'QUALF flag not found.' TYPE 'E'.
        ENDIF.
      WHEN 'E1EDCT1'.
        ls_e1edct1 = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edct1 TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1edct1.
      WHEN 'E1EDCT2'.
        ls_e1edct2 = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edct2 TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1edct2.
      WHEN 'E1CUCFG'.
        ls_e1cucfg = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1cucfg TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1cucfg.
      WHEN 'E1CUINS'.
        ls_e1cuins = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1cuins TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1cuins.
      WHEN 'E1CUPRT'.
        ls_e1cuprt = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1cuprt TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1cuprt.
      WHEN 'E1CUVAL'.
        ls_e1cuval = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1cuval TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1cuval.
      WHEN 'E1CUBLB'.
        ls_e1cublb = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1cublb TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1cublb.
      WHEN 'E1EDL37'.
        ls_e1edl37 = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edl37 TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1edl37.
      WHEN 'E1EDL39'.
        ls_e1edl39 = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edl39 TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1edl39.
      WHEN 'E1EDL38'.
        ls_e1edl38 = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edl38 TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1edl38.
      WHEN 'E1EDL44'.
        ls_e1edl44 = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1edl44 TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1edl44.
      WHEN 'E1EDS01'.
        ls_e1eds01 = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1eds01 TO <fs_sdata>.
        ls_sdata-sdata = ls_e1eds01.
        MOVE im_idoc_value TO <fs_sdata>.
      WHEN 'E1IDOCENHANCEMENT'.
        ls_e1idocenhancement = ls_sdata-sdata.
        ASSIGN COMPONENT im_idoc_sub_segment OF STRUCTURE ls_e1idocenhancement TO <fs_sdata>.
        MOVE im_idoc_value TO <fs_sdata>.
        ls_sdata-sdata = ls_e1idocenhancement.
      WHEN OTHERS.
    ENDCASE.
  ENDIF.
  IF  ex_idoc_data IS NOT INITIAL.
*    ex_idoc_data = ls_sdata1.
*    CLEAR: ls_sdata1.
  ELSE.
    ex_idoc_data = ls_sdata1.  "change on 10.02.2022, ls_sdata changed to ls_sdata1
    CLEAR: ls_sdata1.

  ENDIF.


ENDFUNCTION.
