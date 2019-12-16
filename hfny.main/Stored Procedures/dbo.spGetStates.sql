SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 11/22/2019
-- Description:	Get all the states
-- =============================================

CREATE PROC [dbo].[spGetStates]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get all the states from the database
    SELECT StatePK,
           Abbreviation,
           Name
    FROM dbo.State s;

END;
GO
