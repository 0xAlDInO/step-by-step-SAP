CLASS zcl_act_approve_pr DEFINITION
  PUBLIC
  INHERITING FROM /bobf/cl_lib_a_super_proc
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS /bobf/if_frw_action~execute REDEFINITION.
ENDCLASS.

CLASS zcl_act_approve_pr IMPLEMENTATION.
  METHOD /bobf/if_frw_action~execute.
    DATA lt_data TYPE TABLE OF zspurchreq_i.

    io_read->retrieve(
      EXPORTING
        iv_node = is_ctx-node_key
        it_key  = it_key
      IMPORTING
        et_data = lt_data ).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
      <fs_data>-status = 'A'. " Approuvé

      io_modify->update(
        EXPORTING
          iv_node = is_ctx-node_key
          iv_key  = <fs_data>-key
          is_data = REF #( <fs_data> ) ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
