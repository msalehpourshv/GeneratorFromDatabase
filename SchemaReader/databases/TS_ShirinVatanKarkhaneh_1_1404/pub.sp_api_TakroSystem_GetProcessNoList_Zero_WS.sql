USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Reza Moayed
-- Create date   : 1402-12-12
-- Viewed By	 : 
-- Last Modified : 
-- Description   : لیست انواع فرایند ها
-- =============================================
CREATE PROCEDURE [pub].[sp_api_TakroSystem_GetProcessNoList_Zero_WS]

@ProcessID As NVARCHAR(50)=90

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	
BEGIN TRY

		select d.ProcessID,d.ProcessNo,s.ProcessName from inv.tblStorageDocsDtl d
		Inner join pub.tblProcess s On s.ProcessID= d.ProcessID and s.ProcessNo=d.ProcessNo
		where d.ProcessID=@ProcessID
		group by d.ProcessID,d.ProcessNo,s.ProcessName


END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
