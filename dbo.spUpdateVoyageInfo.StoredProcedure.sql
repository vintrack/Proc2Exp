USE [AutoExport]
GO
/****** Object:  StoredProcedure [dbo].[spUpdateVoyageInfo]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Maibor
-- Create date: 4/17/17
-- Description:	
--	Create new or update recs in AEVoyage table.
--	If Customer, Destinations, or LoadSeq info sent, update those tables as well
-- @Mode: NEW (new Voyage record; MODIFY (update existing Voyage record 
-- @VoyageSQL: if LEN > 0, SQL created by program to update the AEVoyage table
-- @CustomerIDs: NULL, do nothing. Otherwise, Delete Customer IDs for voyage. 
--	Has Values, as comma-separated values, Add CustomerIDs to AEVoyageCustomer 
-- @Destinations: same as CustomerIDs
-- @LoadSeqstable: NULL, do nothing. Otherwise Delete LoadSeq recs for VoyageID. 
--	  If LEN>0, name of tmp table created by program with new LoadSeq recs to insert
--    into the AEVoyageLoadSequence table	
-- @Createdby: used to identify new record created in AEVoyage table
-- =============================================
CREATE PROCEDURE [dbo].[spUpdateVoyageInfo]
	@Mode varchar(10),
	@VoyageID int,
	@VoyageSQL varchar (max),
	@CustomerIDs varchar (100) = NULL,
	@Destinations varchar (1000) = NULL,
	@LoadSeqstable varchar (100) = NULL,
	@Createdby varchar(20)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRY

		DECLARE 
		@SQLCommand varchar (1000);

		-- If @Mode = NEW run @VoyageSQL first to insert record into AEVoyage table & store new VoyageID
		-- Don't need to begin transaction yet, since we have the new ID stored as @VehID
		IF @Mode='NEW'
		BEGIN
			EXEC(@VoyageSQL);
			SELECT TOP 1 @VoyageID = AEVoyageID  FROM AEVoyage
				WHERE CreatedBy = @Createdby ORDER BY CreationDate DESC;
		END 

		BEGIN TRAN

		-- If @Mode = 'MODIFY' Update AEVoyage with @VoyageSQL, 
		--		include in TRAN to permit rollback
		--	Clear Customer, Destination, LoadSeq tables
		IF @Mode='MODIFY' AND LEN(@VoyageSQL) > 0 EXEC (@VoyageSQL);
		
		-- Update AEVoyageCustomer, if necessary; use fnSplitString to return a table
		if @CustomerIDs IS NOT NULL
		BEGIN
			IF @Mode = 'MODIFY' DELETE AEVoyageCustomer WHERE AEVoyageID = @VoyageID;
			IF LEN(@CustomerIDs) > 0
			INSERT INTO AEVoyageCustomer (AEVoyageID,CustomerID,CreationDate,CreatedBy)
				SELECT @VoyageID AS AEVoyageID,
				value AS CustomerID,
				GETDATE() AS CreationDate,
				@Createdby AS CreatedBy
				FROM fnSplitString(@CustomerIDs,',');
		END

		-- Update AEVoyageDestination, if necessary; use fnSplitString to return a table
		IF @Destinations IS NOT NULL
		BEGIN
			IF @Mode = 'MODIFY' DELETE AEVoyageDestination WHERE AEVoyageID = @VoyageID;
			IF LEN(@Destinations) > 0
			INSERT INTO AEVoyageDestination (AEVoyageID,DestinationName,CreationDate,
				CreatedBy) 
				SELECT @VoyageID AS AEVoyageID,
				value AS DestinationName,
				GETDATE() AS CreationDate,
				@Createdby AS CreatedBy
				FROM fnSplitString(@Destinations,',');
		END

		-- Update AEVoyageLoadSequence, if necessary
		IF @LoadSeqstable IS NOT NULL
		BEGIN
			-- Delete current LoadSeq info for voyage
			DELETE AEVoyageLoadSequence WHERE VoyageID=@VoyageID;

			-- Insert new records (if any) from @LoadSeqstable
			IF LEN(@LoadSeqstable) > 0
			BEGIN
				SET @SQLCommand = 'INSERT INTO AEVoyageLoadSequence (VoyageID,Sequence,
				CustomerID,DestinationName,SizeClass,CreationDate,CreatedBy) 
				SELECT ' +
				CAST(@VoyageID AS varchar(5)) + ' AS VoyageID,
				Sequence, CustomerID,DestinationName,SizeClass,CURRENT_TIMESTAMP,''' +
				@Createdby + ''' AS CreatedBy FROM ' + @LoadSeqstable;

				EXEC(@SQLCommand);
				
			END
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

		-- Delete new row inserted in AEVoyage
		IF @Mode = 'NEW' DELETE AEVoyage WHERE AEVoyageID=@VoyageID;

		IF @@TRANCOUNT > 0 ROLLBACK TRAN;
	END CATCH

	IF @@TRANCOUNT > 0 
	BEGIN
		COMMIT TRAN;
		SELECT 'OK' AS result;
	END

	-- Drop @LoadSeqstable
	IF LEN(ISNULL(@LoadSeqstable,'')) > 0
	BEGIN
		SET @SQLCommand = 'DROP TABLE ' + @LoadSeqstable;
		EXEC(@SQLCommand);
	END

END
GO
