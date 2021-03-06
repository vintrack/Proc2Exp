USE [AutoExport]
GO
/****** Object:  Table [dbo].[AutoportExportVehicles]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AutoportExportVehicles](
	[AutoportExportVehiclesID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NULL,
	[VehicleYear] [varchar](6) NULL,
	[Make] [varchar](50) NULL,
	[Model] [varchar](50) NULL,
	[Bodystyle] [varchar](50) NULL,
	[VIN] [varchar](17) NULL,
	[Color] [varchar](20) NULL,
	[VehicleLength] [varchar](10) NULL,
	[VehicleWidth] [varchar](10) NULL,
	[VehicleHeight] [varchar](10) NULL,
	[VehicleWeight] [varchar](10) NULL,
	[VehicleCubicFeet] [varchar](10) NULL,
	[VehicleStatus] [varchar](20) NULL,
	[TitleNumber] [varchar](20) NULL,
	[TitleState] [varchar](2) NULL,
	[DestinationName] [varchar](20) NULL,
	[ExporterID] [int] NULL,
	[FreightForwarderID] [int] NULL,
	[VesselID] [int] NULL,
	[BookingNumber] [varchar](20) NULL,
	[VoyageNumber] [varchar](20) NULL,
	[CustomerIdentification] [varchar](20) NULL,
	[SizeClass] [varchar](10) NULL,
	[BayLocation] [varchar](20) NULL,
	[EntryRate] [decimal](19, 2) NULL,
	[EntryRateOverrideInd] [int] NULL,
	[PerDiemGraceDays] [int] NULL,
	[PerDiemGraceDaysOverrideInd] [int] NULL,
	[TotalCharge] [decimal](19, 2) NULL,
	[DateReceived] [datetime] NULL,
	[ReceivedExceptionDate] [datetime] NULL,
	[DateSubmittedCustoms] [datetime] NULL,
	[CustomsExceptionDate] [datetime] NULL,
	[CustomsApprovedDate] [datetime] NULL,
	[DateShipped] [datetime] NULL,
	[BilledInd] [int] NULL,
	[BillingID] [int] NULL,
	[DateBilled] [datetime] NULL,
	[VINDecodedInd] [int] NULL,
	[Note] [varchar](1000) NULL,
	[RecordStatus] [varchar](20) NULL,
	[CreationDate] [datetime] NULL,
	[CreatedBy] [varchar](20) NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [varchar](20) NULL,
	[CreditHoldInd] [int] NULL,
	[CreditHoldBy] [varchar](20) NULL,
	[CustomsApprovalPrintedInd] [int] NULL,
	[VoyageID] [int] NULL,
	[CustomsCoverSheetPrintedInd] [int] NULL,
	[NoStartInd] [int] NULL,
	[CustomsApprovalPrintedDate] [datetime] NULL,
	[ConsigneeID] [int] NULL,
	[LastPhysicalDate] [datetime] NULL,
	[HasAudioSystemInd] [int] NULL,
	[HasNavigationSystemInd] [int] NULL,
	[TransshipPortName] [varchar](20) NULL,
	[SpecialInstructions] [varchar](1000) NULL,
	[CustomsApprovedCoverSheetPrintedInd] [int] NULL,
	[PortReceiptNumber] [varchar](20) NULL,
	[VoyageChangeHoldDate] [datetime] NULL,
	[ReceivedBy] [varchar](30) NULL,
	[LastPhysicalBy] [varchar](30) NULL,
	[BarCodeLabelPrintedInd] [int] NULL,
	[VIVTagNumber] [varchar](10) NULL,
	[BarCodeLabelPrintedDate] [datetime] NULL,
	[MechanicalExceptionInd] [int] NULL,
	[LeftBehindInd] [int] NULL,
	[ITNNumber] [varchar](20) NULL,
	[BillToInd] [int] NULL,
	[BillToCustomerID] [int] NULL,
	[BillToNote] [varchar](1000) NULL,
 CONSTRAINT [PK_AutoportExportVehicles] PRIMARY KEY CLUSTERED 
(
	[AutoportExportVehiclesID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_AutoportExportVIN]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_AutoportExportVIN] ON [dbo].[AutoportExportVehicles]
(
	[VIN] ASC,
	[CreationDate] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_AutoportExportVoyageID]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_AutoportExportVoyageID] ON [dbo].[AutoportExportVehicles]
(
	[VoyageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
