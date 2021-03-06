USE [AutoExport]
GO
/****** Object:  StoredProcedure [dbo].[spValidateHHUser]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spValidateHHUser]
@PortPassIDNumber varchar(12)
AS
BEGIN
		DECLARE @CountUsers INT		

		SELECT @CountUsers = COUNT(U.UserID)
		FROM Users U
		INNER JOIN UserRole UR ON U.UserID = UR.UserID AND UR.RoleName = 'YardOperations'
		WHERE U.RecordStatus = 'Active'
		AND U.PortPassIDNumber = @PortPassIDNumber
		
		IF (@CountUsers = 0)
		BEGIN
			SELECT 0 AS CountUsers, '' as UserCode, @PortPassIDNumber as PortPassIDNumber, '' as UserName, '' as MultipleUserCodes
		END
		ELSE IF (@CountUsers = 1)
		BEGIN
			SELECT 1 AS CountUsers, U.UserCode, U.PortPassIDNumber, ISNULL(U.FirstName, '') + ' ' + ISNULL(U.LastName, '') as UserName, '' as MultipleUserCodes
			FROM Users U
			INNER JOIN UserRole UR ON U.UserID = UR.UserID AND UR.RoleName = 'YardOperations'
			WHERE U.RecordStatus = 'Active'
			AND U.PortPassIDNumber = @PortPassIDNumber
		END
		ELSE
		BEGIN
			SELECT DISTINCT @CountUsers AS CountUsers, '' as UserCode, @PortPassIDNumber as PortPassIDNumber, '' as UserName,
				STUFF((SELECT ', ' + UserCode
				FROM Users
				WHERE PortPassIDNumber = U.PortPassIDNumber
				ORDER BY UserID ASC
				FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 2, '') MultipleUserCodes
				FROM Users U
				WHERE PortPassIDNumber = @PortPassIDNumber
		END	
END

GO
