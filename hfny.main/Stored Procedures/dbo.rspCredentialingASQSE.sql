SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Derek Cacciotti>
-- Create date: <May 21, 2018>
-- Description:	<report: Credentialing 6-6.C ASQSE>
-- Edit date: 
-- rspASQHistory 1
-- =============================================

CREATE procedure [dbo].[rspCredentialingASQSE]
(
    @ProgramFK       VARCHAR(MAX)   = null,
    @SupervisorFK    int            = null,
    @WorkerFK        int            = null,
    @UnderCutoffOnly char(1)        = 'N',
    @PC1ID           varchar(13)    = '',
    @SiteFK          int            = null, 
    @CaseFiltersPositive varchar(100) = ''
)
AS

--DECLARE @programfk       VARCHAR(MAX)   = '1'
--DECLARE @supervisorfk    int            = null
--DECLARE @workerfk        int            = null
--DECLARE @UnderCutoffOnly char(1)        = 'N'
--DECLARE @pc1ID           varchar(13)    = ''
--DECLARE @sitefk          int            = NULL
--DECLARE @CaseFiltersPositive varchar(100) = ''
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred

  if @programfk is null
	begin
		select @programfk = substring((select ','+ltrim(rtrim(str(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end
	set @programfk = replace(@programfk,'"','')
	set @SiteFK = isnull(@SiteFK, 0)
	set @CaseFiltersPositive = case	when @CaseFiltersPositive = '' then null
								else @CaseFiltersPositive
						   end;

	declare @n int = 0
	select @n = case when @UnderCutoffOnly = 'Y' then 1 else 0 end


	declare @cteAll table (
		   supervisor varchar(100)
		 , worker varchar(100)
		 , PC1ID char(13)
		 , TCName varchar(450)
		 , TCDOB varchar(12)
		 , GestationalAge int
		 , TCAge varchar(150)
		 , DateCompleted varchar(12)
		 , InWindow varchar(50)
		 , [TCAgeCode] char(2)
		 , ASQTCReceiving int
	)

	declare @cteMain table (
		supervisor char(50)
		,worker char(50)
		,PC1ID char(15)
		,TCName char(50)
		,TCDOB datetime
		,GestationalAge int
		,TCAge varchar(150)
		,DateCompleted datetime
		,InWindow char(15)
		,TCAgeCode int
		,ASQTCReceiving bit
	)
	insert into @cteMain
	select
		  LTRIM(RTRIM(supervisor.firstname))+' '+LTRIM(RTRIM(supervisor.lastname))
		 ,LTRIM(RTRIM(fsw.firstname))+' '+LTRIM(RTRIM(fsw.lastname))
		 ,d.PC1ID
		 ,LTRIM(RTRIM(c.TCFirstName))+' '+LTRIM(RTRIM(c.TCLastName))
		 ,convert(varchar(12),c.TCDOB,101)
		 ,c.GestationalAge
		 ,ltrim(rtrim(replace(b.[AppCodeText],'(optional)','')))
		 ,convert(varchar(12),a.ASQSEDateCompleted,101) 
		 ,case when a.ASQSEInWindow is null then 'Unknown'
			  when a.ASQSEInWindow = 1 then 'In Window' else 'Out of Window' end 
		 ,a.ASQSETCAge
		 ,ISNULL(a.ASQSEReceiving,0) 
		from dbo.ASQSE a
			inner join codeApp b on a.ASQSETCAge = b.AppCode and b.AppCodeGroup = 'TCAge' and b.AppCodeUsedWhere like '%AQ%'
			inner join TCID c on c.TCIDPK = a.TCIDFK
			inner join CaseProgram d on d.HVCaseFK = a.HVCaseFK
			inner join dbo.SplitString(@programfk,',') on d.programfk = listitem
			inner join dbo.udfCaseFilters(@CaseFiltersPositive, '', @ProgramFK) cf on cf.HVCaseFK = a.HVCaseFK
			inner join worker fsw ON d.CurrentFSWFK = fsw.workerpk
			inner join workerprogram wp on wp.workerfk = fsw.workerpk  AND wp.programfk = listitem
			inner join worker supervisor on wp.supervisorfk = supervisor.workerpk
		

		where
			 d.DischargeDate is null
			 and d.currentFSWFK = ISNULL(@workerfk,d.currentFSWFK)
			 and wp.supervisorfk = ISNULL(@supervisorfk,wp.supervisorfk)
			 and d.PC1ID = case when @pc1ID = '' then d.PC1ID else @pc1ID end
			 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)


    declare @cteNone table (
		supervisor char(50)
		,worker char(50)
		,PC1ID char(15)
		,TCName char(50)
		,TCDOB datetime
		,GestationalAge int
		,TCAge varchar(150)
		,DateCompleted datetime
		,InWindow char(15)
		,TCAgeCode int
		,ASQTCReceiving bit
	)
	insert into @cteNone
	select LTRIM(RTRIM(supervisor.firstname))+' '+LTRIM(RTRIM(supervisor.lastname))
		 ,LTRIM(RTRIM(fsw.firstname))+' '+LTRIM(RTRIM(fsw.lastname))
		 ,d.PC1ID
		 ,LTRIM(RTRIM(c.TCFirstName))+' '+LTRIM(RTRIM(c.TCLastName))
		 ,CASE WHEN c.TCDOB IS NOT NULL THEN convert(varchar(12),c.TCDOB,101) ELSE convert(varchar(12),h.EDC,101) END
		 ,c.GestationalAge
		 ,'[None]'
		 ,''
		 ,''
		 ,''
		 ,0
		from 
			CaseProgram d 
			INNER JOIN HVCase AS h ON h.HVCasePK = d.HVCaseFK
			inner join dbo.SplitString(@programfk,',') on d.programfk = listitem
			inner join dbo.udfCaseFilters(@CaseFiltersPositive, '', @ProgramFK) cf on cf.HVCaseFK = h.HVCasePK
			inner join worker fsw ON d.CurrentFSWFK = fsw.workerpk
			inner join workerprogram wp on wp.workerfk = fsw.workerpk  AND wp.programfk = listitem
			inner join worker supervisor on wp.supervisorfk = supervisor.workerpk
			LEFT OUTER JOIN TCID c on c.HVCaseFK = d.HVCaseFK
			LEFT OUTER JOIN dbo.ASQSE AS a ON d.HVCaseFK = a.HVCaseFK
		where 
		h.CaseProgress > 8 AND
			 d.DischargeDate is null
			 and d.currentFSWFK = ISNULL(@workerfk,d.currentFSWFK)
			 and wp.supervisorfk = ISNULL(@supervisorfk,wp.supervisorfk)
			 and d.PC1ID = case when @pc1ID = '' then d.PC1ID else @pc1ID end
			 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
			 AND a.HVCaseFK IS NULL
			 AND c.TCDOB IS NOT NULL 
			 AND (CASE WHEN @UnderCutoffOnly = 'Y' THEN 1 ELSE 0 END = 0)


insert into @cteAll	
	  SELECT DISTINCT * FROM @cteMain
	  UNION all
	  SELECT * FROM @cteNone 
	
declare @cteAdjAge table (
	 supervisor varchar(100)
	, worker varchar(100)
	, PC1ID char(13)
	, TCName varchar(450)
	, TCDOB varchar(12)
	, GestationalAge int
	, TCAge varchar(150)
	, DateCompleted varchar(12)
	, InWindow varchar(50)
	, [TCAgeCode] char(2)
	, ASQTCReceiving int
	, AdjTCDOB varchar(12)
)
	insert into @cteAdjAge
	SELECT * 
         ,CASE WHEN (CASE WHEN dateadd(year, datediff (year, a.TCDOB, getdate()), a.TCDOB) > getdate()
            THEN datediff(year, a.TCDOB, getdate()) - 1
            ELSE datediff(year, a.TCDOB, getdate())
          END) < 2 AND a.GestationalAge <= 40 
          THEN convert(DATETIME, a.TCDOB, 101) + (40 - a.GestationalAge) * 7
          ELSE convert(DATETIME, a.TCDOB, 101) END AdjTCDOB
	FROM @cteAll AS a

declare @cteFinal table (
	supervisor varchar(100)
	, worker varchar(100)
	, PC1ID char(13)
	, TCName varchar(450)
	, TCDOB varchar(12)
	, GestationalAge int
	, TCAge varchar(150)
	, DateCompleted varchar(12)
	, InWindow varchar(50)
	, [TCAgeCode] char(2)
	, ASQTCReceiving int
	, AdjTCDOB varchar(12)
	, Age int
	, AgeMonth int
	,AgeAtDateCompleted int
	,AgeAtDateCompletedMonth int
)
insert into @cteFinal
	SELECT *
	,CASE WHEN dateadd(year, datediff (year, AdjTCDOB, getdate()), AdjTCDOB) > getdate()
            THEN datediff(year, AdjTCDOB, getdate()) - 1
            ELSE datediff(year, AdjTCDOB, getdate())
          END
	
	,datediff(month, AdjTCDOB, getdate())
	
	, CASE WHEN DateCompleted <> '' 
	THEN CASE WHEN dateadd(year, datediff (year, AdjTCDOB, DateCompleted), AdjTCDOB) > DateCompleted
            THEN datediff(year, AdjTCDOB, DateCompleted) - 1
            ELSE datediff(year, AdjTCDOB, DateCompleted)
          END
	ELSE -1 END
	
	, CASE WHEN DateCompleted <> '' 
	THEN 
	
		CASE 
			WHEN DATEPART(DAY, AdjTCDOB) > DATEPART(DAY, DateCompleted)
			THEN datediff (month, AdjTCDOB, DateCompleted) - 1
			ELSE datediff (month, AdjTCDOB, DateCompleted)
		END

	--datediff (month, AdjTCDOB, DateCompleted)	
	ELSE -1 END
		
	FROM @cteAdjAge
	
	declare @cteXXX table (
		PC1ID char(15)
		,nASQ int
	)
	insert into @cteXXX
	SELECT PC1ID, sum(CASE WHEN AgeAtDateCompleted = -1 THEN 0 
	WHEN (Age - AgeAtDateCompleted) <= 1 THEN 1 ELSE 0 END) AS nASQ
	FROM @cteFinal
	GROUP BY PC1ID

    declare @cteYYY table (
		supervisor varchar(100)
	, worker varchar(100)
	, PC1ID char(13)
	, TCName varchar(450)
	, TCDOB varchar(12)
	, GestationalAge int
	, TCAge varchar(150)
	, DateCompleted varchar(12)
	, InWindow varchar(50)
	, [TCAgeCode] char(2)
	, ASQTCReceiving int
	, AdjTCDOB varchar(12)
	, Age int
	, AgeMonth int
	,AgeAtDateCompleted int
	,AgeAtDateCompletedMonth int
	,nASQ int
	,Meets char(3)
)
insert into @cteYYY
SELECT a.*, b.nASQ
, CASE WHEN a.Age = 1 THEN (CASE WHEN b.nASQ >= 2 THEN 'Yes' ELSE 'No' END)
       WHEN a.Age = 2 THEN (CASE WHEN b.nASQ >= 2 THEN 'Yes' ELSE 'No' END)
       ELSE (CASE WHEN b.nASQ >= 1 THEN 'Yes' ELSE 'No' END)
  END AS Meets
FROM @cteFinal AS a JOIN @cteXXX AS b ON a.PC1ID = b.PC1ID

declare @cteASQTCReceiving table (
	PC1ID char(15)
	,EI int
)
insert into @cteASQTCReceiving
SELECT d.PC1ID, SUM(CASE WHEN  a.ASQSEReceiving = 1 then 1 ELSE 0 END) AS EI
FROM dbo.ASQSE AS a
inner join CaseProgram d on d.HVCaseFK = a.HVCaseFK
inner join dbo.SplitString(@programfk,',') on d.programfk = listitem
GROUP BY d.PC1ID

-- Meets,
SELECT 
supervisor, worker, a.PC1ID, TCName, TCDOB, GestationalAge, TCAge, 
DateCompleted, InWindow, [TCAgeCode], AdjTCDOB, Age, AgeMonth,
CASE WHEN AgeAtDateCompleted = -1 THEN 0 ELSE AgeAtDateCompleted END AgeAtDateCompleted, 
nASQ, AgeAtDateCompletedMonth, b.EI, CASE WHEN b.EI > 0 THEN 'EI' ELSE
a.Meets END AS Meets, CASE WHEN a.[ASQTCReceiving] = 1 THEN 'Yes' ELSE 'No' END AS TCReceivingEI
FROM @cteYYY AS a JOIN @cteASQTCReceiving AS b ON a.PC1ID = b.PC1ID
WHERE Age > 0 AND Age <= 5
order by Age DESC, worker, PC1ID, TCAgeCode
GO
