USE [AutoExport]
GO
/****** Object:  Table [dbo].[v]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[v](
	[AutoportExportVehiclesID] [int] NULL,
	[FreightForwarderID] [int] NULL,
	[ExporterID] [int] NULL,
	[BookingNumber] [varchar](20) NULL,
	[VehicleStatus] [varchar](20) NULL,
	[statusdate] [datetime] NULL
) ON [PRIMARY]
GO
