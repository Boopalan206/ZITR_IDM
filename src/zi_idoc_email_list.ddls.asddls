@EndUserText.label: 'Email list for IDOC Process'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_BRF_PLUS'
define custom entity ZI_IDOC_EMAIL_LIST
{
  key msg_type : abap.string;
  key dep_name : abap.string;
      email_id : abap.string;
}
