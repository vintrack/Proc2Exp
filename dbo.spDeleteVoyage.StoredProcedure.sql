USE [AutoExport]
GO
/****** Object:  StoredProcedure [dbo].[spDeleteVoyage]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Maibor
-- Create date: 4/21/17
-- Description:	Users wants to delete a voyage
--	Update AutoportExportVehicles, set VoyageID to NULL
--	Delete record in AEVoyage
--	Delete records in AEVoyageCustomer,AEVoyageDestination, AEVoyageLoadSequence
-- =============================================
CREATE PROCEDURE [dbo].[spDeleteVoyage]
	@VoyageID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    BEGIN TRY
		BEGIN TRAN
		UPDATE AutoportExportVehicles SET VoyageID = NULL WHERE VoyageID=@VoyageID;
		DELETE AEVoyage WHERE AEVoyageID=@VoyageID;
		DELETE AEVoyageCustomer WHERE AEVoyageID=@VoyageID;
		DELETE AEVoyageDestination WHERE AEVoyageID=@VoyageID;
		DELETE AEVoyageLoadSequence WHERE VoyageID=@VoyageID;
	END TRY

	BEGIN CATCH
		-- Based on Microsoft example: 
		-- https://docs.microsoft.com/en-us/sql/t-sql/language-elements/try-catch-transact-sql
		SELECT
		'ERROR' AS result,
		ERROR_NUMBER() AS ErrorNumber,
		ERROR_SEVERITY() AS ErrorSeverity,
		ERROR_STATE() AS ErrorState,
		ERROR_PROCEDURE() AS ErrorProcedure,
		ERROR_LINE() AS ErrorLine,
		ERROR_MESSAGE() AS ErrorMessage;

		IF @@TRANCOUNT > 0 ROLLBACK TRAN;
	END CATCH

	
	IF @@TRANCOUNT > 0 
	BEGIN
		COMMIT TRAN;
		SELECT 'OK' AS result;
	END
END
GO
