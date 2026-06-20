@AbapCatalog.sqlViewName: 'ZITR_SQL_ANAL'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ITR IDOC ANALYTICAL VIEW'
@Metadata.ignorePropagatedAnnotations: true
define view ZITR_IDM_ANALYTICS
  as select from zitr_analytic   as A
    inner join   ZV_CURRENT_DATE as B on B.mandt = A.mandt
    association[0..*] to I_CalendarDate  as _cal on $projection.idoc_credat = _cal.CalendarDate

{
      @EndUserText.label: 'IDoc Number'
      @UI.hidden: true
  key A.idoc_number          as IdocNumber,

      @EndUserText.label: 'Year'
      A.idoc_year            as IdocYear,

      @EndUserText.label: 'Month'
      A.idoc_month           as IdocMonth,

      @EndUserText.label: ''
      A.customer             as Customer,

      @EndUserText.label: 'Customer Name'
      A.customername         as Customername,


      @Semantics.calendar.yearMonth: true
      @EndUserText.label: 'Month - Year'
      A.monthyear            as Monthyear,
      
      @EndUserText.label: 'IDoc Delayed Value'
      @DefaultAggregation: #SUM
      A.idoc_delayed         as IdocDelayed,

      @EndUserText.label: 'Total Value'
      @DefaultAggregation: #SUM
      A.total_value          as TotalValue,

      @EndUserText.label: 'Avg Delayed Days'
      @DefaultAggregation: #AVG
      A.average_days_delayed as AverageDaysDelayed,

      @EndUserText.label: 'Reason'
      A.reason               as Reason,

      @EndUserText.label: 'Net Value for Error 51'
      @DefaultAggregation: #SUM
      A.idoc_net_error_51    as IdocNetError51,

      @EndUserText.label: 'Net Value for Success 53'
      @DefaultAggregation: #SUM
      A.idoc_net_success_53  as IdocNetSuccess53,


      @EndUserText.label: 'Net Value for Ready 64'
      @DefaultAggregation: #SUM
      A.idoc_net_ready_64    as IdocNetReady64,
      
      @UI.hidden: true
      A.idoc_credat
     

}
where
  A.idoc_credat between B.date_from and B.today_date
