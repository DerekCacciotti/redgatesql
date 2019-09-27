CREATE TABLE [dbo].[Confidentiality]
(
[ConfidentialityPK] [int] NOT NULL IDENTITY(1, 1),
[Username] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AcceptDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Confidentiality] ADD CONSTRAINT [PK_Confidentiality] PRIMARY KEY CLUSTERED  ([ConfidentialityPK]) ON [PRIMARY]
GO
