USE [AutoExport]
GO
/****** Object:  Table [dbo].[AEVoyageCustomer]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AEVoyageCustomer](
	[AEVoyageCustomerID] [int] IDENTITY(1,1) NOT NULL,
	[AEVoyageID] [int] NULL,
	[CustomerID] [int] NULL,
	[CreationDate] [datetime] NULL,
	[CreatedBy] [varchar](20) NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [varchar](20) NULL,
 CONSTRAINT [PK_AEVoyageCustomer] PRIMARY KEY CLUSTERED 
(
	[AEVoyageCustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
