USE [AutoExport]
GO
/****** Object:  Table [dbo].[AEVehicleDamageDetail]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AEVehicleDamageDetail](
	[AEVehicleDamageDetailID] [int] IDENTITY(1,1) NOT NULL,
	[AEDamageClaimID] [int] NULL,
	[AEVehicleInspectionID] [int] NULL,
	[ClaimNumber] [varchar](20) NULL,
	[AutoportExportVehiclesID] [int] NULL,
	[DamageCode] [varchar](10) NULL,
	[DamageDescription] [varchar](100) NULL,
	[CreationDate] [datetime] NULL,
	[CreatedBy] [varchar](20) NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [varchar](20) NULL,
 CONSTRAINT [PK_AEVehicleDamageDetail] PRIMARY KEY CLUSTERED 
(
	[AEVehicleDamageDetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_AEVehicleDamageDetail_AEVID]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_AEVehicleDamageDetail_AEVID] ON [dbo].[AEVehicleDamageDetail]
(
	[AutoportExportVehiclesID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_AEVehicleDamageDetail_CN]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_AEVehicleDamageDetail_CN] ON [dbo].[AEVehicleDamageDetail]
(
	[ClaimNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
