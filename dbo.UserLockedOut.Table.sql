USE [AutoExport]
GO
/****** Object:  Table [dbo].[UserLockedOut]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserLockedOut](
	[UserCode] [varchar](20) NOT NULL,
	[LockedOutDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
