CREATE TABLE [dbo].[PC1ID]
(
[PC1IDPK] [int] NOT NULL IDENTITY(1, 1),
[NextNum] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PC1ID] ADD CONSTRAINT [PK__PC1ID__D89FE0054C6B5938] PRIMARY KEY CLUSTERED  ([PC1IDPK]) ON [PRIMARY]
GO
