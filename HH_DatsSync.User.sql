USE [AutoExport]
GO
/****** Object:  User [HH_DatsSync]    Script Date: 8/31/2018 10:25:17 AM ******/
CREATE USER [HH_DatsSync] FOR LOGIN [HH_DatsSync] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [HH_DatsSync]
GO
