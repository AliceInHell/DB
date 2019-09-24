-- DROP PROCEDURE [Sales].[MaxDiscountByCategory]

CREATE TYPE Sales.SpecialOfferCategoryTableType AS TABLE 
(
	Category NVARCHAR(50)
)
GO


CREATE PROCEDURE [Sales].[MaxDiscountByCategory](@DiscountCategories Sales.SpecialOfferCategoryTableType READONLY) AS
	DECLARE @SQLQuery AS NVARCHAR(1024);
	DECLARE @Categories AS NVARCHAR(MAX);
	SELECT @Categories = STUFF((SELECT ',' + QUOTENAME(c.Category) 
                    from @DiscountCategories AS c
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'')

	SET @SQLQuery = '
		SELECT [Name], ' + @Categories + '
		FROM (  SELECT p.Name, so.Category, so.DiscountPct
				FROM Sales.SpecialOffer AS so
				INNER JOIN Sales.SpecialOfferProduct AS sop ON sop.SpecialOfferID = so.SpecialOfferID 
				INNER JOIN Production.Product AS p ON p.ProductID = sop.ProductID) AS p
		PIVOT
		(MAX(DiscountPct)
		FOR p.Category IN (' + @Categories + ')) AS pvt'
    EXECUTE sp_executesql @SQLQuery
GO


-- call
DECLARE @Categories Sales.SpecialOfferCategoryTableType
INSERT INTO @Categories (Category)
SELECT DISTINCT Category FROM Sales.SpecialOffer

EXECUTE [Sales].[MaxDiscountByCategory] @Categories;