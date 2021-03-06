USE [AutoExport]
GO
/****** Object:  Table [dbo].[AutoportExportShippedVehiclesImport]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AutoportExportShippedVehiclesImport](
	[AutoportExportShippedVehiclesImportID] [int] IDENTITY(1,1) NOT NULL,
	[BatchID] [int] NULL,
	[VIN] [varchar](17) NULL,
	[DateShipped] [datetime] NULL,
	[ImportedInd] [int] NULL,
	[ImportedDate] [datetime] NULL,
	[ImportedBy] [varchar](20) NULL,
	[RecordStatus] [varchar](100) NULL,
	[CreationDate] [datetime] NULL,
	[CreatedBy] [varchar](20) NULL,
	[FileName] [varchar](20) NULL,
 CONSTRAINT [PK_AutoportExportShippedVehiclesImport] PRIMARY KEY CLUSTERED 
(
	[AutoportExportShippedVehiclesImportID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_AutoportExportShippedVehiclesImport_BID]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_AutoportExportShippedVehiclesImport_BID] ON [dbo].[AutoportExportShippedVehiclesImport]
(
	[BatchID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
