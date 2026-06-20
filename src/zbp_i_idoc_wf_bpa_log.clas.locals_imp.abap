CLASS lhc_ZI_IDOC_WF_BPA_LOG DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR WFLogTable RESULT result.
    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE wflogtable.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE wflogtable.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE wflogtable.

    METHODS read FOR READ
      IMPORTING keys FOR READ wflogtable RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK wflogtable.

ENDCLASS.

CLASS lhc_ZI_IDOC_WF_BPA_LOG IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.

    DATA : ls_data TYPE ztitr_wf_bpa_log,
           lt_data TYPE TABLE OF ztitr_wf_bpa_log.

    DATA(lv_idoc_no) = entities[ 1 ]-IdocNumber.
    DATA(lv_wf_id) = entities[ 1 ]-WorkflowId.

    SELECT MAX( sequence ) FROM zi_idoc_wf_bpa_log
      WHERE IdocNumber = @lv_idoc_no AND WorkflowId <> @lv_wf_id INTO @DATA(lv_max_seq).

    IF lv_max_seq IS INITIAL.
      lv_max_seq = 0.
    ENDIF.
    lv_max_seq = lv_max_seq + 1.


    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>).

      ls_data = VALUE #(
                          idoc_number = <ls_entity>-IdocNumber
                          workflow_id = <ls_entity>-WorkflowId
                          needed_by   = <ls_entity>-NeededBy
                          department = <ls_entity>-Department
                          user_desc = <ls_entity>-UserDesc
                          status = <ls_entity>-Status
                          created_by = <ls_entity>-CreatedBy
                          created_on = sy-datum
                          created_at = sy-timlo
                          sequence = lv_max_seq
                       ).

      APPEND ls_data TO lt_data.
      CLEAR : ls_data.
    ENDLOOP.

    INSERT ztitr_wf_bpa_log FROM TABLE lt_data.

  ENDMETHOD.

  METHOD update.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>).

      UPDATE ztitr_wf_bpa_log
        SET status = <ls_entity>-status
            changed_by = <ls_entity>-ChangedBy
            changed_on = sy-datum
            changed_at = sy-timlo
            comments = <ls_entity>-Comments
        WHERE idoc_number = <ls_entity>-IdocNumber AND
              workflow_id = <ls_entity>-WorkflowId.

    ENDLOOP.

  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_IDOC_WF_BPA_LOG DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_IDOC_WF_BPA_LOG IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
