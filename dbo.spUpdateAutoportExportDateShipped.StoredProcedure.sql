USE [AutoExport]
GO
/****** Object:  StoredProcedure [dbo].[spUpdateAutoportExportDateShipped]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[spUpdateAutoportExportDateShipped](
	@VIN		varchar(17),
	@StatusDate	datetime,
	@User		varchar(20)
	)
AS
BEGIN
	/************************************************************************
	*	spUpdateAutoportExportDateShipped				*
	*									*
	*	Description							*
	*	-----------							*
	*	Updates the shipped date and VehicleStatus of the vehicleid	*
	*	passed in, in the AutoportExportVehicles table.			*
	*									*
	*	Change History							*
	*	--------------							*
	*	Date       Init's Description					*
	*	---------- ------ ----------------------------------------	*
	*	1/19/2018  DavidM Modify date checks that @StatusDate is before DateReceived,
	*	DateSubmittedCustoms, CustomsApprovedDate. Return @Operation with error msg, if CATCH occurs
	*	10/10/2017 DavidM Remove TRAN, GOTOs; replace IF @@ERROR test with TRY/CATCH 
	*	03/12/2012 CMK    Initial version				*
	*									*
	************************************************************************/	

	SET nocount on

	BEGIN TRY
		DECLARE	@AutoportExportVehiclesID	int,
			@Count int,
			@DateReceived			datetime,
			@ReceivedExceptionDate		datetime,
			@VoyageChangeHoldDate		datetime,
			@DateSubmittedCustoms		datetime,
			@CustomsExceptionDate		datetime,
			@CustomsApprovedDate		datetime,
			@DateShipped			datetime,
			@UpdatedDate			datetime,
			@Operation varchar(50);


		-- When Sproc finishes:
		-- send back a single record with the fields 'RC' [return code], 'RM' [return msg]
		-- return return code
		-- Values:
		-- RC: 100000  RM: 'No VIN Number Entered.'
		-- RC: 100001  RM: 'No Status Date Entered.'
		-- RC: 100003  RM: 'VIN not found in Autoport Export Vehicles table.'
		-- RC: 100004  RM: 'Multiple matches found for VIN.'
		-- RC: 100022  RM: 'Date Shipped Is Already '+ convert(varchar(10),@DateShipped,101)
		-- RC: 100023  RM: 'Date Received Is Blank'
		-- RC: 100024  RM:'Date Submitted Customs Is Blank'
		-- RC: 100025  RM: 'Customs Approved Date Is Blank'
		-- RC: 100026  RM: 'Date Shipped Before Date Received'
		-- RC: 100027  RM: 'Date Shipped Before Date Submitted Customs'
		-- RC: 100028  RM: 'Date Shipped Before Customs Approval Date'
		-- RC: SQL Error  RM: 'Operation: '+@Operation, 'Error Number '+CONVERT(varchar(10),@ErrorID)+' encountered getting the VIN Count.'		
		-- RC: 0  RM: 'Updated Successfully.'	
	
		-- Ck for VIN
		SET @Operation = 'Ck for VIN';
		IF DATALENGTH(@VIN)<1 OR @VIN IS NULL
		BEGIN
			SELECT 100000 AS RC, 'No VIN Number Entered.' AS RM;
			RETURN 100000;
		END
	
		-- Ck for StatusDate
		SET @Operation = 'Ck for StatusDate';
		IF @StatusDate IS NULL
		BEGIN
			SELECT 100001 AS RC,'No Status Date Entered.' AS RM;
			RETURN 100001;
		END
	
		-- Ck for single rec in AutoportExportVehicles table
		SET @Operation = ' Ck for single rec';
		SELECT @Count = COUNT(*)
		FROM AutoportExportVehicles AEV
		WHERE VIN = @VIN
		AND DateShipped IS NULL
	
		-- Ck VIN not found
		SET @Operation = 'Ck VIN not found';
		IF @Count = 0 OR @Count IS NULL
		BEGIN
			SELECT 100003 AS RC, 'VIN not found in Autoport Export Vehicles table.' AS RM;
			RETURN 100003;
		END
	
		-- Ck Multiple VINs
		SET @Operation = 'Ck Multiple VINs';
		IF @Count > 1
		BEGIN
			SELECT 100004 AS RC, 'Multiple matches found for VIN' AS RM;
			RETURN 100004;
		END
	
		-- Get date field values for the VIN
		SET @Operation = 'Get date field values for the VIN';
		SELECT @AutoportExportVehiclesID = AEV.AutoportExportVehiclesID,
		@DateReceived = AEV.DateReceived, @ReceivedExceptionDate = ReceivedExceptionDate,
		@VoyageChangeHoldDate = AEV.VoyageChangeHoldDate, @DateSubmittedCustoms = AEV.DateSubmittedCustoms,
		@CustomsExceptionDate = AEV.CustomsExceptionDate, @CustomsApprovedDate = AEV.CustomsApprovedDate,
		@DateShipped = AEV.DateShipped
		FROM AutoportExportVehicles AEV
		WHERE AEV.VIN = @VIN
		AND AEV.DateShipped IS NULL
	
		-- Ck that DateShipped IS NULL
		SET @Operation = 'Ck that DateShipped IS NULL';
		IF @DateShipped IS NOT NULL
		BEGIN
			SELECT 100022 AS RC,'Date Shipped Is Already '+ convert(varchar(10),@DateShipped,101) AS RM;
			RETURN 100022;
		END

		-- Ck that DateReceived IS NOT NULL
		SET @Operation = 'Ck that DateReceived IS NOT NULL';
		IF @DateReceived IS NULL
		BEGIN
			SELECT 100023 AS RC,'Date Received Is Blank' AS RM;
			RETURN 100023;
		END

		-- Ck that DateSubmittedCustoms IS NOT NULL
		SET @Operation = 'Ck that DateSubmittedCustoms IS NOT NULL';
		IF @DateSubmittedCustoms IS NULL
		BEGIN
			SELECT 100024 as RC,'Date Submitted Customs Is Blank' AS RM;
			RETURN 100024;
		END
	
		-- Ck that CustomsApprovedDate IS NOT NULL
		SET @Operation = 'Ck that CustomsApprovedDate IS NOT NULL';
		IF @CustomsApprovedDate IS NULL
		BEGIN
			SELECT 100025 AS RC,'Customs Approved Date Is Blank' AS RM;
			RETURN 100025;
		END

		-- Ck if StatusDate < DateReceived
		SET @Operation = 'Ck if StatusDate < DateReceived';
		IF @StatusDate < @DateReceived
		BEGIN
			-- If same day, make @StatusDate = @DateReceived, setting DateShipped = DateReceived
			--	otherwise, return an error
			IF CONVERT(date,@StatusDate) = CONVERT(date,@DateReceived)
				SELECT @StatusDate = @DateReceived
			ELSE
			BEGIN
				SELECT 100026 AS RC,'Date Shipped Before Date Received' AS RM;
				RETURN 100026;
			END
		END

		-- Ck if StatusDate < DateSubmittedCustoms
		SET @Operation = 'Ck if StatusDate < DateSubmittedCustoms';
		IF @StatusDate < @DateSubmittedCustoms
		BEGIN
			-- If same day, make @StatusDate = @DateSubmittedCustoms, setting DateShipped = DateSubmittedCustoms
			--	otherwise, return an error
			IF CONVERT(date,@StatusDate) = CONVERT(date,@DateSubmittedCustoms)
				SELECT @StatusDate = @DateShipped
			ELSE
			BEGIN
				SELECT 100027 AS RC,'Date Shipped Before Date Submitted Customs' AS RM;
				RETURN 100027;
			END
		END
	
		-- Ck if StatusDate < CustomsApprovedDate
		SET @Operation = 'Ck if StatusDate < CustomsApprovedDate';
		IF @StatusDate < @CustomsApprovedDate
		BEGIN
			-- If same day, make @StatusDate = @CustomsApprovedDate, setting DateShipped = CustomsApprovedDate
			--	otherwise, return an error
			IF CONVERT(date,@StatusDate) = CONVERT(date,@CustomsApprovedDate)
				SELECT @StatusDate = @CustomsApprovedDate
			ELSE
			BEGIN
				SELECT 100028 AS RC,'Date Shipped Before Customs Approval Date' AS RM;
				RETURN 100028;
			END
		END
	
		-- Update AutoportExportVehicles
		SET @Operation = 'Update AutoportExportVehicles';
		UPDATE AutoportExportVehicles
		SET 
		DateReceived = @DateReceived,
		ReceivedExceptionDate = NULL,
		VoyageChangeHoldDate = NULL,
		DateSubmittedCustoms = @DateSubmittedCustoms,
		CustomsExceptionDate = NULL,
		CustomsApprovedDate = @CustomsApprovedDate,
		DateShipped = @StatusDate,
		VehicleStatus = 'Shipped',		
		UpdatedDate = @StatusDate,
		UpdatedBy = @User
		WHERE AutoportExportVehiclesID = @AutoportExportVehiclesID;

		-- Return Success
		SELECT 0 AS RC, 'Updated Successfully' AS RM;
		RETURN 0;	
	END TRY

	BEGIN CATCH
		SELECT  @@ERROR AS RC, 'Operation: ' + @Operation + 
		', Error Number '+ CONVERT(varchar(10), @@ERROR) + 
		', Error Msg ' + ERROR_MESSAGE() AS RM;
		RETURN @@ERROR;
	END CATCH
END
GO
