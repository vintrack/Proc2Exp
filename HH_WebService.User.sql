USE [AutoExport]
GO
/****** Object:  User [HH_WebService]    Script Date: 8/31/2018 10:25:17 AM ******/
CREATE USER [HH_WebService] FOR LOGIN [HH_WebService] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [HH_WebService]
GO
