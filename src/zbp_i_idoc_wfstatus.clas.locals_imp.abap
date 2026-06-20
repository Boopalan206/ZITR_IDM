CLASS lhc_ZI_IDOC_WFSTATUS DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_idoc_wfstatus RESULT result.

ENDCLASS.

CLASS lhc_ZI_IDOC_WFSTATUS IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

ENDCLASS.
