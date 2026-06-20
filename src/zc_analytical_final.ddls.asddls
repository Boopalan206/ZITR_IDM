@AbapCatalog.sqlViewName: 'ZC_ANALYTICAL'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'consumption view'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #CONSUMPTION

define view zc_analytical_final
  as select from ZANALYTICS_FINAL
{
      @UI.lineItem: [{ position: 10 }]
  key IdocNumber,
      @UI.lineItem: [{ position: 15 }]
  key IdocYear,
      @UI.lineItem: [{ position: 20 }]
  key IdocMonth,
      @UI.lineItem: [{ position: 25 }]
      Credat,
      @UI.lineItem: [{ position: 30 }]
      Customername,
      @UI.lineItem: [{ position: 35 }]
      Monthyear,
      @UI.lineItem: [{ position: 40 }]
      @DefaultAggregation: #SUM
      IdocDelayed,
      @UI.lineItem: [{ position: 45 }]
      @DefaultAggregation: #SUM
      TotalValue,
      @UI.lineItem: [{ position: 50 }]
      @DefaultAggregation: #AVG
      AverageDaysDelayed,
      @UI.lineItem: [{ position: 55 }]
      Reason,
      @UI.lineItem: [{ position: 60 }]
      ReasonText,
      @UI.lineItem: [{ position: 65 }]
      IdocType,
      @UI.lineItem: [{ position: 70 }]
      MessageType
}
