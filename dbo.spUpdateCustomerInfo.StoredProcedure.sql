USE [AutoExport]
GO
/****** Object:  StoredProcedure [dbo].[spUpdateCustomerInfo]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Maibor
-- Create date: 5/11/17
-- Description:	Update Customer, Location, Rates tables based on parameters
-- @customerSQL/locbillingSQL/loc_streetSQL: SQL to update the Customer (if applicable) & Location table (if applicable)
-- @customeraction: NEW/MODIFY/[blank] no action
-- @loc_billing_action: NEW/MODIFY/DELETE/[blank] no action
-- @loc_street_action: NEW/MODIFY/DELETE/SAME (as BillingAddr)/[blank] no action
-- @tmpRateTable: if not blank, delete Rates in AutoportExportRates for @CustomerID, then insert rates from @tmpRateTable
-- @CustomerID: 
-- @CreationDate: CreationDate used in NEW actions, so easy to update new recs, & delete new recs, if error encountererd, without a TRAN
-- @CreatedBy: Createdby to ensure correct record retrieved for new recs
-- Use TRAN for Update/Delete actions, to allow Rollback if error
-- Perform customer/loc action and return result: OK or ERROR
-- =============================================
CREATE PROCEDURE [dbo].[spUpdateCustomerInfo] 
	@customeraction varchar(10) = '',
	@customerSQL varchar(max) = '',
	@loc_billing_action varchar(10) = '',
	@loc_billingSQL varchar(max) = '',
	@loc_street_action varchar(10) = '',
	@loc_streetSQL varchar(max) = '',
	@Rate_action varchar(10),
	@tmpRateTable varchar (50),
	@CustomerID int,
	@CreationDate DateTime,
	@CreatedBy varchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE 
	@newCustomerID int = 0,
	@newLocBillingID int = 0,
	@newLocStreetID int = 0,
	@SQLCommand varchar (2000),
	@SQLRemovetmp varchar (200) = 'DROP TABLE ' + @tmpRateTable;

	-- ##### INITIAL SET UP #####
	BEGIN TRY	
		-- If necessary, insert new recs in Customer & Location tables.
		-- Don't need TRAN. Can delete, if necessary, by new IDs
		if @customeraction = 'NEW'
		BEGIN
			-- Run SQL to insert new rec in Customer table
			EXEC(@CustomerSQL);

			-- Store in @newCustomerID new ID created
			SELECT @newCustomerID = CustomerID  FROM Customer
				WHERE CreatedBy = @CreatedBy AND CreationDate = @CreationDate;

			-- If @tmpRateTable exists, update CustomerID with @newCustomerID
			IF LEN(@tmpRateTable) > 0
			BEGIN
				SET @SQLCommand = 'UPDATE ' + @tmpRateTable + ' SET CustomerID = ' + 
				CAST(@newCustomerID AS varchar(7));
				EXEC(@SQLCommand);
			END
		END

		IF @loc_billing_action = 'NEW' 
		BEGIN
				-- Insert new rec in Location
				EXEC(@loc_billingSQL);

				-- Get new LocID
				SELECT @newLocBillingID = LocationID FROM Location 
					WHERE LocationType ='BillingAddress' AND CreatedBy = @CreatedBy AND CreationDate = @CreationDate;
		END

		IF @loc_street_action = 'NEW' 
		BEGIN
				-- Insert new rec in Location
				EXEC(@loc_streetSQL);

				-- Get new LocID
				SELECT @newLocStreetID = LocationID FROM Location 
					WHERE LocationType ='Street Address' AND CreatedBy = @CreatedBy AND CreationDate = @CreationDate;
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

		-- Delete any new Location recs inserted
		IF @customeraction='NEW' DELETE Customer WHERE CustomerID = @newCustomerID;
		IF @loc_billing_action='NEW' DELETE Location WHERE LocationID = @newLocBillingID;
		IF @loc_street_action='NEW' DELETE Location WHERE LocationID = @newLocStreetID;

		-- Remove @tmpRateTable
		IF @Rate_action = 'ADD' EXEC(@SQLRemovetmp);

		RETURN;
	END CATCH

	-- ##### NEW CUSTOMER #####
	-- No TRAN, only new recs created
	-- Just need to update Address ID links between Customer & Location tables
	IF @customeraction = 'NEW'
	BEGIN

		BEGIN TRY
			-- Link Customer/Location tables for new Billing loc, if required
			IF @loc_billing_action = 'NEW' 
			BEGIN
				UPDATE Customer SET BillingAddressID = @newLocBillingID WHERE CustomerID=@newCustomerID;
				UPDATE Location SET ParentRecordID = @newCustomerID WHERE LocationID=@newLocBillingID;
			END
		
			-- Link Customer/Location tables for new Street loc, if required
			IF @loc_street_action = 'NEW'
			BEGIN
				UPDATE Customer SET MainAddressID = @newLocStreetID WHERE CustomerID = @newCustomerID;
				UPDATE Location SET ParentRecordID = @newCustomerID WHERE LocationID = @newLocStreetID;
			END
		
			-- Set MainAddressID to BillingAddressID in Customer table if required
			IF @loc_street_action = 'SAME' UPDATE Customer SET MainAddressID = BillingAddressID WHERE CustomerID = @newCustomerID;

			-- If new Rates, Insert them into the AutoportExportRates table
			IF @Rate_action = 'ADD'
			BEGIN
				SET @SQLCommand = 'INSERT INTO AutoportExportRates (CustomerID,EntryFee,PerDiem,
					PerDiemGraceDays,StartDate,EndDate,CreationDate,CreatedBy,RateType)
					SELECT CustomerID,EntryFee,PerDiem,
					PerDiemGraceDays,StartDate,EndDate,CreationDate,CreatedBy,RateType
					FROM ' + @tmpRateTable;
				EXEC(@SQLCommand);
			END

			-- Remove @tmpRateTable
			IF @Rate_action = 'ADD' EXEC(@SQLRemovetmp);

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
			DELETE Customer WHERE CustomerID=@newCustomerID;

			-- Delete any new Location recs inserted by CreationDate
			IF @loc_billing_action='NEW' DELETE Location WHERE LocationID = @newLocBillingID;
			IF @loc_street_action='NEW' DELETE Location WHERE LocationID = @newLocStreetID;

			-- Remove @tmpRateTable
			IF @Rate_action = 'ADD' EXEC(@SQLRemovetmp);

			RETURN;
		END CATCH
	END

	---- ### MODIFY SECTION ### 	
	-- Need to modify Customer rec, & may need to modify/delete Location recs
	-- Use TRAN to allow Rollback
	IF @customeraction = 'MODIFY'
	BEGIN
		BEGIN TRY
		
		BEGIN TRAN
			
			-- Make change to Customer table
			EXEC(@customerSQL);
			
			-- Perform any Billing action required
			IF LEN(@loc_billing_action) > 0
			BEGIN
				IF @loc_billing_action = 'NEW' UPDATE Customer SET BillingAddressID = @newLocBillingID
					WHERE CustomerID = @CustomerID;

				IF @loc_billing_action = 'MODIFY' EXEC(@loc_billingSQL);

				IF @loc_billing_action = 'DELETE' 
				BEGIN
					-- Run SQL to delete Location rec
					EXEC(@loc_billingSQL);

					-- If MainAddressID = BillingAddressID in Customer table, set MainAddressID to NULL
					IF EXISTS (SELECT MainAddressID FROM Customer 
						WHERE CustomerID = @CustomerID AND
						MainAddressID = BillingAddressID) 
						UPDATE Customer SET MainAddressID = NULL WHERE CustomerID = @CustomerID;

					-- Set BillingAddress to NULL in Customer table
					UPDATE Customer SET BillingAddressID = NULL WHERE CustomerID = @CustomerID;
				END
			END	-- IF LEN(@loc_billing_action > 0

			-- Perform any Street action required
			IF LEN(@loc_street_action) > 0
			BEGIN
				IF @loc_street_action = 'NEW' UPDATE Customer SET MainAddressID = @newLocStreetID
					WHERE CustomerID = @CustomerID;

				IF @loc_street_action = 'MODIFY' EXEC(@loc_billingSQL);

				-- Update Customer table MainAddressID, if same
				IF @loc_street_action = 'SAME' UPDATE Customer SET MainAddressID = 
						BillingAddressID WHERE CustomerID=@CustomerID;

				IF @loc_street_action = 'RESET' EXEC(@loc_billingSQL);

				IF @loc_street_action = 'DELETE' 
				BEGIN
					EXEC(@loc_billingSQL);
					UPDATE Customer SET MainAddressID = NULL WHERE CustomerID=@CustomerID;
				END
			END	-- IF LEN(@loc_street_action) > 0

			-- If there is a Rate action, Delete current Rates. If action='ADD', insert new rates
			IF LEN(@Rate_action) > 0
			BEGIN
				DELETE AutoportExportRates WHERE CustomerID = @CustomerID;

				IF @Rate_action = 'ADD'
				BEGIN
					SET @SQLCommand = 'INSERT INTO AutoportExportRates (CustomerID,EntryFee,PerDiem,
					PerDiemGraceDays,StartDate,EndDate,CreationDate,CreatedBy,RateType)
					SELECT CustomerID,EntryFee,PerDiem,
					PerDiemGraceDays,StartDate,EndDate,CreationDate,CreatedBy,RateType
					FROM ' + @tmpRateTable;
					EXEC(@SQLCommand);
				END
				
			END
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
			IF @loc_billing_action='NEW' DELETE Location WHERE LocationID = @newLocBillingID;
			IF @loc_street_action='NEW' DELETE Location WHERE LocationID = @newLocStreetID;

			-- Remove @tmpRateTable
			IF @Rate_action = 'ADD' EXEC(@SQLRemovetmp);

			RETURN;
		END CATCH		

		IF @@TRANCOUNT > 0 COMMIT TRAN;
		
		-- Remove @tmpRateTable
		IF @Rate_action = 'ADD' EXEC(@SQLRemovetmp);
		
		SELECT 'OK' AS result;

		RETURN;
	END  -- IF Customeraction = 'MODIFY'
	
	---- ### ONLY ADDRESS SECTION change ### 
	IF @customeraction = ''
	BEGIN
		BEGIN TRY
		BEGIN TRAN
		
		IF @loc_billing_action = 'NEW'
			UPDATE Customer SET BillingAddressID = @newLocBillingID WHERE CustomerID=@CustomerID;

		IF @loc_billing_action = 'MODIFY'
				EXEC (@loc_billingSQL);

		IF @loc_billing_action = 'DELETE' 
		BEGIN
			-- Run SQL to delete Location rec
			EXEC(@loc_billingSQL);

			-- If MainAddressID = BillingAddressID in Customer table, set MainAddressID to NULL
			IF EXISTS (SELECT MainAddressID FROM Customer 
				WHERE CustomerID = @CustomerID AND
				MainAddressID = BillingAddressID) 
				UPDATE Customer SET MainAddressID = NULL WHERE CustomerID = @CustomerID;

			-- Set BillingAddress to NULL in Customer table
			UPDATE Customer SET BillingAddressID = NULL WHERE CustomerID = @CustomerID;
		END

		IF @loc_street_action = 'NEW' UPDATE Customer SET MainAddressID = @newLocStreetID,
			UpdatedBy=@CreatedBy,UpdatedDate = @CreationDate
			WHERE CustomerID = @CustomerID;

		IF @loc_street_action = 'MODIFY' EXEC(@loc_streetSQL);

		-- Update Customer table MainAddressID = BillingAddressID, if same. Delete Street LocID, if exists.
		IF @loc_street_action = 'SAME' 
		BEGIN
			-- If MainAddressID exists in Customer, DELETE from Location
			SELECT @newLocStreetID = MainAddressID FROM Customer WHERE CustomerID=@CustomerID AND MainAddressID IS NOT NULL;
			IF @newLocStreetID <> 0 DELETE Location WHERE LocationID=@newLocStreetID;

			UPDATE Customer SET MainAddressID = 
				BillingAddressID WHERE CustomerID=@CustomerID;
		END
		
		IF @loc_street_action = 'RESET' EXEC(@loc_streetSQL);
		
		IF @loc_street_action = 'DELETE' 
		BEGIN
			EXEC(@loc_streetSQL);
			UPDATE Customer SET MainAddressID = NULL WHERE CustomerID=@CustomerID;
		END

		-- If there is a Rate action, Delete current Rates. If action='ADD', insert new rates
			IF LEN(@Rate_action) > 0
			BEGIN
				DELETE AutoportExportRates WHERE CustomerID = @CustomerID;

				IF @Rate_action = 'ADD'
				BEGIN
					SET @SQLCommand = 'INSERT INTO AutoportExportRates (CustomerID,EntryFee,PerDiem,
					PerDiemGraceDays,StartDate,EndDate,CreationDate,CreatedBy,RateType)
					SELECT CustomerID,EntryFee,PerDiem,
					PerDiemGraceDays,StartDate,EndDate,CreationDate,CreatedBy,RateType
					FROM ' + @tmpRateTable;

					EXEC(@SQLCommand);
				END
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
		IF @loc_billing_action='NEW' DELETE Location WHERE LocationID = @newLocBillingID;
		IF @loc_street_action='NEW' DELETE Location WHERE LocationID = @newLocStreetID;

		-- Remove @tmpRateTable
		IF @Rate_action = 'ADD' EXEC(@SQLRemovetmp);
		
		RETURN;
	END CATCH
	
	IF @@TRANCOUNT > 0 COMMIT TRAN;
	SELECT 'OK' AS result;

	-- Remove @tmpRateTable
	IF @Rate_action = 'ADD' EXEC(@SQLRemovetmp);
	
	END	-- IF @customeraction = ''
END
GO
