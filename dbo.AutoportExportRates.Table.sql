USE [AutoExport]
GO
/****** Object:  Table [dbo].[AutoportExportRates]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AutoportExportRates](
	[AutoportExportRatesID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NULL,
	[EntryFee] [decimal](19, 2) NULL,
	[PerDiem] [decimal](19, 2) NULL,
	[PerDiemGraceDays] [int] NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[CreationDate] [datetime] NULL,
	[CreatedBy] [varchar](20) NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [varchar](20) NULL,
	[RateType] [varchar](20) NULL,
 CONSTRAINT [PK_AutoportExportRates] PRIMARY KEY CLUSTERED 
(
	[AutoportExportRatesID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_AutoportExportRates_CIDSDED]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_AutoportExportRates_CIDSDED] ON [dbo].[AutoportExportRates]
(
	[CustomerID] ASC,
	[StartDate] ASC,
	[EndDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
