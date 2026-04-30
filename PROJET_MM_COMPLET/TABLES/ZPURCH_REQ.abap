@EndUserText.label : 'Table de Demande d''Achat'
@AbapCatalog.enhancementCategory : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #LIMITED
define table zpurch_req {
  key client    : abap.clnt not null;
  key pr_uuid   : snwd_node_key not null;
  pr_id         : abap.char(10);
  matnr         : matnr;
  quantity      : abap.quan(13,3);
  meins         : meins;
  werks         : werks_d;
  status        : abap.char(1);
  total_price   : abap.curr(15,2);
  waers         : waers;
  created_by    : abap.char(12);
}
