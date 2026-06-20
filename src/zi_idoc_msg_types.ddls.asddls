@EndUserText.label: 'Message Types for IDOC Process'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_BRF_PLUS'
define custom entity ZI_IDOC_MSG_TYPES
{
  key msg_type : abap.string;
  description : abap.string;
}
