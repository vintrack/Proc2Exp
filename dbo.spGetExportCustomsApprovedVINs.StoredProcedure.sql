USE [AutoExport]
GO
/****** Object:  StoredProcedure [dbo].[spGetExportCustomsApprovedVINs]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetExportCustomsApprovedVINs]
AS
BEGIN
	
	/*
	   This goes into AutoExport database
	*/ 
 
	SELECT TOP 1 [VoyageID]
	  , convert(varchar(10), [VoyageDate]) + ' ' + [VesselName] + ' ' + convert(varchar, [CreationTime], 108)
	FROM [dbo].[CustomsApprovedLine1]
	ORDER BY 1 DESC

	SELECT [VIN]
	  ,[DestinationName]
	FROM [dbo].[CustomsApprovedVINs]
  
END
GO
