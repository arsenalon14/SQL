With QTY AS (
  SELECT  
    EXTRACT(Month From DepartureDate) AS Month,Route,
    sum(Case When SSRDesc not in ('Water','Coffee','Americano','Boba Milk Tea') AND Extract(Year From DepartureDate) = 2024 THEN SSRCount ELSE 0 END) AS TotalQTY2024,
    sum(Case When SSRDesc not in ('Water','Coffee','Americano','Boba Milk Tea') AND Extract(Year From DepartureDate) = 2025 THEN SSRCount ELSE 0 END) AS TotalQTY2025,
  FROM `hidden-will-437506-i9.taaifs.Prebook` AS P
  Group by Month, Route
),
Pax AS (
  SELECT
    Extract(Month From DepartureDate) AS Month,
    sum(CAse When Extract(Year From DepartureDate) = 2024 Then PaxCount Else 0 END) AS TotalPax2024,
    sum(CAse When Extract(Year From DepartureDate) = 2025 Then PaxCount Else 0 END) AS TotalPax2025
  From `hidden-will-437506-i9.taaifs.Nationality` AS N
  Group by Month
)
Select 
  P.Month,P.Route,
  ROUND(SAFE_DIVIDE(P.TotalQTY2024, N.TotalPax2024)*100, 6) AS TUR2024,
  ROUND(SAFE_DIVIDE(P.TotalQTY2025, N.TotalPax2025)*100, 6) AS TUR2025,
  ROUND(SAFE_DIVIDE(P.TotalQTY2025, N.TotalPax2025)*100, 6) - ROUND(SAFE_DIVIDE(P.TotalQTY2024, N.TotalPax2024)*100, 6) AS TURDiff
FROM QTY AS P
JOIN  Pax AS N
 ON P.Month = N.Month
Order by P.Month ASC