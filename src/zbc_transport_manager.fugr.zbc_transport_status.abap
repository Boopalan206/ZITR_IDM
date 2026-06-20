FUNCTION zbc_transport_status.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(PE_TRKORR) TYPE  E070-TRKORR
*"  CHANGING
*"     REFERENCE(PS_STATUS) TYPE  ZSTE_STATTR OPTIONAL
*"     REFERENCE(PS_DT_QAS) TYPE  DATUM OPTIONAL
*"     REFERENCE(PS_HR_QAS) TYPE  UZEIT OPTIONAL
*"     REFERENCE(PS_RC_QAS) TYPE  SY-SUBRC OPTIONAL
*"     REFERENCE(PS_DT_QAS_AUTORIZ) TYPE  DATUM OPTIONAL
*"     REFERENCE(PS_HR_QAS_AUTORIZ) TYPE  UZEIT OPTIONAL
*"     REFERENCE(PS_DT_PRD_MARC_IMP) TYPE  DATUM OPTIONAL
*"     REFERENCE(PS_HR_PRD_MARC_IMP) TYPE  UZEIT OPTIONAL
*"     REFERENCE(PS_DT_PRD) TYPE  DATUM OPTIONAL
*"     REFERENCE(PS_HR_PRD) TYPE  UZEIT OPTIONAL
*"     REFERENCE(PS_RC_PRD) TYPE  SY-SUBRC OPTIONAL
*"     REFERENCE(PS_HR_PRD_FINAL) TYPE  UZEIT OPTIONAL
*"----------------------------------------------------------------------
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
* ArcelorMittal Tubarão - Projeto Conexão                              *
*----------------------------------------------------------------------*
* ArcelorMittal Sistemas                                               *
* Módulo    : xx                                                       *
* Programa  : xxxxxxxxx                                                *
* Transação : xxxxxxxx                                                 *
* Tipo Prog : xxxxxxxxxxx                                              *
* Descrição : xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  *
* Objetivo  : xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  *
*----------------------------------------------------------------------*
* Data       | Solicitante/         | Descrição da alteração           *
* Request    | Responsável          |                                  *
*----------------------------------------------------------------------*
* 03.04.2008 | José Eustáquio       | Codificação Inicial              *
* xxxxxxxxxx | Rodrigo Bernardo     |                                  *
*----------------------------------------------------------------------*

  TYPE-POOLS ctslg.

  FIELD-SYMBOLS: <ls_request> TYPE ctslg_request_info,
                 <system>     TYPE ctslg_system,
                 <step>       TYPE ctslg_step,
                 <action>     TYPE ctslg_action.

  TYPES: BEGIN OF ty_status,
           del_qas(1) TYPE c,
           del_vir(1) TYPE c,
           sem_qas(1) TYPE c,
           sem_vir(1) TYPE c,
         END OF ty_status.

  DATA: st_e070 TYPE e070.

  DATA: st_settings TYPE ctslg_settings,
        st_requests TYPE ctslg_request_info,
        st_status   TYPE ty_status,
        it_requests TYPE ctslg_request_infos.

  DATA: l_user   TYPE e070-as4user,
        l_rej(1) TYPE c.
*        lc_qas(3) TYPE c VALUE 'EQ4',
*        lc_vir(3) TYPE c VALUE 'EV4',
*        lc_prd(3) TYPE c VALUE 'EP4'.

  st_settings-detailed_depiction = 'X'.

  CALL FUNCTION 'TR_READ_GLOBAL_INFO_OF_REQUEST'
    EXPORTING
      iv_trkorr   = pe_trkorr
      iv_dir_type = 'T'
      is_settings = st_settings
    IMPORTING
      es_cofile   = st_requests-cofile
      ev_user     = l_user
      ev_project  = st_requests-project.

  REFRESH: it_requests.

  APPEND st_requests TO it_requests.

  CLEAR: ps_dt_qas, ps_hr_qas, ps_rc_qas,
         ps_dt_prd, ps_hr_prd, ps_rc_prd,
         ps_status, st_status,
         ps_dt_qas_autoriz, ps_hr_qas_autoriz, ps_hr_prd_final,
         ps_dt_prd_marc_imp, ps_hr_prd_marc_imp.

  SELECT SINGLE * INTO st_e070
    FROM e070
   WHERE trkorr = pe_trkorr.

  IF st_e070-trstatus EQ 'D' OR
     st_e070-trstatus EQ 'L'.
    ps_status = c_dev.                                      "'1-DEV'.
    EXIT.
  ENDIF.

  LOOP AT it_requests ASSIGNING <ls_request>.

    IF <ls_request>-cofile-systems[] IS INITIAL.
      EXIT.
    ENDIF.

    CLEAR l_rej.

*-- Tratar importação QAS
    LOOP AT <ls_request>-cofile-systems ASSIGNING <system>
                                          WHERE systemid = c_eq4. "lc_qas.

      LOOP AT <system>-steps ASSIGNING <step>.
        IF <step>-stepid = 'q'.
          CLEAR: st_status-del_qas, st_status-sem_qas.
          LOOP AT <step>-actions ASSIGNING <action>.
            ps_dt_qas_autoriz = <action>-date.
            ps_hr_qas_autoriz = <action>-time.
          ENDLOOP.
          EXIT.
        ENDIF.

*------ Início bloco de importação
        IF <step>-stepid = 'I'.
          CLEAR: ps_dt_qas, ps_hr_qas, ps_rc_qas.
        ENDIF.

*------ Verificar se foi eliminado do buffer
        IF <step>-stepid EQ '>'.
          st_status-del_qas = 'S'.
        ENDIF.

        CHECK <step>-stepid NE '<' AND <step>-stepid NE '>'.

        LOOP AT <step>-actions ASSIGNING <action>.

          IF <step>-stepid = 'I'.
            ps_dt_qas = <action>-date.
            ps_hr_qas = <action>-time.
          ENDIF.

          ps_rc_qas = <action>-rc.

        ENDLOOP.

      ENDLOOP.

    ENDLOOP.

    IF sy-subrc NE 0.
      st_status-sem_qas = 'S'.
    ENDIF.

*-- Tratar importação PRD
    LOOP AT <ls_request>-cofile-systems ASSIGNING <system>
                                          WHERE systemid = c_ep4. "lc_prd.

      LOOP AT <system>-steps ASSIGNING <step>.
        IF <step>-stepid = 'q'.
          CLEAR: l_rej.
          LOOP AT <step>-actions ASSIGNING <action>.
            ps_dt_qas_autoriz = <action>-date.
            ps_hr_qas_autoriz = <action>-time.
          ENDLOOP.
*          EXIT.
        ENDIF.
*------ Início bloco de importação
        IF <step>-stepid = 'I'.
          CLEAR: ps_dt_prd, ps_hr_prd, ps_rc_prd.
*------ Foi eliminado do buffer
        ELSEIF <step>-stepid = '>' OR <step>-stepid = '|'.
          l_rej = 'S'.
        ENDIF.

        CHECK <step>-stepid NE '>'.

        LOOP AT <step>-actions ASSIGNING <action>.
***---> BOC BXMUKK 04/08/2025, Based on RISE migration
          IF <step>-stepid = 'I' OR <step>-stepid = '('.
            ps_dt_prd = <action>-date.
            ps_hr_prd = <action>-time.
          ENDIF.
***---> EOC BXMUKK Based on RISE migration
          IF <step>-stepid EQ '<'.
            ps_dt_prd_marc_imp = <action>-date.
            ps_hr_prd_marc_imp = <action>-time.
          ELSE.
            ps_rc_prd       = <action>-rc.
            ps_hr_prd_final = <action>-time.
          ENDIF.

        ENDLOOP.

      ENDLOOP.

    ENDLOOP.

*-- Verificar rejeição no Virtual
*    IF l_rej NE 'S'.
    LOOP AT <ls_request>-cofile-systems ASSIGNING <system>
                                          WHERE systemid = c_ev4. "lc_vir.
      LOOP AT <system>-steps ASSIGNING <step>.
        IF <step>-stepid = 'q'.
          CLEAR: l_rej, st_status-del_vir, st_status-sem_vir.
          LOOP AT <step>-actions ASSIGNING <action>.
            ps_dt_qas_autoriz = <action>-date.
            ps_hr_qas_autoriz = <action>-time.
          ENDLOOP.
          EXIT.
        ENDIF.
        IF <step>-stepid = '|' OR <step>-stepid = '>'.
          l_rej = 'S'.
          st_status-del_vir = 'S'.
*            EXIT.
        ENDIF.
      ENDLOOP.
      IF l_rej = 'S'.
*          EXIT.
      ENDIF.
    ENDLOOP.
    IF sy-subrc NE 0.
      st_status-sem_vir = 'S'.
    ENDIF.
*    ENDIF.

*-- Determinar status
    IF  st_status-del_qas = 'S' AND
        ps_dt_qas IS INITIAL AND
        ps_dt_prd IS INITIAL AND
      ( st_status-del_vir = 'S' OR
        st_status-sem_vir = 'S' ).
      ps_status = c_rej.                                    "'4-REJ'.
      EXIT.
    ENDIF.

    IF ( st_status-del_vir = 'S' OR st_status-sem_vir = 'S' ) AND
         ps_dt_qas IS INITIAL AND ps_dt_prd IS INITIAL AND
         st_status-sem_vir NE 'S'.
      ps_status = c_rej.                                    "'4-REJ'.
      EXIT.
    ENDIF.

    IF st_status-sem_qas NE 'S' AND ps_dt_qas IS INITIAL AND  ps_dt_prd IS INITIAL.
      ps_status = c_dev.                                    "'1-DEV'.
    ENDIF.

    IF NOT ps_dt_qas IS INITIAL AND ps_dt_prd IS INITIAL.
      ps_status = c_qas.                                    "'2-QAS'.
    ENDIF.

    IF NOT ps_dt_qas IS INITIAL AND NOT ps_dt_prd IS INITIAL.
      ps_status = c_prd.                                    "'3-PRD'.
    ENDIF.

    IF NOT ps_dt_qas IS INITIAL AND ps_dt_prd IS INITIAL AND
      l_rej = 'S'.
      ps_status = c_rej.                                    "'4-REJ'.
    ENDIF.

    IF st_status-sem_qas = 'S'.
      ps_status = c_erd.                                    "'6-ERD'.
    ENDIF.

  ENDLOOP.

  IF ps_status IS INITIAL.
    ps_status = c_slo.                                      "'5-SLO'.
  ENDIF.
ENDFUNCTION.
