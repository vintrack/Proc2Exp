USE [AutoExport]
GO
/****** Object:  Table [dbo].[Customer]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customer](
	[CustomerID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerCode] [varchar](20) NULL,
	[CustomerName] [varchar](50) NULL,
	[DBAName] [varchar](50) NULL,
	[ShortName] [varchar](20) NULL,
	[MainAddressID] [int] NULL,
	[BillingAddressID] [int] NULL,
	[CustomerType] [varchar](20) NULL,
	[CustomerSubType] [varchar](20) NULL,
	[VendorNumber] [varchar](20) NULL,
	[LoadNumberPrefix] [varchar](4) NULL,
	[LoadNumberLength] [int] NULL,
	[NextLoadNumber] [int] NULL,
	[InternalComment] [varchar](1000) NULL,
	[DriverComment] [varchar](1000) NULL,
	[CollectionsIssueInd] [int] NULL,
	[SortOrder] [int] NULL,
	[AlwaysShowInWIPInd] [int] NULL,
	[EligibleForAutoLoadConfigInd] [int] NULL,
	[ApplyFuelSurchargeInd] [int] NULL,
	[FSPOverrideInd] [int] NULL,
	[FuelSurchargePercent] [decimal](19, 2) NULL,
	[DefaultBillingMethod] [varchar](20) NULL,
	[BulkBillingInd] [int] NULL,
	[DoNotPrintInvoiceInd] [int] NULL,
	[DoNotExportInvoiceInfoInd] [int] NULL,
	[NewCustomerInd] [int] NULL,
	[RecordStatus] [varchar](15) NULL,
	[CreationDate] [datetime] NULL,
	[CreatedBy] [varchar](20) NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [varchar](20) NULL,
	[PortStorageCustomerInd] [int] NULL,
	[RequiresPONumberInd] [int] NULL,
	[AutoportExportCustomerInd] [int] NULL,
	[SendEmailConfirmationsInd] [int] NULL,
	[AssignedToExternalCollectionsInd] [int] NULL,
	[CustomerOf] [varchar](50) NULL,
	[STIFollowupRequiredInd] [int] NULL,
	[BookingNumberPrefix] [varchar](10) NULL,
	[HandheldScannerCustomerCode] [varchar](10) NULL,
	[HideNewFreightFromBrokersInd] [int] NULL,
	[DamagePhotoRequiredInd] [int] NULL,
 CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_BillingAddressID]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_BillingAddressID] ON [dbo].[Customer]
(
	[BillingAddressID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [IX_Customer_AECI]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_Customer_AECI] ON [dbo].[Customer]
(
	[AutoportExportCustomerInd] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [IX_Customer_ASWI]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_Customer_ASWI] ON [dbo].[Customer]
(
	[AlwaysShowInWIPInd] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Customer_CN]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_Customer_CN] ON [dbo].[Customer]
(
	[CustomerName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Customer_CT]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_Customer_CT] ON [dbo].[Customer]
(
	[CustomerType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [IX_Customer_SECI]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_Customer_SECI] ON [dbo].[Customer]
(
	[SendEmailConfirmationsInd] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [IX_Customer_SO]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_Customer_SO] ON [dbo].[Customer]
(
	[SortOrder] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_CustomerCode]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_CustomerCode] ON [dbo].[Customer]
(
	[CustomerCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [IX_MainAddressID]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_MainAddressID] ON [dbo].[Customer]
(
	[MainAddressID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
