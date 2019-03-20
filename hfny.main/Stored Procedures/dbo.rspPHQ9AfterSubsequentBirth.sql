SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[rspPHQ9AfterSubsequentBirth]
(
    @sDate as datetime,
	@eDate as datetime,
	@programfk  as VARCHAR(MAX)
)
as
begin
	set nocount on;
	IF @programfk IS NULL begin
		select @programfk = 
			substring((select ',' + ltrim(rtrim(str(HVProgramPK))) 
						from HVProgram
						for xml path('')),2,8000)
	end

	set @programfk = replace(@programfk,'"','')

	select OtherChild.OtherChildPK
	, OtherChild.DOB
	, HVCase.TCDOB
	, HVCase.HVCasePK
	, cp.PC1ID
	, case when OtherChild.FirstName <> '' then OtherChild.FirstName
	       else 'Missing'
	  end as FirstName
	, case when OtherChild.LastName <> '' then OtherChild.LastName
		   else 'Missing'
	  end as LastName	
	, cf.codeFormName as [FormName]
	, p.FormInterval
	, p.FormFK
	, p.DateAdministered
	, case when datediff(day, DOB, p.DateAdministered) <= 93 and datediff(day, DOB, p.DateAdministered) > 0 then 'Yes'
		   else 'No'
	  end as Within3Months
	from OtherChild 
	inner join dbo.SplitString(@programfk,',') ON OtherChild.programfk  = listitem
	left join dbo.PHQ9 p on p.HVCaseFK = OtherChild.HVCaseFK
	inner join hvcase on HVCase.HVCasePK = OtherChild.HVCaseFK and HVCase.TCDOB is not null
	inner join codeForm cf on cf.codeFormAbbreviation = p.FormType 
	inner join dbo.CaseProgram cp on cp.HVCaseFK = HVCase.HVCasePK
	where DOB between @sDate and @eDate
	--must be subsequent pregnancies 
	and DOB > TCDOB
	and DOB <= p.DateAdministered
	and Relation2PC1 = '01' --biological child
    --need to exclude empty phq9 rows that are written because follow-up always writes a row, regardless of whether the phq9 was administered.
	--We're being as generous as possible and including phq9s that have at least one question answered. 
	--Also need other children that have not had a phq9, so check for null phq9pk or at least one question answered.
	and (p.Difficulty is not null or --or they did one
			 p.Down is not null or 
			 p.Interest is not null or 
			 p.Sleep is not null or 
			 p.SlowOrFast is not null or 
			 p.Tired is not null)

end
GO
