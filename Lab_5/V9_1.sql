CREATE FUNCTION Sales.GetFormattedSpesialOfferStartDate(@SpecialOfferID INT) RETURNS NVARCHAR(50) AS
BEGIN
	DECLARE @date datetime
	SELECT @date = StartDate
	FROM Sales.SpecialOffer AS so
	WHERE so.SpecialOfferID = @SpecialOfferID

	RETURN FORMAT(@date, 'MMMM, dd. dddd')
END;
GO

SELECT Sales.GetFormattedSpesialOfferStartDate (1)
GO


CREATE FUNCTION Sales.GetSpecialOfferProducts(@SpecialOfferID INT) RETURNS TABLE AS
RETURN
SELECT 
	[p].[ProductID],
	[p].[Name],
	[p].[ProductNumber],
	[p].[MakeFlag],
	[p].[FinishedGoodsFlag],
	[p].[Color],
	[p].[SafetyStockLevel],
	[p].[ReorderPoint],
	[p].[StandardCost],
	[p].[ListPrice],
	[p].[Size],
	[p].[SizeUnitMeasureCode],
	[p].[WeightUnitMeasureCode],
	[p].[Weight],
	[p].[DaysToManufacture],
	[p].[ProductLine],
	[p].[Class],
	[p].[Style],
	[p].[ProductSubcategoryID],
	[p].[ProductModelID],
	[p].[SellStartDate],
	[p].[SellEndDate],
	[p].[DiscontinuedDate],
	[p].[rowguid],
	[p].[ModifiedDate]
FROM Sales.SpecialOffer AS so
JOIN Sales.SpecialOfferProduct AS sop ON sop.SpecialOfferID = so.SpecialOfferID
JOIN Production.Product AS p ON p.ProductID = sop.ProductID
GO


SELECT * FROM Sales.SpecialOffer CROSS APPLY Sales.GetSpecialOfferProducts(SpecialOfferID)
SELECT * FROM Sales.SpecialOffer OUTER APPLY Sales.GetSpecialOfferProducts(SpecialOfferID)
GO


CREATE FUNCTION Sales.GetSpecialOfferProductsMultistatement(@SpecialOfferID INT) RETURNS @result TABLE (
	[ProductID] [int] NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[ProductNumber] [nvarchar](25) NOT NULL,
	[MakeFlag] [dbo].[Flag] NOT NULL,
	[FinishedGoodsFlag] [dbo].[Flag] NOT NULL,
	[Color] [nvarchar](15) NULL,
	[SafetyStockLevel] [smallint] NOT NULL,
	[ReorderPoint] [smallint] NOT NULL,
	[StandardCost] [money] NOT NULL,
	[ListPrice] [money] NOT NULL,
	[Size] [nvarchar](5) NULL,
	[SizeUnitMeasureCode] [nchar](3) NULL,
	[WeightUnitMeasureCode] [nchar](3) NULL,
	[Weight] [decimal](8, 2) NULL,
	[DaysToManufacture] [int] NOT NULL,
	[ProductLine] [nchar](2) NULL,
	[Class] [nchar](2) NULL,
	[Style] [nchar](2) NULL,
	[ProductSubcategoryID] [int] NULL,
	[ProductModelID] [int] NULL,
	[SellStartDate] [datetime] NOT NULL,
	[SellEndDate] [datetime] NULL,
	[DiscontinuedDate] [datetime] NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL) AS 
BEGIN
	INSERT INTO @result
	SELECT 
		[p].[ProductID],
		[p].[Name],
		[p].[ProductNumber],
		[p].[MakeFlag],
		[p].[FinishedGoodsFlag],
		[p].[Color],
		[p].[SafetyStockLevel],
		[p].[ReorderPoint],
		[p].[StandardCost],
		[p].[ListPrice],
		[p].[Size],
		[p].[SizeUnitMeasureCode],
		[p].[WeightUnitMeasureCode],
		[p].[Weight],
		[p].[DaysToManufacture],
		[p].[ProductLine],
		[p].[Class],
		[p].[Style],
		[p].[ProductSubcategoryID],
		[p].[ProductModelID],
		[p].[SellStartDate],
		[p].[SellEndDate],
		[p].[DiscontinuedDate],
		[p].[rowguid],
		[p].[ModifiedDate]
	FROM Sales.SpecialOffer AS so
	JOIN Sales.SpecialOfferProduct AS sop ON sop.SpecialOfferID = so.SpecialOfferID
	JOIN Production.Product AS p ON p.ProductID = sop.ProductID
	RETURN
END;
GO