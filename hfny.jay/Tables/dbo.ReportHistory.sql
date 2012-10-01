CREATE TABLE [dbo].[ReportHistory]
(
[ReportHistoryPK] [int] NOT NULL IDENTITY(1, 1),
[ProgramFK] [int] NOT NULL,
[ReportCategory] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportFK] [int] NOT NULL,
[ReportName] [char] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReportType] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TimeRun] [datetime] NOT NULL,
[UserFK] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]




GO
ALTER TABLE [dbo].[ReportHistory] ADD CONSTRAINT [PK__ReportHi__488810E06BE40491] PRIMARY KEY CLUSTERED  ([ReportHistoryPK]) ON [PRIMARY]
GO
