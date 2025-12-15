USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [hst].[funGetUniqueId]
WITH ENCRYPTION
AS
BEGIN
	Declare @Result AS BigInt
	
	SELECT @Result = ISNULL(MAX(Id),0) FROM hst.tblUniqueId
		
	IF @Result = 0
	BEGIN
		SELECT @Result = ISNULL(MAX(Id),1) 
		from (
			select MAX(HistoryID) Id FROM hst.tblHistoryRecords
			Union ALL
			select MAX(HistoryBatch) FROM hst.tblHistoryRecords
			Union ALL
			select MAX(RecordID) FROM hst.tblHistoryRecords
			Union ALL
			select MAX(HistoryID) FROM hst.tblHistoryFields) A
			
		INSERT INTO hst.tblUniqueId VALUES (@Result)
	END
	ELSE
		Update 	hst.tblUniqueId SET Id=@Result+1

	
	SELECT @Result+1
END


GO
