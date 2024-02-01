*&---------------------------------------------------------------------*
*& Report ZAB_C4
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zab_c4.

include zab_c4_top.
include zab_c4_frm.

START-OF-SELECTION.

  PERFORM get_data.
  PERFORM set_fc.
  PERFORM set_layout.
  PERFORM display_alv.


  *&---------------------------------------------------------------------*
*& Include          ZAB_C4_TOP
*&---------------------------------------------------------------------*


"FIELDCAT MERGE ILE KULLANILACAK LOCAL STRUCTURE TANIMLAMASI(i_internal_tabname YERINDE KULLANILACAK)
DATA: BEGIN OF gt_list OCCURS 0,
        ebeln LIKE ekko-ebeln,  "TYPE YERINE LIKE KULLANILMASI DAHA STABIL OLMASINI SAĞLIYOR BU CASE'DE
        ebelp LIKE ekpo-ebelp,
        bstyp LIKE ekko-bstyp,
        bsart LIKE ekko-bsart,
        matnr LIKE ekpo-matnr,
        menge LIKE ekpo-menge,
        meins LIKE ekpo-meins,
        statu LIKE ekpo-statu,
      END OF gt_list. "AYRICA DATA TANIMLAMASI YAPILMASINA GEREK YOK.


"2 farklı tablonın birleşimi
TYPES: BEGIN OF gty_list,
         ebeln TYPE ebeln,
         ebelp TYPE ebelp,
         bstyp TYPE ebstyp,
         bsart TYPE esart,
         matnr TYPE matnr,
         menge TYPE bstmg,
         meins TYPE meins,
       END OF gty_list.

DATA: gs_list TYPE gty_list.



DATA: gt_fieldcat TYPE slis_t_fieldcat_alv, "tablo
      gs_fieldcat TYPE slis_fieldcat_alv.   "structure


"LAYOUT DÜZENLEMELERİ İÇİN
DATA: gs_layout TYPE slis_layout_alv.

DATA: gt_events TYPE slis_t_event,
      gs_event  TYPE slis_alv_event.


*&---------------------------------------------------------------------*
*& Include          ZAB_C4_FRM
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
FORM get_data .
  SELECT
    ekko~ebeln
    ekpo~ebelp
    ekko~bstyp
    ekko~bsart
    ekpo~matnr
    ekpo~menge
    ekpo~meins
    FROM ekko
    INNER JOIN ekpo ON  ekpo~ebeln EQ ekko~ebeln
    INTO TABLE gt_list.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fc
*&---------------------------------------------------------------------*
FORM set_fc .
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name     = sy-repid "programın adını tutar
      i_internal_tabname = 'GT_LIST' "ITAB verilmesini ister
*     I_STRUCTURE_NAME   =
      i_inclname         = sy-repid
    CHANGING
      ct_fieldcat        = gt_fieldcat.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout
*&---------------------------------------------------------------------*
FORM set_layout .
  gs_layout-window_titlebar = 'REUSE ALV BAŞLIK'. "alv başlık ismi değiştirme
  gs_layout-zebra = abap_true. "zebra layout
  gs_layout-colwidth_optimize = abap_true. "kolon genişliklerini optimize eder
ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_alv
*&---------------------------------------------------------------------*
FORM display_alv.

  gs_event-name = slis_ev_pf_status_set.
  gs_event-form = 'PF_STATUS_SET'.
  APPEND gs_event to gt_events.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid               "CALLBACK BİR YAPILAR TOPLULUĞUDUR I_CALLBACK_PROGRAM HANGİ PROGRAMIN İÇERİSİNDE OLDUĞUNU DEKLARE EDER.
*     i_callback_pf_status_set = 'PF_STATUS_SET'        "ÖRNEĞİN PF_STATUS_sET İLE GUİ STATUS ATAMASI
*     I_CALLBACK_USER_COMMAND  = ' '                    "USER COMMAND İLE BU GUİ STATUSÜN TUŞLARINI ÇEŞİTLENDİREBİLİRİZ
*     i_callback_top_of_page   = 'TOP_OF_PAGE_DENEME'   "ALVDE BAŞLIK EKRANI EKLEMEK İÇİN GEREKEN CALLBACK YAPISI
      is_layout                = gs_layout
      it_fieldcat              = gt_fieldcat
      it_events                = gt_events              "it_events Callback'in gelişmiş versiyonudur
    TABLES
      t_outtab                 = gt_list.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form pf_status_set
*&---------------------------------------------------------------------*
FORM pf_status_set using p_extab type slis_t_extab.
  set PF-STATUS 'ZSTANDARD'. "PROGRAMDAKİ GUİ STATUSUN İSMİ
ENDFORM.      
