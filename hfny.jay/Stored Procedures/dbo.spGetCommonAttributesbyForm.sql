SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROCEDURE [dbo].[spGetCommonAttributesbyForm]
	@FormFK [int],
	@FormType [char](8)
AS

SET NOCOUNT ON;

SELECT * 
FROM CommonAttributes
WHERE FormFK = @FormFK
AND FormType = @FormType





GO
