@EndUserText.label: 'Custom Details of IDoc Header'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_DETAIL_IDOC'
define root custom entity ZI_IDOC_HEADER
 
{
  key IDOC_NUMBER    : edi_docnum;
      NET_VALUE      : abap.string;
      UOM            : abap.string;
      STATUS         : abap.string;
      SOLD_TO        : abap.string;
      PURCHASE_ORDER : abap.string;
      BOL_NUMBER     : abap.string;
      MESSAGE_TYPE   : abap.string;
      SALES_ORG      : abap.string;
      WF_STATUS      : abap.string;
      PO_DATE        : abap.string;
      _LineItems     : composition [1..*] of ZI_IDOC_ITEM;
}
