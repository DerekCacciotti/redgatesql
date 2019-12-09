CREATE TABLE [dbo].[codeReportAccess]
(
[codeReportAccessPK] [int] NOT NULL IDENTITY(1, 1),
[StartDate] [datetime] NOT NULL,
[EndDate] [datetime] NULL,
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
