USE [AutoExport]
GO
/****** Object:  StoredProcedure [dbo].[spGetBatchIDAndIncrement]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Maibor
-- Create date: 5/26/17
-- Description:	Get Current BatchID from SettingTable & increment it. Use TRAN so each BatchID is used only once
-- =============================================
CREATE PROCEDURE [dbo].[spGetBatchIDAndIncrement]
@ImportType varchar(10) = NULL
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE
		@batchID int;

		BEGIN TRAN
			-- Use NextAutoportExportVehicleImportBatchID as ValueKey in
			--	SettingTable, unless @ImportType IS NOT NULL
			IF @ImportType IS NULL
			BEGIN
				SELECT @batchID = ValueDescription FROM SettingTable 
					WHERE ValueKey='NextAutoportExportVehicleImportBatchID';
				UPDATE SettingTable SET ValueDescription = @batchID + 1 
					WHERE ValueKey='NextAutoportExportVehicleImportBatchID';
			END
			
			IF @ImportType = 'SHIP'
			BEGIN
				SELECT @batchID = ValueDescription FROM SettingTable 
					WHERE ValueKey='NextAutoportExportShippedImportBatchID';
				UPDATE SettingTable SET ValueDescription = @batchID + 1 
					WHERE ValueKey='NextAutoportExportShippedImportBatchID';
			END

			IF @ImportType = 'EXPORT'
			BEGIN
				SELECT @batchID = ValueDescription FROM SettingTable 
					WHERE ValueKey='NextBillingExportBatchID';
				UPDATE SettingTable SET ValueDescription = @batchID + 1 
					WHERE ValueKey='NextBillingExportBatchID';
			END
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

		IF @@TRANCOUNT > 0 ROLLBACK TRAN;
	END CATCH

	IF @@TRANCOUNT > 0 
	BEGIN
		COMMIT TRAN;
		SELECT 'OK' AS result,@batchID AS batchID;
	END
END
GO
