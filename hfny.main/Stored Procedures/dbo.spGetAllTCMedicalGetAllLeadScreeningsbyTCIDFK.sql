SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spGetAllTCMedicalGetAllLeadScreeningsbyTCIDFK] @TCIDFK INT AS


SELECT tm.*,
  cmi.MedicalItemCode, cmi.MedicalItemText, 
  Cast(cast(lc.AppCode as int) as varchar(2)) +'. '+ lc.AppCodeText1 as leadtext,
  Cast(Cast(mr1.ReasonCode as int) as varchar(2)) + '. ' + mr1.ReasonDescription as r1,
  Cast(Cast(mr2.ReasonCode as int) as varchar(2)) + '. ' + mr2.ReasonDescription as r2,
  Cast(Cast(mr3.ReasonCode as int) as varchar(2)) + '. ' + mr3.ReasonDescription as r3,
  CONVERT(CHAR(10),tm.TCItemDate,111) AS DisplayDate 
from dbo.TCMedical tm
inner join dbo.codeMedicalItem cmi
	on tm.TCMedicalItem=cmi.MedicalItemCode
left outer join 
	(select AppCode, left(AppCodeText,30) as AppCodeText1 from codeApp where AppCodeGroup='LeadLevel') lc 
	on tm.leadlevelcode=lc.AppCode
left outer join 
	dbo.codeERHospitalReasons mr1
	on tm.MedicalReason1 = mr1.ReasonCode
left outer join
	dbo.codeERHospitalReasons mr2
	on tm.MedicalReason2 = mr2.ReasonCode
left outer join 
	dbo.codeERHospitalReasons mr3
	on tm.MedicalReason3 = mr3.ReasonCode
where TCIDFK=@TCIDFK AND cmi.MedicalItemUsedWhere = 'TM' AND  cmi.MedicalItemCode = 15
 
GO
