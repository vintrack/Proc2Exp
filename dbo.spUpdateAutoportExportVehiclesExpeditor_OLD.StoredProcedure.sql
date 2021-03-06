USE [AutoExport]
GO
/****** Object:  StoredProcedure [dbo].[spUpdateAutoportExportVehiclesExpeditor_OLD]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUpdateAutoportExportVehiclesExpeditor_OLD](
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
	*									*
	*	Change History							*
	*	--------------							*
	*	Date       Init's Description					*
	*	---------- ------ ----------------------------------------	*
	*	04/09/2012 CristiP    Initial version				*
	*									*
	************************************************************************/	

	SET nocount on

	DECLARE	@AutoportExportVehiclesID	int,
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
	
	SELECT @Count = NULL
	
	SELECT @Count = COUNT(*)
	FROM AutoportExportVehicles AEV
	WHERE VIN = @VIN
	AND DateShipped is NULL
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

	IF @LeftBehindFlg = @NonRunnerFlg
	BEGIN
		SELECT @ErrorID = 100004
		SELECT @Msg = 'The VIN cannot be both: a Left-Behind and a Non-Runner at the same time'
		GOTO Error_Encountered
	END	

	SELECT @AutoportExportVehiclesID = AEV.AutoportExportVehiclesID
	FROM AutoportExportVehicles AEV
	WHERE AEV.VIN = @VIN
	IF @@ERROR <> 0
	BEGIN
		SELECT @ErrorID = @@ERROR
		SELECT @Msg = 'Error Number '+CONVERT(varchar(10),@ErrorID)+' encountered getting the Vehicle Details'
		GOTO Error_Encountered
	END
	
	UPDATE AutoportExportVehicles
	SET BayLocation = @BayLocation,
	LeftBehindInd = @LeftBehindFlg,
	NoStartInd = @NonRunnerFlg,
	UpdatedDate = @UpdatedDate,
	UpdatedBy = @User,
	LastPhysicalDate = @UpdatedDate,
	LastPhysicalBy = @User
	WHERE AutoportExportVehiclesID = @AutoportExportVehiclesID
	IF @@ERROR <> 0
	BEGIN
		SELECT @ErrorID = @@ERROR
		SELECT @Msg = 'Error Number '+CONVERT(varchar(10),@ErrorID)+' encountered updating the Vehicle Record'
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
