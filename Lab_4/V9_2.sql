CREATE VIEW Sales.OfferAndProductView (
	[Category],
	[Description],
	[DiscountPct],
	[EndDate],
	[MaxQty],
	[MinQty],
	[ModifiedDate],
	[rowguid],
	[SpecialOfferID],
	[StartDate],
	[Type],
	[ProductID],
	[Name]
)
WITH SCHEMABINDING 
AS
SELECT 
	[so].[Category],
	[so].[Description],
	[so].[DiscountPct],
	[so].[EndDate],
	[so].[MaxQty],
	[so].[MinQty],
	[so].[ModifiedDate],
	[so].[rowguid],
	[so].[SpecialOfferID],
	[so].[StartDate],
	[so].[Type],
	[p].[ProductID],
	[p].[Name]
FROM [Sales].[SpecialOffer] AS so
INNER JOIN [Sales].[SpecialOfferProduct] AS sop ON sop.SpecialOfferID = so.SpecialOfferID
INNER JOIN [Production].[Product] AS p ON p.ProductID = sop.ProductID
GO

CREATE UNIQUE CLUSTERED INDEX IX_OfferAndProductView_ProductID_SpecialOfferID
ON AdventureWorks2012.Sales.OfferAndProductView (ProductId, SpecialOfferID)
GO


CREATE TRIGGER [Sales].[TriggerOfferAndProductViewOnInsertUpdateDelete] ON [Sales].[OfferAndProductView]
INSTEAD OF INSERT, UPDATE, DELETE AS
BEGIN
	IF EXISTS (SELECT * FROM inserted)
	BEGIN
		IF EXISTS (
			SELECT * 
			FROM OfferAndProductView AS v 
			JOIN inserted ON inserted.ProductID = v.ProductID AND inserted.SpecialOfferID = v.SpecialOfferID)
		BEGIN
			-- update
			UPDATE Sales.SpecialOffer SET
				[Category] = [inserted].[Category],
				[Description] = [inserted].[Description],
				[DiscountPct] = [inserted].[DiscountPct],
				[EndDate] = [inserted].[EndDate],
				[MaxQty] = [inserted].[MaxQty],
				[MinQty] = [inserted].[MinQty],
				[ModifiedDate] = [inserted].[ModifiedDate],
				[rowguid] = [inserted].[RowGuid],
				[StartDate] = [inserted].[StartDate],
				[Type] = [inserted].[Type]
			FROM [inserted]
			WHERE [inserted].[SpecialOfferID] = [Sales].[SpecialOffer].[SpecialOfferID]
		END
		ELSE
		BEGIN
			-- insert
			INSERT INTO Sales.SpecialOffer (
				[Category],
				[Description],
				[DiscountPct],
				[EndDate],
				[MaxQty],
				[MinQty],
				[ModifiedDate],
				[rowguid],
				[StartDate],
				[Type])
			SELECT 
				[Category],
				[Description],
				[DiscountPct],
				[EndDate],
				[MaxQty],
				[MinQty],
				[ModifiedDate],
				[rowguid],
				[StartDate],
				[Type]
			FROM [inserted]

			INSERT INTO [Sales].[SpecialOfferProduct] (
				[SpecialOfferID],
				[ProductID],
				[ModifiedDate],
				[rowguid])
			SELECT 
				[so].[SpecialOfferID],
				[ProductID],
				GETDATE(),
				NEWID()
			FROM [inserted]
			JOIN [Sales].[SpecialOffer] AS [so] ON [so].[rowguid] = [inserted].[rowguid]
		END
	END

	IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
	BEGIN
		-- delete
		DELETE FROM Sales.SpecialOfferProduct 
		WHERE ProductID IN (SELECT ProductID FROM deleted)

		DELETE FROM Sales.SpecialOffer 
		WHERE SpecialOfferID IN (SELECT SpecialOfferID FROM deleted) AND SpecialOfferID NOT IN (SELECT SpecialOfferID FROM Sales.SpecialOfferProduct)
	END
END
GO


INSERT INTO Sales.OfferAndProductView (
	Category,
	[Description],
	DiscountPct,
	EndDate,
	MaxQty,
	MinQty,
	ModifiedDate,
	RowGuid,
	StartDate,
	[Type],
	ProductID,
	[Name]
)
VALUES ('category', 'description', 42.42, GETDATE(), 3, 1, GETDATE(), NEWID(), GETDATE(), 'type', 1, 'Adjustable Race')

UPDATE Sales.OfferAndProductView SET
	Category = 'category',
	[Description] = 'another description',
	DiscountPct = 13.13,
	EndDate = GETDATE(),
	MaxQty = 10,
	MinQty = 5,
	ModifiedDate = GETDATE(),
	RowGuid = NEWID(),
	StartDate = GETDATE(),
	[Type] = 't',
	[Name] = 'Adjustable Race'
WHERE Category = 'category'

DELETE FROM Sales.OfferAndProductView
WHERE Category = 'category'

-- output
SELECT * FROM Sales.OfferAndProductView WHERE Category = 'category'