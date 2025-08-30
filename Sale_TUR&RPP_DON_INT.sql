WITH Quatitydata AS (
  SELECT 
    EXTRACT(Year FROM n.FlightDate) AS Year,
    EXTRACT(Month FROM n.FlightDate) AS Month,
    CASE WHEN Country = 'THAILAND' Then 'Dom' Else 'Int' END AS TypeFlight,
    SUM(CASE WHEN ProductCategory = 'Beverage' AND PromoRefID = 'À la carte' AND ProductCode NOT in ('FNBG02000607','FNBG02000638','FNBG02000688','FNBG02000670','FNBG02000766','FNBG02000767','FNBG02000768','FNBG04000062') THEN n.Quantity ELSE 0 END) AS BeverageQTY,
    SUM(CASE WHEN ProductCategory = 'Non-Perishable' AND PromoRefID = 'À la carte' THEN n.Quantity ELSE 0 END) AS Non_PerQTY,
    SUM(CASE WHEN ProductCategory = 'Perishable' AND PromoRefID = 'À la carte' THEN n.Quantity ELSE 0 END) AS PerishableQTY,
    SUM(CASE WHEN ProductCategory = 'Combo' AND PromoRefID <> 'À la carte' AND ProductCode NOT IN ('COMBO1000999','COMBO1001481','COMBO1001482','COMBO1000406','COMBO1001519','COMBO1001520','COMBO1002154','COMBO1002155','COMBO1002313','COMBO1002675','COMBO1002678','COMBO1002711','COMBO1002712','COMBO1002982','COMBO1002983') THEN n.Quantity ELSE 0 END) AS ComboQTYPromo,
    SUM(CASE WHEN ProductCategory = 'Beverage' THEN n.NetSales ELSE 0 END) AS BeverageRev,
    SUM(CASE WHEN ProductCategory = 'Non-Perishable' THEN n.NetSales ELSE 0 END) AS Non_PerRev,
    SUM(CASE WHEN ProductCategory = 'Perishable' THEN n.NetSales ELSE 0 END) AS PerishableRev,
    SUM(CASE WHEN ProductCategory = 'Combo' AND PromoRefID <> 'À la carte' AND ProductCode NOT IN ('COMBO1000999','COMBO1001481','COMBO1001482','COMBO1000406','COMBO1001519','COMBO1001520','COMBO1002154','COMBO1002155','COMBO1002313','COMBO1002675','COMBO1002678','COMBO1002711','COMBO1002712','COMBO1002982','COMBO1002983') THEN n.NetSales ELSE 0 END) AS ComboRevPromo
  FROM `hidden-will-437506-i9.taaifs.MasterSale` AS n
  Where PaymentStatus <> 'Refunded' 
  GROUP BY
    EXTRACT(Year FROM n.FlightDate),
    EXTRACT(Month FROM n.FlightDate),
    CASE WHEN Country = 'THAILAND' Then 'Dom' Else 'Int' END
),
Paxdata AS (
  SELECT
    EXTRACT(YEAR FROM DepartureDate) AS Year,
    EXTRACT(MONTH FROM DepartureDate) AS Month,
    CASE WHEN Country = 'THAILAND' THEN 'Dom' ELSE 'Int' END AS TypeFlight,
    SUM(CASE WHEN LiftStatus = 'Boarded' THEN PaxCount ELSE 0 END) AS TotalPax
  FROM `hidden-will-437506-i9.taaifs.Nationality` AS m
  GROUP BY 
    EXTRACT(YEAR FROM DepartureDate),
    EXTRACT(MONTH FROM DepartureDate),
    CASE WHEN Country = 'THAILAND' THEN 'Dom' ELSE 'Int' END
)
SELECT 
  n.Year,
  n.Month,
  n.TypeFlight,
  n.BeverageQTY + n.Non_PerQTY + n.PerishableQTY + n.ComboQTYPromo AS TotalQTY,
  ((n.BeverageRev + n.ComboRevPromo) + n.Non_PerRev + n.PerishableRev) AS TotalRev,
  m.TotalPax,
  ROUND(SAFE_DIVIDE((n.BeverageQTY + n.Non_PerQTY + n.PerishableQTY + n.ComboQTYPromo) * 100, m.TotalPax), 2) AS TUR,
  ROUND(SAFE_DIVIDE((n.BeverageRev + n.ComboRevPromo) + n.Non_PerRev + n.PerishableRev, m.TotalPax), 2) AS RPP
FROM Quatitydata AS n
JOIN Paxdata AS m
  ON n.Year = m.Year 
  AND n.Month = m.Month
  AND n.TypeFlight = m.TypeFlight
ORDER BY n.Year, n.Month