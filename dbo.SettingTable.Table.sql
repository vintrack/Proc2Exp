USE [AutoExport]
GO
/****** Object:  Table [dbo].[SettingTable]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SettingTable](
	[SettingTableID] [int] IDENTITY(1,1) NOT NULL,
	[ValueKey] [varchar](50) NULL,
	[ValueDescription] [varchar](255) NULL,
	[ShareWithMobileInd] [int] NULL,
	[AllowChangeByAdminInd] [int] NULL,
	[SettingName] [varchar](30) NULL,
	[Description] [varchar](7000) NULL,
	[DataType] [varchar](30) NULL,
	[DataSubType] [varchar](30) NULL,
	[DAIOnlyInd] [int] NULL,
	[RecordStatus] [varchar](15) NULL,
	[CreationDate] [datetime] NULL,
	[CreatedBy] [varchar](20) NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [varchar](20) NULL,
 CONSTRAINT [PK_SettingTable] PRIMARY KEY CLUSTERED 
(
	[SettingTableID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_ValueKey]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_ValueKey] ON [dbo].[SettingTable]
(
	[ValueKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
