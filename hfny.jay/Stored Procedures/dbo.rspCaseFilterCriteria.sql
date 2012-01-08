SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jay Robohn
-- Create date: Jan. 06, 2011
-- Modified: 
-- Description: <report: CaseFilter Criteria : main use reportviewer page control set up>
-- =============================================
CREATE PROCEDURE [dbo].[rspCaseFilterCriteria] (@programfks varchar(100))

AS
BEGIN
  -- SET NOCOUNT ON added to prevent extra result sets from
  -- interfering with SELECT statements.
  SET NOCOUNT ON;

    -- Insert statements for procedure here
  -- First table, distinct list of FieldTitles
  SELECT DISTINCT cf1.ProgramFK, FieldTitle, CaseFilterNameFK 
  From CaseFilter cf1, listCaseFilterName lcfn
  WHERE listCaseFilterNamePK=CaseFilterNameFK and
    @programfks LIKE('%,' + CAST(cf1.programfk AS VARCHAR(100)) + ',%') 
  --Second table, distinct list of FilterValues
  SELECT DISTINCT UPPER(FilterValue) as filtervalue, cf.ProgramFK, FieldTitle, CaseFilterNameFK 
  from CaseFilter cf,listCaseFilterName lcfn2
  where listCaseFilterNamePK=CaseFilterNameFK and
    @programfks LIKE('%,' + CAST(cf.programfk AS VARCHAR(100)) + ',%')
END
GO
