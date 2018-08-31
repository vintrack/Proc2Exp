USE [AutoExport]
GO
/****** Object:  User [daiuser]    Script Date: 8/31/2018 10:25:17 AM ******/
CREATE USER [daiuser] FOR LOGIN [daiuser] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [daiuser]
GO
ALTER ROLE [db_datareader] ADD MEMBER [daiuser]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [daiuser]
GO
