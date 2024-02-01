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

data: gs_cell_color type slis_specialcol_alv. "CELL COLOR İÇİN ÖZEL TANIMALAMA


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

  "LINE COLOR (SATIR SATIR ÇALIŞIR)
  "COLOR REFERE ETMESİ İÇİN HER ZAMAN İLK KARAKTER C OLMALI
  "COL DEĞERİ 5  "İNT DEĞERİ 0 "INV DEĞERİ 0
  "COL = RENK    "İNT OPACITY  "INV ARKAPLAN RENGİ
  LOOP AT gt_list1 INTO gs_list. "İLK SATIRI AÇIK YEŞİLE BOYUYAN KOD PARÇASI
    IF sy-tabix EQ 1.
      gs_list-line_color = 'C500'.
      MODIFY gt_list1 FROM gs_list.
    ENDIF.
  ENDLOOP.

  "CELL COLOR(HÜCRE VE SÜÜTUN BAZINDA ÇALIŞIR)
  LOOP AT gt_list1 INTO gs_list.
    gs_cell_color-fieldname = 'MATNR'.      "MATNR ALANI KOMPLE KIRMIZI RENGE DÖNÜŞTÜ
    gs_cell_color-color-col = 6.
    gs_cell_color-color-int = 1.
    gs_cell_color-color-inv = 0.
    APPEND gs_cell_color TO gs_list-cell_color.
    MODIFY gt_list1 FROM gs_list.

    gs_cell_color-fieldname = 'BSART'.      "BSART ALANI KOMPLE TURUNCU RENGE DÖNÜŞTÜ
    gs_cell_color-color-col = 7.
    gs_cell_color-color-int = 1.
    gs_cell_color-color-inv = 0.
    APPEND gs_cell_color TO gs_list-cell_color.
    MODIFY gt_list1 FROM gs_list.
  ENDLOOP.
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
  gs_layout-info_fieldname = 'LINE_COLOR'. "Line_color sütunu renklendirme için değerleri tutacak anlamına gelen atama
  gs_layout-coltab_fieldname = 'CELL_COLOR'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_alv
*&---------------------------------------------------------------------*
FORM display_alv.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
*     i_callback_pf_status_set = 'PF_STATUS_SET'
*     I_CALLBACK_USER_COMMAND  = ' '
*     i_callback_top_of_page   = 'TOP_OF_PAGE_DENEME'
      is_layout          = gs_layout
      it_fieldcat        = gt_fieldcat
      it_events          = gt_events
    TABLES
      t_outtab           = gt_list1.
ENDFORM.


