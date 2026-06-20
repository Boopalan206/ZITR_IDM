@AbapCatalog.sqlViewName: 'ZCU_DATE'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CURRENT DATE'
@Metadata.ignorePropagatedAnnotations: true
define view ZV_CURRENT_DATE as select from t000
{
 
  key mandt,
       cast( $session.system_date as abap.dats ) as today_date,
      cast( dats_add_days( cast( $session.system_date as abap.dats ), -90, 'INITIAL' ) as abap.dats ) as date_from
      

}
