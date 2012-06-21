SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spGetSubTopics] 
	-- Add the parameters for the stored procedure here
	@ProgramFK AS INT,
	@topicFK AS int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT DISTINCT SubTopicPK,  cast([SubTopicCode] AS VARCHAR(MAX)) + ' ' + [SubTopicName] AS SubTopicCodeName FROM SubTopic t 
	WHERE ProgramFK=@ProgramFK AND topicfk=@topicfk
END
GO
