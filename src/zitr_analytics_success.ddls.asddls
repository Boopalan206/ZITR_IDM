@AbapCatalog.sqlViewName: 'ZIDIC_SUCCESS'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ITR IDOC SUCCESS ANALYSIS'
@Metadata.ignorePropagatedAnnotations: true
@OData.publish: true


define view ZITR_ANALYTICS_SUCCESS
  as select from zitr_s_analytic
{
      @EndUserText.label: 'IDoc_Number'
      @UI.hidden: true
      @UI.lineItem: [{ position: 105, label: 'IDoc Number' }]
  key idoc_number          as IdocNumber,

      @EndUserText.label: 'Year'
      @UI.lineItem: [{ position: 10, label: 'Year' }]
      idoc_year            as IdocYear,

      @EndUserText.label: 'MOnth'
      @UI.lineItem: [{ position: 20, label: 'Month' }]
      idoc_month           as IdocMonth,

      @EndUserText.label: 'Customer'
      @UI.lineItem: [{ position: 30, label: 'Customer' }]
      customer             as Customer,

      @EndUserText.label: 'Customer'
      @UI.lineItem: [{ position:40, label: 'Customer Name' }]
      
      customername         as Customername,

      @EndUserText.label: 'Month'
      @UI.lineItem: [{ position: 50, label: 'Month - Year' }]
      monthyear            as Monthyear,

      @EndUserText.label: 'Delayed Order Value'
      @UI.lineItem: [{ position: 60, label: 'Delayed Value' }]
      @DefaultAggregation: #SUM
      idoc_delayed         as IdocDelayed,

     
      @UI.lineItem: [{ position: 70, label: 'Total Value' }]
      @DefaultAggregation: #SUM
      total_value          as TotalValue,

      @EndUserText.label: 'Average Delayed Days'
      @UI.lineItem: [{ position: 80, label: 'Average Delayed Days' }]
      @DefaultAggregation: #AVG
      average_days_delayed as AverageDaysDelayed,

      @EndUserText.label: 'Errors'
      @UI.lineItem: [{ position: 90, label: 'Reason' }]
      reason               as Reason,

      @EndUserText.label: 'Reason Text'
      @UI.lineItem: [{ position: 100, label: 'Reason Text' }]
      reason_text          as ReasonText
}
