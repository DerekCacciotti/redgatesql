SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dar Chen>
-- Create date: <04/04/2016>
-- Description:	<This Credentialing report gets you 'Summary for 1-2.A Acceptance Rates and 1-2.B Refusal Rates Analysis'>
-- rspCredentialingKempeAnalysis_Summary 2, '01/01/2011', '12/31/2011'
-- rspCredentialingKempeAnalysis_Summary 1, '04/01/2012', '03/31/2013'
-- =============================================

CREATE PROCEDURE [dbo].[rspCredentialingKempeAnalysis_Summary] (@programfk VARCHAR(MAX) = NULL,
@StartDate DATETIME,
@EndDate DATETIME)
--WITH RECOMPILE
AS

    DECLARE @programfkX VARCHAR(MAX)
    DECLARE @StartDateX DATETIME = @StartDate
    DECLARE @EndDateX DATETIME = @EndDate


    IF @programfk IS NULL
    BEGIN
        SELECT
            @programfk = SUBSTRING((SELECT
                    ',' + LTRIM(RTRIM(STR(HVProgramPK)))
                FROM HVProgram
                FOR XML PATH (''))
            , 2, 8000)
    END

    SET @programfk = REPLACE(@programfk, '"', '')
    SET @programfkX = @programfk
    SET @StartDateX = @StartDate
    SET @EndDateX = @EndDate

    ;
    WITH main
    AS
    (SELECT
            HVCasePK
           ,CASE
                WHEN h.tcdob IS NOT NULL THEN h.tcdob
                ELSE h.EDC
            END AS tcdob
           ,DischargeDate
           ,IntakeDate
           ,k.KempeDate
           ,PC1FK
           ,cp.DischargeReason
           ,OldID
           ,PC1ID
           ,KempeResult
           ,cp.CurrentFSWFK
           ,cp.CurrentFAWFK
           ,CASE
                WHEN h.tcdob IS NOT NULL THEN h.tcdob
                ELSE h.EDC
            END AS babydate
           ,CASE
                WHEN h.IntakeDate IS NOT NULL THEN h.IntakeDate
                ELSE cp.DischargeDate
            END AS testdate
           ,P.PCDOB
           ,P.Race
           ,ca.MaritalStatus
           ,ca.HighestGrade
           ,ca.IsCurrentlyEmployed
           ,ca.OBPInHome
           ,CASE
                WHEN MomScore = 'U' THEN 0
                ELSE CAST(MomScore AS INT)
            END AS MomScore
           ,CASE
                WHEN DadScore = 'U' THEN 0
                ELSE CAST(DadScore AS INT)
            END AS DadScore
           ,FOBPresent
           ,MOBPresent
           ,OtherPresent
           ,MOBPartnerPresent --as MOBPartner 
           ,FOBPartnerPresent --as FOBPartner
           ,GrandParentPresent --as MOBGrandmother
           ,PIVisitMade
           ,y.DV
           ,y.MH
           ,y.SA
           ,y.DD

           ,CASE
                WHEN (ISNULL(k.MOBPartnerPresent, 0) = 0 AND
                    ISNULL(k.FOBPartnerPresent, 0) = 0 AND
                    ISNULL(k.GrandParentPresent, 0) = 0 AND
                    ISNULL(k.OtherPresent, 0) = 0) THEN CASE
                        WHEN k.MOBPresent = 1 AND
                            k.FOBPresent = 1 THEN 3 -- both parent
                        WHEN k.MOBPresent = 1 THEN 1 -- MOB Only
                        WHEN k.FOBPresent = 1 THEN 2 -- FOB Only
                        ELSE 4  -- parent/other
                    END
                ELSE 4 -- parent/other
            END presentCode

        FROM HVCase h
        INNER JOIN CaseProgram cp
            ON cp.HVCaseFK = h.HVCasePK
        INNER JOIN dbo.SplitString(@programfkX, ',')
            ON cp.ProgramFK = ListItem
        INNER JOIN Kempe k
            ON k.HVCaseFK = h.HVCasePK
        INNER JOIN PC P
            ON P.PCPK = h.PC1FK
        LEFT OUTER JOIN (SELECT
                KempeFK
               ,SUM(CASE
                    WHEN PIVisitMade > 0 THEN 1
                    ELSE 0
                END) PIVisitMade
            FROM Preintake
            WHERE ProgramFK = @programfkX
            GROUP BY KempeFK) AS x
            ON x.KempeFK = k.KempePK
        LEFT OUTER JOIN (SELECT
                a.HVCaseFK
               ,CASE
                    WHEN DomesticViolence = '1' THEN 1
                    ELSE 0
                END AS DV
               ,CASE
                    WHEN (Depression = '1' OR
                        MentalIllness = '1') THEN 1
                    ELSE 0
                END AS MH
               ,CASE
                    WHEN (AlcoholAbuse = '1' OR
                        SubstanceAbuse = '1') THEN 1
                    ELSE 0
                END AS SA
               ,CASE
                    WHEN DevelopmentalDisability = '1' THEN 1
                    ELSE 0
                END AS DD
            FROM PC1Issues AS a
            JOIN (SELECT
                    MIN(PC1IssuesPK) AS PC1IssuesPK
                   ,HVCaseFK
                FROM PC1Issues
                WHERE ProgramFK = @programfkX
                AND RTRIM(Interval) = '1'
                GROUP BY HVCaseFK) AS b
                ON a.PC1IssuesPK = b.PC1IssuesPK) AS y
            ON h.HVCasePK = y.HVCaseFK
        LEFT JOIN CommonAttributes ca
            ON ca.HVCaseFK = h.HVCasePK
            AND ca.FormType = 'KE'
        WHERE (h.IntakeDate IS NOT NULL
        OR cp.DischargeDate IS NOT NULL) -- only include kempes that are positive and where there is a clos_date or an intake date.
        AND k.KempeResult = 1
        AND k.KempeDate BETWEEN @StartDateX AND @EndDateX),
    main1
    AS
    (SELECT
            CASE
                WHEN IntakeDate IS NOT NULL THEN '1' --'AcceptedFirstVisitEnrolled' 
                WHEN KempeResult = 1 AND
                    IntakeDate IS NULL AND
                    DischargeDate IS NOT NULL AND
                    (PIVisitMade > 0 AND
                    PIVisitMade IS NOT NULL) THEN '2' -- 'AcceptedFirstVisitNotEnrolled'
                ELSE '3' -- 'Refused' 
            END Status

           ,a.IntakeDate AS [IntakeDate2]
           ,a.KempeResult AS [KempeResult2]
           ,a.PIVisitMade AS [PIVisitMade2]
           ,a.DischargeDate AS [DischargeDate2]
           ,a.DischargeReason AS [DischargeReason2]

           ,DATEDIFF(DAY, PCDOB, testdate) / 365.25 AS age
           ,CASE
                WHEN a.MomScore > a.DadScore THEN a.MomScore
                ELSE a.DadScore
            END KempeScore
           ,CASE
                WHEN DATEDIFF(d, testdate, babydate) > 0 AND
                    DATEDIFF(d, testdate, babydate) < 30.44 * 3 THEN 3
                WHEN (DATEDIFF(d, testdate, babydate) >= 30.44 * 3 AND
                    DATEDIFF(d, testdate, babydate) < 30.44 * 6) THEN 2
                WHEN DATEDIFF(d, testdate, babydate) >= ROUND(30.44 * 6, 0) THEN 1
                WHEN DATEDIFF(d, testdate, babydate) <= 0 THEN 4
            END AS Trimester
           ,*

        FROM main AS a),
    total1
    AS
    (SELECT
            COUNT(*) AS total
           ,SUM(CASE
                WHEN a.Status = '1' THEN 1
                ELSE 0
            END) AS totalG1
           ,SUM(CASE
                WHEN a.Status = '2' THEN 1
                ELSE 0
            END) AS totalG2
           ,SUM(CASE
                WHEN a.Status = '3' THEN 1
                ELSE 0
            END) AS totalG3
        FROM main1 AS a),
    total2
    AS
    (SELECT
            'Totals (N = ' + CONVERT(VARCHAR, total) + ')' AS [title]
           ,CONVERT(VARCHAR, totalG1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(totalG1 AS FLOAT) * 100 / NULLIF(total, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, totalG2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(totalG2 AS FLOAT) * 100 / NULLIF(total, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, totalG3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(totalG3 AS FLOAT) * 100 / NULLIF(total, 0), 0), 0)) + '%)' AS col3
           ,'1' AS col4
        FROM total1),
    total3
    AS
    (SELECT
            'Acceptance Rate - ' +
            CONVERT(VARCHAR, ROUND(COALESCE(CAST((totalG1 + totalG2) AS FLOAT) * 100 / NULLIF(total, 0), 0), 0)) + '%' AS [title]
           ,'' AS col1
           ,'' AS col2
           ,'' AS col3
           ,'1' AS col4
        FROM total1

        UNION ALL
        SELECT
            '' AS [title]
           ,'' AS col1
           ,'' AS col2
           ,'' AS col3
           ,'1' AS col4),
    age1
    AS
    (SELECT
            SUM(CASE
                WHEN a.Status = '1' THEN 1
                ELSE 0
            END) AS totalG1
           ,SUM(CASE
                WHEN a.Status = '2' THEN 1
                ELSE 0
            END) AS totalG2
           ,SUM(CASE
                WHEN a.Status = '3' THEN 1
                ELSE 0
            END) AS totalG3

           ,SUM(CASE
                WHEN age < 18 THEN 1
                ELSE 0
            END) AS age18
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    age < 18 THEN 1
                ELSE 0
            END) AS age18G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    age < 18 THEN 1
                ELSE 0
            END) AS age18G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    age < 18 THEN 1
                ELSE 0
            END) AS age18G3

           ,SUM(CASE
                WHEN (age >= 18 AND
                    age < 20) THEN 1
                ELSE 0
            END) AS age20
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    (age >= 18 AND
                    age < 20) THEN 1
                ELSE 0
            END) AS age20G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    (age >= 18 AND
                    age < 20) THEN 1
                ELSE 0
            END) AS age20G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    (age >= 18 AND
                    age < 20) THEN 1
                ELSE 0
            END) AS age20G3

           ,SUM(CASE
                WHEN (age >= 20 AND
                    age < 30) THEN 1
                ELSE 0
            END) AS age30
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    (age >= 20 AND
                    age < 30) THEN 1
                ELSE 0
            END) AS age30G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    (age >= 20 AND
                    age < 30) THEN 1
                ELSE 0
            END) AS age30G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    (age >= 20 AND
                    age < 30) THEN 1
                ELSE 0
            END) AS age30G3

           ,SUM(CASE
                WHEN (age >= 30) THEN 1
                ELSE 0
            END) AS age40
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    (age >= 30) THEN 1
                ELSE 0
            END) AS age40G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    (age >= 30) THEN 1
                ELSE 0
            END) AS age40G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    (age >= 30) THEN 1
                ELSE 0
            END) AS age40G3

        FROM main1 AS a),
    age2
    AS
    (SELECT
            'Age' AS [title]
           ,'' AS col1
           ,'' AS col2
           ,'' AS col3
           ,'1' AS col4
        UNION ALL

        SELECT
            '  Under 18' AS [title]
           ,CONVERT(VARCHAR, age18G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(age18G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, age18G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(age18G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, age18G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(age18G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'1' AS col4
        FROM age1

        UNION ALL
        SELECT
            '  18 up to 20' AS [title]
           ,CONVERT(VARCHAR, age20G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(age20G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, age20G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(age20G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, age20G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(age20G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'1' AS col4
        FROM age1

        UNION ALL
        SELECT
            '  20 up to 30' AS [title]
           ,CONVERT(VARCHAR, age30G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(age30G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, age30G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(age30G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, age30G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(age30G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'1' AS col4
        FROM age1

        UNION ALL
        SELECT
            '  30 and over' AS [title]
           ,CONVERT(VARCHAR, age40G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(age40G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, age40G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(age40G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, age40G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(age40G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'1' AS col4
        FROM age1

        UNION ALL
        SELECT
            '' AS [title]
           ,'' AS col1
           ,'' AS col2
           ,'' AS col3
           ,'1' AS col4),
    race1
    AS
    (SELECT
            SUM(CASE
                WHEN a.Status = '1' THEN 1
                ELSE 0
            END) AS totalG1
           ,SUM(CASE
                WHEN a.Status = '2' THEN 1
                ELSE 0
            END) AS totalG2
           ,SUM(CASE
                WHEN a.Status = '3' THEN 1
                ELSE 0
            END) AS totalG3

           ,SUM(CASE
                WHEN Race = '01' THEN 1
                ELSE 0
            END) AS race01
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    Race = '01' THEN 1
                ELSE 0
            END) AS race01G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    Race = '01' THEN 1
                ELSE 0
            END) AS race01G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    Race = '01' THEN 1
                ELSE 0
            END) AS race01G3

           ,SUM(CASE
                WHEN Race = '02' THEN 1
                ELSE 0
            END) AS race02
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    Race = '02' THEN 1
                ELSE 0
            END) AS race02G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    Race = '02' THEN 1
                ELSE 0
            END) AS race02G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    Race = '02' THEN 1
                ELSE 0
            END) AS race02G3

           ,SUM(CASE
                WHEN Race = '03' THEN 1
                ELSE 0
            END) AS race03
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    Race = '03' THEN 1
                ELSE 0
            END) AS race03G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    Race = '03' THEN 1
                ELSE 0
            END) AS race03G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    Race = '03' THEN 1
                ELSE 0
            END) AS race03G3

           ,SUM(CASE
                WHEN Race = '04' THEN 1
                ELSE 0
            END) AS race04
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    Race = '04' THEN 1
                ELSE 0
            END) AS race04G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    Race = '04' THEN 1
                ELSE 0
            END) AS race04G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    Race = '04' THEN 1
                ELSE 0
            END) AS race04G3

           ,SUM(CASE
                WHEN Race = '05' THEN 1
                ELSE 0
            END) AS race05
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    Race = '05' THEN 1
                ELSE 0
            END) AS race05G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    Race = '05' THEN 1
                ELSE 0
            END) AS race05G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    Race = '05' THEN 1
                ELSE 0
            END) AS race05G3

           ,SUM(CASE
                WHEN Race = '06' THEN 1
                ELSE 0
            END) AS race06
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    Race = '06' THEN 1
                ELSE 0
            END) AS race06G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    Race = '06' THEN 1
                ELSE 0
            END) AS race06G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    Race = '06' THEN 1
                ELSE 0
            END) AS race06G3

           ,SUM(CASE
                WHEN Race = '07' THEN 1
                ELSE 0
            END) AS race07
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    Race = '07' THEN 1
                ELSE 0
            END) AS race07G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    Race = '07' THEN 1
                ELSE 0
            END) AS race07G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    Race = '07' THEN 1
                ELSE 0
            END) AS race07G3

           ,SUM(CASE
                WHEN (Race IS NULL OR
                    Race = '') THEN 1
                ELSE 0
            END) AS race08
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    (Race IS NULL OR
                    Race = '') THEN 1
                ELSE 0
            END) AS race08G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    (Race IS NULL OR
                    Race = '') THEN 1
                ELSE 0
            END) AS race08G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    (Race IS NULL OR
                    Race = '') THEN 1
                ELSE 0
            END) AS race08G3

        FROM main1 AS a),
    race2
    AS
    (SELECT
            'Race' AS [title]
           ,'' AS col1
           ,'' AS col2
           ,'' AS col3
           ,'1' AS col4
        UNION ALL
        SELECT
            '  White, non-Hispanic' AS [title]
           ,CONVERT(VARCHAR, race01G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(race01G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, race01G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(race01G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, race01G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(race01G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'1' AS col4
        FROM race1

        UNION ALL
        SELECT
            '  Black, non-Hispanic' AS [title]
           ,CONVERT(VARCHAR, race02G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(race02G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, race02G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(race02G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, race02G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(race02G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'1' AS col4
        FROM race1

        UNION ALL
        SELECT
            '  Hispanic/Latina/Latino' AS [title]
           ,CONVERT(VARCHAR, race03G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(race03G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, race03G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(race03G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, race03G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(race03G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'1' AS col4
        FROM race1

        UNION ALL
        SELECT
            '  Asian' AS [title]
           ,CONVERT(VARCHAR, race04G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(race04G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, race04G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(race04G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, race04G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(race04G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'1' AS col4
        FROM race1

        UNION ALL
        SELECT
            '  Native American' AS [title]
           ,CONVERT(VARCHAR, race05G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(race05G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, race05G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(race05G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, race05G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(race05G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'1' AS col4
        FROM race1

        UNION ALL
        SELECT
            '  Multiracial' AS [title]
           ,CONVERT(VARCHAR, race06G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(race06G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, race06G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(race06G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, race06G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(race06G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'1' AS col4
        FROM race1

        UNION ALL
        SELECT
            '  Other' AS [title]
           ,CONVERT(VARCHAR, race07G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(race07G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, race07G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(race07G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, race07G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(race07G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'1' AS col4
        FROM race1

        UNION ALL
        SELECT
            '  Missing' AS [title]
           ,CONVERT(VARCHAR, race08G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(race08G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, race08G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(race08G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, race08G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(race08G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'1' AS col4
        FROM race1

        UNION ALL
        SELECT
            '' AS [title]
           ,'' AS col1
           ,'' AS col2
           ,'' AS col3
           ,'1' AS col4),
    martial1
    AS
    (SELECT
            SUM(CASE
                WHEN a.Status = '1' THEN 1
                ELSE 0
            END) AS totalG1
           ,SUM(CASE
                WHEN a.Status = '2' THEN 1
                ELSE 0
            END) AS totalG2
           ,SUM(CASE
                WHEN a.Status = '3' THEN 1
                ELSE 0
            END) AS totalG3

           ,SUM(CASE
                WHEN MaritalStatus = '01' THEN 1
                ELSE 0
            END) AS MaritalStatus01
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    MaritalStatus = '01' THEN 1
                ELSE 0
            END) AS MaritalStatus01G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    MaritalStatus = '01' THEN 1
                ELSE 0
            END) AS MaritalStatus01G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    MaritalStatus = '01' THEN 1
                ELSE 0
            END) AS MaritalStatus01G3

           ,SUM(CASE
                WHEN MaritalStatus = '02' THEN 1
                ELSE 0
            END) AS MaritalStatus02
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    MaritalStatus = '02' THEN 1
                ELSE 0
            END) AS MaritalStatus02G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    MaritalStatus = '02' THEN 1
                ELSE 0
            END) AS MaritalStatus02G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    MaritalStatus = '02' THEN 1
                ELSE 0
            END) AS MaritalStatus02G3

           ,SUM(CASE
                WHEN MaritalStatus = '03' THEN 1
                ELSE 0
            END) AS MaritalStatus03
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    MaritalStatus = '03' THEN 1
                ELSE 0
            END) AS MaritalStatus03G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    MaritalStatus = '03' THEN 1
                ELSE 0
            END) AS MaritalStatus03G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    MaritalStatus = '03' THEN 1
                ELSE 0
            END) AS MaritalStatus03G3

           ,SUM(CASE
                WHEN MaritalStatus = '04' THEN 1
                ELSE 0
            END) AS MaritalStatus04
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    MaritalStatus = '04' THEN 1
                ELSE 0
            END) AS MaritalStatus04G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    MaritalStatus = '04' THEN 1
                ELSE 0
            END) AS MaritalStatus04G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    MaritalStatus = '04' THEN 1
                ELSE 0
            END) AS MaritalStatus04G3

           ,SUM(CASE
                WHEN MaritalStatus = '05' THEN 1
                ELSE 0
            END) AS MaritalStatus05
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    MaritalStatus = '05' THEN 1
                ELSE 0
            END) AS MaritalStatus05G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    MaritalStatus = '05' THEN 1
                ELSE 0
            END) AS MaritalStatus05G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    MaritalStatus = '05' THEN 1
                ELSE 0
            END) AS MaritalStatus05G3

           ,SUM(CASE
                WHEN (MaritalStatus IS NULL OR
                    MaritalStatus NOT IN ('01', '02', '03', '04', '05')) THEN 1
                ELSE 0
            END) AS MaritalStatus06
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    (MaritalStatus IS NULL OR
                    MaritalStatus NOT IN ('01', '02', '03', '04', '05')) THEN 1
                ELSE 0
            END) AS MaritalStatus06G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    (MaritalStatus IS NULL OR
                    MaritalStatus NOT IN ('01', '02', '03', '04', '05')) THEN 1
                ELSE 0
            END) AS MaritalStatus06G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    (MaritalStatus IS NULL OR
                    MaritalStatus NOT IN ('01', '02', '03', '04', '05')) THEN 1
                ELSE 0
            END) AS MaritalStatus06G3

        FROM main1 AS a),
    martial2
    AS
    (SELECT
            'Martial Status' AS [title]
           ,'' AS col1
           ,'' AS col2
           ,'' AS col3
           ,'1' AS col4

        UNION ALL
        SELECT
            '  Married' AS [title]
           ,CONVERT(VARCHAR, MaritalStatus01G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(MaritalStatus01G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, MaritalStatus01G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(MaritalStatus01G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, MaritalStatus01G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(MaritalStatus01G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'1' AS col4
        FROM martial1

        UNION ALL
        SELECT
            '  Not Married' AS [title]
           ,CONVERT(VARCHAR, MaritalStatus02G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(MaritalStatus02G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, MaritalStatus02G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(MaritalStatus02G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, MaritalStatus02G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(MaritalStatus02G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'1' AS col4
        FROM martial1

        UNION ALL
        SELECT
            '  Separated' AS [title]
           ,CONVERT(VARCHAR, MaritalStatus03G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(MaritalStatus03G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, MaritalStatus03G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(MaritalStatus03G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, MaritalStatus03G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(MaritalStatus03G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'1' AS col4
        FROM martial1

        UNION ALL
        SELECT
            '  Divorced' AS [title]
           ,CONVERT(VARCHAR, MaritalStatus04G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(MaritalStatus04G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, MaritalStatus04G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(MaritalStatus04G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, MaritalStatus04G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(MaritalStatus04G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'1' AS col4
        FROM martial1

        UNION ALL
        SELECT
            '  Widowed' AS [title]
           ,CONVERT(VARCHAR, MaritalStatus05G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(MaritalStatus05G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, MaritalStatus05G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(MaritalStatus05G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, MaritalStatus05G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(MaritalStatus05G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'1' AS col4
        FROM martial1

        UNION ALL
        SELECT
            '  Unknown' AS [title]
           ,CONVERT(VARCHAR, MaritalStatus06G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(MaritalStatus06G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, MaritalStatus06G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(MaritalStatus06G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, MaritalStatus06G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(MaritalStatus06G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'1' AS col4
        FROM martial1

        UNION ALL
        SELECT
            '' AS [title]
           ,'' AS col1
           ,'' AS col2
           ,'' AS col3
           ,'1' AS col4),
    edu1
    AS
    (SELECT
            SUM(CASE
                WHEN a.Status = '1' THEN 1
                ELSE 0
            END) AS totalG1
           ,SUM(CASE
                WHEN a.Status = '2' THEN 1
                ELSE 0
            END) AS totalG2
           ,SUM(CASE
                WHEN a.Status = '3' THEN 1
                ELSE 0
            END) AS totalG3

           ,SUM(CASE
                WHEN HighestGrade IN ('01', '02') THEN 1
                ELSE 0
            END) AS HighestGrade01
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    HighestGrade IN ('01', '02') THEN 1
                ELSE 0
            END) AS HighestGrade01G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    HighestGrade IN ('01', '02') THEN 1
                ELSE 0
            END) AS HighestGrade01G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    HighestGrade IN ('01', '02') THEN 1
                ELSE 0
            END) AS HighestGrade01G3

           ,SUM(CASE
                WHEN HighestGrade IN ('03', '04') THEN 1
                ELSE 0
            END) AS HighestGrade02
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    HighestGrade IN ('03', '04') THEN 1
                ELSE 0
            END) AS HighestGrade02G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    HighestGrade IN ('03', '04') THEN 1
                ELSE 0
            END) AS HighestGrade02G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    HighestGrade IN ('03', '04') THEN 1
                ELSE 0
            END) AS HighestGrade02G3

           ,SUM(CASE
                WHEN HighestGrade IN ('05', '06', '07', '08') THEN 1
                ELSE 0
            END) AS HighestGrade03
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    HighestGrade IN ('05', '06', '07', '08') THEN 1
                ELSE 0
            END) AS HighestGrade03G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    HighestGrade IN ('05', '06', '07', '08') THEN 1
                ELSE 0
            END) AS HighestGrade03G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    HighestGrade IN ('05', '06', '07', '08') THEN 1
                ELSE 0
            END) AS HighestGrade03G3

           ,SUM(CASE
                WHEN HighestGrade IS NULL THEN 1
                ELSE 0
            END) AS HighestGrade04
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    HighestGrade IS NULL THEN 1
                ELSE 0
            END) AS HighestGrade04G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    HighestGrade IS NULL THEN 1
                ELSE 0
            END) AS HighestGrade04G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    HighestGrade IS NULL THEN 1
                ELSE 0
            END) AS HighestGrade04G3

        FROM main1 AS a),
    edu2
    AS
    (SELECT
            'Education' AS [title]
           ,'' AS col1
           ,'' AS col2
           ,'' AS col3
           ,'2' AS col4

        UNION ALL
        SELECT
            '  Less than 12' AS [title]
           ,CONVERT(VARCHAR, HighestGrade01G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(HighestGrade01G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, HighestGrade01G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(HighestGrade01G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, HighestGrade01G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(HighestGrade01G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'2' AS col4
        FROM edu1

        UNION ALL
        SELECT
            '  HS/GED' AS [title]
           ,CONVERT(VARCHAR, HighestGrade02G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(HighestGrade02G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, HighestGrade02G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(HighestGrade02G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, HighestGrade02G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(HighestGrade02G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'2' AS col4
        FROM edu1

        UNION ALL
        SELECT
            '  More than 12' AS [title]
           ,CONVERT(VARCHAR, HighestGrade03G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(HighestGrade03G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, HighestGrade03G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(HighestGrade03G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, HighestGrade03G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(HighestGrade03G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'2' AS col4
        FROM edu1

        UNION ALL
        SELECT
            '  Unknown' AS [title]
           ,CONVERT(VARCHAR, HighestGrade04G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(HighestGrade04G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, HighestGrade04G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(HighestGrade04G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, HighestGrade04G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(HighestGrade04G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'2' AS col4
        FROM edu1

        UNION ALL
        SELECT
            '' AS [title]
           ,'' AS col1
           ,'' AS col2
           ,'' AS col3
           ,'2' AS col4),
    employed1
    AS
    (SELECT
            SUM(CASE
                WHEN a.Status = '1' THEN 1
                ELSE 0
            END) AS totalG1
           ,SUM(CASE
                WHEN a.Status = '2' THEN 1
                ELSE 0
            END) AS totalG2
           ,SUM(CASE
                WHEN a.Status = '3' THEN 1
                ELSE 0
            END) AS totalG3

           ,SUM(CASE
                WHEN IsCurrentlyEmployed = 1 THEN 1
                ELSE 0
            END) AS Employed01
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    IsCurrentlyEmployed = 1 THEN 1
                ELSE 0
            END) AS Employed01G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    IsCurrentlyEmployed = 1 THEN 1
                ELSE 0
            END) AS Employed01G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    IsCurrentlyEmployed = 1 THEN 1
                ELSE 0
            END) AS Employed01G3

           ,SUM(CASE
                WHEN IsCurrentlyEmployed = 0 THEN 1
                ELSE 0
            END) AS Employed02
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    IsCurrentlyEmployed = 0 THEN 1
                ELSE 0
            END) AS Employed02G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    IsCurrentlyEmployed = 0 THEN 1
                ELSE 0
            END) AS Employed02G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    IsCurrentlyEmployed = 0 THEN 1
                ELSE 0
            END) AS Employed02G3

        FROM main1 AS a),
    employed2
    AS
    (SELECT
            'Employed' AS [title]
           ,'' AS col1
           ,'' AS col2
           ,'' AS col3
           ,'2' AS col4

        UNION ALL
        SELECT
            '  Yes' AS [title]
           ,CONVERT(VARCHAR, Employed01G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(Employed01G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, Employed01G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(Employed01G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, Employed01G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(Employed01G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'2' AS col4
        FROM employed1

        UNION ALL
        SELECT
            '  No' AS [title]
           ,CONVERT(VARCHAR, Employed02G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(Employed02G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, Employed02G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(Employed02G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, Employed02G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(Employed02G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'2' AS col4
        FROM employed1

        UNION ALL
        SELECT
            '' AS [title]
           ,'' AS col1
           ,'' AS col2
           ,'' AS col3
           ,'2' AS col4),
    inHome1
    AS
    (SELECT
            SUM(CASE
                WHEN a.Status = '1' THEN 1
                ELSE 0
            END) AS totalG1
           ,SUM(CASE
                WHEN a.Status = '2' THEN 1
                ELSE 0
            END) AS totalG2
           ,SUM(CASE
                WHEN a.Status = '3' THEN 1
                ELSE 0
            END) AS totalG3

           ,SUM(CASE
                WHEN OBPInHome = 1 THEN 1
                ELSE 0
            END) AS InHome01
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    OBPInHome = 1 THEN 1
                ELSE 0
            END) AS InHome01G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    OBPInHome = 1 THEN 1
                ELSE 0
            END) AS InHome01G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    OBPInHome = 1 THEN 1
                ELSE 0
            END) AS InHome01G3

           ,SUM(CASE
                WHEN OBPInHome = 0 THEN 1
                ELSE 0
            END) AS InHome02
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    OBPInHome = 0 THEN 1
                ELSE 0
            END) AS InHome02G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    OBPInHome = 0 THEN 1
                ELSE 0
            END) AS InHome02G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    OBPInHome = 0 THEN 1
                ELSE 0
            END) AS InHome02G3


           ,SUM(CASE
                WHEN OBPInHome IS NULL THEN 1
                ELSE 0
            END) AS InHome03
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    OBPInHome IS NULL THEN 1
                ELSE 0
            END) AS InHome03G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    OBPInHome IS NULL THEN 1
                ELSE 0
            END) AS InHome03G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    OBPInHome IS NULL THEN 1
                ELSE 0
            END) AS InHome03G3
        FROM main1 AS a),
    inHome2
    AS
    (SELECT
            'Bio Father in Home' AS [title]
           ,'' AS col1
           ,'' AS col2
           ,'' AS col3
           ,'2' AS col4
        UNION ALL
        SELECT
            '  Yes' AS [title]
           ,CONVERT(VARCHAR, InHome01G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(InHome01G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, InHome01G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(InHome01G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, InHome01G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(InHome01G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'2' AS col4
        FROM inHome1

        UNION ALL
        SELECT
            '  No' AS [title]
           ,CONVERT(VARCHAR, InHome02G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(InHome02G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, InHome02G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(InHome02G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, InHome02G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(InHome02G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'2' AS col4
        FROM inHome1

        UNION ALL
        SELECT
            '  Unknown' AS [title]
           ,CONVERT(VARCHAR, InHome03G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(InHome03G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, InHome03G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(InHome03G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, InHome03G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(InHome03G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'2' AS col4
        FROM inHome1

        UNION ALL
        SELECT
            '' AS [title]
           ,'' AS col1
           ,'' AS col2
           ,'' AS col3
           ,'2' AS col4),
    score1
    AS
    (SELECT
            SUM(CASE
                WHEN a.Status = '1' THEN 1
                ELSE 0
            END) AS totalG1
           ,SUM(CASE
                WHEN a.Status = '2' THEN 1
                ELSE 0
            END) AS totalG2
           ,SUM(CASE
                WHEN a.Status = '3' THEN 1
                ELSE 0
            END) AS totalG3

           ,SUM(CASE
                WHEN MomScore >= 25 AND
                    DadScore < 25 THEN 1
                ELSE 0
            END) AS Score01
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    MomScore >= 25 AND
                    DadScore < 25 THEN 1
                ELSE 0
            END) AS Score01G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    MomScore >= 25 AND
                    DadScore < 25 THEN 1
                ELSE 0
            END) AS Score01G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    MomScore >= 25 AND
                    DadScore < 25 THEN 1
                ELSE 0
            END) AS Score01G3

           ,SUM(CASE
                WHEN MomScore < 25 AND
                    DadScore >= 25 THEN 1
                ELSE 0
            END) AS Score02
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    MomScore < 25 AND
                    DadScore >= 25 THEN 1
                ELSE 0
            END) AS Score02G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    MomScore < 25 AND
                    DadScore >= 25 THEN 1
                ELSE 0
            END) AS Score02G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    MomScore < 25 AND
                    DadScore >= 25 THEN 1
                ELSE 0
            END) AS Score02G3


           ,SUM(CASE
                WHEN MomScore >= 25 AND
                    DadScore >= 25 THEN 1
                ELSE 0
            END) AS Score03
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    MomScore >= 25 AND
                    DadScore >= 25 THEN 1
                ELSE 0
            END) AS Score03G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    MomScore >= 25 AND
                    DadScore >= 25 THEN 1
                ELSE 0
            END) AS Score03G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    MomScore >= 25 AND
                    DadScore >= 25 THEN 1
                ELSE 0
            END) AS Score03G3
        FROM main1 AS a),
    score2
    AS
    (SELECT
            'Whose Score Qualifies' AS [title]
           ,'' AS col1
           ,'' AS col2
           ,'' AS col3
           ,'2' AS col4
        UNION ALL
        SELECT
            '  Mother' AS [title]
           ,CONVERT(VARCHAR, Score01G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(Score01G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, Score01G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(Score01G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, Score01G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(Score01G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'2' AS col4
        FROM score1

        UNION ALL
        SELECT
            '  Father' AS [title]
           ,CONVERT(VARCHAR, Score02G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(Score02G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, Score02G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(Score02G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, Score02G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(Score02G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'2' AS col4
        FROM score1

        UNION ALL
        SELECT
            '  Mother & Father' AS [title]
           ,CONVERT(VARCHAR, Score03G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(Score03G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, Score03G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(Score03G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, Score03G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(Score03G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'2' AS col4
        FROM score1

        UNION ALL
        SELECT
            '' AS [title]
           ,'' AS col1
           ,'' AS col2
           ,'' AS col3
           ,'2' AS col4),
    kempescore1
    AS
    (SELECT
            SUM(CASE
                WHEN a.Status = '1' THEN 1
                ELSE 0
            END) AS totalG1
           ,SUM(CASE
                WHEN a.Status = '2' THEN 1
                ELSE 0
            END) AS totalG2
           ,SUM(CASE
                WHEN a.Status = '3' THEN 1
                ELSE 0
            END) AS totalG3

           ,SUM(CASE
                WHEN KempeScore BETWEEN 25 AND 49 THEN 1
                ELSE 0
            END) AS KempeScore01
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    KempeScore BETWEEN 25 AND 49 THEN 1
                ELSE 0
            END) AS KempeScore01G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    KempeScore BETWEEN 25 AND 49 THEN 1
                ELSE 0
            END) AS KempeScore01G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    KempeScore BETWEEN 25 AND 49 THEN 1
                ELSE 0
            END) AS KempeScore01G3

           ,SUM(CASE
                WHEN KempeScore BETWEEN 50 AND 74 THEN 1
                ELSE 0
            END) AS KempeScore02
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    KempeScore BETWEEN 50 AND 74 THEN 1
                ELSE 0
            END) AS KempeScore02G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    KempeScore BETWEEN 50 AND 74 THEN 1
                ELSE 0
            END) AS KempeScore02G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    KempeScore BETWEEN 50 AND 74 THEN 1
                ELSE 0
            END) AS KempeScore02G3


           ,SUM(CASE
                WHEN KempeScore >= 75 THEN 1
                ELSE 0
            END) AS KempeScore03
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    KempeScore >= 75 THEN 1
                ELSE 0
            END) AS KempeScore03G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    KempeScore >= 75 THEN 1
                ELSE 0
            END) AS KempeScore03G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    KempeScore >= 75 THEN 1
                ELSE 0
            END) AS KempeScore03G3
        FROM main1 AS a),
    kempescore2
    AS
    (SELECT
            'Kempe Score' AS [title]
           ,'' AS col1
           ,'' AS col2
           ,'' AS col3
           ,'2' AS col4
        UNION ALL
        SELECT
            '  25-49' AS [title]
           ,CONVERT(VARCHAR, KempeScore01G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(KempeScore01G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, KempeScore01G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(KempeScore01G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, KempeScore01G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(KempeScore01G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'2' AS col4
        FROM kempescore1

        UNION ALL
        SELECT
            '  50-74' AS [title]
           ,CONVERT(VARCHAR, KempeScore02G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(KempeScore02G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, KempeScore02G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(KempeScore02G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, KempeScore02G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(KempeScore02G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'2' AS col4
        FROM kempescore1


        UNION ALL
        SELECT
            '  75+' AS [title]
           ,CONVERT(VARCHAR, KempeScore03G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(KempeScore03G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, KempeScore03G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(KempeScore03G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, KempeScore03G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(KempeScore03G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'2' AS col4
        FROM kempescore1

        UNION ALL
        SELECT
            '' AS [title]
           ,'' AS col1
           ,'' AS col2
           ,'' AS col3
           ,'2' AS col4),
    issues1
    AS
    (SELECT
            SUM(CASE
                WHEN a.Status = '1' THEN 1
                ELSE 0
            END) AS totalG1
           ,SUM(CASE
                WHEN a.Status = '2' THEN 1
                ELSE 0
            END) AS totalG2
           ,SUM(CASE
                WHEN a.Status = '3' THEN 1
                ELSE 0
            END) AS totalG3

           ,SUM(CASE
                WHEN DV = 1 THEN 1
                ELSE 0
            END) AS issues01
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    DV = 1 THEN 1
                ELSE 0
            END) AS issues01G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    DV = 1 THEN 1
                ELSE 0
            END) AS issues01G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    DV = 1 THEN 1
                ELSE 0
            END) AS issues01G3

           ,SUM(CASE
                WHEN MH = 1 THEN 1
                ELSE 0
            END) AS issues02
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    MH = 1 THEN 1
                ELSE 0
            END) AS issues02G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    MH = 1 THEN 1
                ELSE 0
            END) AS issues02G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    MH = 1 THEN 1
                ELSE 0
            END) AS issues02G3

           ,SUM(CASE
                WHEN SA = 1 THEN 1
                ELSE 0
            END) AS issues03
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    SA = 1 THEN 1
                ELSE 0
            END) AS issues03G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    SA = 1 THEN 1
                ELSE 0
            END) AS issues03G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    SA = 1 THEN 1
                ELSE 0
            END) AS issues03G3

           ,SUM(CASE
                WHEN DD = 1 THEN 1
                ELSE 0
            END) AS issues04
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    DD = 1 THEN 1
                ELSE 0
            END) AS issues04G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    DD = 1 THEN 1
                ELSE 0
            END) AS issues04G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    DD = 1 THEN 1
                ELSE 0
            END) AS issues04G3
        FROM main1 AS a),
    issues2
    AS
    (SELECT
            'PC1 Issues' AS [title]
           ,'' AS col1
           ,'' AS col2
           ,'' AS col3
           ,'3' AS col4
        UNION ALL
        SELECT
            '  DV' AS [title]
           ,CONVERT(VARCHAR, issues01G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(issues01G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, issues01G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(issues01G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, issues01G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(issues01G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'3' AS col4
        FROM issues1

        UNION ALL
        SELECT
            '  MH' AS [title]
           ,CONVERT(VARCHAR, issues02G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(issues02G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, issues02G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(issues02G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, issues02G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(issues02G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'3' AS col4
        FROM issues1

        UNION ALL
        SELECT
            '  SA' AS [title]
           ,CONVERT(VARCHAR, issues03G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(issues03G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, issues03G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(issues03G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, issues03G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(issues03G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'3' AS col4
        FROM issues1

        UNION ALL
        SELECT
            '  DD' AS [title]
           ,CONVERT(VARCHAR, issues04G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(issues04G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, issues04G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(issues04G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, issues04G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(issues04G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'3' AS col4
        FROM issues1

        UNION ALL
        SELECT
            '' AS [title]
           ,'' AS col1
           ,'' AS col2
           ,'' AS col3
           ,'3' AS col4),
    trimester1
    AS
    (SELECT
            SUM(CASE
                WHEN a.Status = '1' THEN 1
                ELSE 0
            END) AS totalG1
           ,SUM(CASE
                WHEN a.Status = '2' THEN 1
                ELSE 0
            END) AS totalG2
           ,SUM(CASE
                WHEN a.Status = '3' THEN 1
                ELSE 0
            END) AS totalG3

           ,SUM(CASE
                WHEN Trimester = 1 THEN 1
                ELSE 0
            END) AS trimester01
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    Trimester = 1 THEN 1
                ELSE 0
            END) AS trimester01G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    Trimester = 1 THEN 1
                ELSE 0
            END) AS trimester01G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    Trimester = 1 THEN 1
                ELSE 0
            END) AS trimester01G3

           ,SUM(CASE
                WHEN Trimester = 2 THEN 1
                ELSE 0
            END) AS trimester02
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    Trimester = 2 THEN 1
                ELSE 0
            END) AS trimester02G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    Trimester = 2 THEN 1
                ELSE 0
            END) AS trimester02G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    Trimester = 2 THEN 1
                ELSE 0
            END) AS trimester02G3

           ,SUM(CASE
                WHEN Trimester = 3 THEN 1
                ELSE 0
            END) AS trimester03
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    Trimester = 3 THEN 1
                ELSE 0
            END) AS trimester03G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    Trimester = 3 THEN 1
                ELSE 0
            END) AS trimester03G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    Trimester = 3 THEN 1
                ELSE 0
            END) AS trimester03G3

           ,SUM(CASE
                WHEN Trimester = 4 THEN 1
                ELSE 0
            END) AS trimester04
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    Trimester = 4 THEN 1
                ELSE 0
            END) AS trimester04G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    Trimester = 4 THEN 1
                ELSE 0
            END) AS trimester04G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    Trimester = 4 THEN 1
                ELSE 0
            END) AS trimester04G3

        FROM main1 AS a),
    trimester2
    AS
    (SELECT
            'Trimester (at time of Enrollment/Discharge)' AS [title]
           ,'' AS col1
           ,'' AS col2
           ,'' AS col3
           ,'3' AS col4
        UNION ALL
        SELECT
            '  1st' AS [title]
           ,CONVERT(VARCHAR, trimester01G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(trimester01G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, trimester01G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(trimester01G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, trimester01G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(trimester01G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'3' AS col4
        FROM trimester1

        UNION ALL
        SELECT
            '  2nd' AS [title]
           ,CONVERT(VARCHAR, trimester02G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(trimester02G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, trimester02G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(trimester02G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, trimester02G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(trimester02G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'3' AS col4
        FROM trimester1

        UNION ALL
        SELECT
            '  3rd' AS [title]
           ,CONVERT(VARCHAR, trimester03G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(trimester03G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, trimester03G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(trimester03G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, trimester03G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(trimester03G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'3' AS col4
        FROM trimester1

        UNION ALL
        SELECT
            '  Postnatal' AS [title]
           ,CONVERT(VARCHAR, trimester04G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(trimester04G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, trimester04G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(trimester04G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, trimester04G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(trimester04G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'3' AS col4
        FROM trimester1

        UNION ALL
        SELECT
            '' AS [title]
           ,'' AS col1
           ,'' AS col2
           ,'' AS col3
           ,'3' AS col4),
    assessment1
    AS
    (SELECT
            SUM(CASE
                WHEN a.Status = '1' THEN 1
                ELSE 0
            END) AS totalG1
           ,SUM(CASE
                WHEN a.Status = '2' THEN 1
                ELSE 0
            END) AS totalG2
           ,SUM(CASE
                WHEN a.Status = '3' THEN 1
                ELSE 0
            END) AS totalG3

           ,SUM(CASE
                WHEN presentCode = 1 THEN 1
                ELSE 0
            END) AS assessment01
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    presentCode = 1 THEN 1
                ELSE 0
            END) AS assessment01G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    presentCode = 1 THEN 1
                ELSE 0
            END) AS assessment01G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    presentCode = 1 THEN 1
                ELSE 0
            END) AS assessment01G3

           ,SUM(CASE
                WHEN presentCode = 2 THEN 1
                ELSE 0
            END) AS assessment02
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    presentCode = 2 THEN 1
                ELSE 0
            END) AS assessment02G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    presentCode = 2 THEN 1
                ELSE 0
            END) AS assessment02G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    presentCode = 2 THEN 1
                ELSE 0
            END) AS assessment02G3

           ,SUM(CASE
                WHEN presentCode = 3 THEN 1
                ELSE 0
            END) AS assessment03
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    presentCode = 3 THEN 1
                ELSE 0
            END) AS assessment03G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    presentCode = 3 THEN 1
                ELSE 0
            END) AS assessment03G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    presentCode = 3 THEN 1
                ELSE 0
            END) AS assessment03G3

           ,SUM(CASE
                WHEN presentCode = 4 THEN 1
                ELSE 0
            END) AS assessment04
           ,SUM(CASE
                WHEN a.Status = '1' AND
                    presentCode = 4 THEN 1
                ELSE 0
            END) AS assessment04G1
           ,SUM(CASE
                WHEN a.Status = '2' AND
                    presentCode = 4 THEN 1
                ELSE 0
            END) AS assessment04G2
           ,SUM(CASE
                WHEN a.Status = '3' AND
                    presentCode = 4 THEN 1
                ELSE 0
            END) AS assessment04G3

        FROM main1 AS a),
    assessment2
    AS
    (SELECT
            'Present at Assessment' AS [title]
           ,'' AS col1
           ,'' AS col2
           ,'' AS col3
           ,'3' AS col4
        UNION ALL
        SELECT
            '  MOB only' AS [title]
           ,CONVERT(VARCHAR, assessment01G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(assessment01G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, assessment01G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(assessment01G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, assessment01G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(assessment01G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'3' AS col4
        FROM assessment1

        UNION ALL
        SELECT
            '  FOB Only' AS [title]
           ,CONVERT(VARCHAR, assessment02G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(assessment02G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, assessment02G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(assessment02G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, assessment02G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(assessment02G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'3' AS col4
        FROM assessment1

        UNION ALL
        SELECT
            '  Both Parents' AS [title]
           ,CONVERT(VARCHAR, assessment03G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(assessment03G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, assessment03G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(assessment03G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, assessment03G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(assessment03G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'3' AS col4
        FROM assessment1

        UNION ALL
        SELECT
            '  Parent and Other' AS [title]
           ,CONVERT(VARCHAR, assessment04G1) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(assessment04G1 AS FLOAT) * 100 / NULLIF(totalG1, 0), 0), 0)) + '%)' AS col1
           ,CONVERT(VARCHAR, assessment04G2) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(assessment04G2 AS FLOAT) * 100 / NULLIF(totalG2, 0), 0), 0)) + '%)' AS col2
           ,CONVERT(VARCHAR, assessment04G3) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(assessment04G3 AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'3' AS col4
        FROM assessment1

        UNION ALL
        SELECT
            '' AS [title]
           ,'' AS col1
           ,'' AS col2
           ,'' AS col3
           ,'3' AS col4),
    refused1
    AS
    (SELECT
            COUNT(*) AS totalG3
           ,SUM(CASE
                WHEN DischargeReason = '36' THEN 1
                ELSE 0
            END) [Refused]
           ,SUM(CASE
                WHEN DischargeReason = '12' THEN 1
                ELSE 0
            END) [UnableToLocate]
           ,SUM(CASE
                WHEN DischargeReason = '19' THEN 1
                ELSE 0
            END) [TCAgedOut]
           ,SUM(CASE
                WHEN DischargeReason = '07' THEN 1
                ELSE 0
            END) [OutOfTargetArea]
           ,SUM(CASE
                WHEN DischargeReason IN ('25') THEN 1
                ELSE 0
            END) [Transfered]
           ,SUM(CASE
                WHEN DischargeReason NOT IN ('36', '12', '19', '07', '25') THEN 1
                ELSE 0
            END) [AllOthers]
        FROM main1 AS a
        WHERE a.Status = '3'),

    refused2
    AS
    (SELECT
            'Reason for Refused' AS [title]
           ,'' AS col1
           ,'' AS col2
           ,'' AS col3
           ,'3' AS col4
        UNION ALL
        SELECT
            '  Refused' AS [title]
           ,'' AS col1
           ,'' AS col2
           ,CONVERT(VARCHAR, Refused) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(Refused AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'3' AS col4
        FROM refused1

        UNION ALL
        SELECT
            '  Unable To Locate' AS [title]
           ,'' AS col1
           ,'' AS col2
           ,CONVERT(VARCHAR, UnableToLocate) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(UnableToLocate AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'3' AS col4
        FROM refused1

        UNION ALL
        SELECT
            '  TC Aged Out' AS [title]
           ,'' AS col1
           ,'' AS col2
           ,CONVERT(VARCHAR, TCAgedOut) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(TCAgedOut AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'3' AS col4
        FROM refused1

        UNION ALL
        SELECT
            '  Out of Target Area' AS [title]
           ,'' AS col1
           ,'' AS col2
           ,CONVERT(VARCHAR, OutOfTargetArea) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(OutOfTargetArea AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'3' AS col4
        FROM refused1

        UNION ALL
        SELECT
            '  Transfered' AS [title]
           ,'' AS col1
           ,'' AS col2
           ,CONVERT(VARCHAR, Transfered) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(Transfered AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'3' AS col4
        FROM refused1

        UNION ALL
        SELECT
            '  All Others' AS [title]
           ,'' AS col1
           ,'' AS col2
           ,CONVERT(VARCHAR, AllOthers) + ' (' + CONVERT(VARCHAR, ROUND(COALESCE(CAST(AllOthers AS FLOAT) * 100 / NULLIF(totalG3, 0), 0), 0)) + '%)' AS col3
           ,'3' AS col4
        FROM refused1

        UNION ALL
        SELECT
            '' AS [title]
           ,'' AS col1
           ,'' AS col2
           ,'' AS col3
           ,'3' AS col4),

    rpt1
    AS
    (SELECT
            *
        FROM total2
        UNION ALL
        SELECT
            *
        FROM total3
        UNION ALL
        SELECT
            *
        FROM age2
        UNION ALL
        SELECT
            *
        FROM race2
        UNION ALL
        SELECT
            *
        FROM martial2
        UNION ALL
        SELECT
            *
        FROM edu2
        UNION ALL
        SELECT
            *
        FROM employed2
        UNION ALL
        SELECT
            *
        FROM inHome2
        UNION ALL
        SELECT
            *
        FROM score2
        UNION ALL
        SELECT
            *
        FROM kempescore2
        UNION ALL
        SELECT
            *
        FROM issues2
        UNION ALL
        SELECT
            *
        FROM trimester2
        UNION ALL
        SELECT
            *
        FROM assessment2
        UNION ALL
        SELECT
            *
        FROM refused2)

    -- listing records
    --SELECT * 
    --FROM main1 AS a
    --WHERE a.Status = 3

    SELECT
        Title AS [Title]
       ,col1 AS [AcceptedFirstVisitEnrolled]
       ,col2 AS [AcceptedFirstVisitNotEnrolled]
       ,col3 AS [Refused]
       ,col4 AS [groupID]
    FROM rpt1
GO
