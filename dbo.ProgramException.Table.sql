USE [AutoExport]
GO
/****** Object:  Table [dbo].[ProgramException]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProgramException](
	[ExceptionID] [int] IDENTITY(1,1) NOT NULL,
	[ExceptionMessage] [varchar](1000) NOT NULL,
	[Usercode] [varchar](20) NOT NULL,
	[CreationDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ProgramException] PRIMARY KEY CLUSTERED 
(
	[ExceptionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
