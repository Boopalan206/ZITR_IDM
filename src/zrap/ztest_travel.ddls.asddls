@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'TRavel Test'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@UI.headerInfo: {
    typeName: 'Travel',
    typeNamePlural: 'Travels',
    title: { type: #STANDARD, value: 'TravelId' },
    description: { value: 'Description' }
}
define view entity ZTest_Travel
  as select from ztravel_data as travel
{
    @UI.facet: [{ purpose: #STANDARD,
                  type: #IDENTIFICATION_REFERENCE,
                  position: 10,
                  label: 'Customer Details' }]
  @UI.lineItem:       [{ position: 09, label: 'Travel Id' }]
  @UI.selectionField: [{ position: 10 }]
  key travel_id as TravelId,

  @UI.selectionField: [{ position: 20 }]
  @UI.lineItem:       [{ position: 10, label: 'Agency' }]
  agency_id as AgencyId,

  @UI.lineItem:       [{ position: 20, label: 'Customer ID' }]
  customer_id as CustomerId,

  @UI.lineItem:       [{ position: 30, label: 'Begin Date' }]
  begin_date as BeginDate,

  @UI.lineItem:       [{ position: 40, label: 'End Date' }]
  end_date as EndDate,

  @UI.lineItem:       [{ position: 80, label: 'Booking Fee' }]
  booking_fee as BookingFee,

  @UI.lineItem:       [{ position: 60, label: 'Total Price' }]
  total_price as TotalPrice,

  @UI.lineItem:       [{ position: 70, label: 'Currency Code' }]
  currency_code as CurrencyCode,

  @UI.lineItem:       [{ position: 50, label: 'Description' }]
  description as Description,

  overall_status        as OverallStatus,
  attachment            as Attachment,
  mime_type             as MimeType,
  file_name             as FileName,
  created_by            as CreatedBy,
  created_at            as CreatedAt,
  local_last_changed_by as LocalLastChangedBy,
  local_last_changed_at as LocalLastChangedAt,
  last_changed_at       as LastChangedAt
}

