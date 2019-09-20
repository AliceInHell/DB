CREATE TABLE Sales.SpecialOfferHst (
	ID INT IDENTITY(1, 1) PRIMARY KEY,
	[Action] CHAR(6) NOT NULL CHECK (Action IN('INSERT', 'UPDATE', 'DELETE')),
	ModifiedDate DATETIME NOT NULL,
	SourceID INT NOT NULL,
	UserName VARCHAR(128) NOT NULL
)
GO

/*DROP TABLE Sales.SpecialOfferHst
DROP TRIGGER Sales.SpecialOfferTrigger
DROP VIEW Sales.SpecialOfferView*/

CREATE TRIGGER Sales.SpecialOfferTrigger
ON Sales.SpecialOffer
AFTER INSERT, UPDATE, DELETE AS
	INSERT INTO Sales.SpecialOfferHst ([Action], ModifiedDate, SourceID, UserName)
	SELECT
		CASE 
			WHEN inserted.SpecialOfferID IS NULL THEN 'DELETE'
			WHEN deleted.SpecialOfferID IS NULL  THEN 'INSERT'
			ELSE 'UPDATE'
		END,
	GetDate(),
	COALESCE(inserted.SpecialOfferID, deleted.SpecialOfferID),
	User_Name()
	FROM inserted 
	FULL OUTER JOIN deleted ON inserted.SpecialOfferID = deleted.SpecialOfferID
GO


CREATE VIEW Sales.SpecialOfferView 
WITH ENCRYPTION
AS 
SELECT * 
FROM Sales.SpecialOffer
GO

DENY VIEW DEFINITION ON Sales.SpecialOfferView TO PUBLIC


INSERT INTO Sales.SpecialOfferView (
	Category, 
	[Description], 
	DiscountPct, 
	EndDate, 
	MaxQty,
	MinQty, 
	ModifiedDate, 
	rowguid, 
	StartDate, 
	[Type])
VALUES ('Category', 'Insert', 3.1, GetDate(), 5, 2, GetDate(), NEWID(), GetDate(), 'Type')

UPDATE Sales.SpecialOfferView SET [Description] = 'UPDATE' WHERE Category = 'Category'

DELETE Sales.SpecialOfferView WHERE [Description] = 'UPDATE'


SELECT * 
FROM Sales.SpecialOfferHst