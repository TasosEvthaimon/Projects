drop table DailyData

CREATE TABLE DailyData (
    DailyDataID SERIAL PRIMARY KEY, -- Auto-incrementing primary key
    PopulationID TEXT,              -- Use TEXT for simple string identifiers
    CostDate DATE,                  -- Date without time
    FishNo INT,                     -- Number of fish
    AverageWeight DECIMAL(18, 2)   -- Average weight of the fish
);
   
INSERT INTO DailyData (PopulationID, CostDate, FishNo, AverageWeight) VALUES
('Population1', '2020-01-31', 15000, 55.00), 
('Population2', '2020-01-31', 30000, 100.00),
('Population3', '2020-02-29', 1000, 150.00), 
('Population4', '2020-02-29', 4000, 75.00),  
('Population5', '2020-03-31', 2000, 200.00),
('Population6', '2020-03-31', 1900, 250.00), 
('Population7', '2020-04-30', 30000, 175.00), 
('Population8', '2020-04-30', 15000, 125.00), 
('Population9', '2020-05-31', 2500, 300.00), 
('Population10', '2020-05-31', 1200, 350.00),
('Population11', '2020-06-30', 1800, 180.00), 
('Population12', '2020-06-30', 22000, 225.00),
('Population13', '2020-07-31', 160, 200.00),
('Population14', '2020-07-31', 190, 300.00),
('Population15', '2020-08-31', 1400, 450.00),
('Population16', '2020-08-31', 2000, 500.00),
('Population17', '2020-09-30', 22000, 150.00),
('Population18', '2020-09-30', 1700, 250.00),
('Population19', '2020-10-31', 2100, 400.00),
('Population20', '2020-10-31', 1500, 450.00);

select * from dailydata d 

--Λάθος αποτέλεσμα,δεν είχα καταλάβει σωστά, αλλά το κρατάω, καθώς θα μπορούσε να χρησιμοποιηθεί 
WITH LastDayOfMonth AS (
    SELECT
        PopulationID,
        CostDate,
        (FishNo * AverageWeight / 1000) AS Biomass,
        DATE_TRUNC('month', CostDate) + INTERVAL '1 month - 1 day' AS LastDay
    FROM DailyData
    WHERE EXTRACT(YEAR FROM CostDate) = 2020
),
FilteredBiomass AS (
    SELECT
        PopulationID,
        CostDate,
        Biomass
    FROM LastDayOfMonth
    WHERE CostDate = LastDay
)
SELECT 
    CASE 
        WHEN Biomass BETWEEN 0 AND 100 THEN '0-100'
        WHEN Biomass BETWEEN 100.01 AND 200 THEN '100-200'
        WHEN Biomass BETWEEN 200.01 AND 300 THEN '200-300'
        WHEN Biomass BETWEEN 300.01 AND 500 THEN '300-500'
        ELSE '500+'
    END AS SizeClass,
    COUNT(*) AS RecordCount,
    SUM(Biomass) AS TotalBiomass
FROM FilteredBiomass
GROUP BY
    CASE 
        WHEN Biomass BETWEEN 0 AND 100 THEN '0-100'
        WHEN Biomass BETWEEN 100.01 AND 200 THEN '100-200'
        WHEN Biomass BETWEEN 200.01 AND 300 THEN '200-300'
        WHEN Biomass BETWEEN 300.01 AND 500 THEN '300-500'
        ELSE '500+'
    END
ORDER BY
    SizeClass;
    

    
   -- Υπολογισμός Βιομάζας και Εύρεση Τελευταίας Ημέρας Κάθε Μήνα
   --Ξεκινάω με το ποιες στήλες θέλω να φαίνονται
SELECT
    LastDay AS "Date",
    CASE 
        WHEN AverageWeight BETWEEN 0 AND 100 THEN '0-100'
        WHEN AverageWeight BETWEEN 100.01 AND 200 THEN '100-200'
        WHEN AverageWeight BETWEEN 200.01 AND 300 THEN '200-300'
        WHEN AverageWeight BETWEEN 300.01 AND 500 THEN '300-500'
        ELSE '500+'
    END AS "Average Weight Class",
    SUM(FishNo * AverageWeight / 1000) AS "Biomass" 
    -- Θέλω τα δεδομένα του  πίνακα, αλλά το έτος να είναι το  2020 και ορίζω και το last day of the month για κάθε ημερομηνία που έχω
FROM (
    SELECT
        PopulationID,
        CostDate,
        FishNo,
        AverageWeight,
        (FishNo * AverageWeight / 1000) AS Biomass,
        DATE_TRUNC('month', CostDate) + INTERVAL '1 month - 1 day' AS LastDay
    FROM DailyData
    WHERE EXTRACT(YEAR FROM CostDate) = 2020
) AS BiomassData
--Τωρα θέλω η ημερομηνία για την οποία γίνεται λόγος "CostDate" να είναι η τελευταία ημέρα για αυτό το μήνα, οπότε φιλτράρω με βάση αυτό
WHERE CostDate = LastDay
-- Θέλω αυτό να γίνει για κάθε τελευταία ημέρα κάθε μήνα και για κάθε Average Weight Class, οπότε group by αυτα τα δύο
GROUP BY
    LastDay,
    CASE 
        WHEN AverageWeight BETWEEN 0 AND 100 THEN '0-100'
        WHEN AverageWeight BETWEEN 100.01 AND 200 THEN '100-200'
        WHEN AverageWeight BETWEEN 200.01 AND 300 THEN '200-300'
        WHEN AverageWeight BETWEEN 300.01 AND 500 THEN '300-500'
        ELSE '500+'
    END
ORDER BY
    LastDay,
    "Average Weight Class";