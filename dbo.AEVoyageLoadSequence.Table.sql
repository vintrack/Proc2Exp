USE [AutoExport]
GO
/****** Object:  Table [dbo].[AEVoyageLoadSequence]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AEVoyageLoadSequence](
	[AEVoyageLoadSequenceID] [int] IDENTITY(1,1) NOT NULL,
	[VoyageID] [int] NULL,
	[Sequence] [int] NULL,
	[CustomerID] [int] NULL,
	[DestinationName] [varchar](20) NULL,
	[SizeClass] [varchar](10) NULL,
	[CreationDate] [datetime] NULL,
	[CreatedBy] [varchar](20) NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [varchar](20) NULL,
 CONSTRAINT [PK_AEVoyageLoadSequence] PRIMARY KEY CLUSTERED 
(
	[AEVoyageLoadSequenceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_AEVoyageLoadSequence_VID]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_AEVoyageLoadSequence_VID] ON [dbo].[AEVoyageLoadSequence]
(
	[VoyageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
