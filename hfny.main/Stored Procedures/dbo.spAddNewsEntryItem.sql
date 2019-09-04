SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddNewsEntryItem](@Contents varchar(max)=NULL,
@OrderBy int=NULL,
@NewsEntryFK int=NULL)
AS
INSERT INTO NewsEntryItem(
Contents,
OrderBy,
NewsEntryFK
)
VALUES(
@Contents,
@OrderBy,
@NewsEntryFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
