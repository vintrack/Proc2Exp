USE [AutoExport]
GO
/****** Object:  Table [dbo].[VINDecode]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VINDecode](
	[VINDecodeID] [int] IDENTITY(1,1) NOT NULL,
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
	[PayRate] [decimal](19, 2) NULL,
 CONSTRAINT [PK_VINDecode] PRIMARY KEY CLUSTERED 
(
	[VINDecodeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_VINDecode_VS]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_VINDecode_VS] ON [dbo].[VINDecode]
(
	[VINSquish] ASC,
	[CreationDate] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
