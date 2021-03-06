USE [AutoExport]
GO
/****** Object:  StoredProcedure [dbo].[spAutoExportLogin]    Script Date: 8/31/2018 10:25:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Maibor
-- Create date: 11/7/16
-- Description:	
-- If 1st Time Login, PasswordUpdatedDate IS NULL, allow Password or PIN usage, 
--	and return FIRST as result.
-- If not 1st Time Login, must change Password every 120 days. If PasswordUpdatedDate is 
--	> 119 days from Today, return CHANGE as result .
--	Password is case-sensitive and must: 
-- If valid credentials and no Password change needed, include RoleName field in each rec returned
-- =============================================
CREATE PROCEDURE [dbo].[spAutoExportLogin] 
	@userID varchar(50),
	@password varchar(50),
	@HostName varchar(255),
	@BuildDate datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   DECLARE
	@availablelogin Datetime,
	@count int,
	@lockoutminutes int = 60;

	-- Use ~ to represent new line.

	-- Check if userID exists
	SELECT @count = COUNT(userID) FROM Users WHERE UserCode=@userid;
	IF @count = 0 
	BEGIN
		SELECT 'No user found for the User Name entered.' +
			'~Please verify your entry, otherwise contact Administrator.' AS result;
		return;
	END

	-- Check if userID is active
	SELECT @count = COUNT(userID) FROM Users WHERE UserCode=@userid and RecordStatus='Active';
	IF @count = 0 
	BEGIN
		SELECT 'The User Name: ' + @userID + ' is not active.' +
			'~Please contact the Administrator to correct.' AS result;
		return;
	END

	-- Check if userID is locked out; last LockoutDate is within @lockoutminutes  of current date
	SELECT @count = COUNT(UserCode)
		FROM UserLockedOut WHERE UserCode=@userid AND 
		 DATEDIFF(MINUTE,LockedOutDate,CURRENT_TIMESTAMP) < @lockoutminutes;
	IF @count > 0
	BEGIN
		-- Set 
		SELECT @availablelogin = MAX(LockedOutDate) FROM UserLockedOut
		WHERE UserCode=@userid AND DATEDIFF(MINUTE,LockedOutDate,CURRENT_TIMESTAMP) < @lockoutminutes;

		SET @availablelogin = DATEADD(MI,@lockoutminutes,@availablelogin);

		SELECT 'The User Name ' + @userID + ' is currently locked out and ' +
		'cannot Log in again until ' + FORMAT(@availablelogin,'M/d/yy h:mm tt') +
		'.~~Please contact the Administrator to correct.' AS result;
		return;
	END

	-- Check If 1st time usage, PasswordUpdatedDate Is Null
	SELECT @count = COUNT(userID) FROM Users WHERE UserCode=@userID AND 
		PasswordUpdatedDate IS NULL;
	IF @count > 0
	BEGIN
		-- 1st time Login. Check both Password and PIN.
		-- Use COLLATE sql_latin1_general_cp1_cs_as to include Case sensitivity
		SELECT @count = COUNT(userID) FROM Users WHERE UserCode=@userID AND 
		(Password=@password COLLATE sql_latin1_general_cp1_cs_as OR 
			PIN=@password COLLATE sql_latin1_general_cp1_cs_as);
		IF @count = 0
		BEGIN
			-- Password and PIN are not valid
			-- Check how many Login attempts within @lockoutminutes minutes.
			SELECT @count = COUNT(UserCode) FROM UserLoginAttempts 
			WHERE UserCode=@userID AND DATEDIFF(MINUTE,LoginDate,CURRENT_TIMESTAMP) < @lockoutminutes;
			IF @count < 2
			BEGIN
				-- Add a record to UserLoginAttempts
				INSERT INTO UserLoginAttempts (UserCode,LoginDate)
				VALUES (@userID,CURRENT_TIMESTAMP);

				SELECT 'The Case Sensitive password is not correct for the user entered.' AS result; 
				return;
			END 
			ELSE
			BEGIN
				-- There are at least 2 failed login attempts within @lockoutminutes minutes, 
				INSERT INTO UserLockedOut(UserCode,LockedOutDate) -- create Lockout record
				VALUES (@userID,CURRENT_TIMESTAMP);

				-- DELETE Loginattempts within @lockoutminutes minutes
				DELETE UserLoginAttempts WHERE UserCode=@userID AND DATEDIFF(MINUTE,LoginDate,CURRENT_TIMESTAMP) < @lockoutminutes;

				-- Prepare result
				SET @availablelogin = DATEADD(MI,@lockoutminutes,CURRENT_TIMESTAMP); -- determine @availablelogin date
			
				SELECT 'The User Name: ' + @userID + ' is now locked out and ' +
				'cannot Log in again until ' + FORMAT(@availablelogin,'M/d/yy h:mm tt') +
				'.~~Please contact the Administrator to correct.' AS result;
				return;
			END
		END  -- In UserID & Pwd/IN don't match
		ELSE  -- Correct credentials, 1st time Login, return FIRST as result,Password
		BEGIN
			SELECT 'FIRST' AS result,Password FROM Users WHERE UserCode=@userID;
			return;
		END
	END  -- if 1ST Time used

	-- Not 1st time usage, check if just Password is correct
	SELECT @count = COUNT(userID) FROM Users WHERE UserCode=@userID AND 
		Password=@password COLLATE sql_latin1_general_cp1_cs_as;
	IF @count = 0 -- UserID & Password are not valid
	BEGIN
		-- Check how many Login attempts within @lockoutminutes minutes.
			SELECT @count = COUNT(UserCode) FROM UserLoginAttempts 
			WHERE UserCode=@userID AND DATEDIFF(MINUTE,LoginDate,CURRENT_TIMESTAMP) < @lockoutminutes;
			IF @count < 2
			BEGIN
				-- Add a record to UserLoginAttempts
				INSERT INTO UserLoginAttempts (UserCode,LoginDate)
				VALUES (@userID,CURRENT_TIMESTAMP);
				SELECT 'The Case Sensitive password is not correct for the user entered.' AS result; 
				return;
			END 

			-- There are at least 2 failed login attempts within @lockoutminutes minutes, 
			INSERT INTO UserLockedOut(UserCode,LockedOutDate) -- create Lockout record
			VALUES (@userID,CURRENT_TIMESTAMP);

			-- DELETE Loginattempts within @lockoutminutes minutes
			DELETE UserLoginAttempts WHERE UserCode=@userID AND DATEDIFF(MINUTE,LoginDate,CURRENT_TIMESTAMP) < @lockoutminutes;

			-- Prepare result
			SET @availablelogin = DATEADD(MI,@lockoutminutes,CURRENT_TIMESTAMP); -- determine @availablelogin date

			SELECT 'The User Name: ' + @userID + ' is now locked out and ' +
			'cannot Log in again until ' + FORMAT(@availablelogin,'M/d/yy h:mm tt') +
			'.~~Please contact the Administrator to correct.' AS result;
			return;
	END

	-- Password is OK. Check if PasswordUpdatedDate is older than 119 days from today
	SELECT @count = COUNT(userID) FROM Users WHERE UserCode=@userID AND 
		PasswordUpdatedDate < DATEADD(d,-119,CURRENT_TIMESTAMP);
	IF @count > 0 
	BEGIN
		SELECT 'CHANGE' AS result,Password FROM Users WHERE UserCode=@userID;;
		return;
	END

	-- Password is OK. Delete any other attempts today within @lockoutminutes minutes
	DELETE UserLoginAttempts WHERE UserCode = @userID AND 
		LoginDate > DATEADD (MINUTE,-@lockoutminutes,CURRENT_TIMESTAMP);

	-- Check that there is at least one RoleName for the user
	SELECT @count = COUNT(Rolename) 
	FROM Users us INNER JOIN 
	UserRole ur on ur.userid = us.UserID 
	WHERE us.UserCode = @userid; 
	IF @count = 0
	BEGIN
		SELECT 'There are no roles assigned to User Name: ' + @userID + 
			'.~Please contact the Administrator to correct.' AS result;
		return;
	END

	-- Create a Login record and rturn RoleNames
	INSERT INTO UserLoginLog (UserCode,LoginDate,LogoutDate,SPID,HostName,BuildDate)
	VALUES (@userID,CURRENT_TIMESTAMP,NULL,@@SPID,@HostName,@BuildDate);

	SELECT 'OK' As result,us.FirstName + ' ' + us.LastName AS FullName,
	ur.RoleName 
	FROM Users us INNER JOIN 
	UserRole ur on ur.userid = us.UserID 
	WHERE us.UserCode = @userid and RecordStatus='Active' 
	ORDER BY ur.RoleName;
END

GO
