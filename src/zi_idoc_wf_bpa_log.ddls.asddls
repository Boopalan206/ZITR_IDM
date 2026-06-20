@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS for workflow bpa log'
define root view entity ZI_IDOC_WF_BPA_LOG
  as select from ztitr_wf_bpa_log
{
  key idoc_number as IdocNumber,
  key workflow_id as WorkflowId,
      sequence    as Sequence,
      department  as Department,
      user_desc   as UserDesc,
      needed_by   as NeededBy,
      status      as Status,
      created_on  as CreatedOn,
      created_at  as CreatedAt,
      created_by  as CreatedBy,
      changed_on  as ChangedOn,
      changed_at  as ChangedAt,
      changed_by  as ChangedBy,
      comments    as Comments
}
