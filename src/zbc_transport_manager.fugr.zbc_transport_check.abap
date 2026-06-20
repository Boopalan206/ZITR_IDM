FUNCTION zbc_transport_check.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  CHANGING
*"     REFERENCE(IT_REQUESTS_ORIG) TYPE  CTS_TRKORRS
*"     REFERENCE(IT_RETURN) TYPE  ZSTGEC001
*"----------------------------------------------------------------------
  TYPES: BEGIN OF ty_tasks,
           trkorr     TYPE e070-trkorr,
           as4user    TYPE e070-as4user,
           trfunction TYPE e070-trfunction,
           trstatus   TYPE e070-trstatus,
         END OF ty_tasks.

  DATA: it_requests        TYPE cts_trkorrs,
        it_requests_a      TYPE cts_trkorrs,
        it_requests_d      TYPE cts_trkorrs,
        it_requests_orig_a TYPE cts_trkorrs,
        it_e071            TYPE STANDARD TABLE OF e071,
        it_e071k           TYPE STANDARD TABLE OF e071k,
        it_e071_ob         TYPE STANDARD TABLE OF e071,
        it_e071k_ob        TYPE STANDARD TABLE OF e071k,
        it_tasks           TYPE STANDARD TABLE OF ty_tasks,
        it_log_req         TYPE STANDARD TABLE OF ty_transport_log.

  DATA: st_requests        LIKE LINE OF it_requests,
        st_requests_orig   LIKE LINE OF it_requests,
        st_transport_log_o TYPE ty_transport_log,
        st_e071            TYPE e071,
        st_e071k           TYPE e071k,
        st_e071_ob         TYPE e071,
        st_e071k_ob        TYPE e071k,
        st_return          TYPE zstgee018.

  DATA: l_tabix     TYPE sy-tabix,
        l_as4user   TYPE e070-as4user,
        l_as4user_a TYPE e070-as4user.

  REFRESH it_return.

  it_requests_orig_a[] = it_requests_orig[].

  SORT it_requests_orig_a BY trkorr.

  LOOP AT it_requests_orig INTO st_requests_orig.

    REFRESH:  it_tasks, it_e071, it_e071k.

*-- Selecionar usuário da request
    SELECT SINGLE as4user INTO l_as4user
      FROM e070
     WHERE trkorr = st_requests_orig-trkorr.

*-- Selecionar objetos da request
    SELECT * INTO TABLE it_e071
      FROM e071
     WHERE trkorr = st_requests_orig-trkorr.

*-- Selecionar chaves da request
    SELECT * INTO TABLE it_e071k
      FROM e071k
     WHERE trkorr = st_requests_orig-trkorr.

*-- Selecionar tasks e usuários
    SELECT trkorr as4user trfunction trstatus INTO TABLE it_tasks
      FROM e070
     WHERE strkorr = st_requests_orig-trkorr.

* Selecionar objetos das tasks
    IF sy-subrc EQ 0.
      SELECT * APPENDING TABLE it_e071
        FROM e071 FOR ALL ENTRIES IN it_tasks
       WHERE trkorr = it_tasks-trkorr.
      SELECT * APPENDING TABLE it_e071k
        FROM e071k FOR ALL ENTRIES IN it_tasks
       WHERE trkorr = it_tasks-trkorr.
    ENDIF.

    DELETE it_e071 WHERE object = 'RELE'.

    CHECK NOT it_e071[] IS INITIAL.

    SORT: it_e071  BY pgmid object obj_name,
          it_e071k BY pgmid object objname mastertype mastername.

    DELETE ADJACENT DUPLICATES FROM it_e071
                                      COMPARING pgmid object obj_name.

    DELETE ADJACENT DUPLICATES FROM it_e071k
                                      COMPARING pgmid object objname
                                                mastertype mastername.
    SORT it_requests_d BY trkorr.

    DELETE ADJACENT DUPLICATES FROM it_requests_d.

*-- Bucar log da request de origem
    PERFORM transport_log_read USING st_requests_orig-trkorr.

    st_transport_log_o = st_transport_log.

    LOOP AT it_e071 INTO st_e071.

      REFRESH: it_requests, it_log_req.

*---- Selecionar request por objeto
      SELECT e070~trkorr
           INTO TABLE it_requests_a
        FROM e071 JOIN e070
          ON e071~trkorr = e070~trkorr
       WHERE e071~pgmid    =    st_e071-pgmid
         AND e071~object   =    st_e071-object
         AND e071~obj_name =    st_e071-obj_name
         AND e070~trfunction IN ('K', 'W')
         AND e070~trstatus   IN ('R', 'N').

      SORT it_requests_a BY trkorr.

      DELETE ADJACENT DUPLICATES FROM it_requests_a.

      DELETE it_requests_a WHERE trkorr(4) NE 'ED4K'.

      LOOP AT it_requests_a INTO st_requests .
        l_tabix = sy-tabix.
*        READ TABLE it_requests_d
*              WITH KEY trkorr = st_requests-trkorr
*            TRANSPORTING NO FIELDS.
*        IF sy-subrc EQ 0.
*          DELETE it_requests_a INDEX l_tabix.
*          CONTINUE.
*        ENDIF.
*        IF st_requests-trkorr+5(1) NA sy-abcde.
*          DELETE it_requests_a INDEX l_tabix.
*          APPEND st_requests TO it_requests_d.
*          CONTINUE.
*        ENDIF.
        READ TABLE it_requests_orig_a
                  WITH KEY trkorr = st_requests-trkorr
           TRANSPORTING NO FIELDS BINARY SEARCH.
        IF sy-subrc EQ 0.
          DELETE it_requests_a INDEX l_tabix.
          APPEND st_requests TO it_requests_d.
          CONTINUE.
        ENDIF.
        PERFORM transport_log_read USING st_requests-trkorr.
        IF st_transport_log-status = '4-DEL'.
          DELETE it_requests_a INDEX l_tabix.
          APPEND st_requests TO it_requests_d.
          CONTINUE.
        ENDIF.

*------ Request fora está só no QAS
        IF     st_transport_log-dt_prd IS INITIAL AND
           NOT st_transport_log-dt_qas IS INITIAL.

**-------- Se Data no QAS da Request Origem for menor
**-------- que a Data no QAS da Request fora, está OK
*          IF st_transport_log_o-dt_qas < st_transport_log-dt_qas.
*            DELETE it_requests_a INDEX l_tabix.
*            APPEND st_requests TO it_requests_d.
*            CONTINUE.
*          ENDIF.

*------ Request fora está em PRD ou DEV
        ELSE.
          IF st_transport_log_o-dt_qas IS INITIAL.
            DELETE it_requests_a INDEX l_tabix.
            APPEND st_requests TO it_requests_d.
            CONTINUE.
          ENDIF.
          IF st_transport_log_o-dt_qas > st_transport_log-dt_prd.
            DELETE it_requests_a INDEX l_tabix.
            APPEND st_requests TO it_requests_d.
            CONTINUE.
          ENDIF.

          IF st_transport_log-status = '3-PRD' AND
            st_transport_log_o-dt_qas > st_transport_log-dt_qas.
            DELETE it_requests_a INDEX l_tabix.
            APPEND st_requests TO it_requests_d.
            CONTINUE.
          ENDIF.

          IF st_transport_log_o-dt_qas = st_transport_log-dt_prd AND
             st_transport_log_o-hr_qas > st_transport_log-hr_prd.
            DELETE it_requests_a INDEX l_tabix.
            APPEND st_requests TO it_requests_d.
            CONTINUE.
          ENDIF.
        ENDIF.
***---> BOC BXMUKK 04/08/2025, Based on RISE migration
        IF st_transport_log-status  = '3-EP4'.
          DELETE it_requests_a INDEX l_tabix.
          APPEND st_requests TO it_requests_d.
          CONTINUE.
        ENDIF.
***---> EOC BXMUKK Based on RISE migration
        APPEND st_transport_log TO it_log_req.
      ENDLOOP.

      CHECK NOT it_requests_a[] IS INITIAL.

      CLEAR st_e071k.
      READ TABLE it_e071k WITH KEY mastertype = st_e071-object
                                   mastername = st_e071-obj_name
                                       INTO st_e071k.

      IF sy-subrc EQ 0.
        SELECT trkorr
             INTO TABLE it_requests
          FROM e071k FOR ALL ENTRIES IN it_requests_a
         WHERE trkorr  = it_requests_a-trkorr
           AND pgmid      = st_e071k-pgmid
           AND object     = st_e071k-object
           AND objname    = st_e071k-objname
           AND mastername = st_e071-obj_name
           AND mastertype = st_e071-object
           AND tabkey     = st_e071k-tabkey.
      ELSE.
        it_requests[] = it_requests_a[].
      ENDIF.

      SORT it_requests BY trkorr.

      DELETE ADJACENT DUPLICATES FROM it_requests.

      PERFORM transport_text_read USING st_requests_orig-trkorr ' '.

      LOOP AT it_requests INTO st_requests.
        MOVE-CORRESPONDING st_e071 TO st_return.
        st_return-trkorr      = st_requests_orig-trkorr.
        st_return-as4text     = g_as4text.
        st_return-as4user     = l_as4user.
        st_return-trkorr_f    = st_requests-trkorr.
        PERFORM transport_text_read USING st_requests-trkorr 'F'.
        st_return-as4text_f   = g_as4text_f.
        CLEAR st_transport_log.
        READ TABLE it_log_req WITH KEY trkorr = st_requests-trkorr
                                  INTO st_transport_log.
        st_return-status_f    = st_transport_log-status.
        SELECT SINGLE as4user INTO l_as4user_a
          FROM e070
         WHERE trkorr = st_requests-trkorr.
        st_return-as4user_f   = l_as4user_a.
        st_return-object_key  = st_e071k-object.
        st_return-objname_key = st_e071k-objname.
        st_return-tabkey      = st_e071k-tabkey.
        APPEND st_return TO it_return.
      ENDLOOP.

    ENDLOOP.
  ENDLOOP.

ENDFUNCTION.
