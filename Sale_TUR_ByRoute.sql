With MasterQTY AS (
  SELECT  
    EXTRACT(Month From FlightDate) AS Month,Route,
    SUM(CASE WHEN ProductCategory = 'Beverage' AND ProductCode NOT in ('FNBG02000607','FNBG02000638','FNBG02000688','FNBG02000670','FNBG02000766','FNBG02000767','FNBG02000768','FNBG04000062') THEN Quantity ELSE 0 END) AS BeverageQTY,
    SUM(CASE WHEN ProductCategory = 'Non-Perishable' THEN Quantity ELSE 0 END) AS Non_PerQTY,
    SUM(CASE WHEN ProductCategory = 'Perishable' THEN Quantity ELSE 0 END) AS PerishableQTY,
  sum(NetSales) AS TotalRev
  FROM `hidden-will-437506-i9.taaifs.MasterSale` AS M
  Where EXTRACT(Year From FlightDate) = 2025 AND ProductCategory in ('Beverage','Perishable','Non-Perishable','Combo') AND ProductCode not in ('COMBO1000999','COMBO1001481','COMBO1001482','COMBO1000406','COMBO1001519','COMBO1001520','COMBO1002154','COMBO1002155','COMBO1002313','COMBO1002675','COMBO1002678','COMBO1002711','COMBO1002712','COMBO1002982','COMBO1002983')
  Group by Month, Route
),
Pax AS (
  SELECT
    Extract(Month From DepartureDate) AS Month,
    sum(PaxCount) AS TotalPax
  From `hidden-will-437506-i9.taaifs.Nationality` AS N
  Where EXTRACT(Year From DepartureDate) = 2025
  Group by Month
)
Select 
  M.Month,M.Route,
  ROUND(SAFE_DIVIDE(M.BeverageQTY, N.TotalPax)*100, 6) AS Bev_TUR,
  ROUND(SAFE_DIVIDE(M.Non_PerQTY, N.TotalPax)*100, 6) AS Non_Per_TUR,
  ROUND(SAFE_DIVIDE(M.PerishableQTY, N.TotalPax)*100, 6) AS Per_TUR,
  ROUND(SAFE_DIVIDE(M.TotalRev,N.TotalPax), 2) AS RPP
FROM MasterQTY AS M
JOIN  Pax AS N
 ON M.Month = N.Month
Order by M.Month ASC