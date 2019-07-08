SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Chris Papas
-- Create date: 08/14/2012
-- Description:	Get worker first event dates for workers NOT TERMINATED
		--Hire Date / First Kempe / First Home Visit / Termination / First Supervisor / First ASQ
-- Edit Date: 10/18/2013 as per John, we want there most recent program, so don't bring in programs where the worker transferred from
--		(example: "where k.ProgramFK = @prgfk" (this code ALSO eliminates duplicate rows if the worker transferred)
-- =============================================
CREATE FUNCTION [dbo].[fnGetWorkerEventDates]
(	
	-- Add the parameters for the function here
	@prgfk AS INT = Null,
	@supervisorfk AS INT = Null,
	@workerfk AS INT = Null
)
RETURNS @WorkerDates TABLE (WorkerPK INT
	, WrkrLName varchar(35)
	, WrkrFName  varchar(35)
	, FAWInitialStart DATE --12/12/2013 No longer using IntitialStart date
	, SupervisorInitialStart DATE --12/12/2013 No longer using IntitialStart date
	, FSWInitialStart DATE --12/12/2013 No longer using IntitialStart date
	, TerminationDate DATE
	, HireDate DATE
	, SupervisorFirstEvent DATE
	, FirstASQDate DATE
	, FirstASQSEDate DATE
	, FirstHomeVisitDate DATE
	, FirstKempeDate DATE
	, FirstEvent DATE
	, FirstPSIDate DATE
	, FirstPHQDate DATE
	, FirstHITSDate DATE
	, FirstAuditCDate DATE
	, FirstCHEERSDate DATE
)
AS
BEGIN 
	DECLARE @ctkempe AS TABLE (WorkerFK INT, KempeDate DATE)
	INSERT INTO @ctkempe ( WorkerFK ,
	                       KempeDate )
		(SELECT DISTINCT fawfk, min(kempedate) AS KempeDate
		FROM Kempe k 
		where k.ProgramFK = @prgfk
		GROUP BY fawfk, programfk
		)

	DECLARE @ctASQ AS TABLE (WorkerFK INT, DateCompleted DATE)
	INSERT INTO @ctASQ ( WorkerFK ,
	                     DateCompleted )
		(SELECT DISTINCT FSWFK, min(DateCompleted)
		FROM asq a
		where a.ProgramFK = @prgfk
		GROUP BY FSWFK, programfk
		)


	DECLARE @ctASQSE AS TABLE (WorkerFK INT, ASQSEDateCompleted DATE)
	INSERT INTO @ctASQSE ( WorkerFK ,
	                     ASQSEDateCompleted )
		(SELECT DISTINCT FSWFK, min(a.ASQSEDateCompleted)
		FROM asqse a
		where a.ProgramFK = @prgfk
		AND a.ASQSEDateCompleted >= '02/01/2019' --this purpose of the ASQ SE is for rspTrainingASQSECore training which did NOT go into effect until this date. 
		--As per conversation with CNoble, only pull workers completing an ASQ SE after the date this training went into effect
		GROUP BY FSWFK, programfk
		)

	DECLARE @ctHVLog AS TABLE (FSWFK INT, VisitStartTime DATE)
	INSERT INTO @ctHVLog ( FSWFK ,
	                       VisitStartTime )
		(SELECT DISTINCT FSWFK, min(VisitStartTime)
		FROM hvlog
		where HVLog.ProgramFK = @prgfk
		GROUP BY FSWFK, programfk
		)
	
	DECLARE @ctSuper AS TABLE (SupervisorFK INT, SuperDate DATE)
	INSERT INTO @ctSuper ( SupervisorFK ,
	                       SuperDate )
		(SELECT DISTINCT SupervisorFK, min(SupervisionDate) AS SuperDate 
		FROM Supervision 
		GROUP BY SupervisorFK
		)

	DECLARE @ctPSI AS TABLE (FSWFK INT, PSIDate DATE)
	INSERT INTO @ctPSI ( FSWFK ,
	                     PSIDate )
		(SELECT DISTINCT FSWFK, min(PSIDateComplete) AS PSIDate 
		FROM PSI 
		GROUP BY FSWFK
		)
	
	DECLARE @ctPHQ AS TABLE (FSWFK INT, PHQDate DATE)	
	INSERT INTO @ctPHQ ( FSWFK ,
	                     PHQDate )
		(SELECT DISTINCT workerfk, min(DateAdministered) 
		FROM dbo.vPHQ9
		GROUP BY workerfk
		)

	DECLARE @ctHITSDate AS TABLE (FSWFK INT, HITSDate DATE)
	INSERT INTO @ctHITSDate ( FSWFK ,
	                          HITSDate )
		(SELECT DISTINCT kempe.FAWFK AS FSWFK, MIN(kempe.KempeDate)  AS HITSDate 
			FROM [dbo].[HITS]
			INNER JOIN dbo.Kempe ON hits.formfk=KempePK AND hits.FormType='KE'
			GROUP BY FAWFK
		  )

	DECLARE @ctAuditC AS TABLE (FSWFK INT, AudtCDate DATE)
	INSERT INTO @ctAuditC ( FSWFK ,
	                        AudtCDate )
		(SELECT DISTINCT kempe.FAWFK, MIN(kempe.KempeDate) 
			FROM [dbo].[AuditC]
			INNER JOIN dbo.Kempe ON [AuditC].formfk=KempePK AND [AuditC].FormType='KE'
			GROUP BY FAWFK
		  )

	DECLARE @ctCHeers AS TABLE (FSWFK INT, ObservationDate DATE)
	INSERT INTO @ctCHeers ( FSWFK ,
	                        ObservationDate )
		(SELECT DISTINCT FSWFK, MIN(ObservationDate) AS ObservationDate
		FROM CheersCheckIn cci
		WHERE cci.ProgramFK = @prgfk
		GROUP BY FSWFK, ProgramFK
		)

		INSERT INTO @WorkerDates ( WorkerPK ,
		                           WrkrLName ,
		                           WrkrFName ,
		                           FAWInitialStart ,
		                           SupervisorInitialStart ,
		                           FSWInitialStart ,
		                           TerminationDate ,
		                           HireDate ,
		                           SupervisorFirstEvent ,
		                           FirstASQDate ,
		                           FirstASQSEDate ,
		                           FirstHomeVisitDate ,
		                           FirstKempeDate ,
		                           FirstEvent ,
		                           FirstPSIDate ,
		                           FirstPHQDate ,
		                           FirstHITSDate ,
		                           FirstAuditCDate ,
		                           FirstCHEERSDate )
		(SELECT DISTINCT w.WorkerPK
			 , w.LastName AS 'WrkrLName'
			 , w.FirstName AS 'WrkrFName'
			 , wp.FAWStartDate as FAWInitialStart --12/12/2013 No longer using IntitialStart date
			 , wp.SupervisorStartDate as SupervisorInitialStart --12/12/2013 No longer using IntitialStart date
			 , wp.FSWStartDate as FSWInitialStart --12/12/2013 No longer using IntitialStart date
			 , wp.TerminationDate
			 , wp.HireDate
			 , CASE WHEN datediff(dd, w.SupervisorFirstEvent, ctSuper.SuperDate) < 0 THEN 
				ctSuper.SuperDate
				ELSE w.SupervisorFirstEvent
				END AS 'SupervisorFirstEvent'
			 , min(ctASQ.DateCompleted)
			 , MIN(ctASQSE.ASQSEDateCompleted) 
			 , min(ctHVLog.VisitStartTime) AS 'FirstHomeVisitDate'
			 , min(ctk.KempeDate) AS 'FirstKempeDate'
			 , CASE WHEN isnull(ctASQ.DateCompleted,'12/31/2099') <= isnull(ctHVLog.VisitStartTime,'12/31/2099') THEN
					CASE WHEN isnull(ctASQ.DateCompleted,'12/31/2099') <= isnull(ctk.KempeDate,'12/31/2099') THEN ctASQ.DateCompleted
					ELSE ctk.KempeDate END
				WHEN isnull(ctASQ.DateCompleted,'12/31/2099') > isnull(ctHVLog.VisitStartTime,'12/31/2099') THEN
					CASE WHEN isnull(ctHVLog.VisitStartTime,'12/31/2099') <= isnull(ctk.KempeDate,'12/31/2099') THEN ctHVLog.VisitStartTime
					ELSE ctk.KempeDate END		
				END AS 'FirstEvent'
			, MIN(ctPSI.PSIDate) AS 'FirstPSIDate'
			, MIN(ctphq.PHQDate) AS 'FirstPHQDate'
			, MIN(ctHITSDate.HITSDate) AS 'FirstHITSDate'
			, MIN(ctAuditC.AudtCDate) AS 'FirstAuditCDate'
			, MIN(ctCheers.ObservationDate) AS 'FirstCHEERSDate'
		FROM Worker w
		INNER JOIN workerprogram wp ON wp.WorkerFK= w.workerpk
		INNER JOIN worker supervisor on supervisorfk = supervisor.workerpk
		LEFT OUTER JOIN @ctASQ ctASQ ON ctASQ.WorkerFK = w.WorkerPK
		LEFT OUTER JOIN @ctASQSE ctASQSE ON	 ctASQSE.WorkerFK = w.WorkerPK
		LEFT OUTER JOIN @cthvlog ctHVLog ON ctHVLog.FSWFK = w.WorkerPK
		LEFT OUTER JOIN @ctKempe ctk ON ctk.WorkerFK = w.workerpk
		LEFT OUTER JOIN @ctSuper ctSuper ON ctsuper.SupervisorFK=w.WorkerPK
		LEFT OUTER JOIN @ctPSI ctPSI ON ctpsi.fswfk = w.WorkerPK
		LEFT OUTER JOIN @ctPHQ ctPHQ ON ctPHQ.FSWFK = w.WorkerPK
		LEFT OUTER JOIN @ctHITSDate ctHITSDate ON ctHITSDate.FSWFK = w.WorkerPK
		LEFT OUTER JOIN @ctAuditC ctAuditC ON ctAuditC.FSWFK = w.WorkerPK
		LEFT OUTER JOIN @ctCheers ctCheers ON ctCheers.FSWFK = w.WorkerPK
		GROUP BY wp.programfk, w.WorkerPK, w.LastName, w.FirstName
		,wp.supervisorfk
		, wp.SupervisorStartDate, wp.TerminationDate, wp.HireDate, ctASQ.DateCompleted, w.SupervisorFirstEvent, ctSuper.SuperDate
		, ctHVLog.VisitStartTime, ctk.KempeDate, wp.FSWStartDate, wp.FAWStartDate
		HAVING (wp.ProgramFK=@prgfk)
		and wp.supervisorfk = isnull(@supervisorfk,wp.supervisorfk)
		and (@workerfk is null or w.WorkerPK = @workerfk) 
		AND wp.TerminationDate IS NULL
		AND w.LastName NOT LIKE '%Transfer%'
		)
	RETURN
END
GO
