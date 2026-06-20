@AbapCatalog.sqlViewName: 'ZFLFMTISSUE'
@VDM.viewType: #CONSUMPTION
@Analytics.query: true
@Metadata.allowExtensions: true
define view Z_Cust_FlfmtIssue
  as select from C_SlsDocFlfmtIssue
{
  key SalesDocument,
      IssueCategory,
      NmbrOfAllIssues,
      TotalNetAmount,
      SalesOrganization,
      DistributionChannel,
      CreatedByUser
}
