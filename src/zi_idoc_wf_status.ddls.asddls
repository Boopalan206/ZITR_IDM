@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS for WF status update'
define root view entity ZI_IDOC_WF_STATUS
  as select from ztitr_wf_status
{
  key workflow_id,
  key idoc_number,
      department,
      user_desc,
      needed_by,
      status
}
