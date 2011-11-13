SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jay Robohn
-- Create date: Nov 12, 2011
-- Description:	all Follow Ups by HVCaseFK; Used for the navagation page
-- =============================================
CREATE PROCEDURE [dbo].[spGetAllFUPbyHVCaseFK]  (@HVCaseFK int)
	-- Add the parameters for the stored procedure here
--	<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
--	<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select appCodeText AS FupIntervalText,appCode as FupInterval, FollowUpDate,  FollowUpPK, PC1InHome, PC2InHome, OBPInHome,FUPInWindow, ProgramFK, HVCaseFK
	from (select appCodeText,appCode 
		from codeApp 
		where appCodeGroup='AgeInterval' and appCodeUsedWhere like '%FU') a
	Left outer join (select CONVERT(VARCHAR(20),FollowUpDate,101) AS FollowUpDate,FollowUpInterval as TCAge, FollowUpPK, 
						PC1InHome, OBPInHome, PC2InHome,FUPInWindow, ProgramFK, HVCaseFK
					from FollowUp where HVCaseFK =@HVCaseFK) b 
	on a.appCode=b.TCAge

END











GO
