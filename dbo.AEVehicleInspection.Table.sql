USE [AutoExport]
GO
/****** Object:  Table [dbo].[AEVehicleInspection]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AEVehicleInspection](
	[AEVehicleInspectionID] [int] IDENTITY(1,1) NOT NULL,
	[AutoportExportVehiclesID] [int] NULL,
	[InspectionType] [int] NULL,
	[InspectionDate] [datetime] NULL,
	[InspectedBy] [varchar](20) NULL,
	[DamageCodeCount] [int] NULL,
	[AttendedInd] [int] NULL,
	[SubjectToInspectionInd] [int] NULL,
	[CleanVehicleInd] [int] NULL,
	[Notes] [varchar](1000) NULL,
	[CreationDate] [datetime] NULL,
	[CreatedBy] [varchar](20) NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [varchar](20) NULL,
 CONSTRAINT [PK_AEVehicleInspection] PRIMARY KEY CLUSTERED 
(
	[AEVehicleInspectionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
