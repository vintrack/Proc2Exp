USE [AutoExport]
GO
/****** Object:  Table [dbo].[VehicleLocationHistory]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VehicleLocationHistory](
	[VehicleLocationHistoryID] [int] IDENTITY(1,1) NOT NULL,
	[VehicleID] [int] NOT NULL,
	[BayLocation] [varchar](50) NULL,
	[CreationDate] [datetime] NOT NULL,
	[CreatedBy] [varchar](20) NOT NULL,
 CONSTRAINT [PK_VehicleLocationHistory] PRIMARY KEY CLUSTERED 
(
	[VehicleLocationHistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleLocationHistory] ADD  CONSTRAINT [DF_VehicleLocationHistory_CreationDate]  DEFAULT (getdate()) FOR [CreationDate]
GO
