USE [AutoExport]
GO
/****** Object:  StoredProcedure [dbo].[spUpdateAutoportExportVehiclesExpeditor]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spUpdateAutoportExportVehiclesExpeditor](
	@VIN		varchar(17),
	@BayLocation varchar(20),
	@LeftBehindFlg bit,
	@NonRunnerFlg bit,
	@User		varchar(20)
	)
AS
BEGIN
	/************************************************************************
	*	[spUpdateAutoportExportVehiclesExpeditor]				*
	*									*
	*	Description							*
	*	-----------							*
	*	Updates the BayLocation of the vehicleid, and the flags	*
	*	passed in, in the AutoportExportVehicles table.			*
	*									*[dbo].[spGetExportRemainingToLoad]
	*	Change History							*
	*	--------------							*
	*	Date       Init's Description					*
	*	---------- ------ ----------------------------------------	*
	*	10/10/2017 DavidM	  Remove TRAN, GOTOs; replace IF @@ERROR test with TRY/CATCH 
	*	04/09/2012 CristiP    Initial version				*
	*									*
	************************************************************************/	

	SET nocount on

	BEGIN TRY
		DECLARE
		@Count int,
		@Date datetime = CURRENT_TIMESTAMP;

		-- When Sproc finishes:
		-- send back a single record with the fields 'RC' [return code], 'RM' [return msg]
		-- return return code
		-- Values:
		-- RC: 100000  RM: 'No VIN Number Entered.'
		-- RC: SQL Error  RM: 'Error Number '+CONVERT(varchar(10),@ErrorID)+' encountered getting the VIN Count.'
		-- RC: 100003  RM: 'VIN not found in Autoport Export Vehicles table'
		-- RC: 100004  RM: 'Multiple matches found for VIN' / 'The VIN cannot be both: a Left-Behind and a Non-Runner at the same time'
		-- RC: 0  RM: 'Updated Successfully.'
	
	
		-- Ck for VIN
		IF DATALENGTH(@VIN)<1 OR @VIN IS NULL
		BEGIN
			SELECT 100000 AS RC, 'No VIN Number Entered.' AS RM;
			RETURN 100000;
		END

		-- Ck for single rec in AutoportExportVehicles table
		SELECT @Count = COUNT(*)
		FROM AutoportExportVehicles
		WHERE VIN = @VIN
		AND DateShipped IS NULL;

		-- Ck VIN not found
		IF @Count = 0 OR @Count IS NULL
		BEGIN
			SELECT 100003 AS RC, 'VIN not found in Autoport Export Vehicles table' AS RM;
			RETURN 100003;
		END

		-- Ck Multiple VINs
		IF @Count > 1
		BEGIN
			SELECT 100004 AS RC, 'Multiple matches found for VIN' AS RM;
			RETURN 100004;
		END

		-- Ck Left-Behind & Non-Runner
		IF @LeftBehindFlg = @NonRunnerFlg
		BEGIN
			SELECT 100004 AS RC,'The VIN cannot be both: a Left-Behind and a Non-Runner at the same time' AS RM;
			RETURN 100004;
		END	
	
		-- Update veh table for the VIN
		UPDATE AutoportExportVehicles
		SET BayLocation = @BayLocation,
		LeftBehindInd = @LeftBehindFlg,
		NoStartInd = @NonRunnerFlg,
		UpdatedDate = @Date,
		UpdatedBy = @User,
		LastPhysicalDate = @Date,
		LastPhysicalBy = @User
		WHERE VIN = @VIN;

		-- Return Success
		SELECT 0 AS RC, 'Updated Successfully' AS RM;
		RETURN 0;	
	END TRY
	
	BEGIN CATCH
		SELECT @@ERROR AS RC, 'Error Number '+ CONVERT(varchar(10), @@ERROR) +', Error Msg ' + 
			ERROR_MESSAGE() AS RM;
		RETURN @@ERROR;
	END CATCH							
END
GO
