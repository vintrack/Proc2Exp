USE [AutoExport]
GO
/****** Object:  Table [dbo].[AEVehicleStatusHistory]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AEVehicleStatusHistory](
	[AEVehicleStatusHistoryID] [int] IDENTITY(1,1) NOT NULL,
	[AutoportExportVehiclesID] [int] NULL,
	[VehicleStatus] [varchar](20) NULL,
	[StatusDate] [datetime] NULL,
	[CreationDate] [datetime] NULL,
	[CreatedBy] [varchar](20) NULL,
 CONSTRAINT [PK_AEVehicleStatusHistory] PRIMARY KEY CLUSTERED 
(
	[AEVehicleStatusHistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_AEVehicleStatusHistory_AEVID]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_AEVehicleStatusHistory_AEVID] ON [dbo].[AEVehicleStatusHistory]
(
	[AutoportExportVehiclesID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
