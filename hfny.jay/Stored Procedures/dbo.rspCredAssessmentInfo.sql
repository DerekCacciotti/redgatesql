SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Jay Robohn orig by Dorothy Baum>
-- Create date: <June 3, 2010>
-- Description:	<report: Credentialing 1-1D. Assessment Info>
-- =============================================
CREATE PROCEDURE [dbo].[rspCredAssessmentInfo] (@StartDate datetime, @EndDate datetime, @programfks varchar(max),
	@posclause varchar(200),@negclause varchar(200))
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

set @posclause = case 
					when @posclause = ''
						then null
					else
						@posclause
					end;

set @negclause = case 
					when @negclause = ''
						then null
					else
						@negclause
					end;
					
-- Insert statements for procedure here
if @posclause is null and @negclause is null -- don't include filters
	with cteTotals 
	as
	(select count(kempepk) as kempettl,
			sum(case when bday>kempedate then 1 else 0 end) as prenatal,
			sum(case when bday<=kempedate then 1 else 0 end) as postnatal,
			sum(case when cast(kempedate-bday as int) <=14 and cast(kempedate-bday as int) >= 0 then 1 else 0 end) as within2wks,
			sum(case when cast(kempedate-bday as int) <=14 then 1 else 0 end) as b4twoWks,
			sum(case when cast(kempedate-bday as int) >14 then 1 else 0 end) as morethan2wks,
			sum(case when KempeResult=0 then 1 else 0 end) as NegativeKempes,
			sum(case when KempeResult=1 then 1 else 0 end) as PositiveKempes
		from
		(select kempe.*,isnull(hvcase.tcdob,hvcase.edc) as bday from kempe, hvcase
		where kempe.hvcasefk=hvcasepk and Kempe.KempeDate>=@StartDate and Kempe.KempeDate<=@EndDate and 
			  (@programfks LIKE('%,' + CAST(kempe.programfk AS VARCHAR(100)) + ',%')))a
	)
	select kempettl
			,prenatal
			,postnatal
			,within2wks
			,b4twoWks
			,morethan2wks
			,NegativeKempes
			,PositiveKempes
			,case when prenatal is not null and prenatal > 0 then prenatal/(kempettl*1.0) else 0 end as PrenatalPercent
			,case when postnatal is not null and postnatal > 0 then postnatal/(kempettl*1.0) else 0 end as PostnatalPercent
			,case when within2wks is not null and within2wks > 0 then within2wks/(kempettl*1.0) else 0 end as twoWkPercent
			,case when morethan2wks is not null and morethan2wks > 0 then morethan2wks/(kempettl*1.0) else 0 end as After2Percent
			,case when prenatal is not null and prenatal > 0 then prenatal + within2wks else within2wks end as Prenatal_2wks
			,case when prenatal is not null and prenatal > 0 then (prenatal + within2wks)/(kempettl*1.0) else within2wks/(kempettl*1.0) end as Percent_2wks
			,case when NegativeKempes is not null and NegativeKempes > 0 then NegativeKempes/(kempettl*1.0) else 0 end as NegKempePercent
			,case when PositiveKempes is not null and PositiveKempes > 0 then PositiveKempes/(kempettl*1.0) else 0 end as PosKempePercent
	from cteTotals
	
else
	with cteTotals 
	as
	(select count(kempepk) as kempettl,
			sum(case when bday>kempedate then 1 else 0 end) as prenatal,
			sum(case when bday<=kempedate then 1 else 0 end) as postnatal,
			sum(case when cast(kempedate-bday as int) <=14 and cast(kempedate-bday as int) >= 0 then 1 else 0 end) as within2wks,
			sum(case when cast(kempedate-bday as int) <=14 then 1 else 0 end) as b4twoWks,
			sum(case when cast(kempedate-bday as int) >14 then 1 else 0 end) as morethan2wks,
			sum(case when KempeResult=0 then 1 else 0 end) as NegativeKempes,
			sum(case when KempeResult=1 then 1 else 0 end) as PositiveKempes
	from
	(select kempe.*,isnull(hvcase.tcdob,hvcase.edc) as bday from kempe, hvcase
	where kempe.hvcasefk=hvcasepk and Kempe.KempeDate>=@StartDate and Kempe.KempeDate<=@EndDate and
			(@programfks LIKE('%,' + CAST(kempe.programfk AS VARCHAR(100)) + ',%')))a,
	(Select hvcasefk from udfCaseFilters(@posclause,@negclause,@programfks)) b
	where a.hvcasefk=b.hvcasefk
	)
	select kempettl
			,prenatal
			,postnatal
			,within2wks
			,b4twoWks
			,morethan2wks
			,NegativeKempes
			,PositiveKempes
			,case when prenatal is not null and prenatal > 0 then prenatal/(kempettl*1.0) else 0 end as PrenatalPercent
			,case when postnatal is not null and postnatal > 0 then postnatal/(kempettl*1.0) else 0 end as PostnatalPercent
			,case when within2wks is not null and within2wks > 0 then within2wks/(kempettl*1.0) else 0 end as twoWkPercent
			,case when morethan2wks is not null and morethan2wks > 0 then morethan2wks/(kempettl*1.0) else 0 end as After2Percent
			,case when prenatal is not null and prenatal > 0 then prenatal + within2wks else within2wks end as Prenatal_2wks
			,case when prenatal is not null and prenatal > 0 then (prenatal + within2wks)/(kempettl*1.0) else within2wks/(kempettl*1.0) end as Percent_2wks
			,case when NegativeKempes is not null and NegativeKempes > 0 then NegativeKempes/(kempettl*1.0) else 0 end as NegKempePercent
			,case when PositiveKempes is not null and PositiveKempes > 0 then PositiveKempes/(kempettl*1.0) else 0 end as PosKempePercent
	from cteTotals
END
GO
