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
    DATA lt_data TYPE TABLE OF zspurchreq_i.

    " 1. Lire les données en cours de saisie
    io_read->retrieve(
      EXPORTING
        iv_node = is_ctx-node_key
        it_key  = it_key
      IMPORTING
        et_data = lt_data ).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
      " 2. Condition de validation : quantité doit être > 0
      IF <fs_data>-quantity <= 0.

        " 3. Bloquer la sauvegarde
        INSERT VALUE #( key = <fs_data>-prkey ) INTO TABLE et_failed_key.

        " 4. Créer le message d'erreur
        IF eo_message IS NOT BOUND.
          eo_message = /bobf/cl_frw_factory=>get_message( ).
        ENDIF.

        eo_message->add_cm(
          EXPORTING
            io_message = NEW /bobf/cm_frw_core(
                           textid   = /bobf/cm_frw_core=>severity_error
                           severity = /bobf/cm_frw_core=>severity_error ) ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
