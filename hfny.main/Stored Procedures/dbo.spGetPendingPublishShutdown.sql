SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[spGetPendingPublishShutdown] @date datetime
as

select		ps.PublishShutdownPK
from		PublishShutdown ps
where		@date between ps.PublishShutdownStart and dateadd(minute, 20, ps.PublishShutdownEnd)
order by	ps.PublishShutdownStart desc ;
GO
