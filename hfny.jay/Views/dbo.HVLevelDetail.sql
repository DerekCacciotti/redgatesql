SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [dbo].[HVLevelDetail] as
select HVLevelpk, hvcasefk,programfk,levelname, caseweight, maximumvisit,minimumvisit,Levelfk,
StartLevelDate,isnull(EndLevel,DischargeDate) as EndLevelDate from 
(select DischargeDate,HVLevelpk, lv1.hvcasefk,lv1.programfk,levelname, caseweight, maximumvisit,minimumvisit,Levelfk,
LevelAssignDate as StartLevelDate,
dateadd(day,-1,(select top 1 LevelAssignDate 
	from HVLevel lv2 
	where lv2.LevelAssigndate>lv1.LevelAssigndate and lv2.hvcasefk=lv1.hvcasefk
    order by levelAssigndate)) EndLevel
from hvlevel lv1
inner join 
codeLevel
on codeLevelPK=levelfk
inner join caseprogram cp
on lv1.hvcasefk=cp.hvcasefk and lv1.programfk=cp.programfk) a


GO
