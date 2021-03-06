USE [AutoExport]
GO
/****** Object:  Table [dbo].[AEPortalUser]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AEPortalUser](
	[AEPortalUserID] [int] IDENTITY(1,1) NOT NULL,
	[Username] [varchar](50) NULL,
	[Password] [varchar](255) NULL,
	[Salt] [varchar](40) NULL,
	[FirstName] [varchar](50) NULL,
	[LastName] [varchar](50) NULL,
	[Email] [varchar](255) NULL,
	[UserType] [varchar](50) NULL,
	[CanCreateAccountsInd] [int] NULL,
	[CustomerID] [int] NULL,
	[FreightForwarderID] [int] NULL,
	[ExporterID] [int] NULL,
	[ConsigneeID] [int] NULL,
	[RecordStatus] [varchar](20) NULL,
	[CreationDate] [datetime] NULL,
	[CreatedBy] [varchar](50) NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [varchar](50) NULL,
	[LastLoginDate] [datetime] NULL,
 CONSTRAINT [PK_AEPortalUser] PRIMARY KEY CLUSTERED 
(
	[AEPortalUserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
