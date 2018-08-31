USE [AutoExport]
GO
/****** Object:  Table [dbo].[AEConsignee]    Script Date: 8/31/2018 10:25:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AEConsignee](
	[AEConsigneeID] [int] IDENTITY(1,1) NOT NULL,
	[ConsigneeName] [varchar](50) NULL,
	[ConsigneeShortName] [varchar](20) NULL,
	[ConsigneeAddressID] [int] NULL,
	[Notes] [varchar](1000) NULL,
	[RecordStatus] [varchar](20) NULL,
	[CreationDate] [datetime] NULL,
	[CreatedBy] [varchar](20) NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [varchar](20) NULL,
	[AEExporterID] [int] NULL,
	[CustomerConsigneeCode] [varchar](20) NULL,
 CONSTRAINT [PK_AEConsignee] PRIMARY KEY CLUSTERED 
(
	[AEConsigneeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
