USE [AutoExport]
GO
/****** Object:  Table [dbo].[CustomsApprovedLine1]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomsApprovedLine1](
	[VoyageID] [int] NOT NULL,
	[VoyageDate] [date] NOT NULL,
	[VesselName] [varchar](100) NULL,
	[CreationTime] [datetime] NOT NULL
) ON [PRIMARY]
GO
