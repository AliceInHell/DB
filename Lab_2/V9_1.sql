SELECT employee.BusinessEntityID, employee.JobTitle, SUM(payHistory.Rate) as AverageRate
FROM AdventureWorks2012.HumanResources.Employee as employee
INNER JOIN AdventureWorks2012.HumanResources.EmployeePayHistory payHistory ON employee.BusinessEntityID = payHistory.BusinessEntityID
GROUP BY employee.BusinessEntityID, employee.JobTitle

SELECT 
	employee.BusinessEntityID, 
	employee.JobTitle, 
	payHistory.Rate,
	CASE 
		WHEN payHistory.Rate <= 50 THEN 'less or equal 50'
		WHEN payHistory.Rate > 50 AND payHistory.Rate <= 100 THEN 'more than 50 but less or equal 100'
		ELSE 'more than 100'
	END as RateReport
FROM AdventureWorks2012.HumanResources.Employee as employee
INNER JOIN AdventureWorks2012.HumanResources.EmployeePayHistory payHistory 
	ON employee.BusinessEntityID = payHistory.BusinessEntityID

SELECT departament.[Name], MAX(payHistory.Rate) as MaxRate
FROM AdventureWorks2012.HumanResources.EmployeeDepartmentHistory as edh
INNER JOIN AdventureWorks2012.HumanResources.Department as departament ON departament.DepartmentID = edh.DepartmentID
INNER JOIN AdventureWorks2012.HumanResources.EmployeePayHistory as payHistory ON payHistory.BusinessEntityID = edh.BusinessEntityID
GROUP BY departament.[Name]
HAVING MAX(payHistory.Rate) > 60