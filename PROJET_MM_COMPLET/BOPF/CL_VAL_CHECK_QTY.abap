CLASS zcl_val_check_qty DEFINITION
  PUBLIC
  INHERITING FROM /bobf/cl_lib_v_super_proc
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS /bobf/if_frw_validation~execute REDEFINITION.
ENDCLASS.

CLASS zcl_val_check_qty IMPLEMENTATION.
  METHOD /bobf/if_frw_validation~execute.
    " Logique pour vérifier que la quantité est positive
    DATA lt_data TYPE TABLE OF zspurchreq_i. " Structure générée par BOPF

    io_read->retrieve(
      EXPORTING
        iv_node = is_ctx-node_key
        it_key  = it_key
      IMPORTING
        et_data = lt_data ).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
      IF <fs_data>-quantity <= 0.
        " Ajouter message d'erreur via eo_message
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
