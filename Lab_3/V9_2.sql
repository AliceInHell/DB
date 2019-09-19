ALTER TABLE dbo.StateProvince
ADD TaxRate smallmoney, CurrencyCode nchar(3), AverageRate money, IntTaxRate AS CEILING(TaxRate)


CREATE TABLE dbo.#StateProvince (
	[StateProvinceID] [int] NOT NULL,
	[StateProvinceCode] [nchar](3) NOT NULL,
	[CountryRegionCode] [nvarchar](3) NOT NULL,
	[IsOnlyStateProvinceFlag] [smallint] NULL,
	-- [Name] [dbo].[Name] NOT NULL,					does not work, user defined type in tempDB
	[Name] [nvarchar](50) NOT NULL,
	[TerritoryID] [int] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[TaxRate] [smallmoney],
	[CurrencyCode] [nchar](3),
	[AverageRate] [money]
	PRIMARY KEY CLUSTERED (StateProvinceID)
)

;WITH AVRCURR AS (
	SELECT cr.ToCurrencyCode AS CurrencyCode, MAX(cr.AverageRate) AS AverageRate
	FROM AdventureWorks2012.Sales.CurrencyRate AS cr
	GROUP BY ToCurrencyCode
),
    TAXTYPE AS (
	SELECT 		
		sp.StateProvinceID,
		taxRate.TaxType, 
		taxRate.TaxRate, 
		crc.CurrencyCode
	FROM dbo.StateProvince sp
	-- INNER JOIN AdventureWorks2012.Person.CountryRegion AS cr ON cr.CountryRegionCode = sp.CountryRegionCode
	INNER JOIN AdventureWorks2012.Sales.CountryRegionCurrency AS crc ON crc.CountryRegionCode = sp.CountryRegionCode
	LEFT JOIN AdventureWorks2012.Sales.SalesTaxRate AS taxRate ON taxRate.StateProvinceID = sp.StateProvinceID
	WHERE taxRate.TaxType = 1 OR taxRate.TaxType IS NULL
) 
INSERT INTO dbo.#StateProvince (
	StateProvinceID, 
	StateProvinceCode, 
	CountryRegionCode,
	IsOnlyStateProvinceFlag,
	[Name],
	TerritoryID,
	ModifiedDate,
	TaxRate,
	CurrencyCode,
	AverageRate )
SELECT 
	sp.StateProvinceID, 
	sp.StateProvinceCode,
	sp.CountryRegionCode,
	sp.IsOnlyStateProvinceFlag,
	sp.[Name],
	sp.TerritoryID,
	sp.ModifiedDate,
	CASE tt.TaxType
		WHEN 1 THEN tt.TaxRate
		ELSE 0
	END AS TaxRate,
	ac.CurrencyCode,
	ac.AverageRate
FROM dbo.StateProvince AS sp
INNER JOIN TAXTYPE AS tt ON tt.StateProvinceID = sp.StateProvinceID
INNER JOIN AVRCURR AS ac ON ac.CurrencyCode = tt.CurrencyCode

-- output updated
SELECT *
FROM dbo.#StateProvince

-- allow identity insert
SET IDENTITY_INSERT dbo.StateProvince ON
GO


DELETE 
FROM dbo.StateProvince 
WHERE CountryRegionCode = 'CA'


MERGE dbo.StateProvince AS t_target
USING dbo.#StateProvince AS t_source
ON t_target.StateProvinceID = t_source.StateProvinceID
WHEN MATCHED THEN UPDATE SET	
	t_target.TaxRate = t_source.TaxRate,
	t_target.CurrencyCode = t_source.CurrencyCode,
	t_target.AverageRate = t_source.AverageRate
WHEN NOT MATCHED BY TARGET THEN	INSERT 
(
	StateProvinceID, 
	StateProvinceCode, 
	CountryRegionCode,
	IsOnlyStateProvinceFlag,
	[Name],
	TerritoryID,
	ModifiedDate,
	TaxRate,
	CurrencyCode,
	AverageRate
)
VALUES
(
	t_source.StateProvinceID, 
	t_source.StateProvinceCode, 
	t_source.CountryRegionCode,
	t_source.IsOnlyStateProvinceFlag,
	t_source.[Name],
	t_source.TerritoryID,
	t_source.ModifiedDate,
	t_source.TaxRate,
	t_source.CurrencyCode,
	t_source.AverageRate
)
WHEN NOT MATCHED BY SOURCE THEN DELETE;

-- output updated
SELECT *
FROM dbo.StateProvince