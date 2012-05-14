IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'CHSRAdmin')
CREATE LOGIN [CHSRAdmin] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [CHSRAdmin] FOR LOGIN [CHSRAdmin]
GO
