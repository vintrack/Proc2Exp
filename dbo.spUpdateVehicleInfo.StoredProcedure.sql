USE [AutoExport]
GO
/****** Object:  StoredProcedure [dbo].[spUpdateVehicleInfo]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Maibor
-- Create date: 4/11/17
-- Description:	Run @VehSQL to insert a rec or update the AutoportExportVehicles table.
--	Create new recs in AEVehicleInspection, AEVehicleDamageDetail tables with info in @tmptable
--		created by the program
-- @Mode: NEW (new Veh. record w/Damage info; MODIFY (update existing Veh. record w/ new Damage info)
-- @tmptable: name of tmptable created by program code with damage info
-- @vehSQL: SQL created by program to update the AutoportExportVehicles table
-- @Createdby: used to identify new record created in AutoportExportVehicles table
-- @CreationDate used as CreationDate/UpdatedDate in all SQL. Allows deletion of 
--	any inserted records without need for a TRAN
-- =============================================
CREATE PROCEDURE [dbo].[spUpdateVehicleInfo]
	@Mode varchar(10),
	@tmptable varchar(50),
	@VehSQL varchar(max),
	@Createdby varchar(20),
	@CreationDate datetime

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE 
	@SQLCommand varchar (1000),
	@VehID int;

	BEGIN TRY
	-- If @Mode = NEW run @VehSQL first to insert record into AutoportExportVehicles table 
	--	& store new VehID
	-- Don't need to begin TRAN yet, since we have the new ID stored as @VehID
	-- Update @tmptable with the new VehID
	IF @Mode='NEW'
	BEGIN
		EXEC(@VehSQL);
		SELECT TOP 1 @VehID =  AutoportExportVehiclesID FROM AutoportExportVehicles
			WHERE CreatedBy = @Createdby ORDER BY CreationDate DESC;

		-- Update the tmptable with the new VehID just created
		SET @SQLCommand = 'UPDATE ' + @tmptable + ' SET AutoportExportVehiclesID = ' + 
			CAST(@VehID AS varchar(7));
		EXEC(@SQLCommand);
	END 

	-- Insert new Inspection records
		SET @SQLCommand = 'INSERT INTO AEVehicleInspection (AutoportExportVehiclesID,
		InspectionType,InspectionDate,InspectedBy,DamageCodecount,Notes,CreationDate,
		CreatedBy)
		SELECT Distinct AutoportExportVehiclesID,InspectionType,InspectionDate,
		InspectedBy,DamageCodecount,Notes,CreationDate,
		InspectedBy AS CreatedBy FROM ' + @tmptable;
		EXEC (@SQLCommand);

		-- Insert new Damage records
		SET @SQLCommand = 'INSERT INTO AEVehicleDamageDetail 
		(AEVehicleInspectionID,AutoportExportVehiclesID,
		DamageCode,DamageDescription,CreationDate,CreatedBy) 
		SELECT  AEVehicleInspectionID,AutoportExportVehiclesID,DamageCode,
		DamageDescription,CreationDate,
		InspectedBy AS CreatedBy FROM ' + @tmptable;
		EXEC (@SQLCommand);

		-- Update DamageDetail records with new AEVehicleInspectionID created in
		-- AEVehicleInspection
		UPDATE d
		SET d.AEVehicleInspectionID=i.AEVehicleInspectionID
		FROM
		AEVehicleDamageDetail d
		INNER JOIN AEVehicleInspection i on i.CreationDate=d.CreationDate

	-- Use TRAN TO Update veh info if @Mode=MODIFY & permit Rollback
	BEGIN TRAN;			
		IF @Mode='MODIFY' EXEC (@VehSQL);
	END TRY

	-- Based on Microsoft example: 
	-- https://docs.microsoft.com/en-us/sql/t-sql/language-elements/try-catch-transact-sql
	BEGIN CATCH
		SELECT
		'ERROR' AS result,
		ERROR_NUMBER() AS ErrorNumber,
		ERROR_SEVERITY() AS ErrorSeverity,
		ERROR_STATE() AS ErrorState,
		ERROR_PROCEDURE() AS ErrorProcedure,
		ERROR_LINE() AS ErrorLine,
		ERROR_MESSAGE() AS ErrorMessage;

		-- Delete new row inserted in AutoportExportVehicles
		IF @Mode = 'NEW' DELETE AutoportExportVehicles 
			WHERE AutoportExportVehiclesID=@VehID;

		-- Delete new recs in AEVehicleInspection
		SET @SQLCommand = 'DELETE ins FROM AEVehicleInspection i 
			INNER JOIN ' + @tmptable + ' tmp ON tmp.CreationDate 
			= i.CreationDate;'
		EXEC (@SQLCommand);

		-- Delete new recs in AEVehicleDamageDetail
		SET @SQLCommand = 'DELETE AEVehicleDamageDetail d 
			INNER JOIN ' + @tmptable + ' tmp ON tmp.CreationDate 
			= d.CreationDate;'
		EXEC (@SQLCommand);

		-- iF MODIFY mode, rollback update to AutoportExportVehicles table
		IF @@TRANCOUNT > 0 AND @Mode = 'MODIFY' ROLLBACK TRAN;
	END CATCH

	IF @@TRANCOUNT > 0 
	BEGIN
		COMMIT TRAN;
		SELECT 'OK' AS result;
	END

	-- Drop tmptable
	SET @SQLCommand = 'DROP TABLE ' + @tmptable;
	EXEC (@SQLCommand);
END
GO
