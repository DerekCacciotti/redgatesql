CREATE TABLE [dbo].[codeFormAccess]
(
[codeFormAccessPK] [int] NOT NULL IDENTITY(1, 1),
[AllowedAccess] [bit] NOT NULL,
[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_codeFormAccess_CreateDate] DEFAULT (getdate()),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[codeFormFK] [int] NOT NULL,
[StateFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[codeFormAccess] ADD CONSTRAINT [PK_codeFormAccess] PRIMARY KEY CLUSTERED  ([codeFormAccessPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[codeFormAccess] ADD CONSTRAINT [FK_codeFormAccess_codeForm] FOREIGN KEY ([codeFormFK]) REFERENCES [dbo].[codeForm] ([codeFormPK])
GO
ALTER TABLE [dbo].[codeFormAccess] ADD CONSTRAINT [FK_codeFormAccess_State] FOREIGN KEY ([StateFK]) REFERENCES [dbo].[State] ([StatePK])
GO
