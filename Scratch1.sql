SELECT 
  RecordLocator, --1
  PassengerID, --2
  Date(BookingDate) BookDate, --3
  CarrierCode, --4
  InternationalDesc, --5
  FlightNumber, --6
  DATE(STD) DepartureDate, --7
  LegSector, --8
  ChargeCode, --9
  name, --10
  count(distinct(ChargeCode)) Total_SSR, --11
  sum(AOCChargeAmount) Total_Rev, --12
  CASE When sum(AOCChargeAmount) = 0 THEN 'Yes' ELSE 'No' END AS Is_Promo --13
FROM `airasia-opdatalake-prd.RADIANT_MIRROR.master_MasterSquareFeeDate`
LEFT JOIN `airasia-opdatalake-prd.NAVITAIRE.ssr`
ON ChargeCode = ssr_code
WHERE 
  CarrierCode in ('FD','XJ') 
  AND BookingStatus in (2,3)
  AND Date(BookingDate) >= ('2026-05-18') 
  AND BookingSalesChannel in ('Internet','Mobile','MOVE CH')
  AND ProductClassCode in ('EC','EP')
  AND IS_Charter = 'N'
  AND InternationalDesc = 'INT'
  AND ChargeCategory in ('Food and Beverage')
  AND ChargeCode not in ('CWDR','WBHL','AMDR','BODR')
Group by 1,2,3,4,5,6,7,8,9,10
Order by 2 ASC