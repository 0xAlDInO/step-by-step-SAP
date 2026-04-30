@AbapCatalog.sqlViewName: 'ZPURCHREQ_I'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface Demande d''Achat'

@ObjectModel.modelCategory: #BUSINESS_OBJECT
@ObjectModel.compositionRoot: true
@ObjectModel.transactionalDbLayerViews: 'Z_I_PurchReq'
@ObjectModel.writeActivePersistence: 'ZPURCH_REQ'
@OData.publish: true

define view Z_I_PurchReq
  as select from zpurch_req
  association [1..1] to mara as _Material on $projection.Material = _Material.matnr
{
    @UI.facet: [ { id: 'idPR', type: #IDENTIFICATION_REFERENCE, label: 'Détails PR' } ]

    key pr_uuid as PRKey,

    @UI.lineItem: [ { position: 10 } ]
    @UI.identification: [ { position: 10 } ]
    pr_id as PurchaseReqID,

    @UI.lineItem: [ { position: 20 } ]
    @UI.identification: [ { position: 20 } ]
    @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Material', element: 'Material' } }]
    matnr as Material,

    @UI.lineItem: [ { position: 30 } ]
    quantity as Quantity,

    meins as Unit,

    @UI.lineItem: [ { position: 40 } ]
    @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Plant', element: 'Plant' } }]
    werks as Plant,

    @UI.lineItem: [ { position: 50 } ]
    @UI.identification: [ { position: 50, type: #FOR_ACTION, dataAction: 'APPROVE_PR', label: 'Approuver' } ]
    status as Status,

    @UI.lineItem: [ { position: 60 } ]
    @Semantics.amount.currencyCode: 'Currency'
    total_price as TotalPrice,

    waers as Currency,

    /* Associations */
    _Material
}
