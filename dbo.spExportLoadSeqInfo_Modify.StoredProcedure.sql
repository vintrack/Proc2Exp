USE [AutoExport]
GO
/****** Object:  StoredProcedure [dbo].[spExportLoadSeqInfo_Modify]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Maibor
-- Create date: 4/28/2017
-- Description:	Return Load Seq info for Export sheet
--              Outputs # of Vehicles that have not cleared customs.
-- Modifications
-- 1/18/18 David Maibor: add where Size is not null in final select
-- 11/9/17 Peter T. Owens-Finch: add CustomNotCleared col to output data Also, removed SortOrder column.
-- =============================================
CREATE PROCEDURE [dbo].[spExportLoadSeqInfo_Modify]
	@VoyageID int,
	@OnlyClearedVehs bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- ***** Start ***
-- Create temp table for output
-- Removed SortOrder
CREATE TABLE #tmpoutput
(
Sequence int,
DestinationName varchar(20),
BayLocRow varchar(20),
Size varchar(10),
Units int,
VIV int,
CustomsNotClearedCount int,
);

-- Create recs in #tmpoutput for each Sequence/DestinationName,Row pair needed
-- Restrict to veh's w/ClearedCustoms status if @OnlyClearedVehs = 1
	INSERT INTO #tmpoutput (Sequence,DestinationName,BayLocRow)
	SELECT DISTINCT seq.Sequence, 
	veh.DestinationName,
	CASE 
		WHEN CHARINDEX(' ',veh.BayLocation) > 0 THEN SUBSTRING(veh.BayLocation,1,CHARINDEX(' ',veh.BayLocation)-1) 
		ELSE veh.BayLocation 
	END AS BayLocRow
	FROM AEVoyageLoadSequence seq
	LEFT JOIN AutoportExportVehicles veh ON seq.VoyageID = veh.VoyageID AND seq.CustomerID = veh.CustomerID
		AND seq.DestinationName = veh.DestinationName AND seq.SizeClass = veh.SizeClass
	WHERE 
	seq.VoyageID = @VoyageID
	AND veh.DateShipped IS NULL
	AND (@OnlyClearedVehs = 1 AND veh.VehicleStatus='ClearedCustoms'
	OR @OnlyClearedVehs = 0 AND veh.VehicleStatus IS NOT NULL);

-- Create tmp table, #tmprawdata to hold all rows of data, one row per SizeClass
-- Peter Owens-Finch, 11/9/17: Add CustomsNotClearedCount to #tmprawdata.
CREATE TABLE #tmprawdata
(
Sequence int,
DestinationName varchar(20),
BayLocRow varchar(20),
Size varchar(10),
Units int,
VIV int,
CustomsNotClearedCount int
);

-- Use modified DATS query to fill #tmprawdata, restrict to vehs with ClearedCustoms status if @OnlyClearedVehs=1
-- Peter Owens-Finch, 11/9/17: Add CustomsNotClearedCount to qry
INSERT INTO #tmprawdata
SELECT seq.Sequence, 
veh.DestinationName,
CASE 
	WHEN CHARINDEX(' ',veh.BayLocation) > 0 THEN SUBSTRING(veh.BayLocation,1,CHARINDEX(' ',veh.BayLocation)-1) 
	ELSE veh.BayLocation 
END AS BaylocRow,
veh.SizeClass,
COUNT(*) Units,
SUM(CASE 
	WHEN LEN(RTRIM(ISNULL(veh.VIVTagNumber,''))) > 0 THEN 1 
	ELSE 0 
END) AS VIV,
SUM(CASE
	WHEN veh.VehicleStatus<>'ClearedCustoms' THEN 1
	ELSE 0
END) AS CustomsNotClearedCount
FROM AEVoyageLoadSequence seq
LEFT JOIN AutoportExportVehicles veh ON seq.VoyageID = veh.VoyageID AND seq.CustomerID = veh.CustomerID
	AND seq.DestinationName = veh.DestinationName AND seq.SizeClass = veh.SizeClass
WHERE 
seq.VoyageID = @VoyageID
AND veh.DateShipped IS NULL
AND (@OnlyClearedVehs = 1 AND veh.VehicleStatus='ClearedCustoms'
	OR @OnlyClearedVehs = 0 AND veh.VehicleStatus IS NOT NULL)
GROUP BY 
seq.Sequence, 
CASE 
	WHEN CHARINDEX(' ',veh.BayLocation) > 0 THEN SUBSTRING(veh.BayLocation,1,CHARINDEX(' ',veh.BayLocation)-1) 
	ELSE veh.BayLocation 
END,
veh.DestinationName,
veh.SizeClass


-- Create tmp table, #tmpmultisizes to hold all rows from #tmprawdata where multiple
--	SizeClasses for the same row
-- Peter Owens-Finch, 11/9/17: Add CustomsNotClearedCount to #tmpmultisizes. 
CREATE TABLE #tmpmultisizes
(
Sequence int,
DestinationName varchar(20),
BaylocRow varchar(20),
Size varchar(10),
SizeClasses int,
Units int,
VIV int,
CustomsNotClearedCount int
);

-- Peter Owens-Finch, 11/9/17: Add CustomsNotClearedCount to insert
INSERT INTO #tmpmultisizes (Sequence,DestinationName,
BaylocRow,SizeClasses,Units,VIV,CustomsNotClearedCount)
select Sequence,
DestinationName,
BaylocRow,
COUNT(Size) As SizeClasses,
SUM(Units) as Units,
SUM(VIV) AS VIV,
SUM(CustomsNotClearedCount) AS CustomsNotClearedCount
from #tmprawdata
GROUP BY
Sequence,DestinationName,BaylocRow
HAVING COUNT(Size) > 1
ORDER BY Sequence,BaylocRow

-- Update #tmpOutput from #tmprawdata for all BaylocRows with only one SizeClass
UPDATE out
SET out.Size=raw.Size, out.Units=raw.Units,out.VIV=raw.VIV,out.CustomsNotClearedCount=raw.CustomsNotClearedCount
FROM #tmpoutput out
INNER JOIN #tmprawdata raw on raw.Sequence=out.Sequence and 
	raw.DestinationName=out.DestinationName and raw.BayLocRow=out.BayLocRow
LEFT OUTER JOIN #tmpmultisizes multi on multi.Sequence=out.Sequence and
	multi.DestinationName=out.DestinationName and 
	multi.BaylocRow=out.BayLocRow
WHERE multi.Sequence IS NULL;

-- #tmpOutput now has all the data for ByLocRows with only one SizeClass

-- Update ##tmpmultisizes with multiple sizes
UPDATE multi
SET Size = CAST(ISNULL(rawA.Size,'') AS varchar(1)) + 
CAST(ISNULL(rawB.Size,'') AS varchar(1)) + 
CAST(ISNULL(rawC.Size,'') AS varchar(1)) + 
CAST(ISNULL(rawD.Size,'') AS varchar(1)) + 
CAST(ISNULL(rawE.Size,'') AS varchar(1)) +
CAST(ISNULL(rawZ.Size,'') AS varchar(1))
FROM #tmpmultisizes multi
LEFT OUTER JOIN #tmprawdata rawA on rawA.Sequence=multi.Sequence
	and rawA.DestinationName=multi.DestinationName
	and rawA.BayLocRow=multi.BaylocRow
	and rawA.Size='A'
LEFT OUTER JOIN #tmprawdata rawB on rawB.Sequence=multi.Sequence
	and rawB.DestinationName=multi.DestinationName
	and rawB.BayLocRow=multi.BaylocRow
	and rawB.Size='B'
LEFT OUTER JOIN #tmprawdata rawC on rawC.Sequence=multi.Sequence
	and rawC.DestinationName=multi.DestinationName
	and rawC.BayLocRow=multi.BaylocRow
	and rawC.Size='C'
LEFT OUTER JOIN #tmprawdata rawD on rawD.Sequence=multi.Sequence
	and rawD.DestinationName=multi.DestinationName
	and rawD.BayLocRow=multi.BaylocRow
	and rawD.Size='D'
LEFT OUTER JOIN #tmprawdata rawE on rawE.Sequence=multi.Sequence
	and rawE.DestinationName=multi.DestinationName
	and rawE.BayLocRow=multi.BaylocRow
	and rawE.Size='E'
LEFT OUTER JOIN #tmprawdata rawZ on rawZ.Sequence=multi.Sequence
	and rawZ.DestinationName=multi.DestinationName
	and rawZ.BayLocRow=multi.BaylocRow
	and rawZ.Size='Z'

-- Update tmpoutput with the multi sizes in #tmpmultisizes
-- Peter Owens-Finch, 11/9/17: Add CustomsNotClearedCount to Update.
UPDATE out
SET out.Size=multi.Size,
out.Units=multi.Units,
out.VIV=multi.VIV,
out.CustomsNotClearedCount=multi.CustomsNotClearedCount
FROM
#tmpoutput out
INNER JOIN #tmpmultisizes multi on multi.Sequence=out.Sequence and
	multi.DestinationName=out.DestinationName and multi.BaylocRow=out.BayLocRow

SELECT * FROM #tmpoutput WHERE Size IS NOT NULL  order by Sequence,BayLocRow;

DROP TABLE #tmpmultisizes
DROP TABLE #tmpoutput
DROP TABLE #tmprawdata

END
GO
