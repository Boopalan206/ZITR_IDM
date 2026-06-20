@EndUserText.label: 'Status Codes for IDOC Process'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_BRF_PLUS'
define custom entity ZI_IDOC_STATUS_CODES
{
  key status_codes : abap.string;
  status_type  : abap.string;
}
