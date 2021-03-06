USE [AutoExport]
GO
/****** Object:  Table [dbo].[AEVoyageDestination_new]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AEVoyageDestination_new](
	[AEVoyageDestinationID] [int] NOT NULL,
	[AEVoyageID] [int] NULL,
	[DestinationName] [varchar](20) NULL,
	[CreationDate] [datetime] NULL,
	[CreatedBy] [varchar](20) NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [varchar](20) NULL
) ON [PRIMARY]
GO
