With SaleByRoute AS ( #Don't Forget to chcek Month And Year
  SELECT  
  Route,
    SUM(
      CASE 
        WHEN ProductCategory = 'Beverage'
            AND ProductCode IN (
             'FNBG02000607','FNBG02000638','FNBG02000688','FNBG02000670',
             'FNBG02000766','FNBG02000767','FNBG02000768','FNBG04000062'
           )
        THEN 0
        ELSE Quantity
      END
  )   AS TotalQTY,
    SUM(NetSales) AS Rev
  FROM `hidden-will-437506-i9.taaifs.MasterSale`
  WHERE
    EXTRACT(YEAR FROM FlightDate) = 2025
    AND EXTRACT(MONTH FROM FlightDate) = 9
  GROUP BY Route
),
PassengerByRoute AS (
  SELECT DailyFlights.Route,
  Round(SUM(DailyFlights.TotalFlights)/2,0) AS TotalFlights,
  sum(DailyFlights.TotalPax) AS TotalPax,
  DailyFlights.TYPEFLIGHT
FROM (
  SELECT
    Route,
    EXTRACT(DATE FROM DepartureDate) AS DepartureDate,
    COUNT(DISTINCT FlightNumber) AS TotalFlights,
    Sum(PaxCount) AS TotalPax,
    CASE When Country = 'THAILAND' Then 'Dom' ELSE 'Int' END AS TYPEFLIGHT
  FROM
    `hidden-will-437506-i9.taaifs.Nationality`
  WHERE EXTRACT(YEAR FROM DepartureDate) = 2025
    AND EXTRACT(MONTH FROM DepartureDate) = 9
  GROUP BY
    Route,
    DepartureDate,
    TYPEFLIGHT
) AS DailyFlights
Group by DailyFlights.Route, DailyFlights.TYPEFLIGHT
Order by TotalFlights DESC
)

Select S.Route, 
  Round(SAFE_DIVIDE(S.Rev,P.TotalFlights),0) RevenuePerFlight, 
  Round(SAFE_DIVIDE(S.TotalQTY,P.TotalPax)*100,2) TUR, 
  Round((S.Rev/P.TotalPax),2) RPP,
  P.TYPEFLIGHT
FROM SaleByRoute AS S
Join PassengerByRoute AS P
ON S.Route = P.Route
