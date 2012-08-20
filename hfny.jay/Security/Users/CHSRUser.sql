IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'CHSRuser')
CREATE LOGIN [CHSRuser] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [CHSRUser] FOR LOGIN [CHSRuser]
GO
