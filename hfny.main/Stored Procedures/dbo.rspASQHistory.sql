SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- rspASQHistory 1

CREATE procedure [dbo].[rspASQHistory]
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

	declare @TCUnder table (
		TCIDFK int
		,flag int
	)
	insert into @TCUnder
	select TCIDFK
		,SUM(
		 case when UnderCommunication = 1 then 1 else 0 end+
		 case when UnderFineMotor = 1 then 1 else 0 end+
		 case when UnderGrossMotor = 1 then 1 else 0 end+
		 case when UnderPersonalSocial = 1 then 1 else 0 end+
		 case when UnderProblemSolving = 1 then 1 else 0 end
		 )
		from ASQ
		group by TCIDFK
		having SUM(
			 case when UnderCommunication = 1 then 1 else 0 end+
			 case when UnderFineMotor = 1 then 1 else 0 end+
			 case when UnderGrossMotor = 1 then 1 else 0 end+
			 case when UnderPersonalSocial = 1 then 1 else 0 end+
			 case when UnderProblemSolving = 1 then 1 else 0 end
			 ) >= @n

	select
		  LTRIM(RTRIM(supervisor.lastname))+', '+LTRIM(RTRIM(supervisor.firstname)) as supervisor
		 ,LTRIM(RTRIM(fsw.lastname))+', '+LTRIM(RTRIM(fsw.firstname)) as worker
		 ,d.PC1ID
		 ,LTRIM(RTRIM(c.TCFirstName))+' '+LTRIM(RTRIM(c.TCLastName)) as TCName
		 ,convert(varchar(12),c.TCDOB,101) as TCDOB
		 ,c.GestationalAge
		 ,ltrim(rtrim(replace(b.[AppCodeText],'(optional)',''))) as TCAge
		 ,convert(varchar(12),a.DateCompleted,101) as DateCompleted
		 ,a.ASQCommunicationScore
		 ,case when UnderCommunication = 1 then '*' else '' end as UnderCommunication
		 ,ASQGrossMotorScore
		 ,case when UnderGrossMotor = 1 then '*' else '' end as UnderGrossMotor
		 ,ASQFineMotorScore
		 ,case when UnderFineMotor = 1 then '*' else '' end as UnderFineMotor
		 ,ASQProblemSolvingScore
		 ,case when UnderProblemSolving = 1 then '*' else '' end as UnderProblemSolving
		 ,ASQPersonalSocialScore
		 ,case when UnderPersonalSocial = 1 then '*' else '' end as UnderPersonalSocial
		 ,case when TCReferred is null then 'Unknown'
			  when TCReferred = 1 then 'Yes' else 'No' end as TCReferred
		 ,case when ASQTCReceiving = '1' then 'Yes' else 'No' end as ASQTCReceiving
		 ,case when ASQInWindow is null then 'Unknown'
			  when ASQInWindow = 1 then 'In' else 'Out' end as ASQInWindow
		 ,case when DiscussedWithPC1 is null then 'Blank'
			  when DiscussedWithPC1 = 1 then 'Yes' else 'No' end as DiscussedWithPC1
		 --,a.TCAge 

		from ASQ a
			inner join codeApp b on a.TCAge = b.AppCode and b.AppCodeGroup = 'TCAge' and b.AppCodeUsedWhere like '%AQ%'
			inner join TCID c on c.TCIDPK = a.TCIDFK
			inner join CaseProgram d on d.HVCaseFK = a.HVCaseFK
			inner join dbo.SplitString(@programfk,',') on d.programfk = listitem
			inner join dbo.udfCaseFilters(@CaseFiltersPositive, '', @ProgramFK) cf on cf.HVCaseFK = a.HVCaseFK
			inner join worker fsw ON d.CurrentFSWFK = fsw.workerpk
			inner join workerprogram wp on wp.workerfk = fsw.workerpk  AND wp.programfk = listitem
			inner join worker supervisor on wp.supervisorfk = supervisor.workerpk
			inner join @TCUnder x on x.TCIDFK = a.TCIDFK
					  
		where
			 d.DischargeDate is null
			 and d.currentFSWFK = ISNULL(@workerfk,d.currentFSWFK)
			 and wp.supervisorfk = ISNULL(@supervisorfk,wp.supervisorfk)
			 --and d.programfk = @programfk
			 and d.PC1ID = case when @pc1ID = '' then d.PC1ID else @pc1ID end
			 --and SiteFK = isnull(@sitefk,SiteFK)
			 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)

UNION all

	select
		  LTRIM(RTRIM(supervisor.lastname))+', '+LTRIM(RTRIM(supervisor.firstname)) as supervisor
		 ,LTRIM(RTRIM(fsw.lastname))+', '+LTRIM(RTRIM(fsw.firstname)) as worker
		 ,d.PC1ID
		 ,LTRIM(RTRIM(c.TCFirstName))+' '+LTRIM(RTRIM(c.TCLastName)) as TCName
		 ,CASE WHEN c.TCDOB IS NOT NULL THEN convert(varchar(12),c.TCDOB,101) ELSE convert(varchar(12),h.EDC,101) END as TCDOB
		 ,c.GestationalAge
		 ,ltrim(rtrim(replace(b.AppCodeText,'(optional)',''))) as TCAge
		 ,convert(varchar(12),a.DateCompleted,101) as DateCompleted
		 ,a.ASQCommunicationScore
		 ,case when UnderCommunication = 1 then '*' else '' end UnderCommunication
		 ,ASQGrossMotorScore
		 ,case when UnderGrossMotor = 1 then '*' else '' end UnderGrossMotor
		 ,ASQFineMotorScore
		 ,case when UnderFineMotor = 1 then '*' else '' end UnderFineMotor
		 ,ASQProblemSolvingScore
		 ,case when UnderProblemSolving = 1 then '*' else '' end UnderProblemSolving
		 ,ASQPersonalSocialScore
		 ,case when UnderPersonalSocial = 1 then '*' else '' end UnderPersonalSocial
		 ,case when TCReferred is null then 'Unknown'
			  when TCReferred = 1 then 'Yes' else 'No' end as TCReferred
		 ,case when ASQTCReceiving = '1' then 'Yes' else 'No' end as ASQTCReceiving
		 ,case when ASQInWindow is null then 'Unknown'
			  when ASQInWindow = 1 then 'In' else 'Out' end as ASQInWindow
		 ,case when DiscussedWithPC1 is null then 'Blank'
			  when DiscussedWithPC1 = 1 then 'Yes' else 'No' end as DiscussedWithPC1
		 --,a.TCReferred
		 --,a.DiscussedWithPC1
		 --,a.ReviewCDS
		 --,a.ASQInWindow
		 --,TCAge

		from --ASQ a
			--inner join codeApp b on a.TCAge = b.AppCode and b.AppCodeGroup = 'TCAge' and b.AppCodeUsedWhere like '%AQ%'
			--inner join TCID c on c.TCIDPK = a.TCIDFK
			CaseProgram d 
			inner join HVCase AS h ON h.HVCasePK = d.HVCaseFK
			inner join dbo.SplitString(@programfk,',') on d.programfk = listitem
			inner join dbo.udfCaseFilters(@CaseFiltersPositive, '', @ProgramFK) cf on cf.HVCaseFK = h.HVCasePK
			inner join worker fsw ON d.CurrentFSWFK = fsw.workerpk
			inner join workerprogram wp on wp.workerfk = fsw.workerpk  AND wp.programfk = listitem
			inner join worker supervisor on wp.supervisorfk = supervisor.workerpk
			left outer join TCID c on c.HVCaseFK = d.HVCaseFK
			left outer join ASQ AS a ON d.HVCaseFK = a.HVCaseFK
			inner join codeApp b on a.TCAge = b.AppCode and b.AppCodeGroup = 'TCAge' and b.AppCodeUsedWhere like '%AQ%'
			
		where 
		h.CaseProgress > 8 AND
			 d.DischargeDate is null
			 and d.currentFSWFK = ISNULL(@workerfk,d.currentFSWFK)
			 and wp.supervisorfk = ISNULL(@supervisorfk,wp.supervisorfk)
			 --and d.programfk = @programfk
			 and d.PC1ID = case when @pc1ID = '' then d.PC1ID else @pc1ID end
			 --and SiteFK = isnull(@sitefk,SiteFK)
			 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
			 AND a.HVCaseFK IS NULL
			 AND c.TCDOB IS NOT NULL 
			 AND (CASE WHEN @UnderCutoffOnly = 'Y' THEN 1 ELSE 0 END = 0)

	--order by fsw.LastName, fsw.FirstName, d.PC1ID, a.DateCompleted	
	
GO
