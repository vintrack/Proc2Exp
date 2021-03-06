USE [AutoExport]
GO
/****** Object:  StoredProcedure [dbo].[spVehiclesOnHold]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Maibor
-- Create date: 10/2/17
-- Description:	Return data for Vehicles On Hold reports
-- 4/16/18 D.Maibor: change ROW_NUMBER to ORDER BY DateReceived
-- 4/9/18 D.Maibor: per Jay Wildfeuer, add date received
-- =============================================
CREATE PROCEDURE [dbo].[spVehiclesOnHold]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    
SELECT 
ROW_NUMBER() OVER (ORDER BY DateReceived) AS rownum,
                CASE 
	                WHEN DATALENGTH(cus.ShortName) > 0 THEN cus.ShortName 
	                ELSE cus.CustomerName 
                END AS customer,
                veh.VIN, 
                veh.Make, 
                veh.Model, 
                veh.BayLocation,
                veh.VehicleStatus AS exception,
                CASE
					WHEN veh.UpdatedDate IS NOT NULL THEN CONVERT(varchar(10),veh.UpdatedDate,101)
					ELSE CONVERT(varchar(10),veh.CreationDate,101)
				END AS exdate,
				CONVERT(varchar(10), veh.DateReceived,101) AS datereceived
                FROM AutoportExportVehicles veh
                LEFT OUTER JOIN Customer cus ON veh.CustomerID = cus.CustomerID
                WHERE veh.VehicleStatus LIKE '%Exception%' OR
                veh.VehicleStatus LIKE '%Hold%'  
				ORDER BY veh.DateReceived
END
GO
