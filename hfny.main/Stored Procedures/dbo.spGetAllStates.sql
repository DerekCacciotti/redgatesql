SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spGetAllStates] @ProgramFK int AS

SELECT s.StatePK, s.Name  FROM State s INNER JOIN HVProgram hp ON hp.StateFK = s.StatePK 
WHERE hp.HVProgramPK = 1
GO
