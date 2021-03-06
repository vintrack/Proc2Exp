USE [AutoExport]
GO
/****** Object:  Table [dbo].[SallaumPolExport]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SallaumPolExport](
	[SallaumPolExportID] [int] IDENTITY(1,1) NOT NULL,
	[BatchID] [int] NULL,
	[Pol] [varchar](5) NULL,
	[TerminalId] [varchar](5) NULL,
	[Barcode] [varchar](50) NOT NULL,
	[ChassisNbr] [varchar](25) NULL,
	[CustomerId] [varchar](9) NULL,
	[Make] [varchar](3) NULL,
	[Model] [varchar](4) NULL,
	[Description] [varchar](50) NULL,
	[Color] [varchar](3) NULL,
	[Location] [varchar](4) NULL,
	[ReceivedOn] [datetime] NULL,
	[ShippedOn] [datetime] NULL,
	[Width1] [varchar](10) NULL,
	[height1] [varchar](10) NULL,
	[Length1] [varchar](10) NULL,
	[Width2] [varchar](10) NULL,
	[height2] [varchar](10) NULL,
	[Length2] [varchar](10) NULL,
	[Weight] [varchar](10) NULL,
	[UnitType] [varchar](50) NULL,
	[VoyageNbr] [varchar](7) NULL,
	[VesselName] [varchar](20) NULL,
	[POD] [varchar](5) NULL,
	[Blocked] [int] NULL,
	[Reason] [varchar](40) NULL,
	[CustomsDocs] [varchar](20) NULL,
	[CustomsRemarks] [varchar](200) NULL,
	[CustomsStatus] [varchar](2) NULL,
	[ClearedOn] [datetime] NULL,
	[Shipper] [varchar](20) NULL,
	[Damages] [varchar](100) NULL,
	[HasRelatedItems] [int] NULL,
	[RemovedFlag] [int] NULL,
	[RemovedReason] [varchar](200) NULL,
	[VehicleStatus] [varchar](100) NULL,
	[ExportedInd] [int] NULL,
	[ExportedDate] [datetime] NULL,
	[ExportedBy] [varchar](50) NULL,
	[RecordStatus] [varchar](100) NULL,
	[CreationDate] [datetime] NULL
) ON [PRIMARY]
GO
