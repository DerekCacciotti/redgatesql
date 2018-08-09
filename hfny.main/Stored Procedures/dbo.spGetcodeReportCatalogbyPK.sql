SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[spGetcodeReportCatalogbyPK]

(@codeReportCatalogPK int)
as
set noCount on ;

select	crc.codeReportCatalogPK
		, crc.CriteriaOptions
		, crc.Defaults
		, crc.Keywords
		, crc.OldReportFK
		, crc.OldReportID
		, crc.ReportCategory
		, crc.ReportClass
		, crc.ReportDescription
		, crc.ReportName
		, a.AttachmentPK
		, a.Attachment
		, a.AttachmentCreateDate
		, a.AttachmentCreator
		, a.AttachmentDescription
		, a.AttachmentFilePath
		, a.AttachmentTitle
		, a.FormDate
		, a.FormFK
		, a.FormType
		, a.HVCaseFK
		, a.ProgramFK
from	codeReportCatalog crc
left outer join Attachment a on a.FormFK = crc.codeReportCatalogPK and a.FormType = 'RC'
where	codeReportCatalogPK = @codeReportCatalogPK ;
GO
