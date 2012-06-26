SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Devinder S. Khalsa
-- Create date: 06/20/2012
-- Description:	Report containing  List Of Medical Facilities
-- Usage: rspListMedicalFacility 1,1
-- =============================================
CREATE PROCEDURE [dbo].[rspListMedicalFacility]
( @programfk INT,
@bMFIsActive      bit             = null
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;  
  
SELECT 
isnull(rtrim(MFName),'') as MFNAME
,isnull(rtrim(MFAddress),'') as MFADDRESS
,isnull(rtrim(MFCity) + ',','')+'  '+isnull(rtrim(MFState) + ',','')+'  '+isnull(rtrim(MFZip),'') as MFCSZ
,isnull(rtrim(MFPhone),'') as MFPHONE    
  FROM [HFNYConversion].[dbo].[listMedicalFacility]
  WHERE ProgramFK = @programfk AND MFIsActive = @bMFIsActive
  ORDER BY MFNAME

  
  
  
  END
GO
