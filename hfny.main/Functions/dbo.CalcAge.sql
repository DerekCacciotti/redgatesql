SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[CalcAge] (@dayOfBirth datetime, @today datetime)
   RETURNS varchar(100)
AS

Begin
DECLARE @thisYearBirthDay datetime
DECLARE @years int, @months int, @days int

set @thisYearBirthDay = DATEADD(year, DATEDIFF(year, @dayOfBirth, @today), @dayOfBirth)
set @years = DATEDIFF(year, @dayOfBirth, @today) - (CASE WHEN @thisYearBirthDay > @today THEN 1 ELSE 0 END)
set @months = MONTH(@today - @thisYearBirthDay) - 1
set @days = DAY(@today - @thisYearBirthDay) - 1

return cast(@years as varchar(2)) + ' years,' + cast(@months as varchar(2)) + ' months,' + cast(@days as varchar(3)) + ' days'
end
GO
