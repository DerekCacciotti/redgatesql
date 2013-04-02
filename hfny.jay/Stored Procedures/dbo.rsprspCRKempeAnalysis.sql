SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <November 16th, 2012>
-- Description:	<This QA report gets you 'ASQ SE for Active Cases with Target Child 6 months or older '>
-- rsprspCRKempeAnalysis 2, '01/01/2011', '12/31/2011'

-- =============================================


CREATE procedure [dbo].[rsprspCRKempeAnalysis](
	@programfk    varchar(max)    = NULL,	
	@StartDate DATETIME,
	@EndDate DATETIME

)
AS
	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')

;
WITH cteCohort AS
(
	-- only include kempes that are positive and where there is a clos_date or an intake date.
	
	SELECT HVCasePK
		 , 	case
			   when h.tcdob is not null then
				   h.tcdob
			   else
				   h.edc
			end as tcdob
		 , DischargeDate
		 , IntakeDate
		 , k.KempeDate
		 , PC1FK
		 , cp.DischargeReason
		 , OldID
		 , PC1ID		 
		 , KempeResult
		 , cp.CurrentFSWFK
		 , cp.CurrentFAWFK		 
		 --, P.Race 
	
	
	 FROM HVCase h
	INNER JOIN CaseProgram cp ON cp.HVCaseFK = h.HVCasePK
	inner join dbo.SplitString(@ProgramFK,',') on cp.programfk = listitem
	INNER JOIN Kempe k ON k.HVCaseFK = h.HVCasePK
	--INNER JOIN PC P ON P.PCPK = h.PC1FK

	WHERE (h.IntakeDate IS NOT NULL OR cp.DischargeDate IS NOT NULL) -- only include kempes that are positive and where there is a clos_date or an intake date.
	AND k.KempeResult = 1
	AND k.KempeDate BETWEEN @StartDate AND @EndDate


)





SELECT * FROM cteCohort

-- rsprspCRKempeAnalysis 2, '01/01/2011', '12/31/2011'



--WITH cteCohort AS
--(
--select 
--	 h.HVCasePK, 
--	cp.PC1ID,
--	case
--	   when h.tcdob is not null then
--		   h.tcdob
--	   else
--		   h.edc
--	end as tcdob,

--	-- Form due date is intake date plus 30.44 days
--	dateadd(mm,1,h.IntakeDate) as FormDueDate,
	
--	LTRIM(RTRIM(fsw.firstname))+' '+LTRIM(RTRIM(fsw.lastname)) as worker,

--	codeLevel.LevelName,
--	h.IntakeDate,
--	cp.DischargeDate,
--	h.CaseProgress,
--	case
--	   when h.tcdob is not null then
--		 datediff(dd, h.tcdob,  @LastDayofPreviousMonth)
--	   else
--		   datediff(dd, h.edc, @LastDayofPreviousMonth)
--	end as XDateAge,
	
--	h.TCNumber,
--	CASE WHEN h.TCNumber > 1 THEN 'Yes' ELSE 'No' End
--	as [MultipleBirth],
	
--	0 AS DevAge,
	
--	case
--	   when T.GestationalAge is null then
--		 0
--	   else
--		   T.GestationalAge
--	end as GestationalAge,
--	T.TCDOD,
	
--	case
--	   when T.TCIDPK is null then
--		 0
--	   else
--		   T.TCIDPK
--	end as TCIDPK,	

--	rtrim(T.TCLastName) + ', ' + rtrim(T.TCFirstName) TCName, 
--	0 AS  	Missing ,
--	0 AS 	OutOfWindow,
--	0 AS 	RecOK
	
--	from dbo.CaseProgram cp
--	inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
--	left join codeLevel on cp.CurrentLevelFK = codeLevel.codeLevelPK
--	inner join dbo.HVCase h ON cp.HVCaseFK = h.HVCasePK	
--	inner join worker fsw on cp.CurrentFSWFK = fsw.workerpk
--	INNER JOIN TCID T ON T.HVCaseFK = h.HVCasePK 

--	where   ((h.IntakeDate <= dateadd(M, -1, @LastDayofPreviousMonth)) AND (h.IntakeDate IS NOT NULL))	-- enrolled atleast 30 days as of analysis point		 		  
--			AND (cp.DischargeDate IS NULL OR cp.DischargeDate > @LastDayofPreviousMonth)  --- case not closed as of analysis point

--)






GO
