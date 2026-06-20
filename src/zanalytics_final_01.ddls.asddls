@AbapCatalog.sqlViewName: 'ZANALYTI_CDS_1'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Replica of Analytical Final'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@OData.publish: true


@UI.chart:[ {
    qualifier: 'DefaultChat',
    chartType: #COLUMN,
    description: 'Total Value By Customer',
    dimensions:  [ 'Customername' ],
    measures:  [ 'TotalValue' ],
    dimensionAttributes: [{dimension: 'Customername', role: #SERIES }],
    measureAttributes: [{measure: 'TotalValue',role: #AXIS_1 }]
},
{
     qualifier: 'VisualCustomer',
    chartType: #DONUT,
    description: 'Total Value By Customer',
    dimensions:  [ 'Customername' ],
    measures:  [ 'TotalValue' ],
    dimensionAttributes: [{dimension: 'Customername', role: #SERIES }],
    measureAttributes: [{measure: 'TotalValue',role: #AXIS_1 }]
},
{
    qualifier: 'VisualReason',
    chartType: #BAR,
    description: 'Total Value By Reason',
    dimensions:  [ 'Reason' ],
    measures:  [ 'TotalValue' ],
    dimensionAttributes: [{dimension: 'Reason', role: #SERIES }],
    measureAttributes: [{measure: 'TotalValue',role: #AXIS_1 }]
},
{
    qualifier: 'VisualMonth',
    chartType: #LINE,
    description: 'Total Value By Month Year',
    dimensions:  [ 'Monthyear' ],
    measures:  [ 'TotalValue' ],
    dimensionAttributes: [{dimension: 'Monthyear', role: #SERIES }],
    measureAttributes: [{measure: 'TotalValue',role: #AXIS_1 }]
},
{
    qualifier: 'VisualCustomer2',
    chartType: #LINE,
    description: 'Delayed value by Customer',
    dimensions:  [ 'Customername' ],
    measures:  [ 'IdocDelayed' ],
    dimensionAttributes: [{dimension: 'Customername', role: #SERIES }],
    measureAttributes: [{measure: 'IdocDelayed',role: #AXIS_1 }]
}

]


@UI.presentationVariant:[
 {
 qualifier: 'PSV_Default',text: 'Total Value By Customer',
 visualizations: [{ type: #AS_CHART, qualifier: 'DefaultChat'
  }]
},
{
 qualifier: 'PSQ1_VisualCustomer',text: 'Total Value By Customer',
 visualizations: [{ type: #AS_CHART, qualifier: 'VisualCustomer'
  }]
},
{
 qualifier: 'PSQ1_VisualReason',text: 'Total Value By Reason',
 visualizations: [{ type: #AS_CHART, qualifier: 'VisualReason'
  }]
},
{
 qualifier: 'PSQ1_VisualMonth',text: 'Total Value By Month Year',
 visualizations: [{ type: #AS_CHART, qualifier: 'VisualMonth'
  }]
},
{
 qualifier: 'PSQ1_VisualCustomer2',text: 'Delayed Value By Customer',
 visualizations: [{ type: #AS_CHART, qualifier: 'VisualCustomer2'
  }]
}
]

define view ZANALYTICS_FINAL_01
  as select from ZANALYTICS_FINAL
{
      @AnalyticsDetails.query.display: #KEY_TEXT
      @UI.selectionField: [{ position: 40 }]
      @UI.lineItem: [{ position: 10, label: 'IDoc Number' }]
      @UI.hidden: true
  key IdocNumber,

      @AnalyticsDetails.query.display: #KEY_TEXT
      @UI.lineItem: [{ position: 20, label: 'YEar' }]
  key IdocYear,

      @AnalyticsDetails.query.display: #KEY_TEXT
      @UI.selectionField: [{ position: 50 }]
      @UI.lineItem: [{ position: 30, label: 'Month' }]
  key IdocMonth,

      @AnalyticsDetails.query.display: #KEY_TEXT
      @UI.lineItem: [{ position: 135, label: 'Create Date' }]
      Credat,

      @AnalyticsDetails.query.display: #KEY_TEXT
      @UI.selectionField: [{ position: 10 }]
      @UI.lineItem: [{ position: 40, label: 'Customer' }]
      Customername,

      @AnalyticsDetails.query.display: #KEY_TEXT
      @UI.lineItem: [{ position: 35, label: 'Month - Year' }]
      Monthyear,

      @DefaultAggregation: #SUM
      @UI.lineItem: [{ position: 55, label: 'Delayed Value' }]
      IdocDelayed,

      @DefaultAggregation: #SUM
      @UI.lineItem: [{ position: 60, label: 'Total Value' }]
      TotalValue,

      @DefaultAggregation: #AVG
      @UI.lineItem: [{ position: 65, label: 'Avg Delaye Days' }]
      AverageDaysDelayed,

      @AnalyticsDetails.query.display: #KEY_TEXT
      @UI.selectionField: [{ position: 20 }]
      @UI.lineItem: [{ position: 34, label: 'Reason' }]
      Reason,

      @AnalyticsDetails.query.display: #KEY_TEXT
      @UI.lineItem: [{ position: 70, label: 'Reason Desc' }]
      ReasonText,

      @AnalyticsDetails.query.display: #KEY_TEXT
      @UI.lineItem: [{ position: 75, label: 'IDoc Type' }]
      IdocType,

      @AnalyticsDetails.query.display: #KEY_TEXT
      @UI.selectionField: [{ position: 30 }]
      @UI.lineItem: [{ position: 50, label: 'Message Type' }]
      MessageType
}
