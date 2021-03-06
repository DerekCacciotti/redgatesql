/*
This is the migration script to update the database with the set of uncommitted changes you selected.

You can customize the script, and your edits will be used in deployment.
The following objects will be affected:
  dbo.ReportHistory
*/

SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Altering [dbo].[ReportHistory]'
GO
ALTER TABLE [dbo].[ReportHistory] ALTER COLUMN [ReportType] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Refreshing [dbo].[ReportHistoryTest]'
GO
EXEC sp_refreshview N'[dbo].[ReportHistoryTest]'
GO
