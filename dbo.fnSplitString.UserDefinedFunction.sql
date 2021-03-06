USE [AutoExport]
GO
/****** Object:  UserDefinedFunction [dbo].[fnSplitString]    Script Date: 8/31/2018 10:25:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnSplitString]
(    
	-- =============================================
-- Author:		David Maibor
-- Create date: 12/23/16
-- Description:	pass in a string and delimter char, and get back a single coloumn table, col. name value 
--	E.g. @Input: '9879,9889,9899' @Character: ',' returns table with 3 rows
-- =============================================
      @Input VARCHAR(MAX),
      @Character CHAR(1)
)
RETURNS @Output TABLE (
      value VARCHAR(max)
)
AS
BEGIN
      DECLARE @StartIndex INT, @EndIndex INT
 
      SET @StartIndex = 1
      IF SUBSTRING(@Input, LEN(@Input) - 1, LEN(@Input)) <> @Character
      BEGIN
            SET @Input = @Input + @Character
      END
 
      WHILE CHARINDEX(@Character, @Input) > 0
      BEGIN
            SET @EndIndex = CHARINDEX(@Character, @Input)
           
            INSERT INTO @Output(value)
            SELECT SUBSTRING(@Input, @StartIndex, @EndIndex - 1) 
           
            SET @Input = SUBSTRING(@Input, @EndIndex + 1, LEN(@Input))
      END
 
      RETURN
END
GO
