USE [AutoExport]
GO
/****** Object:  Table [dbo].[AEExporter]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AEExporter](
	[AEExporterID] [int] IDENTITY(1,1) NOT NULL,
	[ExporterName] [varchar](50) NULL,
	[ExporterShortName] [varchar](20) NULL,
	[ExporterAddressID] [int] NULL,
	[Notes] [varchar](1000) NULL,
	[RecordStatus] [varchar](20) NULL,
	[CreationDate] [datetime] NULL,
	[CreatedBy] [varchar](20) NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [varchar](20) NULL,
	[AEFreightForwarderID] [int] NULL,
	[CustomerExporterCode] [varchar](20) NULL,
 CONSTRAINT [PK_AEExporter] PRIMARY KEY CLUSTERED 
(
	[AEExporterID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
