SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Devinder S. Khalsa
-- Create date: 06/20/2012
-- MP = MEDICAL PROVIDER, CSZ = CITY STATE ZIP, FNLN = FIRST NAME LAST NAME
-- Description:	Report containing  List Of Medical Providers
-- Usage: rspListMedicalProvider 1,1
-- =============================================
CREATE PROCEDURE [dbo].[rspListMedicalProvider]
( @programfk INT,
@bMPIsActive      bit             = null
)


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;  

  
SELECT 
isnull(rtrim(MPLastName),'')+
CASE WHEN len(isnull(rtrim(MPFirstName),'')) > 0 -- Add comma (,) if there is a value in FirstName
 THEN ', ' + isnull(rtrim(MPFirstName),'')
 ELSE
  ''
  end as MPFNLN
,isnull(rtrim(MPAddress),'') as MPADDRESS
,isnull(rtrim(MPCity) + ',','')+'  '+isnull(rtrim(MPState) + ',','')+'  '+isnull(rtrim(MPZip),'') as MPCSZ
,isnull(rtrim(MPPhone),'') as MPPHONE    
  FROM [HFNYConversion].[dbo].[listMedicalProvider]
  WHERE ProgramFK = @programfk AND MPIsActive = @bMPIsActive
  ORDER BY MPFNLN
 
  
  
  
  
  END
GO
