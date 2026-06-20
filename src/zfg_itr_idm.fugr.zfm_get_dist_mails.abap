FUNCTION zfm_get_dist_mails.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_MES_TYPE) TYPE  STRING
*"     VALUE(IV_DEPT_NAME) TYPE  STRING
*"  EXPORTING
*"     VALUE(ET_RESULT) TYPE  ZTT_IDOC_EMAIL_LIST
*"----------------------------------------------------------------------


  CONSTANTS:lv_function_id TYPE if_fdt_types=>id VALUE 'F10C74B575191EDFBDA5FA9EE1BDAF0A'.
  DATA:lv_timestamp         TYPE timestamp,
       lt_name_value        TYPE abap_parmbind_tab,
       ls_name_value        TYPE abap_parmbind,
       lr_data              TYPE REF TO data,
       lx_fdt               TYPE REF TO cx_fdt,
       la_zidoc_appl_val    TYPE if_fdt_types=>element_text,
       la_zde_idoc_dep_name TYPE if_fdt_types=>element_text.
  FIELD-SYMBOLS <la_any> TYPE any.

  FIELD-SYMBOLS : <ls_any> TYPE any.

  TYPES : BEGIN OF ty_result,
            email_id TYPE String,
          END OF ty_result.

  DATA : ls_result TYPE ty_result,
         lt_result TYPE TABLE OF ty_result.
****************************************************************************************************
* All method calls within one processing cycle calling the same function must use the same timestamp.
* For subsequent calls of the same function, we recommend to use the same timestamp for all calls.
* This is to improve the system performance.
****************************************************************************************************
* If you are using structures or tables without DDIC binding, you have to declare the respective types
* by yourself. Insert the according data type at the respective source code line.
****************************************************************************************************
  GET TIME STAMP FIELD lv_timestamp.
****************************************************************************************************
* Process a function without recording trace data, passing context data objects via a name/value table.
****************************************************************************************************
* Prepare function processing:
****************************************************************************************************
  ls_name_value-name = 'ZIDOC_APPL_VAL'.
  la_ZIDOC_APPL_VAL = iv_mes_type.
  GET REFERENCE OF la_ZIDOC_APPL_VAL INTO lr_data.
  ls_name_value-value = lr_data.
  INSERT ls_name_value INTO TABLE lt_name_value.
  CLEAR ls_name_value.
****************************************************************************************************
  ls_name_value-name = 'ZDE_IDOC_DEP_NAME'.
  la_ZDE_IDOC_DEP_NAME = iv_dept_name.
  GET REFERENCE OF la_ZDE_IDOC_DEP_NAME INTO lr_data.
  ls_name_value-value = lr_data.
  INSERT ls_name_value INTO TABLE lt_name_value.
  CLEAR ls_name_value.
****************************************************************************************************
* Create the data to store the result value after processing the function
* You can skip the following call, if you already have
* a variable for the result. Please replace also the parameter
* EA_RESULT in the method call CL_FDT_FUNCTION_PROCESS=>PROCESS
* with the desired variable.
****************************************************************************************************
  cl_fdt_function_process=>get_data_object_reference( EXPORTING iv_function_id      = lv_function_id
                                                                iv_data_object      = '_V_RESULT'
                                                                iv_timestamp        = lv_timestamp
                                                                iv_trace_generation = abap_false
                                                      IMPORTING er_data             = lr_data ).
  ASSIGN lr_data->* TO <la_any>.
  TRY.
      cl_fdt_function_process=>process( EXPORTING iv_function_id = lv_function_id
                                                  iv_timestamp   = lv_timestamp
                                        IMPORTING ea_result      = <la_any>
                                        CHANGING  ct_name_value  = lt_name_value ).

      IF sy-subrc = 0.

        LOOP AT <la_any> ASSIGNING <ls_any>.
          ls_result = <ls_any>.
          APPEND ls_result TO lt_result.
          CLEAR : ls_result.
        ENDLOOP.

        MOVE-CORRESPONDING lt_result TO et_result.

      ENDIF.

    CATCH cx_fdt INTO lx_fdt.
****************************************************************************************************
* You can check CX_FDT->MT_MESSAGE for error handling.
****************************************************************************************************
  ENDTRY.




ENDFUNCTION.
