CREATE PROCEDURE [Sales].[MaxDiscountByCategory](@DiscountCategories NVARCHAR(250)) AS
	DECLARE @SQLQuery AS NVARCHAR(1024);
	SET @SQLQuery = '
		SELECT [Name], ' + @DiscountCategories + '
		FROM (  SELECT p.Name, so.Category, so.DiscountPct
				FROM Sales.SpecialOffer AS so
				INNER JOIN Sales.SpecialOfferProduct AS sop ON sop.SpecialOfferID = so.SpecialOfferID 
				INNER JOIN Production.Product AS p ON p.ProductID = sop.ProductID) AS p
		PIVOT
		(MAX(DiscountPct)
		FOR p.Category IN (' + @DiscountCategories + ')) AS pvt'
    EXECUTE sp_executesql @SQLQuery
GO


EXECUTE [Sales].[MaxDiscountByCategory] '[Reseller],[No Discount],[Customer]';