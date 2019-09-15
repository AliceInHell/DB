USE master 
GO

CREATE DATABASE Vadzim_Makarchyk;
GO

USE Vadzim_Makarchyk
GO

CREATE SCHEMA sales;
GO

CREATE SCHEMA persons;
GO

CREATE TABLE sales.Orders (OrderNum INT NULL);
GO

BACKUP DATABASE Vadzim_Makarchyk
TO "Vadzim_Makarchyk"
WITH FORMAT,
	MEDIANAME = 'SQLServerBackups',
	NAME = 'Vadzim_Makarchyk Backup';
GO

DROP DATABASE Vadzim_Makarchyk
GO

RESTORE DATABASE Vadzim_Makarchyk
FROM "Vadzim_Makarchyk"
GO