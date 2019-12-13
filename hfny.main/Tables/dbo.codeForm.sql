CREATE TABLE [dbo].[codeForm]
(
[codeFormPK] [int] NOT NULL IDENTITY(1, 1),
[FormPKName] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[canBeReviewed] [bit] NULL,
[codeFormAbbreviation] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[codeFormName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatorFieldName] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormDateName] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MainTableName] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 12/13/2019
-- Description:	This trigger removes the related rows in the database
-- =============================================
CREATE TRIGGER [dbo].[TR_DeleteCodeForm] ON [dbo].[codeForm]
INSTEAD OF DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Delete any form access rows for the form
	DELETE cfa FROM dbo.codeFormAccess cfa  
		INNER JOIN Deleted d ON d.codeFormPK = cfa.codeFormFK

	--Delete the form row
	DELETE cf FROM dbo.codeForm cf
		INNER JOIN Deleted d ON d.codeFormPK = cf.codeFormPK

END
GO
ALTER TABLE [dbo].[codeForm] ADD CONSTRAINT [PK__codeForm__C6B7B00D3B75D760] PRIMARY KEY CLUSTERED  ([codeFormPK]) ON [PRIMARY]
GO
