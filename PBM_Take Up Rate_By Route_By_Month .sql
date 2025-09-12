With QTY AS (
  SELECT  
    EXTRACT(Month From DepartureDate) AS Month,Route,
  sum(Case When SSRDesc not in ('Water','Coffee','Americano','Boba Milk Tea') THEN SSRCount ELSE 0 END) AS TotalQTY,
  sum(ConvertedChargeAmount) AS TotalRev
  FROM `hidden-will-437506-i9.taaifs.Prebook` AS P
  Where EXTRACT(Year From DepartureDate) = 2025
  Group by Month, Route
  Order by Month ASC
),
Pax AS (
  SELECT
    Extract(Month From DepartureDate) AS Month,Route,
    sum(PaxCount) AS TotalPax
  From `hidden-will-437506-i9.taaifs.Nationality` AS N
  Where EXTRACT(Year From DepartureDate) = 2025
  Group by Month,Route 
  Order by Month ASC
)
Select 
  P.Month,P.Route,
  Round(SAFE_DIVIDE(P.TotalQTY,N.TotalPax)*100,6) AS TUR,
  P.TotalQTY,  
  Round(SAFE_DIVIDE(P.TotalRev,N.TotalPax),2) AS RPP,
  P.TotalRev,
  N.TotalPax
FROM QTY AS P
JOIN  Pax AS N
 ON P.Month = N.Month 
 AND P.Route = N.Route
Order by P.Month ASC