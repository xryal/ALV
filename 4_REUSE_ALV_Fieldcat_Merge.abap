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



TYPES: BEGIN OF gty_list, "2 farklı tablonın birleşimi
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



DATA: gs_layout TYPE slis_layout_alv. "LAYOUT DÜZENLEMELERİ İÇİN



*&---------------------------------------------------------------------*
*& Include          ZAB_C4_FRM
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
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
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fc .
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name     = sy-repid "programın adını tutar
      i_internal_tabname = 'GT_LIST' "ITAB verilmesini ister
*     I_STRUCTURE_NAME   = "se11 DE tanımlanan structure kullanır.
      i_inclname         = sy-repid
    CHANGING
      ct_fieldcat        = gt_fieldcat.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout .
  gs_layout-window_titlebar = 'REUSE ALV BAŞLIK'. "alv başlık ismi değiştirme
  gs_layout-zebra = abap_true. "zebra layout
  gs_layout-colwidth_optimize = abap_true. "kolon genişliklerini optimize eder
ENDFORM.

*&---------------------------------------------------------------------*
*& Form display_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_alv .
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      is_layout   = gs_layout
      it_fieldcat = gt_fieldcat
    TABLES
      t_outtab    = gt_list.
ENDFORM.
