
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 08/14/2012
-- Description:	Get worker first event dates for workers INCLUDING TERMINATED
		--Hire Date / First Kempe / First Home Visit / Termination / First Supervisor / First ASQ
-- Edit Date: 10/18/2013 as per John, we want there most recent program, so don't bring in programs where the worker transferred from
--		(example: "where k.ProgramFK = @prgfk" (this code ALSO eliminates duplicate rows if the worker transferred)
-- =============================================
CREATE FUNCTION [dbo].[fnGetWorkerEventDatesALL]
(	
	-- Add the parameters for the function here
	@prgfk AS INT = Null,
	@supervisorfk AS INT = Null,
	@workerfk AS INT = Null
)
RETURNS TABLE 
AS
RETURN 
(

		WITH ctKempe AS
		(SELECT DISTINCT fawfk, min(kempedate) AS KempeDate
		FROM Kempe k 
		where k.ProgramFK = @prgfk
		GROUP BY fawfk, programfk
		--Having ProgramFK=@prgfk
		)

		, ctASQ AS
		(SELECT DISTINCT FSWFK, min(DateCompleted) AS DateCompleted
		FROM asq a
		WHERE a.programfk = @prgfk
		GROUP BY FSWFK, programfk
		--Having ProgramFK=@prgfk
		)

		, ctHVLog AS
		(SELECT DISTINCT FSWFK, min(VisitStartTime) AS VisitStartTime
		FROM hvlog
		WHERE hvlog.programfk = @prgfk
		GROUP BY FSWFK, programfk
		--Having ProgramFK=@prgfk
		)
		
		,ctSuper AS
		(SELECT DISTINCT SupervisorFK, min(SupervisionDate) AS SuperDate 
		FROM Supervision s
		GROUP BY SupervisorFK
		)

		,ctPSI AS
		(SELECT DISTINCT FSWFK, min(PSIDateComplete) AS PSIDate 
		FROM PSI 
		GROUP BY FSWFK
		)

		SELECT DISTINCT w.WorkerPK
			 , w.LastName AS 'WrkrLName'
			 , w.FirstName AS 'WrkrFName'
			 , wp.FAWStartDate AS FAWInitialStart --12/12/2013 No longer using IntitialStart date
			 , wp.SupervisorStartDate as SupervisorInitialStart --12/12/2013 No longer using IntitialStart date
			 , wp.FSWStartDate as FSWInitialStart --12/12/2013 No longer using IntitialStart date
			 , wp.TerminationDate
			 , wp.HireDate
			 , CASE WHEN datediff(dd, w.SupervisorFirstEvent, ctSuper.SuperDate) < 0 THEN 
				ctSuper.SuperDate
				ELSE w.SupervisorFirstEvent
				END AS 'SupervisorFirstEvent'
			 , min(ctASQ.DateCompleted) AS 'FirstASQDate'
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
		FROM Worker w
		INNER JOIN workerprogram wp ON wp.WorkerFK= w.workerpk
		INNER JOIN worker supervisor on supervisorfk = supervisor.workerpk
		LEFT OUTER JOIN ctASQ ON ctASQ.FSWFK = w.WorkerPK
		LEFT OUTER JOIN ctHVLog ON ctHVLog.FSWFK = w.WorkerPK
		LEFT OUTER JOIN ctKempe ctk ON ctk.FAWFK = w.workerpk
		LEFT OUTER JOIN ctSuper ON ctsuper.SupervisorFK=w.WorkerPK
		LEFT OUTER JOIN ctPSI ON ctpsi.fswfk = w.WorkerPK
		GROUP BY wp.programfk, w.WorkerPK, w.LastName, w.firstname
		,wp.supervisorfk
		,wp.SupervisorStartDate, wp.TerminationDate, wp.HireDate, ctASQ.DateCompleted, w.SupervisorFirstEvent, ctSuper.SuperDate
		, ctHVLog.VisitStartTime, ctk.KempeDate, wp.FAWStartDate, wp.FSWStartDate
		HAVING (wp.ProgramFK=@prgfk)
		and wp.supervisorfk = isnull(@supervisorfk,wp.supervisorfk)
		AND w.LastName NOT LIKE '%Transfer%'
)
GO
