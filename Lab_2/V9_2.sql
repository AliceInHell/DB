CREATE TABLE dbo.StateProvince (
	[StateProvinceID] [int] IDENTITY(1,1) NOT NULL,
	[StateProvinceCode] [nchar](3) NOT NULL,
	[CountryRegionCode] [nvarchar](3) NOT NULL,
	[IsOnlyStateProvinceFlag] [dbo].[Flag] NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[TerritoryID] [int] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
)
GO

ALTER TABLE dbo.StateProvince
	ADD PRIMARY KEY ([StateProvinceID], [StateProvinceCode])
GO

ALTER TABLE dbo.StateProvince
	ADD CONSTRAINT [TerritoryID]
	CHECK ([TerritoryID] % 2 = 0)
GO

ALTER TABLE dbo.StateProvince
	ADD CONSTRAINT df_TerritoryID
	DEFAULT 2 FOR [TerritoryID]
GO

SET IDENTITY_INSERT dbo.StateProvince ON
GO

INSERT INTO dbo.StateProvince (
	[StateProvinceID], 
	[StateProvinceCode], 
	[CountryRegionCode], 
	[IsOnlyStateProvinceFlag], 
	[Name], 
	[TerritoryID], 
	[ModifiedDate])
SELECT 
	province.StateProvinceID, 
	province.StateProvinceCode, 
	province.CountryRegionCode, 
	province.IsOnlyStateProvinceFlag, 
	province.[Name], 
	2, 
	province.ModifiedDate
FROM 
	(SELECT 
		stateProvince.StateProvinceID, 
		stateProvince.StateProvinceCode, 
		stateProvince.CountryRegionCode, 
		stateProvince.IsOnlyStateProvinceFlag, 
		stateProvince.[Name], 
		stateProvince.ModifiedDate,
		RANK() OVER(PARTITION BY stateProvince.[StateProvinceID], stateProvince.[StateProvinceCode] ORDER BY pAddress.AddressId DESC) AS N
	FROM AdventureWorks2012.Person.StateProvince AS stateProvince
	INNER JOIN AdventureWorks2012.Person.[Address] pAddress ON pAddress.StateProvinceID = stateProvince.StateProvinceID
	INNER JOIN AdventureWorks2012.Person.BusinessEntityAddress eAddress ON eAddress.AddressID = pAddress.AddressID
	INNER JOIN AdventureWorks2012.Person.AddressType addressType ON addressType.AddressTypeID = eAddress.AddressTypeID
	WHERE addressType.[Name] = 'Shipping'
	) AS province
WHERE N = 1
GO

ALTER TABLE dbo.StateProvince
	ALTER COLUMN [IsOnlyStateProvinceFlag] smallint NULL
GO