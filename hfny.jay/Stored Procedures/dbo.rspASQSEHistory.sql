SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[rspASQSEHistory]
(
    @programfk       VARCHAR(MAX)   = null,
    @supervisorfk    int            = null,
    @workerfk        int            = null,
    @UnderCutoffOnly char(1)        = 'N',
    @pc1ID           varchar(13)    = '',
    @sitefk          int            = null
)
AS

--DECLARE @programfk       VARCHAR(MAX)   = '1'
--DECLARE @supervisorfk    int            = null
--DECLARE @workerfk        int            = null
--DECLARE @UnderCutoffOnly char(1)        = 'Y'
--DECLARE @pc1ID           varchar(13)    = ''
--DECLARE @sitefk          int            = null

  if @programfk is null
	begin
		select @programfk = substring((select ','+ltrim(rtrim(str(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end
	set @programfk = replace(@programfk,'"','')
	set @SiteFK = isnull(@SiteFK, 0)
	
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
		 ,convert(varchar(12),a.ASQSEDateCompleted,101) DateCompleted
		 ,a.ASQSETotalScore
		 ,case when ASQSEOverCutOff = 1 then '*' else '' end ASQSEOverCutOff
		 ,case when ASQSEReferred is null then 'Unknown'
			  when ASQSEReferred = 1 then 'Yes' else 'No' end TCReferred
		 ,case when ASQSEReceiving = '1' then 'Yes' else 'No' end ReviewCDS
		 ,case when ASQSEInWindow is null then 'Unknown'
			  when ASQSEInWindow = 1 then 'In Window' else 'Out of Window' end InWindow
		 ,a.ASQSETCAge [TCAgeCode]
		from ASQSE a
			inner join codeApp b on a.ASQSETCAge = b.AppCode and b.AppCodeGroup = 'TCAge' 
			and b.AppCodeUsedWhere like '%AS%'
			inner join TCID c on c.TCIDPK = a.TCIDFK
			inner join CaseProgram d on d.HVCaseFK = a.HVCaseFK
			inner join dbo.SplitString(@programfk,',') on d.programfk = listitem
			inner join worker fsw on d.CurrentFSWFK = fsw.workerpk
			inner join workerprogram wp on wp.workerfk = fsw.workerpk
			inner join worker supervisor on wp.supervisorfk = supervisor.workerpk
		where
			 d.DischargeDate is NULL
			 AND (@n = 0 OR ASQSEOverCutOff= 1)
			 and d.currentFSWFK = ISNULL(@workerfk,d.currentFSWFK)
			 and wp.supervisorfk = ISNULL(@supervisorfk,wp.supervisorfk)
			 and d.PC1ID = case when @pc1ID = '' then d.PC1ID else @pc1ID end
			 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
		order by supervisor
				,worker
				,PC1ID
				,TCAgeCode
GO
