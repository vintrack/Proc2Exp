USE [AutoExport]
GO
/****** Object:  StoredProcedure [dbo].[spUpdateForwarderExporter]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Maibor
-- Create date: 5/22/17
-- Description:	Update FreightForwarder or Exporter info based on parameters
-- @type: FORWARDER or EXPORTER, primary table to update
-- @action: NEW/MODIFY/[blank] no action on primary table
-- @loc_action: NEW/MODIFY/DELETE/[blank] no action
-- @ID: Forwarder or Exporter ID 
-- @primarySQL/locSQL: SQL to update the Forwarder/Exporter (if applicable) & Location table (if applicable)
-- @CreationDate: CreationDate used in NEW actions, so easy to update new recs, & delete new recs, if error encountererd, without a TRAN
-- @CreatedBy: Createdby to ensure correct record retrieved for new recs
-- Use TRAN for Update/Delete actions, to allow Rollback if error
-- Perform primary/loc action and return result: OK or ERROR

-- 1/11/18 D.Maibor: Update @locSQL with new Freight Forwarder ID, if new loc.
-- =============================================
CREATE PROCEDURE [dbo].[spUpdateForwarderExporter]
	@type varchar(15),
	@action varchar(10),
	@loc_action varchar(10),
	@ID int,
	@primarySQL varchar(max),
	@locSQL varchar(max),
	@locID int,
	@CreationDate DateTime,
	@CreatedBy varchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE 
	@newID int = 0,
	@newLocID int = 0,
	@SQLCommand varchar (2000);

	-- ##### INITIAL SET UP #####
	BEGIN TRY	
		-- If necessary, insert new recs in Primary & Location tables.
		-- Don't need TRAN. Can delete, if necessary, by new IDs
		if @action = 'NEW'
		BEGIN
			-- Run SQL to insert new rec in Customer table
			EXEC(@primarySQL);

			-- Store in @newID new ID created
			IF @type = 'FORWARDER'
				SELECT @newID = AEFreightForwarderID  FROM AEFreightForwarder
				WHERE CreatedBy = @CreatedBy AND CreationDate = @CreationDate;
			ELSE
				SELECT @newID = AEExporterID  FROM AEExporter
				WHERE CreatedBy = @CreatedBy AND CreationDate = @CreationDate;
		END

		IF @loc_action = 'NEW' 
		BEGIN
				-- Replace ~ in @locSQL with @newID
				SET @locSQL = REPLACE(@locSQL,'~',@newID);

				-- Insert new rec in Location
				EXEC(@locSQL);

				-- Get new LocID
				SELECT @newLocID = LocationID FROM Location 
					WHERE CreatedBy = @CreatedBy AND CreationDate = @CreationDate;
		END
	END TRY

	-- Based on Microsoft example: 
	-- https://docs.microsoft.com/en-us/sql/t-sql/language-elements/try-catch-transact-sql
	BEGIN CATCH
		SELECT
		'ERROR in INITIAL SET UP' AS result,
		ERROR_NUMBER() AS ErrorNumber,
		ERROR_SEVERITY() AS ErrorSeverity,
		ERROR_STATE() AS ErrorState,
		ERROR_PROCEDURE() AS ErrorProcedure,
		ERROR_LINE() AS ErrorLine,
		ERROR_MESSAGE() AS ErrorMessage;

		-- Delete any new Forwarder/Exporter recs inserted
		IF @action='NEW' 
		BEGIN
			IF @type = 'FORWARDER'
				DELETE AEFreightForwarder WHERE AEFreightForwarderid = @newID;
			ELSE
				DELETE AEExporter WHERE AEExporterID = @newID;
		END
		
		IF @loc_action='NEW' DELETE Location WHERE LocationID = @newLocID;

		RETURN;
	END CATCH

	-- ##### NEW FORWARDER/EXPORTER #####
	-- No TRAN, only new recs created
	-- Just need to update Address ID links between Primary & Location tables
	IF @action = 'NEW'
	BEGIN

		BEGIN TRY
			IF @loc_action = 'NEW' 
			BEGIN
				UPDATE Location SET ParentRecordID = @newID WHERE LocationID=@newLocID;
				
				IF @type = 'FORWARDER'
					UPDATE AEFreightForwarder SET FreightForwarderAddressID = @newLocID WHERE AEFreightForwarderID=@newID;
				ELSE
					UPDATE AEExporter SET ExporterAddressID = @newLocID WHERE AEExporterID=@newID;
			END

			SELECT 'OK' AS result;
			RETURN;
		END TRY

		BEGIN CATCH
			SELECT
			'ERROR in NEW CUSTOMER' AS result,
			ERROR_NUMBER() AS ErrorNumber,
			ERROR_SEVERITY() AS ErrorSeverity,
			ERROR_STATE() AS ErrorState,
			ERROR_PROCEDURE() AS ErrorProcedure,
			ERROR_LINE() AS ErrorLine,
			ERROR_MESSAGE() AS ErrorMessage;

			-- Remove new recs
			IF @type = 'FORWARDER'
				DELETE AEFreightForwarder WHERE AEFreightForwarderid = @newID;
			ELSE
				DELETE AEExporter WHERE AEExporterID = @newID;

			-- Delete new Location rec inserted by CreationDate
			IF @loc_action='NEW' DELETE Location WHERE LocationID = @newLocID;			

			RETURN;
		END CATCH
	END	-- IF @action = NEW

	---- ### MODIFY SECTION ### 	
	-- Need to modify Forwarder/Exportere rec, & may need to modify/delete Location recs
	-- Use TRAN to allow Rollback
	IF @action = 'MODIFY'
	BEGIN
		BEGIN TRY
		
		BEGIN TRAN
			
			-- Make change to Customer table
			EXEC(@primarySQL);
			
			-- Perform any Addr action required
			IF LEN(@loc_action) > 0
			BEGIN
				IF @loc_action = 'NEW' 
				BEGIN
					UPDATE Location SET ParentRecordID = @ID WHERE LocationID=@newLocID;
				
					IF @type = 'FORWARDER'
						UPDATE AEFreightForwarder SET FreightForwarderAddressID = @newLocID WHERE AEFreightForwarderID=@ID;
					ELSE
						UPDATE AEExporter SET ExporterAddressID = @newLocID WHERE AEExporterID=@ID;
				END

				IF @loc_action = 'MODIFY' EXEC(@locSQL);

				IF @loc_action = 'DELETE' 
				BEGIN
					-- Run SQL to delete Location rec
					EXEC(@locSQL);

					-- Update AddressID in Primary table to NULL
					IF @type = 'FORWARDER'
						UPDATE AEFreightForwarder SET FreightForwarderAddressID = NULL WHERE AEFreightForwarderID=@ID;
					ELSE
						UPDATE AEExporter SET ExporterAddressID = NULL WHERE AEExporterID=@ID;
				END
			END	-- IF LEN(@loc_action > 0
		END TRY

		BEGIN CATCH
			SELECT
			'ERROR in MODIFY CUSTOMER' AS result,
			ERROR_NUMBER() AS ErrorNumber,
			ERROR_SEVERITY() AS ErrorSeverity,
			ERROR_STATE() AS ErrorState,
			ERROR_PROCEDURE() AS ErrorProcedure,
			ERROR_LINE() AS ErrorLine,
			ERROR_MESSAGE() AS ErrorMessage;

			IF @@TRANCOUNT > 0 ROLLBACK TRAN;

			-- Delete any new Location recs inserted by CreationDate
			IF @loc_action='NEW' DELETE Location WHERE LocationID = @newLocID;

			RETURN;
		END CATCH		

		IF @@TRANCOUNT > 0 COMMIT TRAN;		
		SELECT 'OK' AS result;

		RETURN;
	END  -- IF @action = 'MODIFY'

	---- ### ONLY ADDRESS SECTION change ### 
	IF @action = ''
	BEGIN
		BEGIN TRY
		BEGIN TRAN
		
		IF @loc_action = 'NEW'
		BEGIN
			UPDATE Location SET ParentRecordID = @ID WHERE LocationID=@newLocID;
				
			IF @type = 'FORWARDER'
				UPDATE AEFreightForwarder SET FreightForwarderAddressID = @newLocID WHERE AEFreightForwarderID=@ID;
			ELSE
				UPDATE AEExporter SET ExporterAddressID = @newLocID WHERE AEExporterID=@ID;
		END

		IF @loc_action = 'MODIFY'
				EXEC (@locSQL);

		IF @loc_action = 'DELETE' 
		BEGIN
			-- Run SQL to delete Location rec
			EXEC(@locSQL);

			-- Update AddressID in Primary table to NULL
			IF @type = 'FORWARDER'
				UPDATE AEFreightForwarder SET FreightForwarderAddressID = NULL WHERE AEFreightForwarderID=@ID;
			ELSE
				UPDATE AEExporter SET ExporterAddressID = NULL WHERE AEExporterID=@ID;
		END		
		END TRY

		BEGIN CATCH
		SELECT
		'ERROR in ONLY ADDR CHANGE' AS result,
		ERROR_NUMBER() AS ErrorNumber,
		ERROR_SEVERITY() AS ErrorSeverity,
		ERROR_STATE() AS ErrorState,
		ERROR_PROCEDURE() AS ErrorProcedure,
		ERROR_LINE() AS ErrorLine,
		ERROR_MESSAGE() AS ErrorMessage;

		IF @@TRANCOUNT > 0 ROLLBACK TRAN;

		-- Delete any new Location recs inserted by CreationDate
		IF @loc_action='NEW' DELETE Location WHERE LocationID = @newLocID;
		
		RETURN;
		END CATCH
	
	IF @@TRANCOUNT > 0 COMMIT TRAN;
	SELECT 'OK' AS result;
	
	END	-- IF @customeraction = ''
END
GO
