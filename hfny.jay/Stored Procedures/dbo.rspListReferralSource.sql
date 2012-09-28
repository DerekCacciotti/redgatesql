
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Devinder S. Khalsa
-- Create date: 06/20/2012
-- Description:	Report containing  referal sources
-- Usage: rspListReferralSource 1,1
-- =============================================
CREATE PROCEDURE [dbo].[rspListReferralSource]
( @programfk INT,
@bRSIsActive      bit             = null
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   
SELECT [ReferralSourceName]     
  FROM [listReferralSource]
  WHERE ProgramFK = @programfk AND RSIsActive = @bRSIsActive AND ReferralSourceName <> ''
  ORDER BY ReferralSourceName
  
  
  END
GO
