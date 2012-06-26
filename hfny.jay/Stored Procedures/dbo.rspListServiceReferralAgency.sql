SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Devinder S. Khalsa
-- Create date: 06/20/2012
-- Description:	Report containing  Service Referral Agency
-- Usage: [rspListServiceReferralAgency] 2,1
-- =============================================
CREATE PROCEDURE [dbo].[rspListServiceReferralAgency]
( @programfk INT,
@bAgencyIsActive      bit             = null
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   
  SELECT [AgencyName]     
  FROM [HFNYConversion].[dbo].[listServiceReferralAgency]
  WHERE ProgramFK = @programfk AND AgencyIsActive = @bAgencyIsActive AND AgencyName <> ''
  ORDER BY AgencyName
  
  
  END
GO
