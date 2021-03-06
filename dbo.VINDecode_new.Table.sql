USE [AutoExport]
GO
/****** Object:  Table [dbo].[VINDecode_new]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VINDecode_new](
	[VINDecodeID] [int] NOT NULL,
	[VINSquish] [varchar](10) NULL,
	[VehicleYear] [varchar](6) NULL,
	[Make] [varchar](50) NULL,
	[Model] [varchar](50) NULL,
	[Bodystyle] [varchar](50) NULL,
	[VehicleLength] [varchar](10) NULL,
	[VehicleWidth] [varchar](10) NULL,
	[VehicleHeight] [varchar](10) NULL,
	[VehicleWeight] [varchar](10) NULL,
	[CreationDate] [datetime] NULL,
	[CreatedBy] [varchar](20) NULL,
	[PayRate] [decimal](19, 2) NULL
) ON [PRIMARY]
GO
