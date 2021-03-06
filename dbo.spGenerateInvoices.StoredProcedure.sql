USE [AutoExport]
GO
/****** Object:  StoredProcedure [dbo].[spGenerateInvoices]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Maibor
-- Create date: 8/25/17
-- Description:	create Invoices for each Customer/Voyage pair passed in
-- Insert new recs into Billing, BillingLineItems, & AutoportExportPerDiem tables
-- Update AutoportExportVehicles table, update BilledInd, BillingID, DateBilled, TotalCharge
-- Modifications:
-- 6/19/18 D.Maibor: make sure PerDiem is charged for ShipDay in PerDiem WHILE loop
-- 1/18/18 D.Maibor: add ck whether DateShipped is before DateReceived

-- PARAMETERS
-- @cusvoypairs: string with CustomerID$VoyageID, or CustomerID#DateShipped pairs, separated by commas
-- If pair has '$', Voyage, charge CustomerID
-- If pair has '~', Voyage, charge BillToCustomerID
-- If pair has '#', no VoyageID, status is 'ShippedByTruck', and DateShipped is provided, charge CustomerID
-- If pair has '^', no VoyageID, status is 'ShippedByTruck', and DateShipped is provided, charge BillToCustomerID
-- E.g: '8$950, 12~950, 14#07/27/2017,8^07/28/2017'
--	CustomerID: 8/VoyageID: 950, BillToCustomerID: 12/VoyageID: 950
--	CustomerID: 14/DateShipped: 7/27/17, BillToCustomerID: 8/DateShipped: 7/28/17
-- @user

-- APPROACH
-- Create table variables to hold data for new & updated recs
-- Insert new recs into the Billing, BillingLineItems, AutoportExportPerDiem tables
--	from associated table variables, use @date for CreationDate of all new recs
-- Store new BillingIDs created from Insert into @tbl_Billing
--	Update AutoportExportVehicles table from tbl variables, perform last so
--		no transaction needed
-- =============================================
CREATE PROCEDURE [dbo].[spGenerateInvoices]
	@custvoypairs varchar(5000),
	@user varchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRY
		-- Create table for initial input data
		DECLARE @tbl_inputdata TABLE
		(value varchar(15));

		-- Create tbl to hold CustomerID/VoyageID or CustomerID/DateShipped pairs, use ID col to easily access each row
		--	and as initial BillingID
		DECLARE @tbl_custvoyage TABLE
		(
		ID int IDENTITY (1,1),
		pair varchar(15),
		CustomerID int,
		BillToCustomerID int,
		Customer varchar(50),
		CustomerCode varchar(20),
		VoyageID int,
		DateShipped datetime,
		BillingAddressID int,
		InvoiceNumber int,
		InvoiceDate datetime
		);

		-- Create tbl for Veh data
		DECLARE @tbl_veh TABLE
		(
			ID int IDENTITY (1,1),
			AutoportExportVehiclesID int,
			CustomerID int,
			BillToCustomerID int,
			VoyageID int,
			VIN varchar(17),
			SizeClass varchar(10),
			EntryRate decimal(19,2),
			EntryRateOverrideInd int,
			PerDiemGraceDays int,
			PerDiemGraceDaysOverrideInd int,
			TotalCharge decimal(19,2),
			BilledInd int,
			BillingID int,
			DateReceived datetime,
			DateShipped datetime,
			DateBilled datetime,
			UpdatedDate datetime,
			UpdatedBy varchar(20),
			CreditHoldInd int
		);

		-- Create table for Billing data. Don't need separate table for BillingLineItems data.
		DECLARE @tbl_billing TABLE
		(
			BillingID int, 
			BillingID_new int,
			CustomerID int,
			InvoiceNumber_int int,
			InvoiceNumber_ch varchar(20),
			InvoiceAmount decimal(19,2),
			InvoiceDate datetime
		);


		-- Create table for PerDiem data.
		DECLARE @tbl_perdiem TABLE
		(
			AutoportExportVehiclesID int,
			PerDiemDate datetime,
			PerDiem decimal(19,2)
		)

		-- Tbl used to identify any problem recs during CKs
		DECLARE @tbl_IDs TABLE
		(ID int);

		-- Load @tbl_inputdata with a row for each pairs in the @custvoypairs string 
		INSERT INTO @tbl_inputdata 
		SELECT * FROM fnSplitString(@custvoypairs,',');

		-- Load @tbl_custvoyage as a row for each original pair, where CustomerID is set
		INSERT INTO @tbl_custvoyage (pair,CustomerID)
		SELECT value AS pair,
		CASE
			WHEN CHARINDEX('$',value) > 0 THEN SUBSTRING (value,1,CHARINDEX('$',value)-1)
			ELSE SUBSTRING (value,1,CHARINDEX('#',value)-1)
		END AS CustomerID
		FROM @tbl_inputdata
		WHERE value LIKE '%$%' OR value LIKE '%#%'

		-- Load @tbl_custvoyage as a row for each original pair, where BillToCustomerID is set
		INSERT INTO @tbl_custvoyage (pair,BillToCustomerID)
		SELECT value AS pair,
		CASE
			WHEN CHARINDEX('~',value) > 0 THEN SUBSTRING (value,1,CHARINDEX('~',value)-1)
			ELSE SUBSTRING (value,1,CHARINDEX('^',value)-1)
		END AS BillToCustomerID
		FROM @tbl_inputdata
		WHERE value LIKE '%~%' OR value LIKE '%^%'

		-- Update @tblcustvoayage, Set CustomerID to BillToCustomerID where BillToCustomerID is not null
		UPDATE @tbl_custvoyage SET CustomerID = BillToCustomerID WHERE BillToCustomerID IS NOT NULL

		-- Update @tbl_custvoyage with Customer name,CustomerCode,BillingAddressID
		UPDATE custvoy
		SET Customer =
			CASE WHEN LEN(RTRIM(ISNULL(cus.ShortName,''))) > 0 THEN cus.ShortName
			ELSE cus.CustomerName
		END,
		CustomerCode = cus.CustomerCode,
		BillingAddressID = cus.BillingAddressID
		FROM @tbl_custvoyage custvoy
		LEFT OUTER JOIN Customer cus on cus.CustomerID=custvoy.CustomerID;

		-- Update @tbl_custvoyage with VoyageID for Voyage, Charge Cust
		UPDATE @tbl_custvoyage SET VoyageID =
			SUBSTRING (pair,CHARINDEX('$',pair)+1,LEN(pair)-CHARINDEX('$',pair))
		from @tbl_custvoyage
		WHERE CHARINDEX('$',pair) > 0;

		-- Update @tbl_custvoyage with VoyageID for Voyage, Charge BillToCust
		UPDATE @tbl_custvoyage SET VoyageID =
			SUBSTRING (pair,CHARINDEX('~',pair)+1,LEN(pair)-CHARINDEX('~',pair))
		from @tbl_custvoyage
		WHERE CHARINDEX('~',pair) > 0;

		-- Update @tbl_custvoyage with DateShipped, for ShipByTruck, Charge Cust
		UPDATE @tbl_custvoyage SET DateShipped = 
			SUBSTRING (pair,CHARINDEX('#',pair)+1,LEN(pair) - CHARINDEX('#',pair))
		WHERE CHARINDEX('#',pair) > 0; 

		-- Update @tbl_custvoyage with DateShipped, for ShipByTruck, Charge BillToCust
		UPDATE @tbl_custvoyage SET DateShipped = 
			SUBSTRING (pair,CHARINDEX('^',pair)+1,LEN(pair) - CHARINDEX('^',pair))
		WHERE CHARINDEX('^',pair) > 0; 

		-- Update @tbl_custvoyage, InvoiceDate
		--	Set to DateShipped if VoyageID is null
		--	Set to Voyage Date if VoyageID is not null
		UPDATE custvoy
		SET InvoiceDate = 
			CASE
				WHEN custvoy.VoyageID IS NULL THEN custvoy.DateShipped
				ELSE voy.VoyageDate
			END
		FROM 
		@tbl_custvoyage custvoy
		LEFT OUTER JOIN AEVoyage voy on voy.AEVoyageID=custvoy.VoyageID

		-- Put veh details into @tbl_veh with VoyageID, and no BillToCustomerID
		--	use @tbl_custvoyage ID as initial BillingID to easily join tables
		INSERT INTO @tbl_veh
		(AutoportExportVehiclesID,CustomerID,
		VoyageID,VIN,
		SizeClass,EntryRate,EntryRateOverrideInd,PerDiemGraceDays,
		PerDiemGraceDaysOverrideInd,TotalCharge,BillingID,BilledInd,
		DateBilled,DateReceived,DateShipped,UpdatedDate,UpdatedBy,CreditHoldInd)
		SELECT 
		AutoportExportVehiclesID,veh.CustomerID,
		veh.VoyageID,veh.VIN,
		veh.SizeClass,veh.EntryRate,veh.EntryRateOverrideInd,veh.PerDiemGraceDays,
		veh.PerDiemGraceDaysOverrideInd,veh.TotalCharge,custvoy.ID AS BillingID,
		veh.BilledInd,veh.DateBilled,veh.DateReceived,veh.DateShipped,veh.UpdatedDate,
		veh.UpdatedBy,veh.CreditHoldInd
		FROM
		@tbl_custvoyage custvoy
		INNER JOIN AutoportExportVehicles veh ON veh.CustomerID=custvoy.CustomerID 
			AND veh.VoyageID=custvoy.VoyageID
		WHERE 
		ISNULL(veh.BilledInd,0) = 0
		AND veh.DateShipped IS NOT NULL
		AND custvoy.VoyageID IS NOT NULL
		AND custvoy.BillToCustomerID IS NULL
		AND veh.BillToCustomerID IS NULL
		ORDER BY veh.CustomerID,veh.VoyageID, veh.AutoportExportVehiclesID;

		-- Add to @tbl_veh, BilltoCustomers with VoyageID
		INSERT INTO @tbl_veh
		(AutoportExportVehiclesID,CustomerID,BillToCustomerID,
		VoyageID,VIN,
		SizeClass,EntryRate,EntryRateOverrideInd,PerDiemGraceDays,
		PerDiemGraceDaysOverrideInd,TotalCharge,BillingID,BilledInd,
		DateBilled,DateReceived,DateShipped,UpdatedDate,UpdatedBy,CreditHoldInd)
		SELECT 
		AutoportExportVehiclesID,veh.BillToCustomerID,veh.BillToCustomerID,
		veh.VoyageID,veh.VIN,
		veh.SizeClass,veh.EntryRate,veh.EntryRateOverrideInd,veh.PerDiemGraceDays,
		veh.PerDiemGraceDaysOverrideInd,veh.TotalCharge,custvoy.ID AS BillingID,
		veh.BilledInd,veh.DateBilled,veh.DateReceived,veh.DateShipped,veh.UpdatedDate,
		veh.UpdatedBy,veh.CreditHoldInd
		FROM
		@tbl_custvoyage custvoy
		INNER JOIN AutoportExportVehicles veh ON veh.BillToCustomerID=custvoy.BillToCustomerID 
			AND veh.VoyageID=custvoy.VoyageID
		WHERE 
		ISNULL(veh.BilledInd,0) = 0
		AND veh.DateShipped IS NOT NULL
		AND custvoy.VoyageID IS NOT NULL
		AND custvoy.BillToCustomerID IS NOT NULL
		AND veh.BillToCustomerID IS NOT NULL
		ORDER BY veh.CustomerID,veh.VoyageID, veh.AutoportExportVehiclesID;

		-- Add to @tbl_veh, No VoyageID (ShippedByTruck), no BillToCustomerID
		INSERT INTO @tbl_veh
		(AutoportExportVehiclesID,CustomerID,
		VoyageID,VIN,
		SizeClass,EntryRate,EntryRateOverrideInd,PerDiemGraceDays,
		PerDiemGraceDaysOverrideInd,TotalCharge,BillingID,BilledInd,
		DateBilled,DateReceived,DateShipped,UpdatedDate,UpdatedBy,CreditHoldInd)
		SELECT 
		AutoportExportVehiclesID,veh.CustomerID,
		veh.VoyageID,veh.VIN,
		veh.SizeClass,veh.EntryRate,veh.EntryRateOverrideInd,veh.PerDiemGraceDays,
		veh.PerDiemGraceDaysOverrideInd,veh.TotalCharge,custvoy.ID AS BillingID,
		veh.BilledInd,veh.DateBilled,veh.DateReceived,veh.DateShipped,veh.UpdatedDate,
		veh.UpdatedBy,veh.CreditHoldInd
		FROM
		@tbl_custvoyage custvoy
		INNER JOIN AutoportExportVehicles veh ON veh.CustomerID=custvoy.CustomerID 
			AND veh.VoyageID IS NULL
		WHERE 
		ISNULL(veh.BilledInd,0) = 0
		AND veh.DateShipped IS NOT NULL
		AND custvoy.VoyageID IS  NULL
		AND custvoy.BillToCustomerID IS NULL
		AND veh.BillToCustomerID IS NULL
		ORDER BY veh.CustomerID,veh.VoyageID, veh.AutoportExportVehiclesID;

		-- Add to @tbl_veh, BilltoCustomers with no VoyageID (ShippedByTruck)
		INSERT INTO @tbl_veh
		(AutoportExportVehiclesID,CustomerID,BillToCustomerID,
		VoyageID,VIN,
		SizeClass,EntryRate,EntryRateOverrideInd,PerDiemGraceDays,
		PerDiemGraceDaysOverrideInd,TotalCharge,BillingID,BilledInd,
		DateBilled,DateReceived,DateShipped,UpdatedDate,UpdatedBy,CreditHoldInd)
		SELECT 
		AutoportExportVehiclesID,custvoy.BillToCustomerID,custvoy.BillToCustomerID,
		veh.VoyageID,veh.VIN,
		veh.SizeClass,veh.EntryRate,veh.EntryRateOverrideInd,veh.PerDiemGraceDays,
		veh.PerDiemGraceDaysOverrideInd,veh.TotalCharge,custvoy.ID AS BillingID,
		veh.BilledInd,veh.DateBilled,veh.DateReceived,veh.DateShipped,veh.UpdatedDate,
		veh.UpdatedBy,veh.CreditHoldInd
		FROM
		@tbl_custvoyage custvoy
		INNER JOIN AutoportExportVehicles veh ON veh.BillToCustomerID=custvoy.BillToCustomerID 
			AND veh.VoyageID IS NULL
		WHERE 
		ISNULL(veh.BilledInd,0) = 0
		AND veh.DateShipped IS NOT NULL
		AND custvoy.VoyageID IS NULL
		AND custvoy.BillToCustomerID IS NOT NULL
		AND veh.BillToCustomerID IS NOT NULL
		ORDER BY veh.CustomerID,veh.VoyageID, veh.AutoportExportVehiclesID;

		DECLARE 
		@AutoportExportVehiclesID int,
		@BillingAddressID int,
		@BillingID int,
		@CreditAccountNumber varchar(5),
		@CreditCostCenterNumber varchar(3),
		@CreditProfitCenterNumber varchar(2),
		@CustomerID int,
		@Customer varchar(50),
		@CustomerCode varchar(20),
		@date datetime = CURRENT_TIMESTAMP,
		@DateReceived datetime,
		@DateShipped datetime,
		@DebitAccountNumber varchar(5),
		@datval datetime,
		@decval decimal(19,2),
		@EntryRate decimal(19,2),
		@Errormsg varchar (2000),
		@intcurrentval int,
		@intmaxval int,
		@intval int,
		@invlength int,
		@invprefix varchar(5),
		@invcurrentvalue int,
		@InvoiceDate datetime,
		@InvoiceType varchar(20) = 'ExportCharge',
		@maxrow int,
		@nextInvNumber_original int,
		@nextInvNumber_new int,
		@PaymentMethod varchar(20) = 'Bill To Customer',
		@PerDiemGraceDays int,
		@PerDiemOverrideInd int,
		@row int,
		@SizeClass varchar(2),
		@tmp varchar(100),
		@VoyageID int,
		@VoyageDate datetime;

		-- Store 1st & last row of @tbl_custvoyage for later loop of each row
		SET @row = 1;
		SELECT @maxrow = MAX(ID) FROM @tbl_custvoyage;

		-- CHECKS:
		-- Any error, stop processing & return ERROR description for display to user

		-- Ck: CUSTOMERS MISSING BILLING ADDR ID
		SELECT TOP 1 @Customer = tbl.Customer
		FROM @tbl_custvoyage tbl
		WHERE ISNULL(BillingAddressID,0) < 1
		ORDER BY 
		tbl.Customer;

		IF LEN(ISNULL(@Customer,'')) > 0
		BEGIN
			SELECT 'ERROR: the Customer, ' + @Customer + 
					' has no Billing Address. Please correct.' AS result;
			return;	
		END;

		-- ck: LOCATION TABLE MISSING BILLING ADDRESS
		SELECT TOP 1 @Customer = tbl.Customer
		FROM @tbl_custvoyage tbl
		LEFT OUTER JOIN Customer cus on cus.CustomerID=tbl.CustomerID
		LEFT OUTER JOIN Location loc on loc.LocationID=cus.BillingAddressID
		WHERE loc.LocationID IS NULL
		ORDER BY tbl.Customer;

		IF LEN(ISNULL(@Customer,'')) > 0
		BEGIN
			SELECT 'ERROR: the Customer, ' + @Customer + ' has no Billing Address. Please correct.' AS result;
			return;	
		END;

		-- ck: CUSTOMERS MISSING CUSTOMERCODE
		SELECT TOP 1 @Customer = Customer
		FROM @tbl_custvoyage 
		WHERE LEN(RTRIM(ISNULL(CustomerCode,''))) = 0
		ORDER BY Customer;

		IF LEN(ISNULL(@Customer,'')) > 0
		BEGIN
			SELECT 'ERROR: the Customer, ' + @Customer + 
				' has no Customer Code. Please correct.' AS result;
			return;	
		END

		-- ck: VEHICLES MISSING SIZE CLASS
		SELECT @intval = COUNT(VIN)
		FROM @tbl_veh
		WHERE LEN(RTRIM(ISNULL(SizeClass,''))) = 0;

		IF @intval > 0
		BEGIN
			if @intval = 1
			BEGIN
				SELECT @tmp = VIN FROM @tbl_veh WHERE LEN(RTRIM(ISNULL(SizeClass,''))) = 0; 
				SELECT 'ERROR: Size Class is missing from VIN ' + @tmp + '.  Please correct.' AS result;
				return;	
			END
			ELSE
			BEGIN
				SELECT 'ERROR: There are ' + CAST(@intval as varchar(4)) + 
					' vehicles missing Size Class. Please correct.' AS result;
				return;	
			END
		END;

		-- ck: VEHICLES MISSING DATERECEIVED
		SELECT @intval = COUNT(VIN)
		FROM @tbl_veh
		WHERE DateReceived IS NULL;

		IF @intval > 0
		BEGIN
			if @intval = 1
			BEGIN
				SELECT @tmp = VIN FROM @tbl_veh WHERE DateReceived IS NULL; 
				SELECT 'ERROR: Date Received is missing from VIN ' + @tmp + '.  Please correct.' AS result;
				return;	
			END
			ELSE
			BEGIN
				SELECT 'ERROR: There are ' + CAST(@intval as varchar(4)) + 
					' vehicles missing Date Received. Please correct.' AS result;
				return;	
			END

		END;

		-- ck: VEHICLES MISSING DATESHIPPED
		SELECT @intval = COUNT(VIN)
		FROM @tbl_veh
		WHERE DateShipped IS NULL;

		IF @intval > 0
		BEGIN
			if @intval = 1
			BEGIN
				SELECT @tmp = VIN FROM @tbl_veh WHERE DateShipped IS NULL; 
				SELECT 'ERROR: Date Received is missing from VIN ' + @tmp + '.  Please correct.' AS result;
				return;	
			END
			ELSE
			BEGIN
				SELECT 'ERROR: There are ' + CAST(@intval as varchar(4)) + 
					' vehicles missing Date Shipped. Please correct.' AS result;
				return;	
			END
		END;

		-- ck: DateShipped < DateReceived (Date only)
		SELECT @intval = COUNT(VIN)
		FROM @tbl_veh
		WHERE CONVERT(date,DateShipped) < CONVERT(date,DateReceived);

		IF @intval > 0
		BEGIN
			if @intval = 1
			BEGIN
				SELECT @tmp = VIN FROM @tbl_veh WHERE DateShipped IS NULL; 
				SELECT 'ERROR: Date Shipped is before Date Received for VIN: ' + @tmp + '.  Please correct.' AS result;
				return;	
			END
			ELSE
			BEGIN
				SELECT 'ERROR: There are ' + CAST(@intval as varchar(4)) + 
					' vehicles where Date Shipped is before Date Received. Please correct.' AS result;
				return;	
			END
		END;

		-- ck: RATES FOR CUSTOMERS & SIZE CLASSES
		SELECT TOP 1 @Customer = tblcv.Customer,
		@SizeClass = tbl.SizeClass
		FROM @tbl_veh tbl 
		INNER JOIN @tbl_custvoyage tblcv on tblcv.CustomerID=tbl.CustomerID AND tblcv.VoyageID=tbl.VoyageID
		LEFT OUTER JOIN AutoportExportRates rates on rates.CustomerID=tblcv.CustomerID AND 
		rates.RateType = 'Size ' + tbl.SizeClass + ' Rate'
		WHERE rates.RateType IS NULL
		ORDER BY tblcv.Customer,
		tbl.SizeClass;

		IF LEN(ISNULL(@Customer,'')) > 0
		BEGIN
			SELECT 'ERROR: the Customer, ' + @Customer + 
				' has no Rates for Size Class ' + @SizeClass + '. Please correct.' AS result;
			return;	
		END;

		-- ck: DebitAccountNumber in Code Table
		SELECT @DebitAccountNumber = Code
		FROM Code
		WHERE CodeType='GLAccount' AND CodeDescription='Accounts Receivable Control';

		IF LEN(ISNULL(@DebitAccountNumber,'')) = 0
		BEGIN
			SELECT 'ERROR: the Code table has no GL Account for Accounts Receivable. Please correct.' AS result;
			return;	
		END

		-- ck: CreditAccountNumber in Code Table
		SELECT @CreditAccountNumber = Code
		FROM Code
		WHERE CodeType='GLAccount' AND CodeDescription='Autoexport Revenue';

		IF LEN(ISNULL(@CreditAccountNumber,'')) = 0
		BEGIN
			SELECT 'ERROR: the Code table has no GL Account for Autoexport Revenue. Please correct.' AS result;
			return;	
		END

		-- ck: CreditProfitCenterNumber in Code Table
		SELECT @CreditProfitCenterNumber = Code
		FROM Code
		WHERE CodeType='ProfitCenter' AND CodeDescription='Handling';

		IF LEN(ISNULL(@CreditProfitCenterNumber,'')) = 0
		BEGIN
			SELECT 'ERROR: the Code table has no Profit Center Number. Please correct.' AS result;
			return;	
		END

		-- ck: CreditCostCenterNumber in Code Table
		SELECT @CreditCostCenterNumber = Code
		FROM Code
		WHERE CodeType='CostCenter' AND CodeDescription='Autoexport';


		IF LEN(ISNULL(@CreditCostCenterNumber,'')) = 0
		BEGIN
			SELECT 'ERROR: the Code table has no Credit Cost Center Number. Please correct.' AS result;
			return;	
		END
		
		-- Insert into @tbl_IDs any rows in @tbl_veh missing EntryRate or PerDiemGraceDays
		INSERT INTO @tbl_IDs (ID)
		SELECT ID
		FROM @tbl_veh
		WHERE (ISNULL(EntryRate,-1)=-1 AND EntryRateOverrideInd=0)
		OR (ISNULL(PerDiemGraceDays,-1)=-1 AND PerDiemGraceDaysOverrideInd=0)
		ORDER BY ID;

		SELECT @intval = COUNT(ID) FROM @tbl_IDs;

		-- Update @tbl_veh with any missing EntryRates or PerDiemGraceDays
		IF @intval > 0
		BEGIN
			SELECT  @intcurrentval = MIN(ID) FROM @tbl_IDs;
			SELECT @intmaxval = MAX(ID) FROM @tbl_IDs;

			-- Loop for each row missing EntryRate or PerDiemGraceDays
			WHILE @intcurrentval <= @intmaxval
			BEGIN
				-- Store AutoportExportVehiclesID to update AutoportExportVehicles table
				SELECT @AutoportExportVehiclesID = AutoportExportVehiclesID FROM @tbl_veh WHERE ID=@intcurrentval;

				-- Ck if current row is missing EntryRate
				IF EXISTS (SELECT ID FROM @tbl_veh WHERE ID=@intcurrentval AND ISNULL(EntryRate,-1)=-1)
				BEGIN

					-- Get EntryRate from the rates tbl, get Customer & SizeClass in case no EntryRate found
					SELECT @EntryRate = ISNULL(rates.EntryFee,-1),
					@Customer = tblcv.Customer,
					@SizeClass = tbl.SizeClass
					FROM @tbl_veh tbl
					INNER JOIN @tbl_custvoyage tblcv on tblcv.CustomerID=tbl.CustomerID AND tblcv.VoyageID=tbl.VoyageID
					LEFT OUTER JOIN AutoportExportRates rates on rates.CustomerID=tbl.CustomerID 
					AND rates.RateType = 'Size ' + tbl.SizeClass + ' Rate'
					AND tbl.DateReceived >= rates.StartDate
					AND tbl.DateReceived < DATEADD(day,1,ISNULL(rates.EndDate,'12/31/2099'))
					WHERE tbl.ID=@intcurrentval;

					IF @EntryRate < 0
					BEGIN
						SELECT 'ERROR: For Customer: ' + @Customer + ', Size Class: ' + @SizeClass + 
							' there is no Entry Fee. Please correct.' AS result;
						return;
					END

					UPDATE @tbl_veh SET EntryRate = @EntryRate WHERE ID = @intcurrentval;
					UPDATE AutoportExportVehicles SET EntryRate = @EntryRate 
						WHERE AutoportExportVehiclesID = @AutoportExportVehiclesID;
				END	--if current row is missing EntryRate

				-- Ck if current row is missing PerDiemGraceDays
				IF EXISTS (SELECT ID FROM @tbl_veh WHERE ID=@intcurrentval AND ISNULL(PerDiemGraceDays,-1)=-1)
				BEGIN
					-- Get PerDiemRate from the rates tbl, get Customer & SizeClass in case no EntryRate found
					SELECT @PerDiemGraceDays = ISNULL(rates.PerDiemGraceDays,-1),
					@Customer = tblcv.Customer,
					@SizeClass = tbl.SizeClass
					FROM @tbl_veh tbl
					INNER JOIN @tbl_custvoyage tblcv on tblcv.CustomerID=tbl.CustomerID AND tblcv.VoyageID=tbl.VoyageID
					LEFT OUTER JOIN AutoportExportRates rates on rates.CustomerID=tbl.CustomerID 
					AND rates.RateType = 'Size ' + tbl.SizeClass + ' Rate'
					AND tbl.DateReceived >= rates.StartDate
					AND tbl.DateReceived < DATEADD(day,1,ISNULL(rates.EndDate,'12/31/2099'))
					WHERE tbl.ID=@intcurrentval;

					IF @PerDiemGraceDays < 0
					BEGIN
						SELECT 'ERROR: For Customer: ' + @Customer + ', Size Class: ' + @SizeClass + 
						' there are no Per Diem Grace Days. Please correct.' AS result;
						return;
					END

					UPDATE @tbl_veh SET PerDiemGraceDays = @PerDiemGraceDays WHERE ID = @intcurrentval;
					UPDATE AutoportExportVehicles SET PerDiemGraceDays = @PerDiemGraceDays
						WHERE AutoportExportVehiclesID = @AutoportExportVehiclesID;
				END	--if current row is missing PerDiemGraceDays

				-- Set @intcurrentval to the next ID, if there is one
				IF EXISTS 
				(SELECT ID FROM @tbl_IDs WHERE ID > @intcurrentval)
				BEGIN
					SELECT TOP 1 @intcurrentval = ID 
					FROM @tbl_IDs
					WHERE ID > @intcurrentval
					ORDER BY ID;
				END
				ELSE
				BEGIN
					SET @intcurrentval = 999999;
				END

			END	-- WHILE  @intcurrentval <= @intmaxval
		END	-- IF any rows in @tbl_IDs		

		-- Get Next Inv#, Inv. prefix, Inv. length from Setting Table
		SELECT @nextInvNumber_original = CAST(ValueDescription AS int) FROM SettingTable WHERE ValueKey='NextAutoportExportInvoiceNumber';
		IF @nextInvNumber_original IS NULL
		BEGIN
			SELECT 'ERROR: there is no Next Invoice Number in the Setting table. IS has been notified.' AS result;
			return;
		END
		SET @nextInvNumber_new = @nextInvNumber_original;

		SELECT @invprefix = ValueDescription FROM SettingTable WHERE ValueKey='AutoportExportInvoiceNumberPrefix';
		IF @invprefix IS NULL
		BEGIN
			SELECT 'ERROR: there is no Invoice Prefix in the Setting table. IS has been notified.' AS result;
			return;
		END

		SELECT @invlength = CAST(ValueDescription AS int) FROM SettingTable WHERE ValueKey='AutoportExportInvoiceNumberLength';
		IF @invlength IS NULL
		BEGIN
			SELECT 'ERROR: there is no Invoice Length in the Setting table. IS has been notified.' AS result;
			return;
		END

		-- Outer most Loop: for each row in @tbl_custvoyage
		--	o Calculate next Inv#
		--  o 
		-- Next Loop: for each vehicle associated with row from @tbl_custvoyage
		-- Inner most Loop: for each day between DateReceived - DateShipped for current vehicle
		-- Insert new recs into @tbl_perdiem for each day's charge (DateReceived - DateShipped) on every vehicle
		-- Update @tbl_veh with TotalCharge, BilledInd=1, DateBilled=@date
		SET @row = 1;
		SELECT @maxrow = MAX(ID) FROM @tbl_custvoyage;

		WHILE @row <= @maxrow
		BEGIN
			-- Store Inv# to use for the Cust/Voyage in @tbl_custvoyage
			UPDATE @tbl_custvoyage SET InvoiceNumber = @nextInvNumber_new WHERE ID=@row;
			SET @nextInvNumber_new = @nextInvNumber_new + 1;

			-- Create a new row in @tbl_billing
			INSERT INTO @tbl_billing(BillingID,CustomerID,InvoiceDate,InvoiceNumber_int)
			SELECT ID AS BillingID,CustomerID, 
			InvoiceDate,
			InvoiceNumber
			FROM @tbl_custvoyage WHERE ID = @row;

			-- Store current CustomerID, VoyageID,InvoiceDate from @tbl_custvoyage
			SELECT @CustomerID = CustomerID,@VoyageID = ISNULL(VoyageID,0),@InvoiceDate=InvoiceDate
			FROM @tbl_custvoyage tbl
			WHERE tbl.ID=@row;

			-- Store MIN/MAX VehID from @tbl_veh for current custvoyage row being processed
			SELECT TOP 1 @intcurrentval = AutoportExportVehiclesID 
			FROM @tbl_veh
			WHERE BillingID = @row
			ORDER BY AutoportExportVehiclesID;

			SELECT TOP 1 @intmaxval = AutoportExportVehiclesID 
			FROM @tbl_veh
			WHERE BillingID = @row
			ORDER BY AutoportExportVehiclesID DESC;

			-- Loop through each VehID in tbl_veh, create PerDiem recs in tbl_perdiem
			-- CAST DateRecievied & datval as dates so WHILE @deatval <= @DateShipped calculates
			--	correctly without time values
			WHILE @intcurrentval > 0
			BEGIN
				SET @AutoportExportVehiclesID = @intcurrentval;
				SELECT @DateReceived = CAST(DateReceived AS date), 
				@DateShipped = CAST(Dateshipped AS date),
				@PerDiemGraceDays = PerDiemGraceDays,
				@EntryRate = EntryRate,
				@SizeClass = SizeClass
				FROM @tbl_veh 
				WHERE AutoportExportVehiclesID=@AutoportExportVehiclesID;
		
				SET @datval = @DateReceived;
				SET @intval = 1; -- use to count each day of perdiem

				-- Loop through each day between @DateReceived - @DateShipped
				WHILE @datval <= @DateShipped
				BEGIN
					SET @decval = 0.00;

					-- Look up PerDiem if day (intval) is AFTER PerDiemGraceDays
					IF (@intval > @PerDiemGraceDays)
					BEGIN
						SELECT @decval = PerDiem FROM AutoportExportRates
						WHERE CustomerID = @CustomerID AND 
						RateType = 'Size ' + @SizeClass + ' Rate' AND
						@datval >= StartDate AND
						@datval < DATEADD(day,1,ISNULL(EndDate,'12/31/2099'));

						IF @decval IS NULL
						BEGIN
							SELECT 'ERROR: there is no PerDiem Rate for Customer: ' + @Customer + ', for Size Class: ' + @SizeClass + 
								', for the Date: ' + CONVERT(varchar(10),@datval,101) + '. Please correct.' AS result;
							return;
						END
					END	-- IF (@intval > @PerDiemGraceDays)

					-- Insert a rec into @tbl_perdiem
					INSERT INTO @tbl_perdiem (AutoportExportVehiclesID,PerDiemDate,PerDiem)
					VALUES (@intcurrentval,@datval,@decval);

					SET @intval = @intval + 1;
					SET @datval = DATEADD(day,1,@datval);
			
				END	-- WHILE @datval <= @DateShipped, loop through PerDiem dates for current vehID
		
				-- Update tbl_veh with total charge
				SELECT @decval = SUM(PerDiem) FROM @tbl_perdiem WHERE AutoportExportVehiclesID=@intcurrentval ;
				UPDATE @tbl_veh SET TotalCharge = @decval WHERE AutoportExportVehiclesID = @intcurrentval;
		

				IF @intcurrentval = @intmaxval
					SET @intcurrentval = -1;
				ELSE
				BEGIN
						-- Get next vehID as @intcurrentval by joining w/@tbl_custvoyage
						SELECT TOP 1 @intcurrentval = AutoportExportVehiclesID 
						FROM @tbl_veh
						WHERE BillingID = @row AND AutoportExportVehiclesID > @intcurrentval
						ORDER BY AutoportExportVehiclesID;
				END

			END	-- WHILE @intcurrentval > 0, loop through VehIDs for current cust/voy pair

			SET @row = @row + 1;
		END	-- WHILE @row <= @maxrow, loop through cust/voy pairs

		-- Set TotalCharge in tbl_veh by adding EntryRate
		UPDATE @tbl_veh SET TotalCharge = TotalCharge + EntryRate,
		BilledInd = 1,
		DateBilled = @date;

		-- Update tbl_Billing w/InvoiceAmount
		WITH cte AS
		(SELECT BillingID,SUM(TotalCharge) as total 
		FROM @tbl_veh
		Group By BillingID)
		UPDATE bill
		SET InvoiceAmount = cte.total
		FROM @tbl_billing bill
		INNER JOIN @tbl_veh veh on veh.CustomerID=bill.CustomerID AND veh.BillingID=bill.BillingID
		INNER JOIN cte on cte.BillingID=bill.BillingID

		-- Make sure NextInv# in Setting table hasn't changed
		SELECT @invcurrentvalue = 
		CAST(ValueDescription AS int) FROM SettingTable WHERE ValueKey='NextAutoportExportInvoiceNumber';

		IF @invcurrentvalue <> @nextInvNumber_original
		BEGIN
			SET @row = 1;
			SET @nextInvNumber_new = @invcurrentvalue;

			-- Update each row of @tbl_custvoyage with new InvoiceNumber
			WHILE @row <= @maxrow
			BEGIN
				UPDATE @tbl_custvoyage SET InvoiceNumber = @nextInvNumber_new WHERE ID=@row;
				SET @nextInvNumber_new = @nextInvNumber_new + 1;

				-- Update InvoiceNumber_int in @tbl_billing
				UPDATE @tbl_billing SET InvoiceNumber_int = @nextInvNumber_new WHERE BillingID = @row;		
			END
		END

		-- Add InvoiceNumber_ch to @tbl_Billing
		SET @row = 1;
		WHILE @row <= @maxrow
		BEGIN
			SELECT @nextInvNumber_new = InvoiceNumber_int FROM @tbl_billing WHERE BillingID=@row;

			-- Get the length of Inv prefix = row's Inv# (e.g. 'EX777')  = 5
			SET @tmp = @invprefix + CAST(@nextInvNumber_new AS varchar(6));
			SET @intval = @invlength - LEN(@tmp);

			SELECT @tmp = @invprefix + RIGHT('000000',@intval) + CAST(@nextInvNumber_new AS varchar(6));
			UPDATE @tbl_billing SET InvoiceNumber_ch = @tmp WHERE BillingID = @row;

			set @row = @row + 1;
		END

		-- Update NextInv# in Setting table 
		UPDATE SettingTable SET ValueDescription = CAST(@nextInvNumber_new + 1 AS varchar(5)) 
		WHERE ValueKey='NextAutoportExportInvoiceNumber';

		-- Insert recs into AutoportExportPerDiem from tbl_PerDiem
		INSERT INTO AutoportExportPerDiem (AutoportExportVehiclesID,PerDiemDate,PerDiem,PerDiemOverrideInd,
		CreatedBy,CreationDate) 
		SELECT 
		AutoportExportVehiclesID,PerDiemDate,PerDiem,
		0 AS PerDiemOverrideInd,
		@user AS CreatedBy,
		@date AS CretionDate
		FROM @tbl_perdiem;

		-- Insert recs into Billing table from tbl_billing
		INSERT INTO Billing (CustomerID,OutsideCarrierInvoiceInd,InvoiceDate,InvoiceNumber,
		InvoiceType,PaymentMethod,TransportCharges,FuelSurchargeRate,
		FuelSurchargeRateOverrideInd,FuelSurcharge,FuelSurchargeOverrideInd,
		OtherCharge1,OtherCharge1Description,
		OtherCharge2,OtherCharge2Description,
		OtherCharge3,OtherCharge3Description,
		OtherCharge4,OtherCharge4Description,
		InvoiceAmount,AmountPaid,CreditsIssued,
		BalanceDue,DueToOutsideCarriers,DueFromOutsideCarriers,
		PaidInFullInd,
		InvoiceStatus,PrintedInd,
		CreditMemoInd,
		CreditedOutInd,
		CreationDate,
		CreatedBy,
		StorageCharges)
		SELECT 
		bill.CustomerID,
		0 AS OutsideCarrierInvoiceInd,
		custvoy.InvoiceDate AS InvoiceDate,
		bill.InvoiceNumber_ch AS InvoiceNumber,
		@InvoiceType AS Invoicetype,
		@PaymentMethod AS PaymentMethod,
		0.00 AS TransportCharges,
		0.00 AS FuelSurchargeRate,
		0 AS FuelSurchargeRateOverrideInd,
		0.00 AS FuelSurcharge,
		0 AS FuelSurchargeOverrideInd,
		0.00 AS OtherCharge1,
		'N/A' AS OtherCharge1Description,
		0.00 AS OtherCharge2,
		'N/A' AS OtherCharge2Description,
		0.00 AS OtherCharge3,
		'N/A' AS OtherCharge3Description,
		0.00 AS OtherCharge4,
		'N/A' AS OtherCharge4Description,
		bill.InvoiceAmount,
		0.00 AS AmountPaid,
		0.00 AS CreditsIssued,
		bill.InvoiceAmount AS BalanceDue,
		0.00 AS DueToOutsideCarriers,
		0.00 AS DueFromOutsideCarriers,
		0 AS PaidInFullInd,
		'Pending' AS InvoiceStatus,
		0 AS PrintedInd,
		0 AS CreditMemoInd,
		0 AS CreditOutInd,
		@date AS CreationDate,
		@user AS CreatedBy,
		bill.InvoiceAmount AS StorageCharges
		FROM @tbl_billing bill
		INNER JOIN @tbl_custvoyage custvoy on custvoy.ID = bill.BillingID;

		-- Update BillingID_new in @tbl_billing with new BillingIDs in Billing tbl
		UPDATE tbl
		SET BillingID_new = bill.BillingID
		FROM @tbl_billing tbl
		INNER JOIN Billing bill on bill.InvoiceNumber = tbl.InvoiceNumber_ch;

		-- Insert recs into BillingLineItems table from tbl_billing
		INSERT INTO BillingLineItems (CustomerID,BillingID,CustomerNumber,InvoiceNumber,
		InvoiceDate,DebitAccountNumber,DebitProfitCenterNumber,DebitCostCenterNumber,
		CreditAccountNumber,CreditProfitCenterNumber,CreditCostCenterNumber,
		ARTransactionAmount,
		CreditMemoInd,Description,ExportedInd,CreationDate,CreatedBy)
		SELECT
		bill.CustomerID,
		bill.BillingID_new,
		custvoy.CustomerCode AS CustomerNumber,
		bill.InvoiceNumber_ch AS InvoiceNumber,
		bill.InvoiceDate,
		@DebitAccountNumber AS DebitAccountNumber,
		'' AS DebitProfitCenterNumber,
		'' AS DebitCostCenterNumber,
		@CreditAccountNumber AS CreditAccountNumber,
		@CreditProfitCenterNumber AS CreditProfitCenterNumber,
		@CreditCostCenterNumber AS CreditCostCenterNumber,
		bill.InvoiceAmount AS ARTransactionAmount,
		0 CreditMemoInd,
		'Autoport Export' AS Description,
		0 AS ExportedInd,
		@date AS CreationDate,
		@user AS CreatedBy
		FROM
		@tbl_billing bill
		INNER JOIN @tbl_custvoyage custvoy on custvoy.ID=bill.BillingID

		-- Update Veh table with billing info
		UPDATE veh
		SET veh.TotalCharge = tbl.Totalcharge,
		veh.BillingID = bill.BillingID_new,
		veh.BilledInd=1,
		veh.DateBilled = @date,
		veh.UpdatedBy = @user,
		veh.UpdatedDate=@date
		FROM @tbl_veh tbl
		INNER JOIN AutoportExportVehicles veh on veh.AutoportExportVehiclesID=tbl.AutoportExportVehiclesID
		INNER JOIN @tbl_custvoyage custvoy on custvoy.CustomerID=tbl.CustomerID and custvoy.ID=tbl.BillingID
		INNER JOIN @tbl_billing bill on bill.BillingID=custvoy.ID

		-- Return OK as result, and new BillingIDs created
		SELECT 'OK' AS result,BillingID_new
		FROM @tbl_billing;

	END TRY

	-- Based on Microsoft example: 
	-- https://docs.microsoft.com/en-us/sql/t-sql/language-elements/try-catch-transact-sql
	BEGIN CATCH
		-- Remove any recs added to Billing, BillingLineItems, & PerDiem tables
		DELETE AutoportExportPerDiem WHERE CreationDate=@date;
		DELETE Billing WHERE CreationDate=@date;
		DELETE BillingLineItems WHERE CreationDate=@date;

		SELECT
		'ERROR' AS result,
		ERROR_NUMBER() AS ErrorNumber,
		ERROR_SEVERITY() AS ErrorSeverity,
		ERROR_STATE() AS ErrorState,
		ERROR_PROCEDURE() AS ErrorProcedure,
		ERROR_LINE() AS ErrorLine,
		ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
    
END
GO
