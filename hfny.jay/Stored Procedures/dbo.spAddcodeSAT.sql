
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeSAT](@codeSATPK_old int=NULL,
@SATCompareDateField char(8)=NULL,
@SATDescription char(100)=NULL,
@SATInterval char(40)=NULL,
@SATName char(15)=NULL)
AS
INSERT INTO codeSAT(
codeSATPK_old,
SATCompareDateField,
SATDescription,
SATInterval,
SATName
)
VALUES(
@codeSATPK_old,
@SATCompareDateField,
@SATDescription,
@SATInterval,
@SATName
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
