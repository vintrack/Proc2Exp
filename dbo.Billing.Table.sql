USE [AutoExport]
GO
/****** Object:  Table [dbo].[Billing]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Billing](
	[BillingID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NULL,
	[OutsideCarrierInvoiceInd] [int] NULL,
	[OutsideCarrierID] [int] NULL,
	[RunID] [int] NULL,
	[InvoiceDate] [datetime] NULL,
	[InvoiceNumber] [varchar](20) NULL,
	[InvoiceType] [varchar](20) NULL,
	[PaymentMethod] [varchar](20) NULL,
	[TransportCharges] [decimal](19, 2) NULL,
	[FuelSurchargeRate] [decimal](19, 2) NULL,
	[FuelSurchargeRateOverrideInd] [int] NULL,
	[FuelSurcharge] [decimal](19, 2) NULL,
	[FuelSurchargeOverrideInd] [int] NULL,
	[OtherCharge1] [decimal](19, 2) NULL,
	[OtherCharge1Description] [varchar](20) NULL,
	[OtherCharge2] [decimal](19, 2) NULL,
	[OtherCharge2Description] [varchar](20) NULL,
	[OtherCharge3] [decimal](19, 2) NULL,
	[OtherCharge3Description] [varchar](20) NULL,
	[OtherCharge4] [decimal](19, 2) NULL,
	[OtherCharge4Description] [varchar](20) NULL,
	[InvoiceAmount] [decimal](19, 2) NULL,
	[AmountPaid] [decimal](19, 2) NULL,
	[CreditsIssued] [decimal](19, 2) NULL,
	[BalanceDue] [decimal](19, 2) NULL,
	[DueToOutsideCarriers] [decimal](19, 2) NULL,
	[DueFromOutsideCarriers] [decimal](19, 2) NULL,
	[PaidInFullInd] [int] NULL,
	[PaidInFullDate] [datetime] NULL,
	[Comments] [varchar](1000) NULL,
	[InvoiceStatus] [varchar](20) NULL,
	[PrintedInd] [int] NULL,
	[DatePrinted] [datetime] NULL,
	[CreditMemoInd] [int] NULL,
	[CreditedOutInd] [int] NULL,
	[CreditMemoID] [int] NULL,
	[ExportedInd] [int] NULL,
	[DateExported] [datetime] NULL,
	[CreationDate] [datetime] NULL,
	[CreatedBy] [varchar](20) NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [varchar](20) NULL,
	[CreditedOutBy] [varchar](20) NULL,
	[StorageCharges] [decimal](19, 2) NULL,
	[DATBillingID] [int] NULL,
	[DATBillingPercentage] [decimal](19, 2) NULL,
 CONSTRAINT [PK_Billing] PRIMARY KEY CLUSTERED 
(
	[BillingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_Billing_CD]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_Billing_CD] ON [dbo].[Billing]
(
	[CreationDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [IX_Billing_CMI]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_Billing_CMI] ON [dbo].[Billing]
(
	[CreditedOutInd] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [IX_Billing_COI]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_Billing_COI] ON [dbo].[Billing]
(
	[CreditedOutInd] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [IX_Billing_DBID]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_Billing_DBID] ON [dbo].[Billing]
(
	[DATBillingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [IX_Billing_DP]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_Billing_DP] ON [dbo].[Billing]
(
	[DatePrinted] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [IX_Billing_ID]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_Billing_ID] ON [dbo].[Billing]
(
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Billing_IN]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_Billing_IN] ON [dbo].[Billing]
(
	[InvoiceNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Billing_IT]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_Billing_IT] ON [dbo].[Billing]
(
	[InvoiceType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [IX_Billing_PI]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_Billing_PI] ON [dbo].[Billing]
(
	[PrintedInd] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [IX_CustomerID]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_CustomerID] ON [dbo].[Billing]
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [IX_RunID]    Script Date: 8/31/2018 10:25:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_RunID] ON [dbo].[Billing]
(
	[RunID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
