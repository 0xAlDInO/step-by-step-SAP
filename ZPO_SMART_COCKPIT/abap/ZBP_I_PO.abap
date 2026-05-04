CLASS zbp_i_po DEFINITION PUBLIC ABSTRACT FINAL FOR BEHAVIOR OF zi_po_header.
ENDCLASS.

CLASS zbp_i_po IMPLEMENTATION.
ENDCLASS.

**********************************************************************
* LOCAL CLASSES DEFINITION & IMPLEMENTATION
**********************************************************************

CLASS lcl_buffer DEFINITION.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_po_buffer,
             cid    TYPE abp_behv_cid,
             header TYPE zi_po_header,
             items  TYPE TABLE OF zi_po_item WITH EMPTY KEY,
             action TYPE char1, " C: Create, U: Update, D: Delete
           END OF ty_po_buffer.

    CLASS-DATA: mt_buffer TYPE TABLE OF ty_po_buffer WITH EMPTY KEY.
ENDCLASS.

CLASS lhc_PurchaseOrder DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR PurchaseOrder RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE PurchaseOrder.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE PurchaseOrder.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE PurchaseOrder.

    METHODS read FOR READ
      IMPORTING keys FOR READ PurchaseOrder RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK PurchaseOrder.

    METHODS rba_Items FOR READ
      IMPORTING keys_rba FOR READ PurchaseOrder\_Items FULL result REQUEST requested_fields RESULT result LINK link.

    METHODS cba_Items FOR MODIFY
      IMPORTING entities_cba FOR CREATE PurchaseOrder\_Items.

ENDCLASS.

CLASS lhc_PurchaseOrder IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.
    LOOP AT entities INTO DATA(ls_entity).
      INSERT VALUE #( cid = ls_entity-%cid header = CORRESPONDING #( ls_entity ) action = 'C' ) INTO TABLE lcl_buffer=>mt_buffer.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    LOOP AT entities INTO DATA(ls_entity).
      INSERT VALUE #( header = CORRESPONDING #( ls_entity ) action = 'U' ) INTO TABLE lcl_buffer=>mt_buffer.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(ls_key).
      INSERT VALUE #( header = VALUE #( PurchaseOrder = ls_key-PurchaseOrder ) action = 'D' ) INTO TABLE lcl_buffer=>mt_buffer.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    IF keys IS NOT INITIAL.
      SELECT * FROM ekko FOR ALL ENTRIES IN @keys WHERE ebeln = @keys-PurchaseOrder INTO TABLE @DATA(lt_po).
      result = CORRESPONDING #( lt_po MAPPING PurchaseOrder = ebeln ).
    ENDIF.
  ENDMETHOD.

  METHOD lock.
    LOOP AT keys INTO DATA(ls_key).
      CALL FUNCTION 'ENQUEUE_EMEKKOE'
        EXPORTING
          ebeln          = ls_key-PurchaseOrder
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2
          OTHERS         = 3.
      IF sy-subrc <> 0.
        APPEND VALUE #( PurchaseOrder = ls_key-PurchaseOrder ) TO failed-purchaseorder.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD rba_Items.
  ENDMETHOD.

  METHOD cba_Items.
    LOOP AT entities_cba INTO DATA(ls_cba).
      READ TABLE lcl_buffer=>mt_buffer WITH KEY cid = ls_cba-%cid_ref REFERENCE INTO DATA(lr_buffer).
      IF sy-subrc <> 0.
         READ TABLE lcl_buffer=>mt_buffer WITH KEY header-PurchaseOrder = ls_cba-PurchaseOrder REFERENCE INTO lr_buffer.
      ENDIF.

      IF lr_buffer IS BOUND.
        LOOP AT ls_cba-%target INTO DATA(ls_target).
          INSERT CORRESPONDING #( ls_target ) INTO TABLE lr_buffer->items.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_PurchaseOrderItem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE PurchaseOrderItem.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE PurchaseOrderItem.

    METHODS read FOR READ
      IMPORTING keys FOR READ PurchaseOrderItem RESULT result.
ENDCLASS.

CLASS lhc_PurchaseOrderItem IMPLEMENTATION.
  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
    IF keys IS NOT INITIAL.
      SELECT * FROM ekpo FOR ALL ENTRIES IN @keys WHERE ebeln = @keys-PurchaseOrder AND ebelp = @keys-PurchaseOrderItem INTO TABLE @DATA(lt_item).
      result = CORRESPONDING #( lt_item MAPPING PurchaseOrder = ebeln PurchaseOrderItem = ebelp ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lsc_zi_po_header DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save REDEFINITION.
    METHODS finalize REDEFINITION.
    METHODS check_before_save REDEFINITION.
ENDCLASS.

CLASS lsc_zi_po_header IMPLEMENTATION.
  METHOD save.
    DATA: ls_header  TYPE bapimepoheader,
          ls_headerx TYPE bapimepoheaderx,
          lt_items   TYPE TABLE OF bapimepoitem,
          lt_itemsx  TYPE TABLE OF bapimepoitemx,
          lt_return  TYPE TABLE OF bapiret2,
          lv_po      TYPE ebeln.

    LOOP AT lcl_buffer=>mt_buffer INTO DATA(ls_buffer).
      CLEAR: ls_header, ls_headerx, lt_items, lt_itemsx, lt_return, lv_po.

      CASE ls_buffer-action.
        WHEN 'C'.
          ls_header-comp_code = ls_buffer-header-CompanyCode.
          ls_header-vendor    = ls_buffer-header-Supplier.
          ls_header-doc_type  = ls_buffer-header-PurchaseOrderType.
          ls_header-purch_org = ls_buffer-header-PurchasingOrganization.
          ls_header-pur_group = ls_buffer-header-PurchasingGroup.
          ls_header-currency  = ls_buffer-header-Currency.
          ls_header-doc_date  = ls_buffer-header-PurchaseOrderDate.

          ls_headerx-comp_code = 'X'.
          ls_headerx-vendor    = 'X'.
          ls_headerx-doc_type  = 'X'.
          ls_headerx-purch_org = 'X'.
          ls_headerx-pur_group = 'X'.
          ls_headerx-currency  = 'X'.
          ls_headerx-doc_date  = 'X'.

          LOOP AT ls_buffer-items INTO DATA(ls_item).
            APPEND VALUE #( po_item = ls_item-PurchaseOrderItem
                            material = ls_item-Material
                            plant = ls_item-Plant
                            quantity = ls_item-PurchaseOrderQuantity
                            po_unit  = ls_item-PurchaseOrderQuantityUnit ) TO lt_items.

            APPEND VALUE #( po_item = ls_item-PurchaseOrderItem
                            material = 'X'
                            plant = 'X'
                            quantity = 'X'
                            po_unit  = 'X' ) TO lt_itemsx.
          ENDLOOP.

          CALL FUNCTION 'BAPI_PO_CREATE1'
            EXPORTING
              poheader  = ls_header
              poheaderx = ls_headerx
            IMPORTING
              purchaseorder = lv_po
            TABLES
              poitem    = lt_items
              poitemx   = lt_itemsx
              return    = lt_return.

        WHEN 'U'.
          ls_header-comp_code = ls_buffer-header-CompanyCode.
          ls_headerx-comp_code = 'X'.

          LOOP AT ls_buffer-items INTO ls_item.
            APPEND VALUE #( po_item = ls_item-PurchaseOrderItem
                            quantity = ls_item-PurchaseOrderQuantity
                            net_price = ls_item-NetPrice ) TO lt_items.
            APPEND VALUE #( po_item = ls_item-PurchaseOrderItem
                            quantity = 'X'
                            net_price = 'X' ) TO lt_itemsx.
          ENDLOOP.

          CALL FUNCTION 'BAPI_PO_CHANGE'
            EXPORTING
              purchaseorder = ls_buffer-header-PurchaseOrder
              poheader      = ls_header
              poheaderx     = ls_headerx
            TABLES
              poitem        = lt_items
              poitemx       = lt_itemsx
              return        = lt_return.

        WHEN 'D'.
          SELECT ebelp FROM ekpo WHERE ebeln = @ls_buffer-header-PurchaseOrder INTO TABLE @DATA(lt_existing_items).
          LOOP AT lt_existing_items INTO DATA(lv_item_num).
            APPEND VALUE #( po_item = lv_item_num delete_ind = 'X' ) TO lt_items.
            APPEND VALUE #( po_item = lv_item_num delete_ind = 'X' ) TO lt_itemsx.
          ENDLOOP.

          CALL FUNCTION 'BAPI_PO_CHANGE'
            EXPORTING
              purchaseorder = ls_buffer-header-PurchaseOrder
            TABLES
              poitem        = lt_items
              poitemx       = lt_itemsx
              return        = lt_return.
      ENDCASE.

      IF lv_po IS NOT INITIAL.
        APPEND VALUE #( %cid = ls_buffer-cid PurchaseOrder = lv_po ) TO mapped-purchaseorder.
      ENDIF.

      LOOP AT lt_return INTO DATA(ls_return) WHERE type CA 'AEX'.
        APPEND VALUE #( %msg = cl_abap_behv=>new_message_from_bapi( is_bapiret2 = ls_return ) ) TO reported-purchaseorder.
        APPEND VALUE #( PurchaseOrder = COND #( WHEN lv_po IS NOT INITIAL THEN lv_po ELSE ls_buffer-header-PurchaseOrder ) ) TO failed-purchaseorder.
      ENDLOOP.
    ENDLOOP.

    CLEAR lcl_buffer=>mt_buffer.
  ENDMETHOD.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.
ENDCLASS.
