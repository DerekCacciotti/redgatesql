SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 03/09/2018
-- Description:	Key dates for Pilot Projects testing One Step Intake (e.g. putting in fake kempe date, then updating Kempe date after Intake)
--              This report is NOT for the programs, but evaluators.  Specifically requested by Corinne Noble and Susan Dietzel
-- =============================================
CREATE procedure [dbo].[rspPilotDates] -- Add the parameters for the stored procedure here
    @ProgramFK	varchar(max)    = null,
    @StartDt	datetime,
    @EndDt		DATETIME
    
as

	if @ProgramFK is null
	begin
		select @ProgramFK = substring((select ',' + ltrim(rtrim(str(HVProgramPK)))
										   from HVProgram
										   for xml path ('')), 2, 8000)
	end
	set @ProgramFK = replace(@ProgramFK, '"', '')

	DECLARE @cohortTable AS TABLE (
		PC1ID varchar(14)
		, EXV int
		, Worker varchar(50)
		, [Screen Date A] DATE
		, [Welcome Phone Call B] DATE
		 ,[Welcome Family Visit Date C] DATE
		 , [Real Kempe Date D] DATE
		 , [Screen to Phone (B - A)] INT
		 , [Welcome Phone to Family Visit (C - B)] INT
		 , [Screen to Family Visit (C - A)] INT
		 , [Welcome Visit to Real Kempe Date (D - C)] INT
		 , [Screen To Real Kempe (D - A)] INT
		 , DischargeDate DATE
	)
	


	INSERT INTO @cohortTable ( PC1ID ,
	                        EXV ,
	                        Worker ,
	                        [Screen Date A] ,
	                        [Welcome Phone Call B] ,
	                        [Welcome Family Visit Date C] ,
	                        [Real Kempe Date D] ,
	                        [Screen to Phone (B - A)] ,
	                        [Welcome Phone to Family Visit (C - B)] ,
	                        [Screen to Family Visit (C - A)] ,
	                        [Welcome Visit to Real Kempe Date (D - C)] ,
	                        [Screen To Real Kempe (D - A)] ,
	                        DischargeDate )
	
	SELECT DISTINCT e.PC1ID
		 , SUM(CASE WHEN CHARINDEX('EXV', cn.CaseNoteContents, 1)>0 THEN 1 ELSE 0 END) AS EXV
		 , rtrim(fsw.LastName) + ', ' + rtrim(fsw.FirstName) [Worker]
		 , b.ScreenDate AS [Screen Date A]
		 , c.FSWAssignDate AS [Welcome Phone Call B]
		 , a.IntakeDate AS [Welcome Family Visit Date C]
		 , a.KempeDate2 AS [Real Kempe Date D]
		 , datediff(day, b.ScreenDate, c.FSWAssignDate) [Screen to Phone (B - A)]
		 , datediff(day, c.FSWAssignDate, a.IntakeDate) [Welcome Phone to Family Visit (C - B)]
		 , datediff(day,  b.ScreenDate, a.IntakeDate) [Screen to Family Visit (C - A)]
		 , datediff(day,  a.IntakeDate, a.KempeDate2) [Welcome Visit to Real Kempe Date (D - C)]
		 , datediff(day,   b.ScreenDate,a.KempeDate2) [Screen To Real Kempe (D - A)]
		 , e.DischargeDate
		from HVCase as a
			left join HVScreen as b on a.HVCasePK = b.HVCaseFK
			left join Preassessment as c on c.HVCaseFK = a.HVCasePK and c.CaseStatus = '02'
			left join Kempe as d on d.HVCaseFK = a.HVCasePK
			INNER JOIN dbo.CaseProgram as e on e.HVCaseFK = a.HVCasePK
			INNER JOIN dbo.SplitString(@programfk, ',') on e.programfk = listitem
			INNER JOIN dbo.Worker as fsw on fsw.WorkerPK = c.PAFSWFK
			inner join WorkerProgram wp on wp.WorkerFK = fsw.WorkerPK
			LEFT JOIN casenote cn ON cn.HVCaseFK = a.HVCasePK

		where
			a.IntakeDate between @StartDt and @EndDt
		GROUP BY e.PC1ID, fsw.LastName,fsw.FirstName, b.ScreenDate, c.FSWAssignDate, a.IntakeDate, a.KempeDate2, e.DischargeDate
		order by e.PC1ID


		INSERT INTO @cohortTable ( PC1ID,
		                        [Screen to Phone (B - A)] 
		                        , [Welcome Phone to Family Visit (C - B)] ,
		                        [Screen to Family Visit (C - A)] ,
		                        [Welcome Visit to Real Kempe Date (D - C)] ,
		                        [Screen To Real Kempe (D - A)] 
								)
		SELECT 'Averages'
		, SUM([Screen to Phone (B - A)]) / COUNT([Screen to Phone (B - A)])
		, SUM([Welcome Phone to Family Visit (C - B)]) / COUNT([Welcome Phone to Family Visit (C - B)])
		, SUM([Screen to Family Visit (C - A)] ) / COUNT([Screen to Family Visit (C - A)] )
		, SUM([Welcome Visit to Real Kempe Date (D - C)] ) / COUNT([Welcome Visit to Real Kempe Date (D - C)] )
		, SUM([Screen To Real Kempe (D - A)] ) / COUNT([Screen To Real Kempe (D - A)] )
		FROM @cohortTable

		SELECT * FROM @cohortTable
GO
