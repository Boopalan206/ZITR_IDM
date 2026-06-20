@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'SalesOrder Root Entity'
@ObjectModel.transactionalProcessingEnabled: true
define root view entity Z_I_SalesOrder
  as select from zso_hdr
{
  key so_id,
      customer,
      @Semantics.amount.currencyCode: 'currency'
      amount,
      currency,
      created_by,
      created_on
}
