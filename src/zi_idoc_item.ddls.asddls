@EndUserText.label: 'Custome Details of IDoc Item'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_DETAIL_IDOC'
define custom entity ZI_IDOC_ITEM

{
  key idoc_number       : edi_docnum;
      material_number   : abap.string;
      material_desc     : abap.string;
      order_quantity    : abap.string;
      uom               : abap.string;
      order_value       : abap.string;
      currency          : abap.string;
      delivery_quantity : abap.string;
      weight            : abap.string;
      wuom              : abap.string;
      po_number         : abap.string;
      item_number       : abap.string;
      cust_part_number  : abap.string;
      delvery_date      : abap.string;
      _header           : association to parent ZI_IDOC_HEADER on _header.IDOC_NUMBER = $projection.idoc_number;
}
