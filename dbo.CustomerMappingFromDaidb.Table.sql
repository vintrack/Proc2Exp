USE [AutoExport]
GO
/****** Object:  Table [dbo].[CustomerMappingFromDaidb]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerMappingFromDaidb](
	[CustomerCode] [varchar](20) NOT NULL,
	[CustomerID_old] [int] NOT NULL,
	[CustomerID_new] [int] NOT NULL,
 CONSTRAINT [PK_CustomerMappingFromDaidb] PRIMARY KEY CLUSTERED 
(
	[CustomerCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
