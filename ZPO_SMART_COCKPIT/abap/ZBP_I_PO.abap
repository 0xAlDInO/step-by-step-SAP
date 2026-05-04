CLASS zbp_i_po DEFINITION PUBLIC ABSTRACT FINAL FOR BEHAVIOR OF zi_po_header_ral.
ENDCLASS.

CLASS zbp_i_po IMPLEMENTATION.
ENDCLASS.

**********************************************************************
* LOCAL DEFINITIONS
**********************************************************************

CLASS lcl_buffer DEFINITION.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_po_buffer,
             cid    TYPE abp_behv_cid,
             header TYPE zi_po_header_ral,
             items  TYPE TABLE OF zi_po_item_ral WITH EMPTY KEY,
             action TYPE char1, " C: Create, U: Update, D: Delete
           END OF ty_po_buffer.
    CLASS-DATA: mt_buffer TYPE TABLE OF ty_po_buffer WITH EMPTY KEY.
ENDCLASS.

CLASS lhc_purchaseorder DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR PurchaseOrder RESULT result.
    METHODS create FOR MODIFY IMPORTING entities FOR CREATE PurchaseOrder.
    METHODS update FOR MODIFY IMPORTING entities FOR UPDATE PurchaseOrder.
    METHODS delete FOR MODIFY IMPORTING keys FOR DELETE PurchaseOrder.
    METHODS read FOR READ IMPORTING keys FOR READ PurchaseOrder RESULT result.
    METHODS lock FOR LOCK IMPORTING keys FOR LOCK PurchaseOrder.
    METHODS rba_items FOR READ IMPORTING keys_rba FOR READ PurchaseOrder\Items RESULT result LINK link.
    METHODS cba_items FOR MODIFY IMPORTING entities_cba FOR CREATE PurchaseOrder\Items.
ENDCLASS.

CLASS lhc_purchaseorderitem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS update FOR MODIFY IMPORTING entities FOR UPDATE PurchaseOrderItem.
    METHODS delete FOR MODIFY IMPORTING keys FOR DELETE PurchaseOrderItem.
    METHODS read FOR READ IMPORTING keys FOR READ PurchaseOrderItem RESULT result.
ENDCLASS.

CLASS lsc_zi_po_header DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save REDEFINITION.
    METHODS finalize REDEFINITION.
    METHODS check_before_save REDEFINITION.
ENDCLASS.

**********************************************************************
* LOCAL IMPLEMENTATIONS
**********************************************************************

CLASS lhc_purchaseorder IMPLEMENTATION.
  METHOD get_instance_authorizations. ENDMETHOD.

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
      result = CORRESPONDING #( lt_po MAPPING
        PurchaseOrder = ebeln
        CompanyCode = bukrs
        Supplier = lifnr
        PurchaseOrderTypeCode = bsart
        PurchasingOrganization = ekorg
        PurchasingGroup = ekgrp
        PurchaseOrderDate = bedat
        Currency = waers
        CreationDate = aedat
        DeletionIndicator = loekz ).
    ENDIF.
  ENDMETHOD.

  METHOD lock.
    LOOP AT keys INTO DATA(ls_key).
      CALL FUNCTION 'ENQUEUE_EMEKKOE'
        EXPORTING ebeln = ls_key-PurchaseOrder
        EXCEPTIONS foreign_lock = 1 system_failure = 2 OTHERS = 3.
      IF sy-subrc <> 0.
        APPEND VALUE #( %tky = ls_key-%tky ) TO failed-purchaseorder.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD rba_items.
    IF keys_rba IS NOT INITIAL.
      SELECT * FROM ekpo FOR ALL ENTRIES IN @keys_rba
        WHERE ebeln = @keys_rba-PurchaseOrder
        INTO TABLE @DATA(lt_items).

      LOOP AT keys_rba INTO DATA(ls_key).
        LOOP AT lt_items INTO DATA(ls_item) WHERE ebeln = ls_key-PurchaseOrder.
          APPEND VALUE #( %tky = ls_key-%tky
                          %target = CORRESPONDING #( ls_item MAPPING
                            PurchaseOrder = ebeln
                            PurchaseOrderItem = ebelp
                            Material = matnr
                            Plant = werks
                            PurchaseOrderQuantity = menge
                            PurchaseOrderQuantityUnit = meins
                            NetPrice = netpr
                            PurchaseOrderItemText = txz01
                            DeletionIndicator = loekz ) ) TO result.
          IF link IS SUPPLIED.
            APPEND VALUE #( %tky = ls_key-%tky
                            source-PurchaseOrder = ls_key-PurchaseOrder
                            target-PurchaseOrder = ls_item-ebeln
                            target-PurchaseOrderItem = ls_item-ebelp ) TO link.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD cba_items.
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

CLASS lhc_purchaseorderitem IMPLEMENTATION.
  METHOD update. ENDMETHOD.
  METHOD delete. ENDMETHOD.
  METHOD read.
    IF keys IS NOT INITIAL.
      SELECT * FROM ekpo FOR ALL ENTRIES IN @keys WHERE ebeln = @keys-PurchaseOrder AND ebelp = @keys-PurchaseOrderItem INTO TABLE @DATA(lt_item).
      result = CORRESPONDING #( lt_item MAPPING
        PurchaseOrder = ebeln
        PurchaseOrderItem = ebelp
        Material = matnr
        Plant = werks
        PurchaseOrderQuantity = menge
        PurchaseOrderQuantityUnit = meins
        NetPrice = netpr
        PurchaseOrderItemText = txz01
        DeletionIndicator = loekz ).
    ENDIF.
  ENDMETHOD.
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
          ls_header = VALUE #( comp_code = ls_buffer-header-CompanyCode vendor = ls_buffer-header-Supplier
                               doc_type = ls_buffer-header-PurchaseOrderTypeCode purch_org = ls_buffer-header-PurchasingOrganization
                               pur_group = ls_buffer-header-PurchasingGroup currency = ls_buffer-header-Currency doc_date = ls_buffer-header-PurchaseOrderDate ).
          ls_headerx = VALUE #( comp_code = 'X' vendor = 'X' doc_type = 'X' purch_org = 'X' pur_group = 'X' currency = 'X' doc_date = 'X' ).
          LOOP AT ls_buffer-items INTO DATA(ls_item).
            APPEND VALUE #( po_item = ls_item-PurchaseOrderItem material = ls_item-Material plant = ls_item-Plant quantity = ls_item-PurchaseOrderQuantity po_unit = ls_item-PurchaseOrderQuantityUnit net_price = ls_item-NetPrice ) TO lt_items.
            APPEND VALUE #( po_item = ls_item-PurchaseOrderItem material = 'X' plant = 'X' quantity = 'X' po_unit = 'X' net_price = 'X' ) TO lt_itemsx.
          ENDLOOP.
          CALL FUNCTION 'BAPI_PO_CREATE1' EXPORTING poheader = ls_header poheaderx = ls_headerx IMPORTING purchaseorder = lv_po TABLES poitem = lt_items poitemx = lt_itemsx return = lt_return.
        WHEN 'U'.
          ls_header = VALUE #( comp_code = ls_buffer-header-CompanyCode vendor = ls_buffer-header-Supplier
                               doc_type = ls_buffer-header-PurchaseOrderTypeCode purch_org = ls_buffer-header-PurchasingOrganization
                               pur_group = ls_buffer-header-PurchasingGroup currency = ls_buffer-header-Currency doc_date = ls_buffer-header-PurchaseOrderDate ).
          ls_headerx = VALUE #( comp_code = 'X' vendor = 'X' doc_type = 'X' purch_org = 'X' pur_group = 'X' currency = 'X' doc_date = 'X' ).
          LOOP AT ls_buffer-items INTO ls_item.
            APPEND VALUE #( po_item = ls_item-PurchaseOrderItem quantity = ls_item-PurchaseOrderQuantity net_price = ls_item-NetPrice ) TO lt_items.
            APPEND VALUE #( po_item = ls_item-PurchaseOrderItem quantity = 'X' net_price = 'X' ) TO lt_itemsx.
          ENDLOOP.
          CALL FUNCTION 'BAPI_PO_CHANGE' EXPORTING purchaseorder = ls_buffer-header-PurchaseOrder poheader = ls_header poheaderx = ls_headerx TABLES poitem = lt_items poitemx = lt_itemsx return = lt_return.
        WHEN 'D'.
          SELECT ebelp FROM ekpo WHERE ebeln = @ls_buffer-header-PurchaseOrder INTO TABLE @DATA(lt_existing).
          LOOP AT lt_existing INTO DATA(lv_item).
            APPEND VALUE #( po_item = lv_item delete_ind = 'X' ) TO lt_items.
            APPEND VALUE #( po_item = lv_item delete_ind = 'X' ) TO lt_itemsx.
          ENDLOOP.
          CALL FUNCTION 'BAPI_PO_CHANGE' EXPORTING purchaseorder = ls_buffer-header-PurchaseOrder TABLES poitem = lt_items poitemx = lt_itemsx return = lt_return.
      ENDCASE.

      IF lv_po IS NOT INITIAL.
        APPEND VALUE #( %cid = ls_buffer-cid PurchaseOrder = lv_po ) TO mapped-purchaseorder.
      ENDIF.

      LOOP AT lt_return INTO DATA(ls_ret) WHERE type CA 'AEX'.
        APPEND VALUE #( %msg = cl_abap_behv=>new_message_from_bapi( is_bapiret2 = ls_ret ) ) TO reported-purchaseorder.
        IF ls_buffer-cid IS NOT INITIAL.
           APPEND VALUE #( %cid = ls_buffer-cid ) TO failed-purchaseorder.
        ELSE.
           APPEND VALUE #( PurchaseOrder = ls_buffer-header-PurchaseOrder ) TO failed-purchaseorder.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
    CLEAR lcl_buffer=>mt_buffer.
  ENDMETHOD.
  METHOD finalize. ENDMETHOD.
  METHOD check_before_save. ENDMETHOD.
ENDCLASS.
