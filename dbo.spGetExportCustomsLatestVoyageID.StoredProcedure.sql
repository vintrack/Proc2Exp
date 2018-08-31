USE [AutoExport]
GO
/****** Object:  StoredProcedure [dbo].[spGetExportCustomsLatestVoyageID]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetExportCustomsLatestVoyageID]
AS
BEGIN
	
	/*
	   This goes into AutoExport database
	*/ 
 
	SELECT TOP 1 [VoyageID]
	FROM [dbo].[CustomsApprovedLine1]
	ORDER BY 1 DESC
  
END

GO
