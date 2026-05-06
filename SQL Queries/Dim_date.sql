-- =============================================
-- 02_09_Dim_Date.sql
-- Purpose: Create a proper Calendar dimension table for time intelligence in Power BI
-- =============================================

CREATE TABLE Dim_Date (
    DateKey          DATE PRIMARY KEY,
    FullDate         DATE,
    Year             INT,
    Quarter          INT,
    MonthNum         INT,
    MonthName        VARCHAR(20),
    MonthNameShort   VARCHAR(3),
    DayOfMonth       INT,
    WeekdayNum       INT,
    WeekdayName      VARCHAR(20),
    IsWeekend        BIT,
    Fiscal_Year      INT   -- Optional: you can customize
);

-- Populate the Date Table (2022-01-01 to 2023-12-31 is safe)
INSERT INTO Dim_Date (DateKey, FullDate)
SELECT 
    DateValue,
    DateValue
FROM (
    SELECT DATEADD(DAY, number, '2022-01-01') AS DateValue
    FROM master.dbo.spt_values 
    WHERE type = 'P' AND number BETWEEN 0 AND 730   -- ~2 years
) d
WHERE DateValue <= '2023-12-31';

-- Fill other columns
UPDATE Dim_Date
SET 
    Year           = DATEPART(YEAR, FullDate),
    Quarter        = DATEPART(QUARTER, FullDate),
    MonthNum       = DATEPART(MONTH, FullDate),
    MonthName      = DATENAME(MONTH, FullDate),
    MonthNameShort = LEFT(DATENAME(MONTH, FullDate), 3),
    DayOfMonth     = DATEPART(DAY, FullDate),
    WeekdayNum     = DATEPART(WEEKDAY, FullDate),
    WeekdayName    = DATENAME(WEEKDAY, FullDate),
    IsWeekend      = CASE WHEN DATEPART(WEEKDAY, FullDate) IN (1,7) THEN 1 ELSE 0 END,
    Fiscal_Year    = DATEPART(YEAR, FullDate);   -- You can adjust fiscal year logic later