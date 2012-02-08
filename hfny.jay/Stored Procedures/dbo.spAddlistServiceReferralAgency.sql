
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddlistServiceReferralAgency](@AgencyIsActive bit=NULL,
@AgencyName varchar(100)=NULL,
@ProgramFK int=NULL)
AS

/*** check agency name duplication ***/
DECLARE @err_message nvarchar(255)
IF EXISTS (select AgencyName from listServiceReferralAgency 
           where ProgramFK = @ProgramFK and AgencyName = @AgencyName) 
	BEGIN	
	  SET @err_message = 'Duplicate agency name'
	  RAISERROR (@err_message, 11,1)
	END

INSERT INTO listServiceReferralAgency(
AgencyIsActive,
AgencyName,
ProgramFK
)
VALUES(
@AgencyIsActive,
@AgencyName,
@ProgramFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
