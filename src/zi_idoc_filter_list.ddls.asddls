@EndUserText.label: 'IDOC BRF+ filter list'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_BRF_PLUS'
define custom entity ZI_IDOC_FILTER_LIST
{
  key FILTER_ID   : abap.string;
      FILTER_VALUE : abap.string;
      filter_description : abap.string;
}
