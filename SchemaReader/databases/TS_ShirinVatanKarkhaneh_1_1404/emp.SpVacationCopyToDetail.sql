USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 88/06/21
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [emp].[SpVacationCopyToDetail]
	@intProcessID	Int,
	@intSerialNo	Int
	WITH ENCRYPTION
AS

BEGIN
	DELETE FROM [emp].[tblVacationDtl]
	WHERE ProcessID = @intProcessID AND SerialNo = @intSerialNo
	
	INSERT INTO [emp].[tblVacationDtl]
           ([ProcessID],[SerialNo],[RowNo],[DocRowNo],[PersonnelID],[VacationTypeID],[StartDate],[EndDate],[StartTime],[EndTime],[DocDate],[ConfirmerPersID],[ConfirmDate],[ApprovalPersID],[ApproveDate],[DocDesc],[RecID],[SessionNo],[DocStep],[Interval],[MissionTypeID],[MissionPlaceID])
	SELECT   ProcessID , SerialNo ,1      ,1         ,PersonnelID  , VacationTypeID , StartDate , EndDate , StartTime , EndTime , DocDate , ConfirmerPersID , ConfirmDate , ApprovalPersID , ApproveDate , DocDesc , RecID , SessionNo , DocStep , Interval ,MissionTypeID ,MissionPlaceID
	FROM [emp].[tblVacationHdr]
	WHERE ProcessID = @intProcessID AND SerialNo = @intSerialNo

END
GO
