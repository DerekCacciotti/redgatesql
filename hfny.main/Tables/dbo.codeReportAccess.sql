CREATE TABLE [dbo].[codeReportAccess]
(
[codeReportAccessPK] [int] NOT NULL IDENTITY(1, 1),
[AllowedAccess] [bit] NOT NULL,
[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_codeReportAccess_CreateDate] DEFAULT (getdate()),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReportFK] [int] NOT NULL,
[StateFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[codeReportAccess] ADD CONSTRAINT [PK_codeReportAccess] PRIMARY KEY CLUSTERED  ([codeReportAccessPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[codeReportAccess] ADD CONSTRAINT [FK_codeReportAccess_codeReportCatalog] FOREIGN KEY ([ReportFK]) REFERENCES [dbo].[codeReportCatalog] ([codeReportCatalogPK])
GO
ALTER TABLE [dbo].[codeReportAccess] ADD CONSTRAINT [FK_codeReportAccess_State] FOREIGN KEY ([StateFK]) REFERENCES [dbo].[State] ([StatePK])
GO
