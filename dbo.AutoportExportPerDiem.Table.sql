USE [AutoExport]
GO
/****** Object:  Table [dbo].[AutoportExportPerDiem]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AutoportExportPerDiem](
	[AutoportExportPerDiemID] [int] IDENTITY(1,1) NOT NULL,
	[AutoportExportVehiclesID] [int] NULL,
	[PerDiemDate] [datetime] NULL,
	[PerDiem] [decimal](19, 2) NULL,
	[PerDiemOverrideInd] [int] NULL,
	[CreationDate] [datetime] NULL,
	[CreatedBy] [varchar](20) NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [varchar](20) NULL,
 CONSTRAINT [PK_AutoportExportPerDiem] PRIMARY KEY CLUSTERED 
(
	[AutoportExportPerDiemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_AutoportExportPerDiem_AEVID]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_AutoportExportPerDiem_AEVID] ON [dbo].[AutoportExportPerDiem]
(
	[AutoportExportVehiclesID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [IX_AutoportExportPerDiem_AEVIDPDD]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_AutoportExportPerDiem_AEVIDPDD] ON [dbo].[AutoportExportPerDiem]
(
	[AutoportExportVehiclesID] ASC,
	[PerDiemDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
