SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE procedure [dbo].[spGetAllTCMedicalbyTCIDFK]
@TCIDFK as int

as
select tm.*,
  cmi.MedicalItemCode, cmi.MedicalItemText,
  Cast(cast(lc.AppCode as int) as varchar(2)) +'. '+ lc.AppCodeText1 as leadtext,
  Cast(Cast(mr1.TCMedicalReason as int) as varchar(2)) + '. ' + mr1.TCMedicalReasonText as r1,
  Cast(Cast(mr2.TCMedicalReason as int) as varchar(2)) + '. ' + mr2.TCMedicalReasonText as r2,
  Cast(Cast(mr3.TCMedicalReason as int) as varchar(2)) + '. ' + mr3.TCMedicalReasonText as r3
from dbo.TCMedical tm
inner join dbo.codeMedicalItem cmi
	on tm.TCMedicalItem=cmi.MedicalItemCode
left outer join 
	(select AppCode, left(AppCodeText,30) as AppCodeText1 from codeApp where AppCodeGroup='LeadLevel') lc 
	on tm.leadlevelcode=lc.AppCode
left outer join 
	codeTCMedical mr1
	on tm.MedicalReason1 = mr1.TCMedicalReason
left outer join
	codeTCMedical mr2
	on tm.MedicalReason2 = mr2.TCMedicalReason
left outer join 
	codeTCMedical mr3
	on tm.MedicalReason3 = mr3.TCMedicalReason
where TCIDFK=@TCIDFK 
order by tm.TCMedicalItem





GO
