USE [AutoExport]
GO
/****** Object:  Table [dbo].[AutoportExportVehiclesImport]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AutoportExportVehiclesImport](
	[AutoportExportVehiclesImportID] [int] IDENTITY(1,1) NOT NULL,
	[BatchID] [int] NULL,
	[VIN] [varchar](20) NULL,
	[BayLocation] [varchar](20) NULL,
	[BookingNumber] [varchar](20) NULL,
	[DestinationName] [varchar](100) NULL,
	[VehicleYear] [varchar](6) NULL,
	[Make] [varchar](50) NULL,
	[Model] [varchar](50) NULL,
	[Bodystyle] [varchar](50) NULL,
	[VehicleLength] [varchar](10) NULL,
	[VehicleWidth] [varchar](10) NULL,
	[VehicleHeight] [varchar](10) NULL,
	[VehicleWeight] [varchar](10) NULL,
	[VehicleCubicFeet] [varchar](10) NULL,
	[VINDecodedInd] [int] NULL,
	[ImportedInd] [int] NULL,
	[ImportedDate] [datetime] NULL,
	[ImportedBy] [varchar](20) NULL,
	[RecordStatus] [varchar](100) NULL,
	[CreationDate] [datetime] NULL,
	[CreatedBy] [varchar](20) NULL,
	[SizeClass] [varchar](20) NULL,
	[AudioSystemFlag] [varchar](20) NULL,
	[NavigationSystemFlag] [varchar](20) NULL,
	[CustomerName] [varchar](50) NULL,
	[Inspector] [varchar](30) NULL,
	[VIVTagNumber] [varchar](10) NULL,
	[Color] [varchar](20) NULL,
	[RunnerInd] [int] NULL,
 CONSTRAINT [PK_AutoportExportVehiclesImport] PRIMARY KEY CLUSTERED 
(
	[AutoportExportVehiclesImportID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_AutoportExportVehiclesImport_BID]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_AutoportExportVehiclesImport_BID] ON [dbo].[AutoportExportVehiclesImport]
(
	[BatchID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [IX_AutoportExportVehiclesImport_II]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_AutoportExportVehiclesImport_II] ON [dbo].[AutoportExportVehiclesImport]
(
	[ImportedInd] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
