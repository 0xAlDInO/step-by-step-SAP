CLASS ztc_purchase_order_rap DEFINITION
  PUBLIC
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    METHODS:
      setup,
      test_create_po FOR TESTING.
ENDCLASS.

CLASS ztc_purchase_order_rap IMPLEMENTATION.
  METHOD setup.
    " Initialize test data if necessary
  ENDMETHOD.

  METHOD test_create_po.
    " Test a Create operation using EML
    MODIFY ENTITIES OF zi_po_header_ral
      ENTITY PurchaseOrder
        CREATE SET FIELDS WITH VALUE #( (
          %cid = 'TC_CREATE_1'
          CompanyCode = '1010'
          Supplier = '0000100000'
          PurchaseOrderTypeCode = 'NB'
          PurchasingOrganization = '1010'
          PurchasingGroup = '001'
          Currency = 'EUR'
        ) )
      MAPPED DATA(lt_mapped)
      FAILED DATA(lt_failed)
      REPORTED DATA(lt_reported).

    " Assertions
    cl_abap_unit_assert=>assert_initial( lt_failed-purchaseorder ).
    cl_abap_unit_assert=>assert_not_initial( lt_mapped-purchaseorder ).

    " In a real scenario with unmanaged BAPI, you might need a mock or
    " to check if the buffer is correctly populated if not doing a full integration test.
  ENDMETHOD.
ENDCLASS.
