FUNCTION-POOL zbc_transport_manager.        "MESSAGE-ID ..

TYPE-POOLS: trwbo.

TABLES: ko008, ko013, e070c.

INCLUDE: rddkorri,
         ctsproject.

TYPES: BEGIN OF ty_transport_log,
         trkorr TYPE e070-trkorr,
         status TYPE zste_stattr,
         dt_qas TYPE d,
         hr_qas TYPE t,
         rc_qas TYPE i,
         dt_prd TYPE d,
         hr_prd TYPE t,
         rc_prd TYPE i,
       END OF ty_transport_log.

CONTROLS: ctl_tasks TYPE TABLEVIEW   USING SCREEN 102.

DATA: BEGIN OF gt_tasks OCCURS 13,
        user LIKE ko013-as4user,
      END   OF gt_tasks.

CONSTANTS:
* Status
  c_dev(5) TYPE c VALUE '1-ED4',
  c_qas(5) TYPE c VALUE '2-EQ4',
  c_prd(5) TYPE c VALUE '3-EP4',
  c_rej(5) TYPE c VALUE '4-DEL',
  c_slo(5) TYPE c VALUE '5-NLO',
  c_erd(5) TYPE c VALUE '6-ERD',
* Environments
  c_ed4(3) TYPE c VALUE 'ED4',
  c_eq4(3) TYPE c VALUE 'EQ4',
  c_ev4(3) TYPE c VALUE 'EV4',
  c_ep4(3) TYPE c VALUE 'EP4',
* Transport number
  c_trn(4) TYPE c VALUE 'ED4K'.

*-- for TR_REQUEST_MODIFY----------------------------------------------*
DATA: gv_action             LIKE sy-ucomm,
      gv_something_changed  TYPE c,
      gv_client_changed     TYPE c,
      gv_status_changed     TYPE c,
      gv_attributes_changed TYPE c,
      gv_owner_changed      TYPE c,
      gv_trkorr_changeable  TYPE c,

      gs_new_object_list    TYPE trwbo_request_header,
      dv_0100_fcode         LIKE sy-ucomm,
      dv_0100_text(10)      TYPE c,
      ko013_save            LIKE ko013,
      gv_cursor_field(30)   TYPE c,
      gv_cursor_line        TYPE i,

      gv_start_column       TYPE i,
      gv_start_row          TYPE i.

DATA: st_transport_log  TYPE ty_transport_log.

DATA: g_as4text   TYPE e07t-as4text,
      g_as4text_f TYPE e07t-as4text.
