"SALV ÖRNEK.
DATA: gt_mara TYPE TABLE OF mara,
      go_salv  TYPE REF TO cl_salv_table.


START-OF-SELECTION.

  SELECT * UP TO 20 ROWS FROM mara
    INTO TABLE gt_mara.

  cl_salv_table=>factory(
    IMPORTING
      r_salv_table   = go_salv                          " SALV OBJESİNE BAĞLAMA
    CHANGING
      t_table        = gt_mara
  ).

  go_salv->display( ).
