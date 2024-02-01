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


DATA: BEGIN OF gt_list OCCURS 0,
        ebeln LIKE ekko-ebeln,
        ebelp LIKE ekpo-ebelp,
        bstyp LIKE ekko-bstyp,
        bsart LIKE ekko-bsart,
        matnr LIKE ekpo-matnr,
        menge LIKE ekpo-menge,
        meins LIKE ekpo-meins,
        statu LIKE ekpo-statu,

      END OF gt_list.



TYPES: BEGIN OF gty_list,
         selkz      TYPE char1,
         ebeln      TYPE ebeln,
         ebelp      TYPE ebelp,
         bstyp      TYPE ebstyp,
         bsart      TYPE esart,
         matnr      TYPE matnr,
         menge      TYPE bstmg,
         meins      TYPE meins,
         line_color TYPE char4,
         cell_color TYPE slis_t_specialcol_alv, "CELL COLOR İÇİN ÖZEL TANIMALAMA
       END OF gty_list.

DATA: gt_list1 TYPE TABLE OF gty_list,
      gs_list  TYPE gty_list.



DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
      gs_fieldcat TYPE slis_fieldcat_alv.



DATA: gs_layout TYPE slis_layout_alv.

DATA: gt_events TYPE slis_t_event,
      gs_event  TYPE slis_alv_event.

DATA: gt_exclude TYPE slis_t_extab, "EXCLUDE İÇİN GEREKLİ TANIMLAMALAR
      gs_exclude TYPE slis_extab.

DATA: gt_sort TYPE slis_t_sortinfo_alv, "kolon bazında avl sıralamak için gerekli
      gs_sort TYPE slis_sortinfo_alv.

DATA: gt_filter type slis_t_filter_alv, "Fılter için gerekli
      gs_filter type slis_filter_alv.





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
    INTO CORRESPONDING FIELDS OF TABLE gt_list1.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fc
*&---------------------------------------------------------------------*
FORM set_fc .
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name     = sy-repid
      i_internal_tabname = 'GT_LIST' "STRUCTURE TIPINDE ITAB verilmesini ister
*     I_STRUCTURE_NAME   =
      i_inclname         = sy-repid
    CHANGING
      ct_fieldcat        = gt_fieldcat.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout
*&---------------------------------------------------------------------*
FORM set_layout .
  gs_layout-window_titlebar = 'REUSE ALV BAŞLIK'.
  gs_layout-zebra = abap_true.
  gs_layout-colwidth_optimize = abap_true. "
ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_alv
*&---------------------------------------------------------------------*
FORM display_alv.

  "INFO TUŞU KALDIRILDI
  gs_exclude-fcode = '&INFO'. "alvdeki butonların fcodunu buraya yazarsak ilgili buton kaldırılacaktır.
  APPEND gs_exclude TO gt_Exclude.

  "SORTING
  gs_sort-spos = 1. "Birinci ÖNCELİK
  gs_sort-tabname = 'GT_LIST1'.
  gs_sort-fieldname = 'BSART'.
  gs_sort-down      = abap_true. "büyükten küçüğe doğru mu
  APPEND gs_sort TO gt_sort.

  gs_sort-spos = 2. "İkinci ÖNCELİK
  gs_sort-tabname = 'GT_LIST1'.
  gs_sort-fieldname = 'MENGE'.
  gs_sort-up      = abap_true. "Küçükten büyüğe doğru doğru mu
  APPEND gs_sort TO gt_sort.

  gs_filter-tabname = 'GT_LIST1'.
  gs_filter-fieldname = 'EBELP'.
  gs_filter-sign0 = 'I'. "İLGİLİ SO DEĞERLERİNİN DAHİLİ KISMINI MI GETİRSİN HARİCİ KISMINI MI
  gs_filter-optio = 'EQ'. "BETWEEN Mİ EQ GİBİ Mİ
  gs_filter-valuf_int = 10.
  APPEND gs_filter TO gt_filter.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
*     i_callback_pf_status_set = 'PF_STATUS_SET'
*     I_CALLBACK_USER_COMMAND  = ' '
*     i_callback_top_of_page   = 'TOP_OF_PAGE_DENEME'
      is_layout          = gs_layout
      it_fieldcat        = gt_fieldcat
      it_events          = gt_events
      it_excluding       = gt_exclude
      it_sort            = gt_sort
      it_filter          = gt_filter
    TABLES
      t_outtab           = gt_list1.
ENDFORM.











      
