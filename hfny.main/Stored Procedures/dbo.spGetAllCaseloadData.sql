SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[spGetAllCaseloadData]
					(@programFK int, @rpdate date, @username varchar(255))

as
	begin
		declare @dateYear int
		declare @dateMonth int
		declare @dateDay int

		declare @tblHolder table 
						(ReportDate date
							, ReportMonth char(3)
							, CaseWeight numeric(6, 2)
						)
		insert into @tblHolder (ReportDate, ReportMonth, CaseWeight)
			exec spGetCaseLoadDataForChart @programFK, @rpdate, @username

		set @dateDay = 1
		set @dateMonth = case datepart(month, @rpdate) when 1 then 12 else datepart(month, @rpdate)  - 1 end
		set @dateYear = case when @dateMonth = 12 then datepart(year, @rpdate) - 1 else datepart(year, @rpdate) end
		set @rpdate = datefromparts(@dateYear, @dateMonth, @dateDay)

		insert into @tblHolder (ReportDate, ReportMonth, CaseWeight)
			exec spGetCaseLoadDataForChart @programFK, @rpdate, @username

		set @dateDay = 1
		set @dateMonth = case datepart(month, @rpdate) when 1 then 12 else datepart(month, @rpdate)  - 1 end
		set @dateYear = case when @dateMonth = 12 then datepart(year, @rpdate) - 1 else datepart(year, @rpdate) end
		set @rpdate = datefromparts(@dateYear, @dateMonth, @dateDay)

		insert into @tblHolder (ReportDate, ReportMonth, CaseWeight)
			exec spGetCaseLoadDataForChart @programFK, @rpdate, @username

		set @dateDay = 1
		set @dateMonth = case datepart(month, @rpdate) when 1 then 12 else datepart(month, @rpdate)  - 1 end
		set @dateYear = case when @dateMonth = 12 then datepart(year, @rpdate) - 1 else datepart(year, @rpdate) end
		set @rpdate = datefromparts(@dateYear, @dateMonth, @dateDay)

		insert into @tblHolder (ReportDate, ReportMonth, CaseWeight)
			exec spGetCaseLoadDataForChart @programFK, @rpdate, @username

		set @dateDay = 1
		set @dateMonth = case datepart(month, @rpdate) when 1 then 12 else datepart(month, @rpdate)  - 1 end
		set @dateYear = case when @dateMonth = 12 then datepart(year, @rpdate) - 1 else datepart(year, @rpdate) end
		set @rpdate = datefromparts(@dateYear, @dateMonth, @dateDay)

		insert into @tblHolder (ReportDate, ReportMonth, CaseWeight)
			exec spGetCaseLoadDataForChart @programFK, @rpdate, @username

		set @dateDay = 1
		set @dateMonth = case datepart(month, @rpdate) when 1 then 12 else datepart(month, @rpdate)  - 1 end
		set @dateYear = case when @dateMonth = 12 then datepart(year, @rpdate) - 1 else datepart(year, @rpdate) end
		set @rpdate = datefromparts(@dateYear, @dateMonth, @dateDay)

		insert into @tblHolder (ReportDate, ReportMonth, CaseWeight)
			exec spGetCaseLoadDataForChart @programFK, @rpdate, @username

		select * from @tblHolder th
		order by th.ReportDate
	end
GO
