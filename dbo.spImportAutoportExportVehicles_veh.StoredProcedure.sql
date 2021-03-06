USE [AutoExport]
GO
/****** Object:  StoredProcedure [dbo].[spImportAutoportExportVehicles_veh]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Maibor
-- Create date: 6/27/17
-- Description:	Process recs in the Import table for the specified batch.
--	Update the Import table with new RecordStatus, ImportedInd, ImportedBy, ImportedDate
--	Insert new recs/Update existing recs in the AutoportExportVehicles table
--	Modifications
--	6/25/18: D.Maibor. Use ISNULL(when checking SizeClass) in dup vins, add (imported) to SIZE CLASS NEEDED
-- =============================================
-- =============================================
CREATE PROCEDURE [dbo].[spImportAutoportExportVehicles_veh]
	@BatchID int,
	@UserCode varchar (20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRY

	-- Create tbl variable, @tmp_output to hold all recs in the Import table for the batch. During processing,
	--	update fields in @tmp_output.
	--	When finished processing, update the Import table & insert new recs in the Veh table from @tmp_output
	-- NOTEs: 
	-- 1) There may be multiple recs for the same VIN
	--	 (Yard operator scanned veh. more than once, WIFI or handheld malfunction, etc.)
	
	-- 2) Primarily the Import table holds new VINs not in the veh tbl (set as NOMATCH recs)
	--	and updated VINS, one rec in the veh tbl (set as ONEMATCH recs)
	
	-- 3) Each scanned VIN may have 0/1/multiple recs in the veh table
	-- a) 'NOMATCH' status means scanned VIN is NOT in the veh table
	-- b) 'ONEMATCH' status means there is ONE rec in the veh table for the scanned VIN 
	-- c) 'MULTIPLE MATCHES FOR VIN' means there are multiple recs in the veh table for the scanned VIN 
	
	-- 4) BayLocation_imp, VIVTagNumber_imp are the BayLoc & VIVTag# entered by the User. For ONEMATCH VINs, 
	--	BayLocation_veh, VIVTagNumber_veh are the BayLoc & VIVTab# currently in the veh table

	DECLARE @debug bit = 0;

	-- Local Variables
	DECLARE
	@Bayloc_current varchar(20),
	@Bayloc_new varchar(20),
	@CreationDate Datetime = CURRENT_TIMESTAMP,
	@CustomerID_current int,
	@CustomerID_new int,
	@DUPCkDone bit,
	@DestinationName_current varchar (20),
	@DestinationName_new varchar (20),
	@ID_dups int = 0,
	@ID_dups_current int,
	@ID_dups_max int,
	@ImportID_output_1stVIN int,
	@ImportID_dups_new int,
	@LastPhyby varchar(65),
	@SizeClass_current varchar(20),
	@SizeClass_new varchar(20),
	@VIN varchar(20),
	@VIVTagNumber_current varchar(20),
	@VIVTagNumber_new varchar(20);
	
	DECLARE
	@tmp_output TABLE
	(ImportID int,
	VIN varchar(17),
	CustomerID int,
	DestinationName varchar(20),
	SizeClass varchar(20),
	VoyageID int,
	EntryRate decimal(19,2),
	PerDiemGraceDays int,
	status varchar(100),
	Inspector varchar(30),
	importedind int,
	BayLocation varchar(20),
	VIVTagNumber varchar(50));

	-- Create tmp_dups, to hold 2nd, 3rd, ... scan of same VIN
	DECLARE
	@tmp_dups TABLE
	(ID int,
	ImportID int,
	VIN varchar(17),
	CustomerID int,
	DestinationName varchar(20),
	SizeClass varchar(20),
	VoyageID int,
	EntryRate decimal(19,2),
	PerDiemGraceDays int,
	status varchar(100),
	Inspector varchar(30),
	importedind int,
	BayLocation varchar(20),
	VIVTagNumber varchar(50));

	-- Fill @tmp_output with orig recs from import table for the Batch
	INSERT INTO @tmp_output (ImportID,VIN,CustomerID,
	DestinationName,SizeClass,Inspector,BayLocation,
	VIVTagNumber)
	SELECT AutoportExportVehiclesImportID AS ImportID,
	imp.VIN,
	cus.CustomerID,
	imp.DestinationName,
	imp.SizeClass,
	imp.Inspector,
	imp.BayLocation,
	RTRIM(ISNULL(imp.VIVTagNumber,'')) AS VIVTagNumber
	FROM AutoportExportVehiclesImport imp
	LEFT OUTER JOIN Customer cus on cus.HandheldScannerCustomerCode=imp.CustomerName 
		AND cus.AutoportExportCustomerInd=1
	WHERE BatchID=@BatchID;

	-- Get fullname from Users table based on Inspector in @tmp_output
	-- Use for LastPhysicalBy & ReceivedBy in veh. table
	SELECT TOP 1 @LastPhyby = RTRIM(Users.FirstName) + ' ' + RTRIM(Users.LastName) 
	FROM @tmp_output tmp
	INNER JOIN Users on Users.UserCode=tmp.Inspector;

	-- ** ERROR CHECKING **

	-- Ck for 'SHOWS AS SHIPPED'
	with shippedvehs AS
	(SELECT veh.VIN,COUNT(veh.VIN) AS totrecs
	FROM AutoportExportVehicles veh
	INNER JOIN @tmp_output tmp on tmp.VIN = veh.VIN 
	WHERE veh.DateShipped IS NOT NULL 
	AND tmp.CustomerID=veh.CustomerID
	GROUP BY veh.VIN 
	HAVING COUNT(tmp.VIN) > 0)
	UPDATE @tmp_output SET status = 'SHOWS AS SHIPPED',importedind=0
	WHERE VIN IN (SELECT VIN FROM shippedvehs);

	-- Ck for 'CUSTOMER NOT FOUND' recs
	UPDATE tmp
	SET tmp.status = 'CUSTOMER NOT FOUND',importedind=0
	FROM
	@tmp_output tmp
	LEFT OUTER JOIN Customer cus on cus.CustomerID=tmp.CustomerID
	WHERE cus.CustomerID IS NULL AND tmp.status IS NULL;

	-- Ck for 'DESTINATION NOT FOUND' recs
	UPDATE tmp
	SET tmp.status = 'DESTINATION NOT FOUND',importedind=0
	FROM
	@tmp_output tmp
	LEFT OUTER JOIN Code on Code.CodeType='ExportDischargePort'
		AND Code.Value2=tmp.DestinationName
	WHERE Code.Value2 IS NULL AND tmp.status IS NULL;

	-- Ck for 'INSPECTOR NOT FOUND' recs
	UPDATE tmp
	SET tmp.status = 'INSPECTOR NOT FOUND',importedind=0
	FROM
	@tmp_output tmp
	LEFT OUTER JOIN Users on Users.UserCode=tmp.Inspector
	WHERE Users.UserCode IS NULL AND tmp.status IS NULL;

	-- Ck for 'MULTIPLE MATCHES' recs in veh table	
	WITH multi AS
	(SELECT veh.VIN,COUNT(veh.VIN) AS totrecs
	FROM AutoportExportVehicles veh 
	WHERE veh.VIN IN 
	(SELECT DISTINCT VIN FROM @tmp_output WHERE status IS NULL) 
	GROUP BY VIN
	HAVING COUNT(veh.VIN) > 1)
	UPDATE @tmp_output SET status = 'MULTIPLE MATCHES FOR VIN',importedind=0
	WHERE VIN in (SELECT VIN FROM multi);

	-- ** ID remaining recs as NOMATCH/ONEMATCH
	-- Ck for 'ONEMATCH' recs, one rec w/same VIN in the veh table
	WITH single AS
	(SELECT veh.VIN,COUNT(veh.VIN) AS totrecs
	FROM AutoportExportVehicles veh 
	WHERE veh.VIN IN 
	(SELECT DISTINCT VIN FROM @tmp_output WHERE status IS NULL) 
	GROUP BY VIN
	HAVING COUNT(veh.VIN) = 1)
	UPDATE @tmp_output SET status = 'ONEMATCH'
	WHERE VIN in (SELECT VIN FROM single);

	-- ** ERROR CHECKING FOR ONEMATCH recs **
	IF EXISTS (SELECT VIN FROM @tmp_output WHERE status = 'ONEMATCH')
	BEGIN
		-- Ck for 'CUSTOMER MISMATCH'
		UPDATE tmp
		SET status = 'CUSTOMER MISMATCH',importedind = 0
		FROM
		@tmp_output tmp
		INNER JOIN AutoportExportVehicles veh on veh.VIN=tmp.VIN
		WHERE tmp.status = 'ONEMATCH' AND tmp.CustomerID <> veh.CustomerID;

		-- Ck for 'DESTINATION MISMATCH'
		UPDATE tmp
		SET status = 'DESTINATION MISMATCH',importedind = 0
		FROM
		@tmp_output tmp
		INNER JOIN AutoportExportVehicles veh on veh.VIN=tmp.VIN
		WHERE tmp.status = 'ONEMATCH' AND veh.DestinationName <> tmp.DestinationName;
	END	-- if ONEMATCH recs in @tmp_output
	
	-- ** ID NOMATCH recs
	-- Update remaining recs as 'NOMATCH'
	UPDATE @tmp_output SET status = 'NOMATCH'
	WHERE status IS NULL;

	-- Load tmp_dups with any dup recs
	WITH dupVINs AS
	(select VIN,COUNT(VIN) AS totrecs 
	from @tmp_output 
	WHERE status IN ('NOMATCH','ONEMATCH')
	group by VIN
	Having COUNT(VIN) > 1)
	INSERT INTO @tmp_dups (ImportID,VIN,CustomerID,DestinationName,status,SizeClass,Baylocation,VIVTagNumber)
	SELECT ImportID,VIN,CustomerID,DestinationName,status,SizeClass,Baylocation,VIVTagNumber 
	FROM
	@tmp_output
	WHERE VIN IN (SELECT VIN FROM dupVINs)
	ORDER BY ImportID;

	-- Load dups into @tmp_dups, if any exist, change status in @tmp_output to NULL
	IF EXISTS (SELECT VIN FROM @tmp_dups)
	BEGIN
		-- Remove from @tmp_dups, 1st row for each VIN
		WITH CTE AS
		(SELECT *,ROW_NUMBER() OVER (PARTITION BY VIN ORDER BY VIN,ImportID) AS RN FROM @tmp_dups)
		DELETE FROM CTE WHERE RN=1;

		-- Update @tmp_output, set Status to NULL for each row in tmp_dups, so 1st VIN row can be ID'd
		UPDATE @tmp_output SET status=NULL WHERE ImportID in (SELECT ImportID from @tmp_dups);

		-- Set ID values 1..n in @tmp_dups
		-- Update BOTH @id AND the ID column to @id + 1;
		UPDATE @tmp_dups 
		SET @ID_dups = ID = @ID_dups + 1;

		-- In @tmp_output, the status for the 1st VIN of each rec to be processed is 'NOMATCH' or 'ONEMATCH'
		--	the status for all dup rows is NULL
		-- Loop through each row in @tmp_dups; ck CustomerID, DestinationName,BayLocation,VIVTagNumber
		--	If all values in dup row are the same as 1st VIN row in @tmp_output, set status to 'DUP VIN NO CHANGES'
		--  If CustomerID or DestinationName are different, set status to 'CUSTOMER MISMATCH' or ' DESTINATION MISMATCH'
		--	If 
		--	If BayLocation or VIVTagNumber are different, update 1st VIN rec w/new values & 
		--		set status of DUP rec to 'BAY LOCATION UPDATED'

		-- Initialize loop counters
		SET @ID_dups_current = 1;
		SELECT @ID_dups_max = MAX(ID) FROM @tmp_dups;

		WHILE @ID_dups_current <= @ID_dups_max
		BEGIN
			SET @DUPCkDone = 0;

			-- Get @ImportID_dups_new,@VIN, @CustomerID_new,@DestinationName_new
			--	@Bayloc_new,@VIVTagNumber_new,@SizeClass_new  from the current @tmp_dups row 
			SELECT 
			@ImportID_dups_new = ImportID,
			@VIN = RTRIM(VIN),
			@CustomerID_new = CustomerID,
			@DestinationName_new = DestinationName,
			@Bayloc_new=RTRIM(BayLocation),
			@VIVTagNumber_new=RTRIM(ISNULL(VIVTagNumber,'')),
			@SizeClass_new = ISNULL(SizeClass,'')
			FROM @tmp_dups WHERE ID=@ID_dups_current;
					
			-- Get @ImportID_output_1stVIN, @Bayloc _current,@VIVTagNumber_current,
			--	@SizeClass_current from 1st VIN rec in @tmp_output
			SELECT 
			@ImportID_output_1stVIN = ImportID,
			@CustomerID_current = CustomerID,
			@DestinationName_current = DestinationName,
			@Bayloc_current = BayLocation,
			@VIVTagNumber_current = RTRIM(ISNULL(VIVTagNumber,'')),
			@SizeClass_current = ISNULL(SizeClass,'')
			FROM @tmp_output
			WHERE RTRIM(VIN) = @VIN AND status IN ('NOMATCH','ONEMATCH');

			-- Ck if all values are the same
			IF @Bayloc_current = @Bayloc_new AND @CustomerID_current = @CustomerID_new AND
				@DestinationName_current = @DestinationName_new AND 
				@VIVTagNumber_current = @VIVTagNumber_new AND
				@SizeClass_current = @SizeClass_new
			BEGIN
				UPDATE @tmp_output 
				SET status = 'DUP VIN NO CHANGES', importedind = 0
				WHERE ImportID = @ImportID_dups_new;

				SET @DUPCkDone = 1;
			END

			-- Ck for CUSTOMER MISMATCH
			IF @DUPCkDone = 0 AND @CustomerID_current <> @CustomerID_new 
			BEGIN
				UPDATE @tmp_output 
				SET status = 'CUSTOMER MISMATCH', importedind = 0
				WHERE ImportID = @ImportID_dups_new;

				SET @DUPCkDone = 1;
			END

			-- Ck for DESTINATION MISMATCH
			IF @DUPCkDone = 0 AND @DestinationName_current <> @DestinationName_new 
			BEGIN
				UPDATE @tmp_output 
				SET status = 'DESTINATION MISMATCH', importedind = 0
				WHERE ImportID = @ImportID_dups_new;

				SET @DUPCkDone = 1;
			END

			-- Ck for SizeClass Update
			IF @DUPCkDone = 0 AND LEN(ISNULL(@SizeClass_current,'')) = 0 AND LEN(ISNULL(@SizeClass_new,'')) > 0
			BEGIN
				-- Update current SizeClass, leave status as NOMATCH/ONEMATCH
				UPDATE @tmp_output
				SET SizeClass = @SizeClass_new
				WHERE ImportID = @ImportID_output_1stVIN;

				-- Update status, importedind in @tmp_out for dup rec
				UPDATE @tmp_output
				SET status = 'SIZE CLASS UPDATED',
				importedind = 1
				WHERE ImportID = @ImportID_dups_new;
			END

			-- Ck if BayLoc and/orVIVTagNumber need update
			IF @DUPCkDone = 0 AND (@Bayloc_current <> @Bayloc_new OR 
				@VIVTagNumber_current <> @VIVTagNumber_new)
			BEGIN	-- #4
				-- Update current Bayloc, leave status as NOMATCH/ONEMATCH
				UPDATE @tmp_output
				SET BayLocation = @Bayloc_new,VIVTagNumber = @VIVTagNumber_new
				WHERE ImportID = @ImportID_output_1stVIN;
				
				-- Update status, importedind in @tmp_out for dup rec
				UPDATE @tmp_output
				SET status = 'BAY LOCATION UPDATED',
				importedind = 1
				WHERE ImportID = @ImportID_dups_new;
			END
			
			-- Get next ImportID from tmp_dups
			SET @ID_dups_current = @ID_dups_current + 1;
		END -- WHILE loop
	END	-- IF EXISTS (SELECT VIN FROM @tmp_dups)

	-- For NOMATCH recs in @tmp_output, Get VoyageID, EntryFee, PerDiemGraceDays, then Insert recs into veh table
	IF EXISTS (SELECT VIN FROM @tmp_output WHERE status='NOMATCH')
	BEGIN
		-- Update NOMATCH recs in @tmp_output with EntryRate, PerDiemGraceDays
			UPDATE tmp
			SET EntryRate=rates.EntryFee,
			PerDiemGraceDays = rates.PerDiemGraceDays
			FROM @tmp_output tmp
			INNER JOIN AutoportExportRates rates on rates.CustomerID=tmp.CustomerID AND
				rates.RateType = 'Size ' + tmp.SizeClass + ' Rate'
			WHERE tmp.status='NOMATCH' AND LEN(ISNULL(tmp.SizeClass,'')) > 0
				AND @CreationDate >= rates.StartDate
				AND @CreationDate < DATEADD(day,1,ISNULL(rates.EndDate,'12/31/2099'));

			-- Update NOMATCH recs in @tmp_output with VoyageID, if found
			-- Create @tmp_voyage to hold all voyageID for each ImportID
			DECLARE @tmp_voyage TABLE
			(ImportID int,
			CustomerID int,
			DestinationName varchar(100),
			AEVoyageID int,
			VoyageDate datetime);

			-- use CTE to fiLl @tmp_voyage
			WITH voyIDs AS	
			(SELECT tmp.ImportID,tmp.CustomerID,tmp.DestinationName, 
			voy.AEVoyageID,voy.VoyageDate
			FROM @tmp_output tmp
			LEFT OUTER JOIN Code on Code.CodeType='ExportDischargePort' AND Code.Value2=tmp.DestinationName
			LEFT OUTER JOIN AEVoyageCustomer voycust on voycust.CustomerID=tmp.CustomerID
			LEFT OUTER JOIN AEVoyageDestination voydest on voydest.AEVoyageID=voycust.AEVoyageID
			LEFT OUTER JOIN AEVoyage voy on voy.AEVoyageID=voycust.AEVoyageID
			WHERE tmp.status = 'NOMATCH' AND
			voydest.DestinationName=Code.Code AND
			voy.VoyageClosedInd = 0 AND 
			voy.VoyageDate >= CONVERT(varchar(10),CURRENT_TIMESTAMP,101))
			INSERT INTO @tmp_voyage SELECT * FROM voyIDs;

			-- use CTE to order ImportIDs by VoyageDate in @tmp_voyage, and remove all but 1st voyage 
			--	for each ImportID
			WITH voyorderd AS
			(SELECT *,ROW_NUMBER() OVER (PARTITION BY ImportID ORDER BY VoyageDate) AS RN FROM @tmp_voyage)
			DELETE FROM voyorderd WHERE RN>1;

			-- Update NOMATCH @tmp_output recs with VoyageID
			UPDATE out
			SET VoyageID = voy.AEVoyageID
			FROM @tmp_output out
			INNER JOIN @tmp_voyage voy on voy.ImportID=out.ImportID
			WHERE out.status = 'NOMATCH';

			-- Update status on NOMATCH recs to 'NEXT VOYAGE NOT FOUND' 
			--	IF VoyageID IS NULL
			UPDATE @tmp_output
			SET status = 'NEXT VOYAGE NOT FOUND'
			WHERE status = 'NOMATCH' AND VoyageID IS NULL;

			-- Insert NOMATCH recs in @tmp_output as new recs into veh table
			--	Use @CreationDate to permit Deleting new recs, if necessary in CATCH below
			INSERT INTO AutoportExportVehicles
			(CustomerID,VehicleYear,Make,Model,Bodystyle,
			VIN,Color,VehicleLength,VehicleWidth,
			VehicleHeight,
			VehicleWeight,VehicleCubicFeet,VehicleStatus,
			DestinationName,BookingNumber,SizeClass,
			BayLocation,EntryRate,EntryRateOverrideInd,
			PerDiemGraceDays,PerDiemGraceDaysOverrideInd,
			TotalCharge,DateReceived,BilledInd,VINDecodedInd,
			Note,RecordStatus,CreationDate,CreatedBy,CreditHoldInd,
			CustomsApprovalPrintedInd,VoyageID,
			CustomsCoverSheetPrintedInd,NoStartInd,
			LastPhysicalDate,HasAudioSystemInd,
			HasNavigationSystemInd,CustomsApprovedCoverSheetPrintedInd,
			ReceivedBy,LastPhysicalBy,BarCodeLabelPrintedInd,
			VIVTagNumber,MechanicalExceptionInd,LeftBehindInd)
			SELECT
			tmp.CustomerID,
			imp.VehicleYear,
			imp.Make,
			imp.Model,
			imp.Bodystyle,
			imp.VIN,
			imp.Color,
			imp.VehicleLength,
			imp.VehicleWidth,
			imp.VehicleHeight,
			imp.VehicleWeight,
			imp.VehicleCubicFeet,
			'Received' AS VehicleStatus,
			Code.Code AS DestinationName,
			'REC' AS BookingNumber,
			imp.SizeClass,
			imp.BayLocation,
			tmp.EntryRate,
			0 AS EntryRateOverrideInd,
			tmp.PerDiemGraceDays,
			0 AS PerDiemGraceDaysOverrideInd,
			0 AS TotalCharge,
			imp.CreationDate AS DateReceived,
			0 AS BilledInd,
			imp.VINDecodedInd,
			'' AS Note,
			'Active' AS RecordStatus,
			@CreationDate AS CreationDate,
			@UserCode AS CreatedBy,
			0 AS CreditHoldInd,
			0 AS CustomsApprovalPrintedInd,
			tmp.VoyageID,
			0 AS CustomsCoverSheetPrintedInd,
			CASE
				WHEN imp.RunnerInd = 0 THEN 1
				ELSE 0
			END AS NoStartInd,
			@CreationDate AS LastPhysicalDate,
			imp.AudioSystemFlag AS HasAudioSystemInd,
			imp.NavigationSystemFlag AS HasNavigationSystemInd,
			0 AS CustomsApprovedCoverSheetPrintedInd,
			@LastPhyby AS ReceivedBy,
			@LastPhyby AS LastPhysicalBy,
			0 AS BarCodeLabelPrintedInd,
			imp.VIVTagNumber,
			0 AS MechanicalExceptionInd,
			0 AS LeftBehindInd
			FROM @tmp_output tmp
			INNER JOIN AutoportExportVehiclesImport imp on imp.AutoportExportVehiclesImportID=tmp.ImportID
			LEFT OUTER JOIN Code on Code.CodeType='ExportDischargePort' AND Code.Value2=tmp.DestinationName
			WHERE tmp.status = 'NOMATCH';
	END  -- IF EXISTS (SELECT VIN FROM @tmp_output WHERE status='NOMATCH')

	-- Since more than one table may be updated, use TRAN to ensure all tables are updated
	BEGIN TRAN

		-- Update veh table for ONEMATCH recs
		IF EXISTS (SELECT VIN FROM @tmp_output WHERE status='ONEMATCH')
		BEGIN
			UPDATE veh
				SET BayLocation=tmp.BayLocation,
				SizeClass = tmp.status,
				DateReceived = @CreationDate,
				VehicleStatus = 'Received',
				LastPhysicalBy = @LastPhyby,
				LastPhysicalDate = @CreationDate
			FROM AutoportExportVehicles veh
			INNER JOIN @tmp_output tmp on tmp.VIN=veh.VIN
			WHERE tmp.status = 'ONEMATCH';
		END

	-- Set status = 'Imported' or SIZE CLASS NEEDED, importedind = 1 for all ONEMATCH/NOMATCH recs in @tmp_output
		UPDATE @tmp_output 
		SET status = 
		CASE
			WHEN LEN(ISNULL(SizeClass,'')) > 0 THEN 'Imported'
			ELSE 'SIZE CLASS NEEDED (Imported)'
		END,
		importedind = 1
		WHERE status IN ('ONEMATCH','NOMATCH');

		-- Update import table from @tmp_import
		UPDATE imp
		SET imp.RecordStatus=tmp.status,
		imp.ImportedInd=tmp.importedind,
		imp.ImportedBy =
		CASE
			WHEN tmp.importedind = 1 THEN @UserCode
			ELSE NULL
		END,
		imp.ImportedDate = 
		CASE
			WHEN tmp.importedind = 1 THEN @CreationDate
			ELSE NULL
		END
		FROM AutoportExportVehiclesImport imp
		INNER JOIN @tmp_output tmp on tmp.ImportID=imp.AutoportExportVehiclesImportID
		WHERE imp.BatchID = @BatchID;
	END TRY

	-- Based on Microsoft example: 
	-- https://docs.microsoft.com/en-us/sql/t-sql/language-elements/try-catch-transact-sql
	BEGIN CATCH
		IF @@TRANCOUNT > 0  ROLLBACK TRAN;

		SELECT
		'ERROR' AS result,
		ERROR_NUMBER() AS ErrorNumber,
		ERROR_SEVERITY() AS ErrorSeverity,
		ERROR_STATE() AS ErrorState,
		ERROR_PROCEDURE() AS ErrorProcedure,
		ERROR_LINE() AS ErrorLine,
		ERROR_MESSAGE() AS ErrorMessage;
	END CATCH

	IF @@TRANCOUNT > 0 
	BEGIN
		COMMIT TRAN;	
		SELECT 'OK' AS result;
	END
END
GO
