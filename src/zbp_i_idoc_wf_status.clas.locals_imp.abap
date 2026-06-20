CLASS lhc_ZI_IDOC_WF_STATUS DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_idoc_wf_status RESULT result.

ENDCLASS.

CLASS lhc_ZI_IDOC_WF_STATUS IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

ENDCLASS.
