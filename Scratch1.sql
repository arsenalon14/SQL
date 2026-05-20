SELECT 
  RecordLocator, --1
  PassengerID, --2
  InternationalDesc, --3
  FlightNumber, --4
  DATE(STD) DepartureDate, --5
  LegSector, --6
  ChargeCode, --7
  count(distinct(ChargeCode)) Total_SSR, --8
  sum(AOCChargeAmount) Total_Rev, --9
  CASE When sum(AOCChargeAmount) = 0 THEN 'Yes' ELSE 'No' END AS Is_Promo --10
FROM `airasia-opdatalake-prd.RADIANT_MIRROR.master_MasterSquareFeeDate`
WHERE 
  CarrierCode in ('FD') 
  AND BookingStatus in (2,3)
  AND Date(BookingDate) = ('2026-05-11') 
  AND BookingSalesChannel in ('Internet','Mobile','MOVE CH')
  AND ProductClassCode in ('EC','EP')
  AND IS_Charter = 'N'
  AND InternationalDesc = 'INT'
  AND ChargeCategory in ('Food and Beverage')
  AND ChargeCode not in ('CWDR','WBHL','AMDR','BODR')
Group by 1,2,3,4,5,6,7
Order by 2 ASC