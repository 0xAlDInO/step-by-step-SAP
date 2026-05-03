CLASS zbp_i_po DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_po_header,
             ebeln TYPE ekko-ebeln,
             bukrs TYPE ekko-bukrs,
             lifnr TYPE ekko-lifnr,
             bsart TYPE ekko-bsart,
             bedat TYPE ekko-bedat,
             waers TYPE ekko-waers,
             netwr TYPE ekko-netwr,
             aedat TYPE ekko-aedat,
           END OF ty_po_header.

    TYPES: BEGIN OF ty_po_item,
             ebeln TYPE ekpo-ebeln,
             ebelp TYPE ekpo-ebelp,
             matnr TYPE ekpo-matnr,
             werks TYPE ekpo-werks,
             menge TYPE ekpo-menge,
             meins TYPE ekpo-meins,
             netpr TYPE ekpo-netpr,
             txz01 TYPE ekpo-txz01,
           END OF ty_po_item.

    TYPES: ty_po_header_tab TYPE STANDARD TABLE OF ty_po_header WITH DEFAULT KEY.
    TYPES: ty_po_item_tab   TYPE STANDARD TABLE OF ty_po_item   WITH DEFAULT KEY.

    METHODS create
      IMPORTING
        !it_header TYPE ty_po_header_tab
        !it_items  TYPE ty_po_item_tab
      EXPORTING
        !ev_ebeln  TYPE ekko-ebeln.

    METHODS update
      IMPORTING
        !it_header TYPE ty_po_header_tab
        !it_items  TYPE ty_po_item_tab.

    METHODS delete
      IMPORTING
        !it_header TYPE ty_po_header_tab.

  PRIVATE SECTION.
    METHODS bapi_create_po
      IMPORTING
        !is_header TYPE ty_po_header
        !it_items  TYPE ty_po_item_tab
      RETURNING
        VALUE(rv_ebeln) TYPE ekko-ebeln.
    METHODS bapi_update_po
      IMPORTING
        !is_header TYPE ty_po_header
        !it_items  TYPE ty_po_item_tab.
    METHODS raise_bapi_error
      IMPORTING
        !it_return TYPE TABLE OF bapiret2.
ENDCLASS.

CLASS zbp_i_po IMPLEMENTATION.
  METHOD create.
    DATA(ls_header) TYPE ty_po_header.
    READ TABLE it_header INDEX 1 INTO ls_header.
    IF ls_header IS INITIAL.
      MESSAGE 'Purchase order header is required for create.' TYPE 'E'.
    ENDIF.
    ev_ebeln = bapi_create_po( is_header = ls_header it_items = it_items ).
  ENDMETHOD.

  METHOD update.
    DATA(ls_header) TYPE ty_po_header.
    READ TABLE it_header INDEX 1 INTO ls_header.
    IF ls_header IS INITIAL.
      MESSAGE 'Purchase order header is required for update.' TYPE 'E'.
    ENDIF.
    bapi_update_po( is_header = ls_header it_items = it_items ).
  ENDMETHOD.

  METHOD delete.
    " Soft delete not supported for Purchase Orders in standard SAP.
    MESSAGE 'Delete is not supported for Purchase Orders. Use cancellation processes instead.' TYPE 'W'.
  ENDMETHOD.

  METHOD bapi_create_po.
    DATA: ls_bapi_header TYPE bapiekko,
          lt_bapi_items  TYPE TABLE OF bapiekpo,
          lt_return      TYPE TABLE OF bapiret2,
          ls_item        TYPE ty_po_item,
          ls_bapi_item   TYPE bapiekpo,
          lv_po_number   TYPE ekko-ebeln.

    " Laisser SAP générer le numéro de PO automatiquement.
    " Ne pas remplir po_number pour éviter les incohérences de numérotation.
    ls_bapi_header-vendor    = is_header-lifnr.
    ls_bapi_header-doc_type  = is_header-bsart.
    ls_bapi_header-company_code = is_header-bukrs.
    ls_bapi_header-currency  = is_header-waers.
    ls_bapi_header-doc_date  = is_header-bedat.

    LOOP AT it_items INTO ls_item.
      CLEAR ls_bapi_item.
      ls_bapi_item-po_item   = ls_item-ebelp.
      ls_bapi_item-material  = ls_item-matnr.
      ls_bapi_item-plant     = ls_item-werks.
      ls_bapi_item-quantity  = ls_item-menge.
      ls_bapi_item-qty_unit  = ls_item-meins.
      ls_bapi_item-net_price = ls_item-netpr.
      ls_bapi_item-short_text = ls_item-txz01.
      APPEND ls_bapi_item TO lt_bapi_items.
    ENDLOOP.

    CALL FUNCTION 'BAPI_PO_CREATE1'
      EXPORTING
        poheader      = ls_bapi_header
      IMPORTING
        purchaseorder = lv_po_number
      TABLES
        poitem        = lt_bapi_items
        return        = lt_return.

    raise_bapi_error( it_return = lt_return ).

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ENDMETHOD.

  METHOD bapi_update_po.
    DATA: ls_bapi_header TYPE bapiekko,
          ls_bapi_headerx TYPE bapiekkox,
          lt_bapi_items  TYPE TABLE OF bapiekpo,
          lt_bapi_itemsx TYPE TABLE OF bapiekpox,
          lt_return      TYPE TABLE OF bapiret2,
          ls_item        TYPE ty_po_item,
          ls_bapi_item   TYPE bapiekpo,
          ls_bapi_itemx  TYPE bapiekpox.

    " Header data
    ls_bapi_header-po_number = is_header-ebeln.
    ls_bapi_header-vendor    = is_header-lifnr.
    ls_bapi_header-doc_type  = is_header-bsart.
    ls_bapi_header-company_code = is_header-bukrs.
    ls_bapi_header-currency  = is_header-waers.
    ls_bapi_header-doc_date  = is_header-bedat.

    " Header change indicators
    ls_bapi_headerx-po_number = is_header-ebeln.
    ls_bapi_headerx-vendor    = 'X'.
    ls_bapi_headerx-doc_type  = 'X'.
    ls_bapi_headerx-company_code = 'X'.
    ls_bapi_headerx-currency  = 'X'.
    ls_bapi_headerx-doc_date  = 'X'.

    " Items data
    LOOP AT it_items INTO ls_item.
      CLEAR: ls_bapi_item, ls_bapi_itemx.
      ls_bapi_item-po_item   = ls_item-ebelp.
      ls_bapi_item-material  = ls_item-matnr.
      ls_bapi_item-plant     = ls_item-werks.
      ls_bapi_item-quantity  = ls_item-menge.
      ls_bapi_item-qty_unit  = ls_item-meins.
      ls_bapi_item-net_price = ls_item-netpr.
      ls_bapi_item-short_text = ls_item-txz01.
      APPEND ls_bapi_item TO lt_bapi_items.

      ls_bapi_itemx-po_item   = ls_item-ebelp.
      ls_bapi_itemx-material  = 'X'.
      ls_bapi_itemx-plant     = 'X'.
      ls_bapi_itemx-quantity  = 'X'.
      ls_bapi_itemx-qty_unit  = 'X'.
      ls_bapi_itemx-net_price = 'X'.
      ls_bapi_itemx-short_text = 'X'.
      APPEND ls_bapi_itemx TO lt_bapi_itemsx.
    ENDLOOP.

    CALL FUNCTION 'BAPI_PO_CHANGE'
      EXPORTING
        purchaseorder = is_header-ebeln
        poheader      = ls_bapi_header
        poheaderx     = ls_bapi_headerx
      TABLES
        poitem        = lt_bapi_items
        poitemx       = lt_bapi_itemsx
        return        = lt_return.

    raise_bapi_error( it_return = lt_return ).

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ENDMETHOD.

  METHOD raise_bapi_error.
    LOOP AT it_return INTO DATA(ls_return).
      IF ls_return-type CA 'AE'.
        MESSAGE ls_return-message TYPE 'E'.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
