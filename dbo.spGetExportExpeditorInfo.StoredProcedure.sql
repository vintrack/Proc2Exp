USE [AutoExport]
GO
/****** Object:  StoredProcedure [dbo].[spGetExportExpeditorInfo]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







/***************************************************
	CREATED	: Feb 07 2012 (Vio)
	UPDATED	: 
	DESC	: 
****************************************************/
CREATE  PROCEDURE [dbo].[spGetExportExpeditorInfo]
	@VoyageID int
AS
BEGIN

	SELECT	CONVERT(varchar(10),AEV.VoyageDate,101) + ' ' + AEV2.VesselName
	FROM	AEVoyage AEV
			LEFT JOIN AEVessel AEV2 ON AEV.AEVesselID = AEV2.AEVesselID
	WHERE	AEV.AEVoyageID = @VoyageID

	SELECT	AEV.VIN, AEV.DestinationName,
			CASE	WHEN CHARINDEX(' ',AEV.BayLocation) > 0 
					THEN LEFT(AEV.BayLocation,CHARINDEX(' ',AEV.BayLocation)-1)
					ELSE AEV.BayLocation 
			END AS Row,
			CASE	WHEN CHARINDEX(' ',AEV.BayLocation) > 0
					THEN RIGHT(AEV.BayLocation,DATALENGTH(AEV.BayLocation)-CHARINDEX(' ',AEV.BayLocation)+1)
					ELSE '' 
			END AS Bay
	FROM	AutoportExportVehicles AEV
	WHERE	AEV.VoyageID = @VoyageID
			AND AEV.DateShipped IS NULL 
			and AEV.CustomsApprovedDate is not null
		
END







GO
