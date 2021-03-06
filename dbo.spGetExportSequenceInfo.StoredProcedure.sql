USE [AutoExport]
GO
/****** Object:  StoredProcedure [dbo].[spGetExportSequenceInfo]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











/***************************************************
	CREATED	: Feb 07 2012 (Vio)
	UPDATED	: 
	DESC	: Get All sequences for a specified Voyage
****************************************************/
CREATE  PROCEDURE [dbo].[spGetExportSequenceInfo]
	@VoyageID int
AS
BEGIN

	SELECT	CONVERT(varchar(10),AEV.VoyageDate,101) + ' ' + ISNULL(AEV2.VesselName,'')
	FROM	AEVoyage AEV
			LEFT JOIN AEVessel AEV2 ON AEV.AEVesselID = AEV2.AEVesselID
	WHERE	AEV.AEVoyageID = @VoyageID

/*
	SELECT	AEVLS.Sequence AS Code, AEVLS.Sequence  AS Description
	FROM	AEVoyageLoadSequence AEVLS
	WHERE	AEVLS.VoyageID = @VoyageID
	ORDER	BY AEVLS.Sequence
*/

/*
	convert(varchar, isnull(AEVLS.CustomerID, 0)) + ' - '
*/

	SELECT AEVLS.Sequence as Code, '' + convert(varchar, isnull(AEVLS.Sequence, 0)) + ' - ' + 
		CASE WHEN DATALENGTH(C.ShortName) > 0 THEN C.ShortName ELSE isnull(C.CustomerName, '') END + ' - ' +
		isnull(AEVLS.DestinationName, '') + ' - ' + isnull(AEVLS.SizeClass, '') as Description
	FROM  AEVoyageLoadSequence AEVLS
	LEFT JOIN Customer C ON AEVLS.CustomerID = C.CustomerID
	WHERE            AEVLS.VoyageID = @VoyageID
	ORDER BY AEVLS.Sequence


END











GO
