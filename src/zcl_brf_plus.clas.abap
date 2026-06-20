CLASS zcl_brf_plus DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.

    "DATA DECLARATION

    CONSTANTS : lc_idoc_status_ip_value TYPE String VALUE 'MON_STATUSES',
                lc_msg_types_ip_value   TYPE String VALUE 'ZMSG_TYPE'.

    DATA : lt_idoc_status_result TYPE ztt_idoc_mestyp,
           lt_msg_type_result    TYPE ztt_idoc_msg_types,
           lt_email_list_result  TYPE ztt_idoc_email_list,
           lv_dep_name           TYPE String,
           lv_msg_type           TYPE String,
           lv_filter_id          TYPE String,
           lt_filter_result      TYPE ztt_idoc_filter_values.

ENDCLASS.

CLASS zcl_brf_plus IMPLEMENTATION.

  METHOD if_rap_query_provider~select.

    "PAGING

    DATA(lv_offset) = io_request->get_paging( )->get_offset( ).
    DATA(lv_page_size) = io_request->get_paging( )->get_page_size( ).
    DATA(lv_max_rows) = COND #( WHEN lv_page_size = if_rap_query_paging=>page_size_unlimited THEN 0
                                ELSE lv_page_size ).

    CASE io_request->get_entity_id( ).

      WHEN 'ZI_IDOC_STATUS_CODES'.

        IF io_request->is_data_requested(  ).

          CALL FUNCTION 'ZFM_GET_ALL_STATUSES'
            EXPORTING
              la_zvar_name_idoc = lc_idoc_status_ip_value
            IMPORTING
              et_result         = lt_idoc_status_result.

          io_response->set_data( lt_idoc_status_result ).

          ""Set Total Number of records in lt_data container
          IF io_request->is_total_numb_of_rec_requested( ).
            io_response->set_total_number_of_records( lines( lt_idoc_status_result ) ).
          ENDIF.

        ENDIF.

      WHEN 'ZI_IDOC_MSG_TYPES'.

        IF io_request->is_data_requested(  ).

          CALL FUNCTION 'ZFM_GET_MSG_TYPES'
            EXPORTING
              iv_input  = lc_msg_types_ip_value
            IMPORTING
              et_result = lt_msg_type_result.

          io_response->set_data( lt_msg_type_result ).

          ""Set Total Number of records in lt_data container
          IF io_request->is_total_numb_of_rec_requested( ).
            io_response->set_total_number_of_records( lines( lt_msg_type_result ) ).
          ENDIF.

        ENDIF.

      WHEN 'ZI_IDOC_EMAIL_LIST'.

        IF io_request->is_data_requested(  ).

          TRY.
              DATA(lt_ranges) = io_request->get_filter( )->get_as_ranges( ).

              ""filter manipulation

              " Look for Dept Name filter
              DATA(lt_DEP_NAME) = COND #( WHEN line_exists( lt_ranges[ name = 'DEP_NAME' ] )
                                          THEN lt_ranges[ name = 'DEP_NAME' ]-range
                                ).

              " Look for CREATION_DATE filter
              DATA(lt_MES_TYPE) = COND #( WHEN line_exists( lt_ranges[ name = 'MSG_TYPE' ] )
                                          THEN lt_ranges[ name = 'MSG_TYPE' ]-range
                                ).

            CATCH cx_rap_query_filter_no_range.
              "handle exception
          ENDTRY.

          IF lt_dep_name IS NOT INITIAL.

            lv_dep_name = lt_dep_name[ 1 ]-low.

          ENDIF.

          IF lt_mes_type IS NOT INITIAL.

            lv_msg_type = lt_mes_type[ 1 ]-low.

          ENDIF.

          CALL FUNCTION 'ZFM_GET_DIST_MAILS'
            EXPORTING
              iv_mes_type  = lv_msg_type
              iv_dept_name = lv_dep_name
            IMPORTING
              et_result    = lt_email_list_result.

          io_response->set_data( lt_email_list_result ).

          ""Set Total Number of records in lt_data container
          IF io_request->is_total_numb_of_rec_requested( ).
            io_response->set_total_number_of_records( lines( lt_email_list_result ) ).
          ENDIF.

        ENDIF.

      WHEN 'ZI_IDOC_FILTER_LIST'.

        IF io_request->is_data_requested(  ).

          CALL FUNCTION 'ZFM_GET_FILTER_VALUES'
            IMPORTING
              et_result = lt_filter_result.

          io_response->set_data( lt_filter_result ).

          ""Set Total Number of records in lt_data container
          IF io_request->is_total_numb_of_rec_requested( ).
            io_response->set_total_number_of_records( lines( lt_filter_result ) ).
          ENDIF.

        ENDIF.

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
