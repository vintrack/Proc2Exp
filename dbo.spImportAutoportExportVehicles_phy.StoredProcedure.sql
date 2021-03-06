USE [AutoExport]
GO
/****** Object:  StoredProcedure [dbo].[spImportAutoportExportVehicles_phy]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Maibor
-- Create date: 6/27/17
-- Description:	Process Import table VINS for the specified batch for a Physical import.
--	Update existing recs in the Import and Veh. table
-- =============================================
CREATE PROCEDURE [dbo].[spImportAutoportExportVehicles_phy]
	@BatchID int,
	@UserCode varchar (20)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRY

	-- Create tbl variable, @tmp_output to hold all recs in the Import table for the batch. After processing,
	--	update the Import table RecordStatus,ImportedInd,ImportedBy,ImportedDate fields with the value in @tmp_output;
	--	for VINs where a single record also exists and DateShipped IS NULL in the veh table, 
	--	update the veh table rec, BayLocation, LastPhyBy, LastPhyDate
	-- NOTEs: 
	-- 1) For Physical imports; Yard operators scanned all veh's in yard for Inv. Comparison report 
	--		(only concerned w/VIN & BayLoc. Customer & Destination are NULL)

	-- 2) There may be multiple recs for the 
	--	same VIN (Yard operator scanned veh. more than once, or handheld malfunction)
	
	-- 3) Each scanned VIN may have 0/1/multiple recs in the veh table
	-- a) 'NOMATCH' status means scanned VIN is NOT in the veh table
	-- b) 'ONEMATCH' status means there is ONE rec in the veh table for the scanned VIN 
	-- c) 'MULTIPLE MATCHES FOR VIN' means there are multiple recs in the veh table for the scanned VIN 

	

	-- Need to update Import table with new status
	-- May need to update Veh table, if recs in @tmp_update

	-- Local Variables
	DECLARE
	@Bayloc_current varchar(20),
	@Bayloc_new varchar(20),
	@CreationDate Datetime = CURRENT_TIMESTAMP,
	@ID_dups int = 0,
	@ID_dups_current int,
	@ID_dups_max int,
	@ImportID_output_1stVIN int,
	@ImportID_dups_new int,
	@LastPhyby varchar(65),
	@VIN varchar(20);

	DECLARE
	@tmp_output TABLE
	(ImportID int,
	VIN varchar(17),
	status varchar(100),
	Inspector varchar(30),
	LastPhyBy varchar (65),
	importedind int,
	BayLocation varchar(20));

	-- Create tmp_dups, to hold 2nd, 3rd, ... scan of same VIN
	DECLARE
	@tmp_dups TABLE
	(ID int,
	ImportID int,
	VIN varchar(17),
	status varchar(100),
	Inspector varchar(30),
	LastPhyBy varchar (65),
	importedind int,
	BayLocation varchar(20));

	-- Fill @tmp_output with orig recs from import table for the Batch, include LastPhyBy (full name), 
	--	set status to 'INVALID INSPECTOR' is missing
	INSERT INTO @tmp_output (ImportID,VIN,Inspector,LastPhyBy,BayLocation,status)
	SELECT AutoportExportVehiclesImportID AS ImportID,
	VIN,
	Inspector,
	CASE
		WHEN Users.UserCode IS NULL THEN NULL
		ELSE RTRIM(Users.FirstName) + ' ' + RTRIM(Users.LastName)
	END AS LastPhyBy,
	BayLocation,
	CASE
		WHEN Users.UserCode IS NULL THEN 'INVALID INSPECTOR'
		ELSE NULL
	END AS status
	FROM AutoportExportVehiclesImport imp
	LEFT OUTER JOIN Users on Users.UserCode=imp.Inspector
	WHERE BatchID=@BatchID;

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

	-- Ck for 'SHOWS AS SHIPPED' if Veh import
	with shippedvehs AS
	(SELECT veh.VIN,COUNT(veh.VIN) AS totrecs
	FROM AutoportExportVehicles veh
	INNER JOIN @tmp_output tmp on tmp.VIN = veh.VIN 
	WHERE veh.DateShipped IS NOT NULL AND tmp.status IS NULL 
	GROUP BY veh.VIN 
	HAVING COUNT(tmp.VIN) > 0)
	UPDATE @tmp_output SET status = 'SHOWS AS SHIPPED',importedind=0
	WHERE VIN IN (SELECT VIN FROM shippedvehs);

	-- ID NOMATCH/ONEMATCH recs for Veh import
	
	-- ID 'ONEMATCH' recs, one rec w/same VIN in the veh table
	WITH single AS
	(SELECT veh.VIN,COUNT(veh.VIN) AS totrecs
	FROM AutoportExportVehicles veh 
	WHERE veh.VIN IN 
	(SELECT DISTINCT VIN FROM @tmp_output WHERE status IS NULL) 
	GROUP BY VIN
	HAVING COUNT(veh.VIN) = 1)
	UPDATE @tmp_output SET status = 'ONEMATCH'
	WHERE VIN in (SELECT VIN FROM single);

	-- ** ID NOMATCH recs **
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
	INSERT INTO @tmp_dups (ImportID,VIN,BayLocation,LastPhyBy)
	SELECT ImportID,VIN,BayLocation,LastPhyBy from 
	@tmp_output
	WHERE VIN IN (SELECT VIN FROM dupVINs)
	ORDER BY ImportID;

	-- Process dups, if any exist
	IF EXISTS (SELECT VIN FROM @tmp_dups)
	BEGIN
		-- Remove from @tmp_dups, 1st row for each VIN
		WITH CTE AS
		(SELECT *,ROW_NUMBER() OVER (PARTITION BY VIN ORDER BY VIN,ImportID) AS RN FROM @tmp_dups)
		DELETE FROM CTE WHERE RN=1;

		-- Update @tmp_output, set Status to NULL for each row in tmp_dups
		UPDATE @tmp_output SET status=NULL WHERE ImportID in (SELECT ImportID from @tmp_dups);

		-- Set ID values 1..n in @tmp_dups
		-- Update BOTH @id AND the ID column to @id + 1;
		UPDATE @tmp_dups 
		SET @ID_dups = ID = @ID_dups + 1;

		-- Set up Loop counters
		SET @ID_dups_current = 1;
		SELECT @ID_dups_max = MAX(ID) FROM @tmp_dups;

		-- Loop through each row in @tmp_dups & compare BayLoc with 1stVIN bayloc in @tmp_output
		-- If BayLocs are the same, set status as 'DUP VIN NO BAYLOC CHANGE', importedind=0
		-- If BayLocs differ, set BayLoc in 1st VIN rec in @tmp_output to new BayLoc, importedind=1, lastphyby new lastphyby
		--	in @tmp_dups. For the 
		WHILE @ID_dups_current <= @ID_dups_max
		BEGIN
			-- Get @ImportID_dups_new,@VIN, @Bayloc_new  from the current @tmp_dups row 
			SELECT 
			@ImportID_dups_new = ImportID,
			@VIN = RTRIM(VIN),
			@Bayloc_new=RTRIM(BayLocation),
			@LastPhyby = LastPhyBy 
			FROM @tmp_dups WHERE ID=@ID_dups_current;
					
			-- Get @ImportID_output_1stVIN, @Bayloc _current to 1st VIN rec in @tmp_output
			SELECT @ImportID_output_1stVIN = ImportID,
			@Bayloc_current = BayLocation
			FROM @tmp_output
			WHERE RTRIM(VIN) = @VIN AND status IN ('NOMATCH','ONEMATCH');

			IF @Bayloc_current <> @Bayloc_new
			BEGIN	-- #4
				-- Update current Bayloc, LastPhyby in @tmp_output for 1stVIN, leave status as NOMATCH/ONEMATCH
				UPDATE @tmp_output
				SET BayLocation = @Bayloc_new,
				LastPhyBy = @LastPhyby
				WHERE ImportID = @ImportID_output_1stVIN;
				
				-- Update status, importedind in @tmp_out for dup rec
				UPDATE @tmp_output
				SET status = 'BAY LOCATION UPDATED',
				importedind = 1
				WHERE ImportID = @ImportID_dups_new;
			END
			ELSE
			BEGIN
				-- Update status in @tmp_output
				UPDATE @tmp_output
				SET status = 'DUP VIN NO BAYLOC CHANGE',
				importedind = 0
				WHERE ImportID = @ImportID_dups_new;
			END	-- #4, IF @Bayloc_current <> @Bayloc_new
					
			-- Get next ImportID from tmp_dups
			SET @ID_dups_current = @ID_dups_current + 1;
		END -- WHILE loop
	END	-- IF EXISTS (SELECT VIN FROM @tmp_dups)
	
	-- Since more than one table may be updated, use TRAN to ensure all tables are updated
	BEGIN TRAN
		-- Update veh table for all VINs in @tmp_output w/status 'ONEMATCH'
		IF EXISTS (SELECT VIN FROM @tmp_output WHERE status = 'ONEMATCH')
		BEGIN
			UPDATE veh
			SET BayLocation = out.BayLocation,
			LastPhysicalBy = out.LastPhyBy,
			LastPhysicalDate = CURRENT_TIMESTAMP,
			UpdatedBy = @UserCode
			FROM AutoportExportVehicles veh
			INNER JOIN @tmp_output out on out.VIN = veh.VIN AND out.status='ONEMATCH';
		END
		
		-- Set status = 'BAY LOCATION UPDATED', importedind = 1 for all ONEMATCH/NOMATCH recs in @tmp_output
		UPDATE @tmp_output 
		SET status = 'BAY LOCATION UPDATED',
		importedind = 1
		WHERE status IN ('ONEMATCH','NOMATCH');

		-- Update import table from @tmp_import
		UPDATE imp
		SET imp.RecordStatus=out.status,
		imp.ImportedInd=out.importedind,
		imp.ImportedBy =
		CASE
			WHEN out.importedind = 1 THEN @UserCode
			ELSE NULL
		END,
		imp.ImportedDate = 
		CASE
			WHEN out.importedind = 1 THEN CURRENT_TIMESTAMP
			ELSE NULL
		END
		FROM AutoportExportVehiclesImport imp
		INNER JOIN @tmp_output out on out.ImportID=imp.AutoportExportVehiclesImportID
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
