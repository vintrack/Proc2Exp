USE [AutoExport]
GO
/****** Object:  Table [dbo].[LocationEmailContacts]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LocationEmailContacts](
	[LocationEmailContactsID] [int] IDENTITY(1,1) NOT NULL,
	[LocationID] [int] NULL,
	[GreetingName] [varchar](200) NULL,
	[EmailAddress] [varchar](255) NULL,
	[HTMLEmailSupportedInd] [int] NULL,
	[PickupNoticeInd] [int] NULL,
	[STIDeliveryNoticeInd] [int] NULL,
	[BillOfLadingInd] [int] NULL,
	[CreationDate] [datetime] NULL,
	[CreatedBy] [varchar](20) NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [varchar](20) NULL,
	[BookingRecordInd] [int] NULL,
 CONSTRAINT [PK_LocationEmailContacts] PRIMARY KEY CLUSTERED 
(
	[LocationEmailContactsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
