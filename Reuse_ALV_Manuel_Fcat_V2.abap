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
TYPES: BEGIN OF gty_list, "2farklı tablo
         ebeln TYPE ebeln,
         ebelp TYPE ebelp,
         bstyp TYPE ebstyp,
         bsart TYPE esart,
         matnr TYPE matnr,
         menge TYPE bstmg,
         meins TYPE meins,
       END OF gty_list.

DATA: gt_list TYPE TABLE OF gty_list, "REUSE ALVYE VERİLECEK OLAN TABLONUN TİP TANIMLAMASI
      gs_list TYPE gty_list.

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
  PERFORM: set_fc_sub USING 'EBELN' 'SAS No' 'SAS Numarası' 'SAS Numarası' abap_true,
           set_fc_sub USING 'EBELP' 'KALEM' 'KALEM' 'KALEM' abap_true,
           set_fc_sub USING 'BSTYP' 'Belge T' 'Belge Tipi' 'Belge Tipi' abap_false,
           set_fc_sub USING 'BSART' 'Belge Tr' 'Belge Türü' 'Belge Türü' abap_false,
           set_fc_sub USING 'MATNR' 'MALZEME' 'MALZEME' 'MALZEME' abap_false,
           set_fc_sub USING 'MENGE' 'MİKTAR' 'MİKTAR' 'MİKTAR' abap_false,
           set_fc_sub USING 'MEINS' 'OB' 'OLCU BİRİM' 'OLCU BİRİM' abap_false.
endform.


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


*&---------------------------------------------------------------------*
*& Form set_fc_sub
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fc_sub USING p_fieldname
                      p_seltext_s
                      p_seltext_m
                      p_seltext_l
                      p_key.
  gs_fieldcat-fieldname = p_fieldname. "ÇEKİLEN VERİNİN EBELN ALANI İLE FİELDCAT EŞLEŞTİRMESİ
  gs_fieldcat-seltext_s = p_seltext_s. "başlıklar kısa
  gs_fieldcat-seltext_m = p_seltext_m."başlıklar orta
  gs_fieldcat-seltext_l = p_seltext_l."başlıklar uzun
  gs_fieldcat-key = p_key. "alanın key olup olmadığını belirten renk
  APPEND gs_fieldcat to gt_fieldcat.
ENDFORM.
