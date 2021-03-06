USE [AutoExport]
GO
/****** Object:  Table [dbo].[tmpAutoportExport]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmpAutoportExport](
	[AutoportExportVehiclesImportID] [int] NULL,
	[AutoportExportVehiclesID] [int] NULL,
	[DateReceived_i] [varchar](10) NULL,
	[DateReceived_v] [datetime] NULL,
	[VIN_i] [varchar](20) NULL,
	[VIN_v] [varchar](20) NULL,
	[DestinationName_i] [varchar](100) NULL,
	[DestinationName_v] [varchar](100) NULL,
	[FullDestinationName] [varchar](100) NULL,
	[HandheldCustomerCode_i] [varchar](50) NULL,
	[VehicleCustomerID_v] [int] NULL,
	[CustomerID_cu] [int] NULL,
	[RecordStatus_i] [varchar](100) NULL,
	[VehicleStatus_v] [varchar](20) NULL,
	[InspectorCode_i] [varchar](30) NULL,
	[InspectorName] [varchar](65) NULL,
	[Receivedby_v] [varchar](30) NULL,
	[BayLocation_i] [varchar](20) NULL,
	[BookingNumber_i] [varchar](20) NULL,
	[Make_i] [varchar](50) NULL,
	[Model_i] [varchar](50) NULL,
	[Bodystyle_i] [varchar](50) NULL,
	[VehicleYear_i] [varchar](6) NULL,
	[VehicleLength_i] [varchar](10) NULL,
	[VehicleWidth_i] [varchar](10) NULL,
	[VehicleHeight_i] [varchar](10) NULL,
	[VehicleWeight_i] [varchar](10) NULL,
	[VehicleCubicFeet_i] [varchar](10) NULL,
	[VINDecodedInd_i] [int] NULL,
	[SizeClass_i] [varchar](20) NULL,
	[AudioSystemFlag_i] [varchar](20) NULL,
	[NavigationSystemFlag_i] [varchar](20) NULL,
	[VIVTagNumber_i] [varchar](10) NULL,
	[Color_i] [varchar](20) NULL,
	[RunnerInd_i] [int] NULL,
	[CreateNewRecord] [int] NULL
) ON [PRIMARY]
GO
