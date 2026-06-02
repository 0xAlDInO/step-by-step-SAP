**********************************************************************
* SECTION 1 : D\UffffffffINITIONS
**********************************************************************

CLASS lcl_buffer DEFINITION.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_po_buffer,
             cid    TYPE abp_behv_cid,
             header TYPE zi_po_header_ral,
             items  TYPE TABLE OF zi_po_item_ral WITH EMPTY KEY,
             action TYPE char1,
           END OF ty_po_buffer.
    CLASS-DATA: mt_buffer TYPE TABLE OF ty_po_buffer WITH EMPTY KEY.
ENDCLASS.

CLASS lhc_purchaseorder DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations
      FOR PurchaseOrder RESULT result.
    METHODS create   FOR MODIFY IMPORTING entities FOR CREATE PurchaseOrder.
    METHODS update   FOR MODIFY IMPORTING entities FOR UPDATE PurchaseOrder.
    METHODS delete   FOR MODIFY IMPORTING keys    FOR DELETE PurchaseOrder.
    METHODS read     FOR READ   IMPORTING keys    FOR READ   PurchaseOrder RESULT result.
    METHODS lock     FOR LOCK   IMPORTING keys    FOR LOCK   PurchaseOrder.
    METHODS rba_items FOR READ
      IMPORTING keys_rba FOR READ PurchaseOrder\_Items
      FULL result_full RESULT result LINK link.
    METHODS cba_items FOR MODIFY
      IMPORTING entities_cba FOR CREATE PurchaseOrder\_Items.
ENDCLASS.

CLASS lhc_purchaseorderitem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS update FOR MODIFY IMPORTING entities FOR UPDATE PurchaseOrderItem.
    METHODS delete FOR MODIFY IMPORTING keys    FOR DELETE PurchaseOrderItem.
    METHODS read   FOR READ   IMPORTING keys    FOR READ   PurchaseOrderItem RESULT result.
ENDCLASS.

CLASS lsc_zi_po_header DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save              REDEFINITION.
    METHODS finalize          REDEFINITION.
    METHODS check_before_save REDEFINITION.
ENDCLASS.

**********************************************************************
* SECTION 2 : IMPL\UffffffffENTATIONS
**********************************************************************

CLASS lcl_buffer IMPLEMENTATION.
ENDCLASS.

CLASS lhc_purchaseorder IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.
  LOOP AT entities INTO DATA(ls_entity).
    INSERT VALUE #(
      cid    = ls_entity-%cid
      header = CORRESPONDING #( ls_entity )
      action = 'C'
    ) INTO TABLE lcl_buffer=>mt_buffer.

    " ✅ %cid existe UNIQUEMENT dans CREATE — c'est correct ici
    " ✅ mais la syntaxe mapped doit être :
    INSERT VALUE #(
      %cid          = ls_entity-%cid
      PurchaseOrder = ls_entity-PurchaseOrder  " peut être vide à ce stade
    ) INTO TABLE mapped-purchaseorder.

  ENDLOOP.
ENDMETHOD.

  METHOD update.
  LOOP AT entities INTO DATA(ls_entity).

    READ TABLE lcl_buffer=>mt_buffer
      WITH KEY header-PurchaseOrder = ls_entity-PurchaseOrder
      REFERENCE INTO DATA(lr_buf).

    IF sy-subrc = 0.
      " ✅ Mise à jour directe sans MAPPING FROM ENTITY
      lr_buf->header-CompanyCode            = ls_entity-CompanyCode.
      lr_buf->header-Supplier               = ls_entity-Supplier.
      lr_buf->header-PurchaseOrderTypeCode  = ls_entity-PurchaseOrderTypeCode.
      lr_buf->header-PurchasingOrganization = ls_entity-PurchasingOrganization.
      lr_buf->header-PurchasingGroup        = ls_entity-PurchasingGroup.
      lr_buf->header-Currency               = ls_entity-Currency.
      lr_buf->header-PurchaseOrderDate      = ls_entity-PurchaseOrderDate.
      lr_buf->action = 'U'.
    ELSE.
      " ✅ CORRESPONDING sans MAPPING FROM ENTITY
      INSERT VALUE #(
        header = CORRESPONDING #( ls_entity )
        action = 'U'
      ) INTO TABLE lcl_buffer=>mt_buffer.
    ENDIF.

  ENDLOOP.
ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(ls_key).
      INSERT VALUE #(
        header = VALUE #( PurchaseOrder = ls_key-PurchaseOrder )
        action = 'D'
      ) INTO TABLE lcl_buffer=>mt_buffer.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    IF keys IS NOT INITIAL.
      SELECT * FROM ekko
        FOR ALL ENTRIES IN @keys
        WHERE ebeln = @keys-PurchaseOrder
        INTO TABLE @DATA(lt_po).

      result = CORRESPONDING #( lt_po MAPPING
        PurchaseOrder          = ebeln
        CompanyCode            = bukrs
        Supplier               = lifnr
        PurchaseOrderTypeCode  = bsart
        PurchasingOrganization = ekorg
        PurchasingGroup        = ekgrp
        PurchaseOrderDate      = bedat
        Currency               = waers
        CreationDate           = aedat
        DeletionIndicator      = loekz ).
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
        APPEND VALUE #( PurchaseOrder = ls_key-PurchaseOrder )
          TO failed-purchaseorder.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD rba_items.
    IF keys_rba IS NOT INITIAL.
      SELECT * FROM ekpo
        FOR ALL ENTRIES IN @keys_rba
        WHERE ebeln = @keys_rba-PurchaseOrder
        INTO TABLE @DATA(lt_items).

      LOOP AT keys_rba INTO DATA(ls_key).
        LOOP AT lt_items INTO DATA(ls_item) WHERE ebeln = ls_key-PurchaseOrder.
          APPEND VALUE #(
            PurchaseOrder             = ls_item-ebeln
            PurchaseOrderItem         = ls_item-ebelp
            Material                  = ls_item-matnr
            Plant                     = ls_item-werks
            PurchaseOrderQuantity     = ls_item-menge
            PurchaseOrderQuantityUnit = ls_item-meins
            NetPrice                  = ls_item-netpr
            PurchaseOrderItemText     = ls_item-txz01
            DeletionIndicator         = ls_item-loekz
          ) TO result.
          APPEND VALUE #(
            source-PurchaseOrder     = ls_key-PurchaseOrder
            target-PurchaseOrder     = ls_item-ebeln
            target-PurchaseOrderItem = ls_item-ebelp
          ) TO link.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD cba_items.
    LOOP AT entities_cba INTO DATA(ls_cba).
      " Recherche par CID d'abord (cr\Uffffffffion dans m\Uffffffff $batch)
      READ TABLE lcl_buffer=>mt_buffer
        WITH KEY cid = ls_cba-%cid_ref
        REFERENCE INTO DATA(lr_buffer).
      " Sinon par cl\UffffffffO (update ou PO existant)
      IF sy-subrc <> 0.
        READ TABLE lcl_buffer=>mt_buffer
          WITH KEY header-PurchaseOrder = ls_cba-PurchaseOrder
          REFERENCE INTO lr_buffer.
      ENDIF.
      IF lr_buffer IS BOUND.
        LOOP AT ls_cba-%target INTO DATA(ls_target).
          INSERT CORRESPONDING #( ls_target ) INTO TABLE lr_buffer->items.
          " Signaler les items cr\Uffffffff au framework
          INSERT VALUE #(
            %cid          = ls_target-%cid
            PurchaseOrder = ls_cba-PurchaseOrder
          ) INTO TABLE mapped-purchaseorderitem.
        ENDLOOP.
      ELSE.
        " PO non trouv\Uffffffffans buffer ? erreur
        LOOP AT ls_cba-%target INTO ls_target.
          APPEND VALUE #(
            %cid = ls_target-%cid
          ) TO failed-purchaseorderitem.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_purchaseorderitem IMPLEMENTATION.

  METHOD update.
  LOOP AT entities INTO DATA(ls_entity).

    READ TABLE lcl_buffer=>mt_buffer
      WITH KEY header-PurchaseOrder = ls_entity-PurchaseOrder
      REFERENCE INTO DATA(lr_buf).

    IF sy-subrc <> 0.
      INSERT VALUE #(
        header = VALUE #( PurchaseOrder = ls_entity-PurchaseOrder )
        action = 'U'
      ) INTO TABLE lcl_buffer=>mt_buffer.
      READ TABLE lcl_buffer=>mt_buffer
        WITH KEY header-PurchaseOrder = ls_entity-PurchaseOrder
        REFERENCE INTO lr_buf.
    ENDIF.

    IF lr_buf IS BOUND.
      READ TABLE lr_buf->items
        WITH KEY PurchaseOrderItem = ls_entity-PurchaseOrderItem
        REFERENCE INTO DATA(lr_item).

      IF sy-subrc = 0.
        " ✅ Mise à jour champ par champ — pas de MAPPING FROM ENTITY
        lr_item->PurchaseOrderQuantity     = ls_entity-PurchaseOrderQuantity.
        lr_item->PurchaseOrderQuantityUnit = ls_entity-PurchaseOrderQuantityUnit.
        lr_item->NetPrice                  = ls_entity-NetPrice.
        lr_item->Material                  = ls_entity-Material.
        lr_item->Plant                     = ls_entity-Plant.
        lr_item->PurchaseOrderItemText     = ls_entity-PurchaseOrderItemText.
      ELSE.
        " ✅ CORRESPONDING simple
        INSERT CORRESPONDING #( ls_entity ) INTO TABLE lr_buf->items.
      ENDIF.
    ENDIF.

  ENDLOOP.
ENDMETHOD.
  ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(ls_key).
      " Pour delete item : on marque l'item individuellement
      READ TABLE lcl_buffer=>mt_buffer
        WITH KEY header-PurchaseOrder = ls_key-PurchaseOrder
        REFERENCE INTO DATA(lr_buf).
      IF sy-subrc <> 0.
        INSERT VALUE #(
          header = VALUE #( PurchaseOrder = ls_key-PurchaseOrder )
          action = 'U'  " BAPI_PO_CHANGE pour delete item
        ) INTO TABLE lcl_buffer=>mt_buffer.
        READ TABLE lcl_buffer=>mt_buffer
          WITH KEY header-PurchaseOrder = ls_key-PurchaseOrder
          REFERENCE INTO lr_buf.
      ENDIF.
      IF lr_buf IS BOUND.
        " Ajouter item avec flag suppression
        INSERT VALUE #(
          PurchaseOrder     = ls_key-PurchaseOrder
          PurchaseOrderItem = ls_key-PurchaseOrderItem
          DeletionIndicator = 'X'
        ) INTO TABLE lr_buf->items.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    IF keys IS NOT INITIAL.
      SELECT * FROM ekpo
        FOR ALL ENTRIES IN @keys
        WHERE ebeln = @keys-PurchaseOrder
          AND ebelp = @keys-PurchaseOrderItem
        INTO TABLE @DATA(lt_item).

      result = CORRESPONDING #( lt_item MAPPING
        PurchaseOrder             = ebeln
        PurchaseOrderItem         = ebelp
        Material                  = matnr
        Plant                     = werks
        PurchaseOrderQuantity     = menge
        PurchaseOrderQuantityUnit = meins
        NetPrice                  = netpr
        PurchaseOrderItemText     = txz01
        DeletionIndicator         = loekz ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_po_header IMPLEMENTATION.

  METHOD check_before_save.
    " Validation m\Uffffffffer avant sauvegarde
    LOOP AT lcl_buffer=>mt_buffer REFERENCE INTO DATA(lr_buf).
      IF lr_buf->action = 'C'.
        " V\Ufffffffffier les champs obligatoires
        IF lr_buf->header-Supplier IS INITIAL.
          APPEND VALUE #(
            PurchaseOrder = lr_buf->header-PurchaseOrder
          ) TO failed-purchaseorder.
          APPEND VALUE #(
            %msg = new_message(
              id       = 'ZMM_PO'
              number   = '001'
              severity = if_abap_behv_message=>severity-error
              v1       = 'Supplier is mandatory' )
          ) TO reported-purchaseorder.
        ENDIF.
        IF lr_buf->header-PurchasingOrganization IS INITIAL.
          APPEND VALUE #(
            PurchaseOrder = lr_buf->header-PurchaseOrder
          ) TO failed-purchaseorder.
          APPEND VALUE #(
            %msg = new_message(
              id       = 'ZMM_PO'
              number   = '002'
              severity = if_abap_behv_message=>severity-error
              v1       = 'Purchasing Org is mandatory' )
          ) TO reported-purchaseorder.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD finalize.
    " Rien \Uffffffffaire ici pour unmanaged
  ENDMETHOD.

  METHOD save.
    DATA: ls_header  TYPE bapimepoheader,
          ls_headerx TYPE bapimepoheaderx,
          lt_items   TYPE TABLE OF bapimepoitem,
          lt_itemsx  TYPE TABLE OF bapimepoitemx,
          lt_return  TYPE TABLE OF bapiret2,
          lv_po      TYPE ebeln.

    LOOP AT lcl_buffer=>mt_buffer REFERENCE INTO DATA(lr_buf).
      CLEAR: ls_header, ls_headerx, lt_items, lt_itemsx, lt_return, lv_po.

      CASE lr_buf->action.

        WHEN 'C'.
          ls_header = VALUE #(
            comp_code = lr_buf->header-CompanyCode
            vendor    = lr_buf->header-Supplier
            doc_type  = lr_buf->header-PurchaseOrderTypeCode
            purch_org = lr_buf->header-PurchasingOrganization
            pur_group = lr_buf->header-PurchasingGroup
            currency  = lr_buf->header-Currency
            doc_date  = lr_buf->header-PurchaseOrderDate ).
          ls_headerx = VALUE #(
            comp_code = 'X' vendor = 'X' doc_type = 'X'
            purch_org = 'X' pur_group = 'X' currency = 'X' doc_date = 'X' ).

          LOOP AT lr_buf->items INTO DATA(ls_item).
            APPEND VALUE #(
              po_item   = ls_item-PurchaseOrderItem
              material  = ls_item-Material
              plant     = ls_item-Plant
              quantity  = ls_item-PurchaseOrderQuantity
              po_unit   = ls_item-PurchaseOrderQuantityUnit
              net_price = ls_item-NetPrice
              item_cat  = '0' ) TO lt_items.
            APPEND VALUE #(
              po_item   = ls_item-PurchaseOrderItem
              material  = 'X' plant = 'X'
              quantity  = 'X' po_unit = 'X' net_price = 'X' ) TO lt_itemsx.
          ENDLOOP.

          CALL FUNCTION 'BAPI_PO_CREATE1'
            EXPORTING
              poheader      = ls_header
              poheaderx     = ls_headerx
            IMPORTING
              purchaseorder = lv_po
            TABLES
              poitem        = lt_items
              poitemx       = lt_itemsx
              return        = lt_return.

          IF lv_po IS NOT INITIAL.
            lr_buf->header-PurchaseOrder = lv_po.
          ENDIF.

        WHEN 'U'.
          ls_header = VALUE #(
            comp_code = lr_buf->header-CompanyCode
            vendor    = lr_buf->header-Supplier
            doc_type  = lr_buf->header-PurchaseOrderTypeCode
            purch_org = lr_buf->header-PurchasingOrganization
            pur_group = lr_buf->header-PurchasingGroup
            currency  = lr_buf->header-Currency
            doc_date  = lr_buf->header-PurchaseOrderDate ).
          ls_headerx = VALUE #(
            comp_code = 'X' vendor = 'X' doc_type = 'X'
            purch_org = 'X' pur_group = 'X' currency = 'X' doc_date = 'X' ).

          LOOP AT lr_buf->items INTO ls_item.
            IF ls_item-DeletionIndicator = 'X'.
              " Delete item individuel
              APPEND VALUE #(
                po_item    = ls_item-PurchaseOrderItem
                delete_ind = 'X' ) TO lt_items.
              APPEND VALUE #(
                po_item    = ls_item-PurchaseOrderItem
                delete_ind = 'X' ) TO lt_itemsx.
            ELSE.
              " Update item
              APPEND VALUE #(
                po_item   = ls_item-PurchaseOrderItem
                quantity  = ls_item-PurchaseOrderQuantity
                net_price = ls_item-NetPrice ) TO lt_items.
              APPEND VALUE #(
                po_item   = ls_item-PurchaseOrderItem
                quantity  = 'X' net_price = 'X' ) TO lt_itemsx.
            ENDIF.
          ENDLOOP.

          CALL FUNCTION 'BAPI_PO_CHANGE'
            EXPORTING
              purchaseorder = lr_buf->header-PurchaseOrder
              poheader      = ls_header
              poheaderx     = ls_headerx
            TABLES
              poitem        = lt_items
              poitemx       = lt_itemsx
              return        = lt_return.

        WHEN 'D'.
          " Supprimer tous les items de la PO
          SELECT ebelp FROM ekpo
            WHERE ebeln = @lr_buf->header-PurchaseOrder
            INTO TABLE @DATA(lt_existing).

          LOOP AT lt_existing INTO DATA(lv_item).
            APPEND VALUE #(
              po_item    = lv_item
              delete_ind = 'X' ) TO lt_items.
            APPEND VALUE #(
              po_item    = lv_item
              delete_ind = 'X' ) TO lt_itemsx.
          ENDLOOP.

          CALL FUNCTION 'BAPI_PO_CHANGE'
            EXPORTING
              purchaseorder = lr_buf->header-PurchaseOrder
            TABLES
              poitem        = lt_items
              poitemx       = lt_itemsx
              return        = lt_return.

      ENDCASE.

    ENDLOOP.

    " Vider le buffer apr\Ufffffffftraitement complet
    CLEAR lcl_buffer=>mt_buffer.

  ENDMETHOD.

ENDCLASS.