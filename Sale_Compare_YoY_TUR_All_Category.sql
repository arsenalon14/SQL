With MasterQTY AS (
  SELECT  
    EXTRACT(Month From FlightDate) AS Month,Route,
    SUM(CASE WHEN ProductCategory = 'Beverage' AND ProductCode NOT in ('FNBG02000607','FNBG02000638','FNBG02000688','FNBG02000670','FNBG02000766','FNBG02000767','FNBG02000768','FNBG04000062') AND Extract(Year From FlightDate) = 2024 THEN Quantity ELSE 0 END) AS BeverageQTY2024,
    SUM(CASE WHEN ProductCategory = 'Beverage' AND ProductCode NOT in ('FNBG02000607','FNBG02000638','FNBG02000688','FNBG02000670','FNBG02000766','FNBG02000767','FNBG02000768','FNBG04000062') AND Extract(Year From FlightDate) = 2025 THEN Quantity ELSE 0 END) AS BeverageQTY2025,
    SUM(CASE WHEN ProductCategory = 'Non-Perishable' AND Extract(Year From FlightDate) = 2024 THEN Quantity ELSE 0 END) AS Non_PerQTY2024,
    SUM(CASE WHEN ProductCategory = 'Non-Perishable' AND Extract(Year From FlightDate) = 2025 THEN Quantity ELSE 0 END) AS Non_PerQTY2025,
    SUM(CASE WHEN ProductCategory = 'Perishable' AND Extract(Year From FlightDate) = 2024 THEN Quantity ELSE 0 END) AS PerishableQTY2024,
    SUM(CASE WHEN ProductCategory = 'Perishable' AND Extract(Year From FlightDate) = 2025 THEN Quantity ELSE 0 END) AS PerishableQTY2025
  FROM `hidden-will-437506-i9.taaifs.MasterSale` AS M
  Where ProductCategory in ('Beverage','Perishable','Non-Perishable','Combo') AND ProductCode not in ('COMBO1000999','COMBO1001481','COMBO1001482','COMBO1000406','COMBO1001519','COMBO1001520','COMBO1002154','COMBO1002155','COMBO1002313','COMBO1002675','COMBO1002678','COMBO1002711','COMBO1002712','COMBO1002982','COMBO1002983')
  Group by Month, Route
),
Pax AS (
  SELECT
    Extract(Month From DepartureDate) AS Month,
    sum(CASE WHEN Extract(Year From DepartureDate) = 2024 THEN PaxCount ELSE 0 END) AS TotalPax2024,
    sum(CASE WHEN Extract(Year From DepartureDate) = 2025 THEN PaxCount ELSE 0 END) AS TotalPax2025
  From `hidden-will-437506-i9.taaifs.Nationality` AS N
  Group by Month
)
Select 
  M.Month,M.Route,
  ROUND(SAFE_DIVIDE(M.BeverageQTY2024, N.TotalPax2024)*100, 6) AS Bev_TUR2024,
  ROUND(SAFE_DIVIDE(M.BeverageQTY2025, N.TotalPax2025)*100, 6) AS Bev_TUR2025,
  ROUND(SAFE_DIVIDE(M.BeverageQTY2025, N.TotalPax2025)*100, 6) - ROUND(SAFE_DIVIDE(M.BeverageQTY2024, N.TotalPax2024)*100, 6) AS Bev_Diff,
  ROUND(SAFE_DIVIDE(M.Non_PerQTY2024, N.TotalPax2024)*100, 6) AS Non_Per_TUR2024,
  ROUND(SAFE_DIVIDE(M.Non_PerQTY2025, N.TotalPax2025)*100, 6) AS Non_Per_TUR2025,
  ROUND(SAFE_DIVIDE(M.Non_PerQTY2025, N.TotalPax2025)*100, 6) - ROUND(SAFE_DIVIDE(M.Non_PerQTY2024, N.TotalPax2024)*100, 6) AS Non_Per_Diff,
  ROUND(SAFE_DIVIDE(M.PerishableQTY2024, N.TotalPax2024)*100, 6) AS Per_TUR2024,
  ROUND(SAFE_DIVIDE(M.PerishableQTY2025, N.TotalPax2025)*100, 6) AS Per_TUR2025,
  ROUND(SAFE_DIVIDE(M.PerishableQTY2025, N.TotalPax2025)*100, 6) - ROUND(SAFE_DIVIDE(M.PerishableQTY2024, N.TotalPax2024)*100, 6) AS Per_Diff
FROM MasterQTY AS M
JOIN  Pax AS N
 ON M.Month = N.Month
Order by M.Month ASC