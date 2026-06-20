@AbapCatalog.sqlViewName: 'ZANALYTICS_CDS'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Analytics'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view ZANALYTICS_FINAL
  as select from zidoc_analytics
{
  key idoc_number          as IdocNumber,
  key idoc_year            as IdocYear,
  key idoc_month           as IdocMonth,
      credat               as Credat,
      customername         as Customername,
      monthyear            as Monthyear,
      idoc_delayed         as IdocDelayed,
      total_value          as TotalValue,
      average_days_delayed as AverageDaysDelayed,
      reason               as Reason,
      reason_text          as ReasonText,
      idoc_type            as IdocType,
      message_type         as MessageType
}
