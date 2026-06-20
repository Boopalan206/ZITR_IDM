@EndUserText.label: 'IDoc Processing for IDM'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_DETAIL_IDOC'
define custom entity ZI_IDOC_PROCESSING
{
 
  key IDOC_NUMBER      : abap.string;
        STATUS         : abap.string;
        STATUS_TYPE    : abap.char( 1 );
}
