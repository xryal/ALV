REPORT zab_c4.

TYPES: BEGIN OF gty_list, "2farklı tablo
         ebeln TYPE ebeln,
         ebelp TYPE ebelp,
         bstyp TYPE ebstyp,
         bsart TYPE esart,
         matnr TYPE matnr,
         menge TYPE bstmg,
       END OF gty_list.

DATA: gt_list TYPE TABLE OF gty_list, "REUSE ALVYE VERİLECEK OLAN TABLONUN TİP TANIMLAMASI
      gs_list TYPE gty_list.

DATA: gt_fieldcat TYPE slis_t_fieldcat_alv, "tablo
      gs_fieldcat TYPE slis_fieldcat_alv.   "structure

DATA: gs_layout TYPE slis_layout_alv. "LAYOUT DÜZENLEMELERİ İÇİN


START-OF-SELECTION.

  SELECT
    ekko~ebeln
    ekpo~ebelp
    ekko~bstyp
    ekko~bsart
    ekpo~matnr
    ekpo~menge
    FROM ekko
    INNER JOIN ekpo ON  ekpo~ebeln EQ ekko~ebeln
    INTO TABLE gt_list.

  "manuel FCAT
  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'EBELN'. "ÇEKİLEN VERİNİN EBELN ALANI İLE FİELDCAT EŞLEŞTİRMESİ
  gs_fieldcat-seltext_s = 'SAS No'. "başlıklar kısa
  gs_fieldcat-seltext_m = 'SAS Numarası'."başlıklar orta
  gs_fieldcat-seltext_l = 'SAS Numarası'."başlıklar uzun
  gs_fieldcat-key = abap_true. "alanın key olup olmadığını belirten renk
  gs_fieldcat-col_pos = 0. "sütunun kaçıncı sırada olması gerektiğni ayarlıyor
  gs_fieldcat-outputlen = 40."kolon genişliğini ayarlar
  gs_fieldcat-edit = abap_true."editiblie kolon
  gs_fieldcat-do_sum = abap_true."ilgili kolonu toplama işlemine tabii tutar.
  APPEND gs_fieldcat TO gt_fieldcat.
  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'EBELP'.
  gs_fieldcat-seltext_s = 'Kalem'.
  gs_fieldcat-seltext_m = 'Kalem'.
  gs_fieldcat-seltext_l = 'Kalem'.
  gs_fieldcat-key = abap_true.
  APPEND gs_fieldcat TO gt_fieldcat.
  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'BSTYP'.
  gs_fieldcat-seltext_s = 'belge tipi'.
  gs_fieldcat-seltext_m = 'belge tipi'.
  gs_fieldcat-seltext_l = 'belge tipi'.
  APPEND gs_fieldcat TO gt_fieldcat.
  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'BSART'.
  gs_fieldcat-seltext_s = 'belge türü'.
  gs_fieldcat-seltext_m = 'belge türü'.
  gs_fieldcat-seltext_l = 'belge türü'.
  APPEND gs_fieldcat TO gt_fieldcat.
  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'MATNR'.
  gs_fieldcat-seltext_s = 'malzeme'.
  gs_fieldcat-seltext_m = 'malzeme'.
  gs_fieldcat-seltext_l = 'malzeme'.
  APPEND gs_fieldcat TO gt_fieldcat.
  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'MENGE'.
  gs_fieldcat-seltext_s = 'miktar'.
  gs_fieldcat-seltext_m = 'miktar'.
  gs_fieldcat-seltext_l = 'miktar'.
  APPEND gs_fieldcat TO gt_fieldcat.

  gs_layout-window_titlebar = 'REUSE ALV BAŞLIK'. "alv başlık ismi değiştirme
  gs_layout-zebra = abap_true. "zebra layout
  gs_layout-colwidth_optimize = abap_true. "kolon genişliklerini optimize eder


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      is_layout   = gs_layout
      it_fieldcat = gt_fieldcat
    TABLES
      t_outtab    = gt_list.
