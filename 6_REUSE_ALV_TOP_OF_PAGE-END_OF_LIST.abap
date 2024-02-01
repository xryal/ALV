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

  "top of page'i it-events yapısını bağladık
  gs_event-name = slis_ev_top_of_page.
  gs_event-form = 'TOP_OF_PAGE_DENEME'. "TOP_OF_PAGE_DENEME FORMUNA BAĞLANIR.
  APPEND gs_event TO gt_events.

  "end of list'i it-events yapısını bağladık
  gs_event-name = slis_ev_end_of_list.
  gs_event-form = 'END_OF_LIST_DENEME'. "END_OF_LIST_DENEME FORMUNA BAĞLANIR.
  APPEND gs_event TO gt_events.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid              "CALLBACK BİR YAPILAR TOPLULUĞUDUR I_CALLBACK_PROGRAM HANGİ PROGRAMIN İÇERİSİNDE OLDUĞUNU DEKLARE EDER.
*     I_CALLBACK_PF_STATUS_SET          = ' '        "ÖRNEĞİN PF_STATUS_sET İLE GUİ STATUS ATAMASI
*     I_CALLBACK_USER_COMMAND           = ' '        "USER COMMAND İLE BU GUİ STATUSÜN TUŞLARINI ÇEŞİTLENDİREBİLİRİZ
*     i_callback_top_of_page = 'TOP_OF_PAGE_DENEME'  "ALVDE BAŞLIK EKRANI EKLEMEK İÇİN GEREKEN CALLBACK YAPISI
      is_layout          = gs_layout
      it_fieldcat        = gt_fieldcat
      it_events          = gt_events                "it_events Callback'in gelişmiş versiyonudur
    TABLES
      t_outtab           = gt_list.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form top_of_page_deneme
*&---------------------------------------------------------------------*
FORM top_of_page_deneme.
  DATA: lt_header TYPE slis_t_listheader, "slis_listheader'dan türeyen tablo ve structure yapısıyla çalışır bu top of page ve end of list yapıları..
        ls_header TYPE slis_listheader.

  DATA: lv_lines TYPE i,
        lv_lines_c type char4.

  DATA lv_date TYPE char10.

  CLEAR: ls_header.
  ls_header-typ = 'H'.
  ls_header-info = 'Satın Alma Şipariş Raporu'.
  APPEND ls_header TO lt_header.

  CLEAR: ls_header.
  ls_header-typ = 'S'.
  ls_header-key = 'Tarih'.
  CONCATENATE sy-datum+6(2)
              '.'
              sy-datum+4(2)
              '.'
              sy-datum+0(4) INTO lv_date.
  ls_header-info = lv_date.
  APPEND ls_header TO lt_header.

  CLEAR: ls_header.
  DESCRIBE TABLE gt_list LINES lv_lines.
  lv_lines_c = lv_lines.
  ls_header-typ = 'A'.
  CONCATENATE 'Raporda Kullanılan Satır Sayısı'
              lv_lines_c
              into ls_header-info
              SEPARATED BY ' '.
  APPEND ls_header TO lt_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_header.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form end_of_list_deneme
*&---------------------------------------------------------------------*
FORM end_of_list_deneme.
  DATA: lt_header TYPE slis_t_listheader, 
        ls_header TYPE slis_listheader.

  DATA: lv_lines TYPE i,
        lv_lines_c type char4.

  DATA lv_date TYPE char10.

  CLEAR: ls_header.
  ls_header-typ = 'H'.
  ls_header-info = 'Satın Alma Şipariş Raporu'.
  APPEND ls_header TO lt_header.

  CLEAR: ls_header.
  ls_header-typ = 'S'.
  ls_header-key = 'Tarih'.
  CONCATENATE sy-datum+6(2)
              '.'
              sy-datum+4(2)
              '.'
              sy-datum+0(4) INTO lv_date.
  ls_header-info = lv_date.
  APPEND ls_header TO lt_header.

  CLEAR: ls_header.
  DESCRIBE TABLE gt_list LINES lv_lines.
  lv_lines_c = lv_lines.
  ls_header-typ = 'A'.
  CONCATENATE 'Raporda Kullanılan Satır Sayısı'
              lv_lines_c
              into ls_header-info
              SEPARATED BY ' '.
  APPEND ls_header TO lt_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_header.
ENDFORM.      
