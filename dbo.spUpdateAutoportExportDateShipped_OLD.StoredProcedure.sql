USE [AutoExport]
GO
/****** Object:  StoredProcedure [dbo].[spUpdateAutoportExportDateShipped_OLD]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[spUpdateAutoportExportDateShipped_OLD](
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
	*	03/12/2012 CMK    Initial version				*
	*									*
	************************************************************************/	

	SET nocount on

	DECLARE	@AutoportExportVehiclesID	int,
		@DateReceived			datetime,
		@ReceivedExceptionDate		datetime,
		@VoyageChangeHoldDate		datetime,
		@DateSubmittedCustoms		datetime,
		@CustomsExceptionDate		datetime,
		@CustomsApprovedDate		datetime,
		@DateShipped			datetime,
		@ReturnCode			int,
		@ReturnMessage			varchar(100),
		@ErrorID			int,
		@Msg				varchar(100),
		@Count				int,
		@UpdatedDate			datetime

	SELECT @Count = 0
	SELECT @ErrorID = 0
	SELECT @UpdatedDate = CURRENT_TIMESTAMP
	
	BEGIN TRAN
	
	IF DATALENGTH(@VIN)<1
	BEGIN
		SELECT @ErrorID = 100000
		SELECT @Msg = 'No VIN Number Entered.'
		GOTO Error_Encountered
	END
	
	IF @StatusDate IS NULL
	BEGIN
		SELECT @ErrorID = 100001
		SELECT @Msg = 'No Status Date Entered.'
		GOTO Error_Encountered
	END
	
	SELECT @Count = NULL
	
	SELECT @Count = COUNT(*)
	FROM AutoportExportVehicles AEV
	WHERE VIN = @VIN
	AND DateShipped IS NULL
	IF @@ERROR <> 0
	BEGIN
		SELECT @ErrorID = @@ERROR
		SELECT @Msg = 'Error Number '+CONVERT(varchar(10),@ErrorID)+' encountered getting the VIN Count'
		GOTO Error_Encountered
	END
	
	IF @Count IS NULL OR @Count = 0
	BEGIN
		SELECT @ErrorID = 100003
		SELECT @Msg = 'VIN not found in Autoport Export Vehicles table'
		GOTO Error_Encountered
	END
	IF @Count > 1
	BEGIN
		SELECT @ErrorID = 100004
		SELECT @Msg = 'Multiple matches found for VIN'
		GOTO Error_Encountered
	END
	
	SELECT @AutoportExportVehiclesID = AEV.AutoportExportVehiclesID,
	@DateReceived = AEV.DateReceived, @ReceivedExceptionDate = ReceivedExceptionDate,
	@VoyageChangeHoldDate = AEV.VoyageChangeHoldDate, @DateSubmittedCustoms = AEV.DateSubmittedCustoms,
	@CustomsExceptionDate = AEV.CustomsExceptionDate, @CustomsApprovedDate = AEV.CustomsApprovedDate,
	@DateShipped = AEV.DateShipped
	FROM AutoportExportVehicles AEV
	WHERE AEV.VIN = @VIN
	AND AEV.DateShipped IS NULL
	IF @@ERROR <> 0
	BEGIN
		SELECT @ErrorID = @@ERROR
		SELECT @Msg = 'Error Number '+CONVERT(varchar(10),@ErrorID)+' encountered getting the Vehicle Details'
		GOTO Error_Encountered
	END
		
	IF @DateShipped IS NOT NULL
	BEGIN
		SELECT @ErrorID = 100022
		SELECT @Msg = 'Date Shipped Is Already '+convert(varchar(10),@DateShipped,101)
		GOTO Error_Encountered
	END
	IF @DateReceived IS NULL
	BEGIN
		SELECT @ErrorID = 100023
		SELECT @Msg = 'Date Received Is Blank'
		GOTO Error_Encountered
	END
	ELSE IF @DateSubmittedCustoms IS NULL
	BEGIN
		SELECT @ErrorID = 100024
		SELECT @Msg = 'Date Submitted Customs Is Blank'
		GOTO Error_Encountered
	END
	ELSE IF @CustomsApprovedDate IS NULL
	BEGIN
		SELECT @ErrorID = 100025
		SELECT @Msg = 'Customs Approved Date Is Blank'
		GOTO Error_Encountered
	END
	IF @StatusDate < @DateReceived
	BEGIN
		IF CONVERT(varchar(10),@StatusDate,101) = CONVERT(varchar(10),@DateReceived,101)
		BEGIN
			SELECT @StatusDate = @DateReceived
		END
		ELSE
		BEGIN
			SELECT @ErrorID = 100026
			SELECT @Msg = 'Date Shipped Before Date Received'
			GOTO Error_Encountered
		END
	END
	IF @StatusDate < @DateSubmittedCustoms
	BEGIN
		IF CONVERT(varchar(10),@StatusDate,101) = CONVERT(varchar(10),@DateSubmittedCustoms,101)
		BEGIN
			SELECT @StatusDate = @DateSubmittedCustoms
		END
		ELSE
		BEGIN
			SELECT @ErrorID = 100027
			SELECT @Msg = 'Date Shipped Before Date Submitted Customs'
			GOTO Error_Encountered
		END
	END
	IF @StatusDate < @CustomsApprovedDate
	BEGIN
		IF CONVERT(varchar(10),@StatusDate,101) = CONVERT(varchar(10),@CustomsApprovedDate,101)
		BEGIN
			SELECT @StatusDate = @CustomsApprovedDate
		END
		ELSE
		BEGIN
			SELECT @ErrorID = 100028
			SELECT @Msg = 'Date Shipped Before Customs Approval Date'
			GOTO Error_Encountered
		END
	END
	SELECT @VoyageChangeHoldDate = NULL
	SELECT @DateShipped = @StatusDate
		
	IF @DateSubmittedCustoms IS NOT NULL
	BEGIN
		SELECT @ReceivedExceptionDate = NULL
	END
	
	IF @CustomsApprovedDate IS NOT NULL
	BEGIN
		SELECT @CustomsExceptionDate = NULL
	END
	
	UPDATE AutoportExportVehicles
	SET DateReceived = @DateReceived,
	ReceivedExceptionDate = @ReceivedExceptionDate,
	VoyageChangeHoldDate = @VoyageChangeHoldDate,
	DateSubmittedCustoms = @DateSubmittedCustoms,
	CustomsExceptionDate = @CustomsExceptionDate,
	CustomsApprovedDate = @CustomsApprovedDate,
	DateShipped = @DateShipped,
	VehicleStatus = 'Shipped',
	UpdatedDate = @UpdatedDate,
	UpdatedBy = @User
	WHERE AutoportExportVehiclesID = @AutoportExportVehiclesID
	IF @@ERROR <> 0
	BEGIN
		SELECT @ErrorID = @@ERROR
		SELECT @Msg = 'Error Number '+CONVERT(varchar(10),@ErrorID)+' encountered updating the Vehicle Record'
		GOTO Error_Encountered
	END
	
	INSERT INTO AEVehicleStatusHistory(
		AutoportExportVehiclesID,
		VehicleStatus,
		StatusDate,
		CreationDate,
		CreatedBy
	)
	VALUES(
		@AutoportExportVehiclesID,
		'Shipped',
		@StatusDate,
		@UpdatedDate,
		@User
	)
	IF @@Error <> 0
	BEGIN
		SELECT @ErrorID = @@ERROR
		SELECT @Msg = 'Error adding Status History Record'
		GOTO Error_Encountered
	END
								
	Error_Encountered:
	IF @ErrorID <> 0
	BEGIN
		ROLLBACK TRAN
		SELECT @ReturnCode = @ErrorID
		SELECT @ReturnMessage = @Msg
		GOTO Do_Return
	END
	ELSE
	BEGIN
		COMMIT TRAN
		SELECT @ReturnCode = 0
		SELECT @ReturnMessage = 'Updated Successfully'
		GOTO Do_Return
	END

	Do_Return:
	SELECT @ReturnCode AS 'RC', @ReturnMessage AS 'RM'

	RETURN @ReturnCode
END


GO
