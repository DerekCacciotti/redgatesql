SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Chris Papas
-- Create date: 07/15/2009
-- Description:	Get ReferralSourcenames List by ProgramPK
-- =============================================
CREATE PROCEDURE [dbo].[spGetListALLReferralSourcebyProgram]
	@ProgramPK as Int = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * FROM 
	listReferralSource
	WHERE ProgramFK = @ProgramPK
	ORDER BY ReferralSourceName
END

GO
