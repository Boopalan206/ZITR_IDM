*&---------------------------------------------------------------------*
*& Include          ZITR_IDM_R_MAIL_TRIGGER_01
*&---------------------------------------------------------------------*
TYPES : BEGIN OF ty_edidc,
          mestyp TYPE edi_mestyp,
          docnum TYPE edi_docnum,
          status TYPE edi_text60,
          direct TYPE edi_direct,
          credat TYPE sy-datum,
          cretim TYPE edi_ccrtim,
        END OF ty_edidc.

TYPES : BEGIN OF ty_edids,
          zmandt TYPE char3,
          docnum TYPE edi_docnum,
          logdat TYPE edi_logdat,
          logtim TYPE edi_logtim,
          countr TYPE edi_countr,
          statxt TYPE edi_statx_,
          stapa1 TYPE edi_stapa1,
          stapa2 TYPE edi_stapa2,
          stapa3 TYPE edi_stapa3,
          stapa4 TYPE edi_stapa4,
        END OF ty_edids.

TYPES : BEGIN OF ty_count,
          mestyp TYPE edi_mestyp,
          count  TYPE i,
          date   TYPE sy-datum,
          direct TYPE char10,
        END OF ty_count.

TYPES : BEGIN OF ty_count1,
          mestyp TYPE edi_mestyp,
          count  TYPE i,
          direct TYPE char10,
        END OF ty_count1.
TYPES : BEGIN OF ty_doc,
          sno TYPE char4,
          mode   TYPE char10,
          mestyp TYPE char10,
          docnum TYPE edi_docnum,
          status TYPE char2,
          odate  TYPE char10,
          time   TYPE char8,
          rdate  TYPE char10,
          comm   TYPE char10,
          reason TYPE string,
        END OF ty_doc.
 TYPES : BEGIN OF ty_att,
           sno TYPE char4,
          mode   TYPE char10,
          mestyp TYPE char10,
          docnum TYPE edi_docnum,
          status TYPE char2,
          odate  TYPE sy-datum,
          time   TYPE sy-uzeit,
          rdate  TYPE char10,
          comm   TYPE char10,
          reason TYPE string,
        END OF ty_att.

TYPES : BEGIN OF ty_attach,
          data TYPE string,
        END OF ty_attach.

DATA : lt_attach TYPE TABLE OF ty_attach,
       ls_attach TYPE ty_attach.

DATA : lt_edidc  TYPE TABLE OF ty_edidc,
       ls_edidc  TYPE ty_edidc,
       lt_table1 TYPE TABLE OF ty_count,
       ls_table1 TYPE ty_count,
       lt_table2 TYPE TABLE OF ty_count1,
       ls_table2 TYPE ty_count1,
       lt_edidc1 TYPE TABLE OF ty_edidc,
       ls_edidc1 TYPE ty_edidc,
       lt_edids TYPE TABLE OF ty_edids,
       ls_edids TYPE ty_edids,
       lt_doc    TYPE TABLE OF ty_doc,
       ls_doc    TYPE ty_doc,
       lt_count  TYPE TABLE OF ty_count,
       ls_count  TYPE ty_count,
       lt_count1 TYPE TABLE OF ty_count1,
       ls_count1 TYPE ty_count1,
       lt_att TYPE TABLE OF ty_att,
       ls_att TYPE ty_att.
DATA : lv_count     TYPE i,
       lv_count1    TYPE i,
       date         TYPE p0001-begda,
       lv_day(02)   TYPE c,
       lv_month(02) TYPE c,
       lv_year(04)  TYPE c,
       lv_para1 TYPE char70,
       lv_para2 TYPE char70,
       lv_para3 TYPE char70,
       lv_para4 TYPE char70.

DATA : lv_mail TYPE soobjinfi1-obj_name,
       lt_to TYPE TABLE OF tvarvc,
       lt_cc TYPE TABLE OF tvarvc,
       ls_to TYPE tvarvc,
       ls_cc TYPE tvarvc,
       lt_from TYPE TABLE OF tvarvc,
       ls_bcc TYPE tvarvc,
        lt_bcc TYPE TABLE OF tvarvc,
       ls_from TYPE tvarvc.
DATA : t_header      TYPE STANDARD TABLE OF w3head WITH HEADER LINE, "Header
       t_header1     TYPE STANDARD TABLE OF w3head WITH HEADER LINE, "Header
       t_fields      TYPE STANDARD TABLE OF w3fields WITH HEADER LINE, "Fields
       t_fields1     TYPE STANDARD TABLE OF w3fields WITH HEADER LINE, "Fields
       t_html_x      TYPE STANDARD TABLE OF w3html, "Html
       t_html_x1     TYPE STANDARD TABLE OF w3html, "Html
       t_html_x2     TYPE STANDARD TABLE OF w3html, "Html
       ls_html_x     TYPE  w3html, "Html
       ls_html_x1    TYPE  w3html, "Html
       ls_html_x2    TYPE  w3html, "Html
       wa_header     TYPE w3head,
       wa_header1    TYPE w3head,
       w_head        TYPE w3head,
       w_head1       TYPE w3head,
       t_html        TYPE STANDARD TABLE OF soli,
       it_attachment TYPE solix_tab,
       wa_receivers  TYPE uiys_iusr,
       wa_from  TYPE uiys_iusr,
       wa_sender  TYPE uiys_iusr,
       ld_subject    TYPE so_obj_des,
       send_email    TYPE REF TO cl_bcs,
       it_fcat       TYPE lvc_t_fcat WITH HEADER LINE,
       it_fcat1      TYPE lvc_t_fcat WITH HEADER LINE.

DATA : lv_xml_type TYPE salv_bs_constant,
       lv_xml      TYPE xstring,
       lv_xlscont  TYPE solix_tab,
       lv_xls_size TYPE so_obj_len.
DATA :go_alv_table TYPE REF TO cl_salv_table,
      lt_text      TYPE bcsy_text,
      lv_hrs       TYPE char2,
      lv_min       TYPE char2,
      lv_sec       TYPE char2,
      lv_to TYPE RVARI_VNAM,
      lv_from TYPE RVARI_VNAM,
      lv_cc TYPE RVARI_VNAM,
      lv_bcc TYPE RVARI_VNAM.

DATA: send_request  TYPE REF TO cl_bcs,
      text          TYPE bcsy_text,
      ls_text       TYPE soli,
      document      TYPE REF TO cl_document_bcs,
*      sender        TYPE REF TO cl_sapuser_bcs,
      recipient     TYPE REF TO if_recipient_bcs,
       sender      TYPE  REF TO cl_cam_address_bcs ,
      bcs_exception TYPE REF TO cx_bcs,
      sent_to_all   TYPE os_boolean.

DATA : lv_sno TYPE i.
