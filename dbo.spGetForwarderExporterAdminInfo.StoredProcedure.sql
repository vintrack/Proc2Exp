USE [AutoExport]
GO
/****** Object:  StoredProcedure [dbo].[spGetForwarderExporterAdminInfo]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Maibor
-- Create date: 5/23/17
-- Description:	Return info to frmFreightForwarderAdmin/frmExporterAdmin in the AutoExport program 
--	Almost identical Forwarder,Exporter info returned. Identical location info returned.
-- =============================================
CREATE PROCEDURE [dbo].[spGetForwarderExporterAdminInfo]
	@type varchar(15),
	@ID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE
	@SQL varchar (max);

	-- Prepare SELECT for info from AEForwarder table
	IF @type = 'FORWARDER'
		SET @SQL = 'SELECT 
			ff.AECustomerID,
			ff.FreightForwarderName,
			RTRIM(ISNULL(ff.FreightForwarderShortName,'''')) AS FreightForwarderShortName,
			ff.FreightForwarderAddressID AS LocationID,ff.CustomerForwarderCode,
			ff.RecordStatus,ff.Notes,ff.CreationDate,ff.CreatedBy,
			ff.UpdatedDate,ff.UpdatedBy,';
	ELSE
		SET @SQL = 'SELECT
			ff.AECustomerID, 
			ex.AEFreightForwarderID,
			ex.AEExporterID,
			ex.ExporterName,
			RTRIM(ISNULL(ex.ExporterShortName,'''')) AS ExporterShortName,
			ex.ExporterAddressID AS LocationID,
			ex.CustomerExporterCode,
			ex.RecordStatus,ex.Notes,ex.CreationDate,ex.CreatedBy,
			ex.UpdatedDate,ex.UpdatedBy,';

	-- Add all the info from the Location table
	SET @SQL = @SQL +
		'RTRIM(ISNULL(loc.LocationName,'''')) AS LocationName,
		RTRIM(ISNULL(loc.LocationShortName,'''')) AS LocationShortName,
		RTRIM(ISNULL(loc.LocationType,'''')) AS LocationType,
		RTRIM(ISNULL(loc.LocationSubType,'''')) AS LocationSubType,
		RTRIM(ISNULL(loc.AddressLine1,'''')) AS AddressLine1,
		RTRIM(ISNULL(loc.AddressLine2,'''')) AS AddressLine2,
		RTRIM(ISNULL(loc.City,'''')) AS City ,
		RTRIM(ISNULL(loc.State,'''')) AS State,
		RTRIM(ISNULL(loc.Zip,'''')) AS Zip,
		RTRIM(ISNULL(loc.Country,'''')) AS Country,
		RTRIM(ISNULL(loc.MainPhone,'''')) AS MainPhone,
		RTRIM(ISNULL(loc.FaxNumber,'''')) AS FaxNumber,
		RTRIM(ISNULL(loc.PrimaryContactFirstName,'''')) AS PrimaryContactFirstName,
		RTRIM(ISNULL(loc.PrimaryContactLastName,'''')) AS PrimaryContactLastName,
		RTRIM(ISNULL(loc.PrimaryContactPhone,'''')) AS PrimaryContactPhone,
		RTRIM(ISNULL(loc.PrimaryContactExtension,'''')) AS PrimaryContactExtension,
		RTRIM(ISNULL(loc.PrimaryContactCellPhone,'''')) AS PrimaryContactCellPhone,
		RTRIM(ISNULL(loc.PrimaryContactEmail,'''')) AS PrimaryContactEmail,
		RTRIM(ISNULL(loc.AlternateContactFirstName,'''')) AS AlternateContactFirstName,
		RTRIM(ISNULL(loc.AlternateContactLastName,'''')) AS AlternateContactLastName,
		RTRIM(ISNULL(loc.AlternateContactPhone,'''')) AS AlternateContactPhone,
		RTRIM(ISNULL(loc.AlternateContactExtension,'''')) AS AlternateContactExtension,
		RTRIM(ISNULL(loc.AlternateContactCellPhone,'''')) AS AlternateContactCellPhone,
		RTRIM(ISNULL(loc.AlternateContactEmail,'''')) AS AlternateContactEmail,
		RTRIM(ISNULL(loc.OtherPhone1Description,'''')) AS OtherPhone1Description,
		RTRIM(ISNULL(loc.OtherPhone1,'''')) AS OtherPhone1,
		RTRIM(ISNULL(loc.OtherPhone2Description,'''')) AS OtherPhone2Description,
		RTRIM(ISNULL(loc.OtherPhone2,'''')) AS OtherPhone2 ';

	-- Add FROM, JOIN & WHERE clauses 
	IF @type = 'FORWARDER'
		SET @SQL = @SQL + 'FROM AEFreightForwarder ff 
			LEFT OUTER JOIN Location loc on loc.LocationID=ff.FreightForwarderAddressID
			WHERE ff.AEFreightForwarderID = ' + CAST(@ID AS varchar(5));
	ELSE
		SET @SQL = @SQL + 'FROM AEExporter ex 
			LEFT OUTER JOIN Location loc on loc.LocationID=ex.ExporterAddressID
			LEFT OUTER JOIN AEFreightForwarder ff on ff.AEFreightForwarderID = ex.AEFreightForwarderID
			WHERE ex.AEExporterID = ' + CAST(@ID AS varchar(5));

	EXEC(@SQL);

END
GO
