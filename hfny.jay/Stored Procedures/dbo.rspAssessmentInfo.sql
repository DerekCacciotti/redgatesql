
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Jay Robohn orig by Dorothy Baum>
-- Create date: <June 3, 2010>
-- Description:	<report: Credentialing 1-1D. Assessment Info>
-- =============================================
CREATE PROCEDURE [dbo].[rspAssessmentInfo] (@StartDate datetime, @EndDate datetime, @programfks varchar(max),
	@posclause varchar(200),@negclause varchar(200))
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    -- Insert statements for procedure here
if @posclause is null and @negclause is null -- don't include filters
	select count(kempepk) as kempettl,
		   sum(case when bday>kempedate then 1 else 0 end) as prenatal,
		   sum(case when bday<=kempedate then 1 else 0 end) as postnatal,
           sum(case when cast(kempedate-bday as int) <=14 and cast(kempedate-bday as int) >= 0 then 1 else 0 end) as within2wks,
		   sum(case when cast(kempedate-bday as int) <=14 then 1 else 0 end) as b4twoWks,
           sum(case when cast(kempedate-bday as int) >14 then 1 else 0 end) as morethan2wks,
           sum(case when KempeResult=0 then 1 else 0 end) as NegativeKempes
	from
	(select kempe.*,isnull(hvcase.tcdob,hvcase.edc) as bday from kempe, hvcase
	where kempe.hvcasefk=hvcasepk and Kempe.KempeDate>=@StartDate and Kempe.KempeDate<=@EndDate and 
		  (@programfks LIKE('%,' + CAST(kempe.programfk AS VARCHAR(100)) + ',%')))a
else
	select count(kempepk) as kempettl,
		   sum(case when bday>kempedate then 1 else 0 end) as prenatal,
		   sum(case when bday<=kempedate then 1 else 0 end) as postnatal,
           sum(case when cast(kempedate-bday as int) <=14 and cast(kempedate-bday as int) >= 0 then 1 else 0 end) as within2wks,
		   sum(case when cast(kempedate-bday as int) <=14 then 1 else 0 end) as b4twoWks,
           sum(case when cast(kempedate-bday as int) >14 then 1 else 0 end) as morethan2wks,
           sum(case when KempeResult=0 then 1 else 0 end) as NegativeKempes
	from
	(select kempe.*,isnull(hvcase.tcdob,hvcase.edc) as bday from kempe, hvcase
	where kempe.hvcasefk=hvcasepk and Kempe.KempeDate>=@StartDate and Kempe.KempeDate<=@EndDate and
			(@programfks LIKE('%,' + CAST(kempe.programfk AS VARCHAR(100)) + ',%')))a,
	(Select hvcasefk from udfCaseFilters(@posclause,@negclause,@programfks)) b
	where a.hvcasefk=b.hvcasefk
END
GO
