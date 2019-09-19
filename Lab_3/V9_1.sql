ALTER TABLE dbo.StateProvince
	ADD AddressType nvarchar(50)
GO


DECLARE @StateProvince TABLE
(
	[StateProvinceID] [int] NOT NULL,
	[StateProvinceCode] [nchar](3) NOT NULL,
	[CountryRegionCode] [nvarchar](3) NOT NULL,
	[IsOnlyStateProvinceFlag] [smallint] NULL,
	[Name] [dbo].[Name] NOT NULL,
	[TerritoryID] [int] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[AddressType] [nvarchar](50) NOT NULL
)

INSERT INTO @StateProvince 
SELECT 
	StateProvince.StateProvinceID,
	stateProvince.StateProvinceCode, 
	stateProvince.CountryRegionCode, 
	stateProvince.IsOnlyStateProvinceFlag,
	stateProvince.[Name],
	stateProvince.TerritoryID,
	stateProvince.ModifiedDate, 
	addressType.[Name]
FROM dbo.StateProvince AS stateProvince
INNER JOIN AdventureWorks2012.Person.[Address] pAddress ON pAddress.StateProvinceID = stateProvince.StateProvinceID
INNER JOIN AdventureWorks2012.Person.BusinessEntityAddress eAddress ON eAddress.AddressID = pAddress.AddressID
INNER JOIN AdventureWorks2012.Person.AddressType addressType ON addressType.AddressTypeID = eAddress.AddressTypeID


UPDATE dbo.StateProvince
SET AddressType = CONCAT(countryRegion.[Name], ' ', sp.AddressType)
FROM @StateProvince AS sp
INNER JOIN AdventureWorks2012.Person.CountryRegion AS countryRegion ON countryRegion.CountryRegionCode = sp.CountryRegionCode
WHERE sp.StateProvinceID = dbo.StateProvince.StateProvinceID AND sp.StateProvinceCode = dbo.StateProvince.StateProvinceCode

-- output updated
SELECT * 
FROM dbo.StateProvince
GO


WITH CTE
AS
(
	SELECT *, RANK() OVER(PARTITION BY sp.AddressType ORDER BY sp.StateProvinceID DESC) AS RankNumber
	FROM dbo.StateProvince AS sp
)
DELETE 
FROM CTE
WHERE CTE.RankNumber > 1
GO

-- output updated
SELECT * 
FROM dbo.StateProvince
GO

ALTER TABLE dbo.StateProvince
	DROP COLUMN AddressType


ALTER TABLE dbo.StateProvince DROP CONSTRAINT TerritoryID
ALTER TABLE dbo.StateProvince DROP CONSTRAINT df_TerritoryID

DROP TABLE dbo.StateProvince