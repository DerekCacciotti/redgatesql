
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 08/14/2012
-- Description:	Get worker first event dates 
		--Hire Date / First Kempe / First Home Visit / Termination / First Supervisor / First ASQ
-- =============================================
CREATE FUNCTION [dbo].[fnGetWorkerEventDates]
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
		GROUP BY fawfk, programfk
		--Having ProgramFK=@prgfk
		)

		, ctASQ AS
		(SELECT DISTINCT FSWFK, min(DateCompleted) AS DateCompleted
		FROM asq a
		GROUP BY FSWFK, programfk
		--Having ProgramFK=@prgfk
		)

		, ctHVLog AS
		(SELECT DISTINCT FSWFK, min(VisitStartTime) AS VisitStartTime
		FROM hvlog
		GROUP BY FSWFK, programfk
		--Having ProgramFK=@prgfk
		)
		
		,ctSuper AS
		(SELECT DISTINCT SupervisorFK, min(SupervisionDate) AS SuperDate 
		FROM Supervision s
		GROUP BY SupervisorFK
		)


		SELECT DISTINCT w.WorkerPK
			 , w.LastName AS 'WrkrLName'
			 , w.FAWInitialStart --as per Jay, we will use Initial start for FAW date
			 , w.SupervisorInitialStart
			 , w.FSWInitialStart
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
		FROM Worker w
		INNER JOIN workerprogram wp ON wp.WorkerFK= w.workerpk
		INNER JOIN worker supervisor on supervisorfk = supervisor.workerpk
		LEFT OUTER JOIN ctASQ ON ctASQ.FSWFK = w.WorkerPK
		LEFT OUTER JOIN ctHVLog ON ctHVLog.FSWFK = w.WorkerPK
		LEFT OUTER JOIN ctKempe ctk ON ctk.FAWFK = w.workerpk
		LEFT OUTER JOIN ctSuper ON ctsuper.SupervisorFK=w.WorkerPK
		GROUP BY wp.programfk, w.WorkerPK, w.LastName
		,wp.supervisorfk
		,w.SupervisorInitialStart, wp.TerminationDate, wp.HireDate, ctASQ.DateCompleted, w.SupervisorFirstEvent, ctSuper.SuperDate
		, ctHVLog.VisitStartTime, ctk.KempeDate, wp.FAWStartDate, w.FAWInitialStart, w.FSWInitialStart
		HAVING (wp.ProgramFK=@prgfk)
		and wp.supervisorfk = isnull(@supervisorfk,wp.supervisorfk)
		AND wp.TerminationDate IS NULL
		AND w.LastName NOT LIKE '%Transfer%'
)
GO
