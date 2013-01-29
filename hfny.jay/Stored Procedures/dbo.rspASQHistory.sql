
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[rspASQHistory]
(
    @programfk       VARCHAR(MAX)   = null,
    @supervisorfk    int            = null,
    @workerfk        int            = null,
    @UnderCutoffOnly char(1)        = 'N',
    @pc1ID           varchar(13)    = '',
    @sitefk          int            = null
)
AS

  if @programfk is null
	begin
		select @programfk = substring((select ','+ltrim(rtrim(str(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end
	set @programfk = replace(@programfk,'"','')
	
--White space for testing Dar's SQL SVN repository
	declare @n int = 0
	select @n = case when @UnderCutoffOnly = 'Y' then 1 else 0 end

	select
		  LTRIM(RTRIM(supervisor.firstname))+' '+LTRIM(RTRIM(supervisor.lastname)) supervisor
		 ,LTRIM(RTRIM(fsw.firstname))+' '+LTRIM(RTRIM(fsw.lastname)) worker
		 ,d.PC1ID
		 ,LTRIM(RTRIM(c.TCFirstName))+' '+LTRIM(RTRIM(c.TCLastName)) TCName
		 ,convert(varchar(12),c.TCDOB,101) TCDOB
		 ,c.GestationalAge
		 ,ltrim(rtrim(replace(b.[AppCodeText],'(optional)',''))) TCAge
		 ,convert(varchar(12),a.DateCompleted,101) DateCompleted
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
			  when TCReferred = 1 then 'Yes' else 'No' end TCReferred
		 ,case when ASQTCReceiving = '1' then 'Yes' else 'No' end ReviewCDS
		 ,case when ASQInWindow is null then 'Unknown'
			  when ASQInWindow = 1 then 'In Window' else 'Out of Window' end InWindow
		 ,a.TCAge [TCAgeCode]

		from ASQ a
			inner join codeApp b on a.TCAge = b.AppCode and b.AppCodeGroup = 'TCAge' and b.AppCodeUsedWhere like '%AQ%'
			inner join TCID c on c.TCIDPK = a.TCIDFK
			inner join CaseProgram d on d.HVCaseFK = a.HVCaseFK
			inner join dbo.SplitString(@programfk,',') on d.programfk = listitem
			inner join worker fsw on d.CurrentFSWFK = fsw.workerpk
			inner join workerprogram wp on wp.workerfk = fsw.workerpk
			inner join worker supervisor on wp.supervisorfk = supervisor.workerpk
			inner join
					  (select TCIDFK
							 ,SUM(
							  case when UnderCommunication = 1 then 1 else 0 end+
							  case when UnderFineMotor = 1 then 1 else 0 end+
							  case when UnderGrossMotor = 1 then 1 else 0 end+
							  case when UnderPersonalSocial = 1 then 1 else 0 end+
							  case when UnderProblemSolving = 1 then 1 else 0 end
							  ) flag
						   from ASQ
						   group by TCIDFK
						   having SUM(
								 case when UnderCommunication = 1 then 1 else 0 end+
								 case when UnderFineMotor = 1 then 1 else 0 end+
								 case when UnderGrossMotor = 1 then 1 else 0 end+
								 case when UnderPersonalSocial = 1 then 1 else 0 end+
								 case when UnderProblemSolving = 1 then 1 else 0 end
								 ) >= @n) x
					  on x.TCIDFK = a.TCIDFK

		where
			 d.DischargeDate is null
			 and d.currentFSWFK = ISNULL(@workerfk,d.currentFSWFK)
			 and wp.supervisorfk = ISNULL(@supervisorfk,wp.supervisorfk)
			 --and d.programfk = @programfk
			 and d.PC1ID = case when @pc1ID = '' then d.PC1ID else @pc1ID end
			 and SiteFK = isnull(@sitefk,SiteFK)
		order by supervisor
				,worker
				,PC1ID
				,TCAgeCode
GO
