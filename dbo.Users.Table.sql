USE [AutoExport]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[UserCode] [varchar](20) NULL,
	[FirstName] [varchar](30) NULL,
	[LastName] [varchar](30) NULL,
	[Password] [varchar](20) NULL,
	[PIN] [varchar](10) NULL,
	[Phone] [varchar](25) NULL,
	[PhoneExtension] [varchar](5) NULL,
	[CellPhone] [varchar](25) NULL,
	[FaxNumber] [varchar](25) NULL,
	[EmailAddress] [varchar](50) NULL,
	[LabelXOffset] [decimal](19, 2) NULL,
	[LabelYOffset] [decimal](19, 2) NULL,
	[IMEI] [varchar](20) NULL,
	[LastConnection] [datetime] NULL,
	[datsVersion] [int] NULL,
	[RecordStatus] [varchar](15) NULL,
	[CreationDate] [datetime] NULL,
	[CreatedBy] [varchar](20) NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [varchar](20) NULL,
	[EmployeeNumber] [varchar](20) NULL,
	[PortPassIDNumber] [varchar](12) NULL,
	[Department] [varchar](20) NULL,
	[StraightTimeRate] [decimal](19, 2) NULL,
	[PieceRateRate] [decimal](19, 2) NULL,
	[PDIRate] [decimal](19, 2) NULL,
	[FlatBenefitPayRate] [decimal](19, 2) NULL,
	[AlternateEmailAddress] [varchar](50) NULL,
	[PasswordUpdatedDate] [datetime] NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_UserCode] UNIQUE NONCLUSTERED 
(
	[UserCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Users_P]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_Users_P] ON [dbo].[Users]
(
	[Password] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Users_RS]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_Users_RS] ON [dbo].[Users]
(
	[RecordStatus] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
