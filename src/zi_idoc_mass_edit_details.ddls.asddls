@EndUserText.label: 'Fetch segment details of a IDOC Msg Type'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_DETAIL_IDOC'
@ObjectModel.resultSet.sizeCategory: #(10000)
define custom entity ZI_IDOC_MASS_EDIT_DETAILS
{
  key SEGMENT      : edihsegtyp;
      MSG_TYPE     : abap.char( 30 );
      SEGMENT_DESC : abap.char( 100 );
      SUB_SEGMENT  : abap.char( 30 );
      SUB_SEG_DESC : abap.char( 100 );
      FIELD_VALUES : abap.char( 30 );
}
