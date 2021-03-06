USE [AutoExport]
GO
/****** Object:  StoredProcedure [dbo].[spGetExportLoadDirectorInfo]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/***************************************************
	CREATED	: Jan 07 2012 (Vio)
	UPDATED	: 
	DESC	: Search for all Vehicles Left Behind
****************************************************/
CREATE   PROCEDURE [dbo].[spGetExportLoadDirectorInfo]
	@VoyageID int
AS
BEGIN

	SELECT	CONVERT(varchar(10),AEV.VoyageDate,101) + ' ' + ISNULL(AEV2.VesselName,'') AS HeaderLine
	FROM	AEVoyage AEV
			LEFT JOIN AEVessel AEV2 ON AEV.AEVesselID = AEV2.AEVesselID
	WHERE	AEV.AEVoyageID = @VoyageID

	SELECT	isnull(AEVLS.Sequence, 0) as Sequence,
			AEV.DestinationName,
			CASE WHEN CHARINDEX(' ',AEV.BayLocation) > 0 THEN SUBSTRING(AEV.BayLocation,1,CHARINDEX(' ',AEV.BayLocation)-1) ELSE AEV.BayLocation END AS Row,
			AEV.SizeClass,
			COUNT(*) AS Total,
			SUM	(CASE WHEN AEV.LeftBehindInd IS NULL THEN 0 ELSE AEV.LeftBehindInd END) AS LeftBehind,
			SUM	(CASE when AEV.NoStartInd is null then 0 else AEV.NoStartInd end)AS NonRunner
	INTO #tmpExportLoadDirectorInfo
	FROM	AutoportExportVehicles AEV
			left JOIN AEVoyageLoadSequence AEVLS ON AEVLS.VoyageID = AEV.VoyageID AND AEVLS.CustomerID = AEV.CustomerID AND AEVLS.DestinationName = AEV.DestinationName AND AEVLS.SizeClass = AEV.SizeClass
	WHERE	AEV.VoyageID = @VoyageID
			AND AEV.DateShipped IS NULL
			AND AEV.CustomsApprovedDate is not null
	GROUP	BY	AEVLS.Sequence, AEV.DestinationName, AEV.SizeClass,
			CASE WHEN CHARINDEX(' ',AEV.BayLocation) > 0 THEN SUBSTRING(AEV.BayLocation,1,CHARINDEX(' ',AEV.BayLocation)-1) ELSE AEV.BayLocation END
	ORDER	BY --AEVLS.Sequence, 
			CASE WHEN CHARINDEX(' ',AEV.BayLocation) > 0 THEN SUBSTRING(AEV.BayLocation,1,CHARINDEX(' ',AEV.BayLocation)-1) ELSE AEV.BayLocation END,
			AEV.DestinationName

	select sum(Total) as GrandTotal from #tmpExportLoadDirectorInfo

	select * from #tmpExportLoadDirectorInfo
	order by Sequence, Row, DestinationName

	drop table #tmpExportLoadDirectorInfo
END









GO
