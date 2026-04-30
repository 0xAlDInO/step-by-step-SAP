@AbapCatalog.sqlViewName: 'ZPURCH_ANA'
@Analytics.dataCategory: #CUBE
@EndUserText.label: 'Analytique Demandes d''Achat'

define view Z_C_PurchReqAnalytics
  as select from zpurch_req
{
    @AnalyticsDetails.query.display: #TEXT
    werks as Plant,

    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    total_price as TotalAmount,

    waers as Currency
}
