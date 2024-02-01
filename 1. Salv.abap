*&---------------------------------------------------------------------*
*& Report ZAB_C1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zab_c1.

"SALV ÖRNEK.
DATA: gt_mara TYPE TABLE OF mara,
      go_salv TYPE REF TO cl_salv_table.


START-OF-SELECTION.

  SELECT * UP TO 20 ROWS FROM mara
    INTO TABLE gt_mara.

  cl_salv_table=>factory(
    IMPORTING
      r_salv_table   = go_salv  " SALV OBJESİNE BAĞLAMA
    CHANGING
      t_table        = gt_mara
  ).

  "KODUN AKIŞINA TERS BİLE OLSA ÇALIŞIYOR ÇÜNKÜ METHOD ÇAĞRISIYLA VAR MI YOK MU KONTROL EDİLİYOR.
  DATA : lo_display TYPE REF TO cl_salv_display_settings. "OoP TYPE REF TO

  lo_display = go_salv->get_display_settings( ).
  lo_display->set_list_header( value = 'DENEME' ).  " NORMAL = / OOP ->
  lo_display->set_striped_pattern( value = 'X' ). "ZEBRA DESEN

  DATA: lo_cols TYPE REF TO cl_salv_columns.

  lo_cols = go_salv->get_columns( ).
  lo_cols->set_optimize( value = 'X' ). "BAŞLIK UZUNLUĞU OPTİMİZASYONU

  DATA: lo_col TYPE REF TO cl_salv_column.

  TRY .
      lo_col = lo_cols->get_column( columnname = 'MATNR' ). "SÜTUN İSMİ DEĞİŞTİRİCİ
      lo_col->set_long_text( 'deneme' ).
      lo_col->set_medium_text( 'denem' ).
      lo_col->set_short_text( 'dene' ).
    CATCH cx_salv_not_found.
      MESSAGE 'cx_salv_not_found hatası döndü.' TYPE 'I'.
      "LOJİK EKLENEBİLİR.
  ENDTRY.

  TRY .
      lo_col = lo_cols->get_column( columnname = 'LAEDA11' ). "SÜTUN GÖRÜNÜRLÜĞÜ

      lo_col->set_visible(
      value = if_salv_c_bool_sap=>false "invisible yapma kodu
      ).

    CATCH cx_salv_not_found.
      MESSAGE 'cx_salv_not_found hatası döndü.' TYPE 'I'. "LAEDA11 DİYE BİR TABLODA SÜTUN BULAMADIĞI İÇİN MESAJ BASTI.
      "LOJİK EKLENEBİLİR.
  ENDTRY.

  DATA: lo_func TYPE REF TO cl_salv_functions.

  lo_func = go_salv->get_functions( ). "TOOLBAR BUTONLARI EKLEME.
  lo_func->set_all( abap_true ).

  DATA: lo_header  TYPE REF TO cl_salv_form_layout_grid, "HEADER EKLEME
        lo_h_label TYPE REF TO cl_salv_form_label,
        lo_h_flow  TYPE REF TO cl_salv_form_layout_flow.

  CREATE OBJECT lo_header.

  lo_h_label = lo_header->create_label( row = 1 column = 1 ).
  lo_h_label->set_text( value = 'Başlık İlk Satır').
  lo_h_flow = lo_header->create_flow( row = 2 column = 1 ).
  lo_h_flow->create_text(
    EXPORTING
     text     = 'TEXT İKİNCİ SATIR'

  ).

  go_salv->set_screen_popup(  "POPUP EKRANI ŞEKLİNDE BASMA
    start_column = 10
    end_column   = 75
    start_line   = 5
    end_line     = 25
  ).

  go_salv->display( ).
