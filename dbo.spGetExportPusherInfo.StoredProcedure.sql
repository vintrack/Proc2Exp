USE [AutoExport]
GO
/****** Object:  StoredProcedure [dbo].[spGetExportPusherInfo]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/***************************************************
	CREATED	: Apr 2012 (Cristi P)
	UPDATED	: 
	DESC	: Search for all Vehicles for Pusher screen
****************************************************/
CREATE PROCEDURE [dbo].[spGetExportPusherInfo]
	@voyageID int
AS
BEGIN

SELECT	CONVERT(varchar(10),AEV.VoyageDate,101) + ' ' + ISNULL(AEV2.VesselName,'') AS HeaderLine
FROM	AEVoyage AEV
		LEFT JOIN AEVessel AEV2 ON AEV.AEVesselID = AEV2.AEVesselID
WHERE	AEV.AEVoyageID = @VoyageID

SELECT	AEV.VIN, 
		AEV.DestinationName,
		CASE WHEN CHARINDEX(' ',AEV.BayLocation) > 0 
			THEN LEFT(AEV.BayLocation,CHARINDEX(' ',AEV.BayLocation)-1) 
			ELSE AEV.BayLocation END AS Row,
		CASE WHEN CHARINDEX(' ',AEV.BayLocation) > 0 
			THEN SUBSTRING(AEV.BayLocation,CHARINDEX(' ',AEV.BayLocation)+1,DATALENGTH(AEV.BayLocation)-CHARINDEX(' ',AEV.BayLocation)) 
			ELSE '' END AS Bay
INTO #tmpExportPusherInfo
FROM	AutoportExportVehicles AEV
WHERE	AEV.VoyageID = @voyageId 
		AND AEV.DateShipped IS NULL
		and AEV.CustomsApprovedDate is not null
		AND isnull(AEV.NoStartInd, 0) = 1

SELECT COUNT(*) FROM #tmpExportPusherInfo

SELECT * FROM #tmpExportPusherInfo
ORDER BY len(Row), Row, len(Bay), Bay

END










GO
