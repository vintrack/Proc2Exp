USE [AutoExport]
GO
/****** Object:  StoredProcedure [dbo].[spGetCustomerAdminInfo]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Maibor
-- Create date: 5/9/17
-- Description:	Retrieve Customer Admin info for the CustomerID passed in
-- Return info to frmCustomerAdmin in the AutoExport program 
-- =============================================
CREATE PROCEDURE [dbo].[spGetCustomerAdminInfo]
	@CustomerID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
SELECT 
cus.CustomerCode,
cus.CustomerName,
cus.DBAName,
cus.ShortName,
cus.CustomerType,
cus.CustomerOf,
cus.MainAddressID,
cus.BillingAddressID,
RTRIM(ISNULL(loc_b.LocationName,'')) AS LocationName_b,
RTRIM(ISNULL(loc_b.LocationShortName,'')) AS LocationShortName_b,
RTRIM(ISNULL(loc_b.LocationType,'')) AS LocationType_b,
RTRIM(ISNULL(loc_b.LocationSubType,'')) AS LocationSubType_b,
RTRIM(ISNULL(loc_b.AddressLine1,'')) AS AddressLine1_b,
RTRIM(ISNULL(loc_b.AddressLine2,'')) AS AddressLine2_b,
RTRIM(ISNULL(loc_b.City,'')) AS City_b ,
RTRIM(ISNULL(loc_b.State,'')) AS State_b,
RTRIM(ISNULL(loc_b.Zip,'')) AS Zip_b,
RTRIM(ISNULL(loc_b.Country,'')) AS Country_b,
RTRIM(ISNULL(loc_b.MainPhone,'')) AS MainPhone_b,
RTRIM(ISNULL(loc_b.FaxNumber,'')) AS FaxNumber_b,
RTRIM(ISNULL(loc_b.PrimaryContactFirstName,'')) AS PrimaryContactFirstName_b,
RTRIM(ISNULL(loc_b.PrimaryContactLastName,'')) AS PrimaryContactLastName_b,
RTRIM(ISNULL(loc_b.PrimaryContactPhone,'')) AS PrimaryContactPhone_b,
RTRIM(ISNULL(loc_b.PrimaryContactExtension,'')) AS PrimaryContactExtension_b,
RTRIM(ISNULL(loc_b.PrimaryContactCellPhone,'')) AS PrimaryContactCellPhone_b,
RTRIM(ISNULL(loc_b.PrimaryContactEmail,'')) AS PrimaryContactEmail_b,
RTRIM(ISNULL(loc_b.AlternateContactFirstName,'')) AS AlternateContactFirstName_b,
RTRIM(ISNULL(loc_b.AlternateContactLastName,'')) AS AlternateContactLastName_b,
RTRIM(ISNULL(loc_b.AlternateContactPhone,'')) AS AlternateContactPhone_b,
RTRIM(ISNULL(loc_b.AlternateContactExtension,'')) AS AlternateContactExtension_b,
RTRIM(ISNULL(loc_b.AlternateContactCellPhone,'')) AS AlternateContactCellPhone_b,
RTRIM(ISNULL(loc_b.AlternateContactEmail,'')) AS AlternateContactEmail_b,
RTRIM(ISNULL(loc_b.OtherPhone1Description,'')) AS OtherPhone1Description_b,
RTRIM(ISNULL(loc_b.OtherPhone1,'')) AS OtherPhone1_b,
RTRIM(ISNULL(loc_b.OtherPhone2Description,'')) AS OtherPhone2Description_b,
RTRIM(ISNULL(loc_b.OtherPhone2,'')) AS OtherPhone2_b,
RTRIM(ISNULL(loc_s.LocationName,'')) AS LocationName_s,
RTRIM(ISNULL(loc_s.LocationShortName,'')) AS LocationShortName_s,
RTRIM(ISNULL(loc_s.LocationType,'')) AS LocationType_s,
RTRIM(ISNULL(loc_s.LocationSubType,'')) AS LocationSubType_s,
RTRIM(ISNULL(loc_s.AddressLine1,'')) AS AddressLine1_s,
RTRIM(ISNULL(loc_s.AddressLine2,'')) AS AddressLine2_s,
RTRIM(ISNULL(loc_s.City,'')) AS City_s,
RTRIM(ISNULL(loc_s.State,'')) AS State_s,
RTRIM(ISNULL(loc_s.Zip,'')) AS Zip_s,
RTRIM(ISNULL(loc_s.Country,'')) AS Country_s,
RTRIM(ISNULL(loc_s.MainPhone,'')) AS MainPhone_s,
RTRIM(ISNULL(loc_s.FaxNumber,'')) AS FaxNumber_s,
RTRIM(ISNULL(loc_s.PrimaryContactFirstName,'')) AS PrimaryFName_s,
RTRIM(ISNULL(loc_s.PrimaryContactLastName,'')) AS PrimaryLName_s,
RTRIM(ISNULL(loc_s.PrimaryContactPhone,'')) AS PrimaryContactPhone_s,
RTRIM(ISNULL(loc_s.PrimaryContactExtension,'')) AS PrimaryContactExt_s,
RTRIM(ISNULL(loc_s.PrimaryContactCellPhone,'')) AS PrimaryContactCell_s,
RTRIM(ISNULL(loc_s.PrimaryContactEmail,'')) AS PrimaryContactEmail_s,
RTRIM(ISNULL(loc_s.AlternateContactFirstName,'')) AS AlternateFName_s,
RTRIM(ISNULL(loc_s.AlternateContactLastName,'')) AS AlternateLName_s,
RTRIM(ISNULL(loc_s.AlternateContactPhone,'')) AS AlternateContactPhone_s,
RTRIM(ISNULL(loc_s.AlternateContactExtension,'')) AS AlternateContactExt_s,
RTRIM(ISNULL(loc_s.AlternateContactCellPhone,'')) AS AlternateContactCell_s,
RTRIM(ISNULL(loc_s.AlternateContactEmail,'')) AS AlternateContactEmail_s,
RTRIM(ISNULL(loc_s.OtherPhone1Description,'')) AS OtherPhone1Description_s,
RTRIM(ISNULL(loc_s.OtherPhone1,'')) AS OtherPhone1_s,
RTRIM(ISNULL(loc_s.OtherPhone2Description,'')) AS OtherPhone2Description_s,
RTRIM(ISNULL(loc_s.OtherPhone2,'')) AS OtherPhone2_s,
cus.DefaultBillingMethod,
cus.RecordStatus,
cus.SendEmailConfirmationsInd,
cus.BookingNumberPrefix,
cus.HandheldScannerCustomerCode,
cus.InternalComment,
cus.CreationDate,
cus.CreatedBy,
cus.UpdatedDate,
cus.UpdatedBy
FROM Customer cus
LEFT OUTER JOIN Location loc_b on loc_b.LocationID=cus.BillingAddressID
LEFT OUTER JOIN Location loc_s on loc_s.LocationID=cus.MainAddressID
WHERE cus.CustomerID = @CustomerID


END
GO
