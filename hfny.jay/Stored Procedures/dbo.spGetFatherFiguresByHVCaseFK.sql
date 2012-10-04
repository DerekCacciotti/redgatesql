SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[spGetFatherFiguresByHVCaseFK]

(
    @HVCaseFK int
)
as
	set nocount on;

	select FatherFigurePK
		  ,DateAcceptService
		  ,DateInactive
		  ,FatherAdvocateFK
		  ,FatherFigureCreateDate
		  ,FatherFigureCreator
		  ,FatherFigureEditDate
		  ,FatherFigureEditor
		  ,HVCaseFK
		  ,IsOBP
		  ,IsPC2
		  ,LiveInPC1Home
		  ,MarriedToPC1
		  ,PC2InPC1Home
		  ,PCFK
		  ,ProgramFK
		  ,RelationToTargetChild
		  ,RelationToTargetChildOther
		from FatherFigure
		where HVCaseFK = @HVCaseFK
GO
