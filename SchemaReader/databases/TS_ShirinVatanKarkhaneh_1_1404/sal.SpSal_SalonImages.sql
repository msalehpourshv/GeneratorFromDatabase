USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Reza NP
-- Create date: 94/01/23
-- Description:	
-- =============================================
create PROCEDURE  [sal].[SpSal_SalonImages]

WITH ENCRYPTION
AS
Begin


SELECT  D.* FROM sal.tblTableImages D

inner join sal.tblTables T
on D.TableID=T.TableID

where D.TableImage is not null 

 
End
GO
