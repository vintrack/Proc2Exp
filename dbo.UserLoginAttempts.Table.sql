USE [AutoExport]
GO
/****** Object:  Table [dbo].[UserLoginAttempts]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserLoginAttempts](
	[UserCode] [varchar](20) NOT NULL,
	[LoginDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
