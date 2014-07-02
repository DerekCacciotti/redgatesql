SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <June 26th, 2014>
-- Description:	<gets you Case Filter List for all cases (pc1id's) in a given program>

-- [rspCaseFilterList] 1
-- exec dbo.rspCaseFilterList @programfks='1',@casefilterspositive=NULL
-- =============================================
CREATE procedure [dbo].[rspCaseFilterList]
(
    @programfks           varchar(max)    = null,
    @casefilterspositive varchar(200) = null                                                  
                                                        
)

as
begin

	
	set @casefilterspositive = case when @casefilterspositive = '' then null else @casefilterspositive end
;
with cteMain as
(
		SELECT HVCasePK
			  ,rtrim(P.PCFirstName) + ' ' + rtrim(P.PCLastName) as PC1FullName
			  ,PC1ID
			  , PCDOB 
			   ,ScreenDate 
			   ,KempeDate
			   ,IntakeDate
			  ,DischargeDate
			  ,DischargeReason
			  ,DischargeReasonSpecify	   
			  ,CurrentFAWFK
			  ,CurrentFSWFK
			  ,CurrentLevelFK
			   ,case -- handling different types of filter types
					when lcf.FilterType = 1
						then case when cf2.CaseFilterNameChoice=1 then 'Yes' else 'No' end
					when lcf.FilterType = 2
						then (select cfno.FilterOption from listCaseFilterNameOption cfno where listCaseFilterNameOptionPK=cf2.CaseFilterNameOptionFK)
					when lcf.FilterType = 3
						then CaseFilterValue
				end as FilterOption	

		 FROM HVCase h
			inner join CaseProgram cp on cp.HVCaseFK = h.HVCasePK
			inner join dbo.SplitString(@ProgramFKs, ',') ss on ss.ListItem = cp.ProgramFK
			inner join PC P on P.PCPK = h.PC1FK
			inner join dbo.udfCaseFilters(@casefilterspositive,'', @ProgramFKs) cf on cf.HVCaseFK = cp.HVCaseFK
			
			inner join CaseFilter cf2 on cf2.HVCaseFK = cp.HVCaseFK
			inner join listCaseFilterName lcf on lcf.listCaseFilterNamePK = cf2.CaseFilterNameFK

)

,cteFilterOptions as -- merge rows i.e. put all filters in one row given an hvcasepk / pc1id
(
	SELECT HVCasePK	
	
			,FilterOption = replace((select cast(FilterOption as varchar(50)) as [data()]
												  from cteMain m1
												  where m1.HVCasePK = m2.HVCasePK
												  order by HVCasePK for xml path('')), ' ', ',')
		  
		  --,FilterOption 
		  FROM cteMain m2
		  group by HVCasePK 
)

,cteFAWFSWNames as 
(
	select distinct HVCasePK	
		, case when m3.CurrentFAWFK is null then 'NO FAW Assigned' 
					else rtrim(w.FirstName) + ' ' + rtrim(w.LastName) 
			end 
			as FAWName	
			
		,rtrim(fsw.firstname)+' '+rtrim(fsw.lastname) fswname

	
			  ,CurrentFAWFK
			  ,CurrentFSWFK
		  FROM cteMain m3
		  inner join Worker w on w.WorkerPK = m3.CurrentFAWFK
		  inner join worker fsw on fsw.workerpk = m3.CurrentFSWFK


)



,cteUniqueFilterCases as
(
	SELECT distinct 
			HVCasePK
		  ,PC1FullName
		  ,PC1ID
		  ,PCDOB
		  ,ScreenDate
		  ,KempeDate
		  ,IntakeDate
		  ,DischargeDate
		  ,DischargeReason
		  ,DischargeReasonSpecify
		  ,CurrentFAWFK
		  ,CurrentFSWFK
		  ,CurrentLevelFK
		  FROM cteMain 

)

,cteFilterCaseList as
(
	SELECT 
		  -- ufc.HVCasePK
		  PC1FullName
		  ,PC1ID
		  ,Convert(VARCHAR(12), PCDOB, 101) PCDOB
		  ,Convert(VARCHAR(12), ScreenDate, 101)  ScreenDate
		  ,Convert(VARCHAR(12), KempeDate, 101)  KempeDate
		  ,Convert(VARCHAR(12), IntakeDate, 101)  IntakeDate		  
		  ,Convert(VARCHAR(12), DischargeDate, 101)  DischargeDate
		  --,ufc.DischargeReason
		  ,ds.DischargeReason
		  ,DischargeReasonSpecify
		  --,ufc.CurrentFAWFK
		  --,ufc.CurrentFSWFK
		  ,FAWName
		  ,FSWName		  
		  --,CurrentLevelFK
		  ,LevelName 		  
		  ,FilterOption FROM cteUniqueFilterCases ufc
	inner join cteFilterOptions fo on fo.HVCasePK = ufc.HVCasePK 
	inner join cteFAWFSWNames FAWFSW on FAWFSW.HVCasePK = ufc.HVCasePK 
	left join codeDischarge ds on ds.DischargeCode = ufc.DischargeReason
	left join codeLevel on codeLevel.codeLevelPK = ufc.CurrentLevelFK

	
	
)



--SELECT * FROM cteFilterOptions
--SELECT * FROM cteUniqueFilterCases
SELECT * FROM cteFilterCaseList
order by PC1ID
-- [rspCaseFilterList] 1


end
GO
