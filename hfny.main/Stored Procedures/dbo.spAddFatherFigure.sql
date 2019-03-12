SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddFatherFigure](@DateAcceptService datetime=NULL,
@DateInactive datetime=NULL,
@FatherAdvocateFK int=NULL,
@FatherFigureCreator varchar(max)=NULL,
@HVCaseFK int=NULL,
@IsOBP bit=NULL,
@IsPC2 bit=NULL,
@IsOther bit=NULL,
@LiveInPC1Home bit=NULL,
@MarriedToPC1 bit=NULL,
@PC2InPC1Home bit=NULL,
@PCFK int=NULL,
@ProgramFK int=NULL,
@RelationToTargetChild char(2)=NULL,
@RelationToTargetChildOther varchar(100)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) FatherFigurePK
FROM FatherFigure lastRow
WHERE 
@DateAcceptService = lastRow.DateAcceptService AND
@DateInactive = lastRow.DateInactive AND
@FatherAdvocateFK = lastRow.FatherAdvocateFK AND
@FatherFigureCreator = lastRow.FatherFigureCreator AND
@HVCaseFK = lastRow.HVCaseFK AND
@IsOBP = lastRow.IsOBP AND
@IsPC2 = lastRow.IsPC2 AND
@IsOther = lastRow.IsOther AND
@LiveInPC1Home = lastRow.LiveInPC1Home AND
@MarriedToPC1 = lastRow.MarriedToPC1 AND
@PC2InPC1Home = lastRow.PC2InPC1Home AND
@PCFK = lastRow.PCFK AND
@ProgramFK = lastRow.ProgramFK AND
@RelationToTargetChild = lastRow.RelationToTargetChild AND
@RelationToTargetChildOther = lastRow.RelationToTargetChildOther
ORDER BY FatherFigurePK DESC) 
BEGIN
INSERT INTO FatherFigure(
DateAcceptService,
DateInactive,
FatherAdvocateFK,
FatherFigureCreator,
HVCaseFK,
IsOBP,
IsPC2,
IsOther,
LiveInPC1Home,
MarriedToPC1,
PC2InPC1Home,
PCFK,
ProgramFK,
RelationToTargetChild,
RelationToTargetChildOther
)
VALUES(
@DateAcceptService,
@DateInactive,
@FatherAdvocateFK,
@FatherFigureCreator,
@HVCaseFK,
@IsOBP,
@IsPC2,
@IsOther,
@LiveInPC1Home,
@MarriedToPC1,
@PC2InPC1Home,
@PCFK,
@ProgramFK,
@RelationToTargetChild,
@RelationToTargetChildOther
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
