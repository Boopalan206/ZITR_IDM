@EndUserText.label: 'IDOC Structures'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_ITR_LIST_QUERY'
define root custom entity ZI_LIST_CUST
{
     key IDOC_NUMBER : abap.string ;
     CUSTOMER_NAME : abap.string;
     IDOC_STATUS : abap.string;
     PO_NUMBER : abap.string;
     BOL_NUMBER : abap.string;
     CREATION_DATE : abap.string;
     DESCRIPTION : abap.string;
     WF_STATUS : abap.string;
     INVOICE_NUMBER : abap.string;
     MESSAGE_TYPE : abap.string;
     MSGTYP_DESC : abap.string;
     BASIC_TYPE : abap.string;
     BSCTYP_DESC : abap.string;
     SHIPPING : abap.string;
     DELIVERY_DATE : abap.string;
}
