/*RESTORE DATABASE AdventureWorks2012
FROM "AdventureWorks2012"
WITH MOVE 'AdventureWorks2012_Data' TO 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\AdventureWorks2012.mdf',
	 MOVE 'AdventureWorks2012_Log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Log\AdventureWorks2012.mdf'
GO*/

SELECT employee.BusinessEntityID, employee.JobTitle, employee.BirthDate, employee.HireDate
FROM AdventureWorks2012.HumanResources.Employee as employee
WHERE employee.BirthDate >= '1981-01-01' AND employee.HireDate >= '2003-04-01'

SELECT SUM(employee.VacationHours) as SumVacationHours, SUM(employee.SickLeaveHours) as SumSickLeaveHours
FROM AdventureWorks2012.HumanResources.Employee as employee

SELECT TOP 3 employee.BusinessEntityID, employee.JobTitle, employee.Gender, employee.BirthDate, employee.HireDate
FROM AdventureWorks2012.HumanResources.Employee as employee
ORDER BY employee.HireDate