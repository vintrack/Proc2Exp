USE [AutoExport]
GO
/****** Object:  Table [dbo].[EventProcessingRecoveryData]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EventProcessingRecoveryData](
	[UserCode] [varchar](20) NOT NULL,
	[VIN] [varchar](17) NOT NULL,
	[StatusDate] [datetime] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[ForwarderID] [int] NULL,
	[ExporterID] [int] NULL,
	[Destination] [varchar](20) NULL,
	[VehicleStatus] [varchar](20) NOT NULL,
	[RecordStatus] [varchar](50) NULL,
	[Note] [varchar](1000) NULL,
	[CreationDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
