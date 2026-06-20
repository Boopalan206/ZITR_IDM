@AbapCatalog.sqlViewName: 'ZITR_ANALYTICS'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Orders Analytical View - APP'
@Metadata.ignorePropagatedAnnotations: true


define view ZITR_IDM_ORDERS_ANALYTICS
  as select from zitr_analytic_01
{

      @UI.lineItem: [{ position: 10, label: 'IDOc Year'  }]
      @EndUserText.label: 'IDOc Year'
  key idoc_year            as IdocYear,

      @UI.lineItem: [{ position: 20, label: 'IDOc Month'  }]
      @EndUserText.label: 'IDOc Month'
  key idoc_month           as IdocMonth,

      @UI.lineItem: [{ position: 30, label: 'Customer'  }]
      @EndUserText.label: 'Customer'
  key customer             as Customer,

      @UI.lineItem: [{ position: 35, label: 'Customer Name'  }]
      @EndUserText.label: 'Customer Name'
      customername,

      @UI.lineItem: [{ position: 35, label: 'Month - Year'  }]
      @EndUserText.label: 'Month - Year'
      monthyear            as MonthYear,

      @UI.lineItem: [{ position: 40, label: 'IDoc Processing Time'  }]
      @EndUserText.label: 'IDoc Processing Time'
      idoc_process_time    as IdocProcessTime,

      @UI.lineItem: [{ position: 50, label: 'Idoc Delayed Value'  }]
      @EndUserText.label: 'Idoc Delayed Value'
      @DefaultAggregation: #SUM
      idoc_delayed         as IdocDelayed,

      @UI.lineItem: [{ position: 60, label: 'IDOc Delayed Percentage'  }]
      @EndUserText.label: 'IDOc Delayed Percentage'
      idoc_delayed_perc    as IdocDelayedPerc,

      @UI.lineItem: [{ position: 70, label: 'Total Value'  }]
      @EndUserText.label: 'Total Value'
      @DefaultAggregation: #SUM
      total_value          as TotalValue,

      @UI.lineItem: [{ position: 80, label: 'Avg Days Delayed'  }]
      @EndUserText.label: 'Avg Days Delayed'
      average_days_delayed as AverageDaysDelayed,

      @UI.lineItem: [{ position: 90, label: 'Reason'  }]
      @EndUserText.label: 'Reason'
      reason               as Reason,

      @UI.lineItem: [{ position: 100, label: 'Errors Idoc 51'  }]
      @EndUserText.label: 'Errors Idoc 51'
      @DefaultAggregation: #SUM
      idoc_error_51        as Error_IDOC_Count,

      @UI.lineItem: [{ position: 110, label: 'Success IDoc 53'  }]
      @EndUserText.label: 'Success IDoc 53'
      @DefaultAggregation: #SUM
      idoc_success_53      as Success_IDOC_Count,

      @UI.lineItem: [{ position: 120, label: 'Errors Idoc 56'  }]
      @EndUserText.label: 'Errors Idoc 56'
      @DefaultAggregation: #SUM
      idoc_error_56        as Manualy_Error_IDOC_Count,

      @UI.lineItem: [{ position: 130, label: 'Ready IDoc 64'  }]
      @EndUserText.label: 'Ready IDoc 64'
      @DefaultAggregation: #SUM
      idoc_ready_64        as Ready_IDOC_Count,

      @UI.lineItem: [{ position: 140, label: 'Error IDoc 51 Net'  }]
      @EndUserText.label: 'Error IDoc 51 Net'
      @DefaultAggregation: #SUM
      idoc_net_error_51    as IdocNetError51,

      @UI.lineItem: [{ position: 150, label: 'Success IDoc 53 Net'  }]
      @EndUserText.label: 'Success IDoc 53 Net'
      @DefaultAggregation: #SUM
      idoc_net_success_53  as IdocNetSuccess53,

      @UI.lineItem: [{ position: 160, label: 'Error IDoc 56 Net'  }]
      @EndUserText.label: 'Error IDoc 56 Net'
      @DefaultAggregation: #SUM
      idoc_net_error_56    as IdocNetError56,

      @UI.lineItem: [{ position: 170, label: 'Ready IDoc 64 Net'  }]
      @EndUserText.label: 'Ready IDoc 64 Net'
      @DefaultAggregation: #SUM
      idoc_net_ready_64    as IdocNetReady64,

      @UI.lineItem: [{ position: 180, label: 'Success Percentage'  }]
      @EndUserText.label: 'Success Percentage'
      @DefaultAggregation: #SUM
      sucess_percentage    as SuccessPercentage,
      
      @UI.lineItem: [{ position: 180, label: 'Count of Errors'  }]
      @EndUserText.label: 'Count of Errors'
      @DefaultAggregation: #SUM
      errors
}
