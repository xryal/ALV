*&---------------------------------------------------------------------*
*& Report ZAB_C4
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zab_c4.

INCLUDE zab_c4_top.
INCLUDE zab_c4_frm.

"ÖNAYARLI DEFAULT VARIANT GETİREN KOD
at SELECTION-SCREEN OUTPUT.
  gs_variant_get-report = sy-repid.
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    CHANGING
      cs_variant = gs_variant_get.
  IF sy-subrc EQ 0.
    p_vari = gs_variant_get-variant.
  ENDIF.

"variant seçimi yapabilmek için gerekli olan f4 help'in çağrılması.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant    = gs_variant_get
    IMPORTING
      e_exit        = gv_exit
      es_variant    = gs_variant_get.

  IF sy-subrc EQ 0.
    IF gv_exit is initial.
      p_vari = gs_variant_get-variant.
    ENDIF.
  ENDIF.


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

DATA: gt_exclude TYPE slis_t_extab,
      gs_exclude TYPE slis_extab.

DATA: gt_sort TYPE slis_t_sortinfo_alv,
      gs_sort TYPE slis_sortinfo_alv.

DATA: gt_filter TYPE slis_t_filter_alv,
      gs_filter TYPE slis_filter_alv.

DATA: gs_variant TYPE disvariant.

"ÖNAYARLI DEFAULT VARIANT GETİREN DATA TANIMLAMALARI
DATA: gs_variant_get TYPE disvariant,
      gv_exit type char1.
PARAMETERS: p_vari TYPE disvariant-variant.




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
*I_SAVE  = 'X' verilirse her kullanıcı bu kayıt varyantlarından etkilenir.
*I_SAVE  = 'U' verilirse  user bazlı kayıt gerççekleştirir.
*I_SAVE  = 'A' verilirse kullanıcı özgü varyant kayıt da edilebilir her kullanıcı için de varyant kayıt edilebilir bunun seçimini kullanıcıya bırakır.

"ÖNAYARLI DEFAULT VARIANT GETİREN KOD
gs_variant-variant = p_vari.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      is_layout          = gs_layout
      it_fieldcat        = gt_fieldcat
      it_events          = gt_events
      it_excluding       = gt_exclude
      it_sort            = gt_sort
      it_filter          = gt_filter
      i_save             = 'A'
      i_default          = ''
    TABLES
      t_outtab           = gt_list1.
ENDFORM.












