USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

Create PROCEDURE hst.funUpdateUniqueId
WITH ENCRYPTION
AS
BEGIN	
		Update 	hst.tblUniqueId SET Id=(SELECT  ISNULL(MAX(Id),1) 
		from (
			select MAX(HistoryID) Id FROM hst.tblHistoryRecords
			Union ALL
			select MAX(HistoryBatch) FROM hst.tblHistoryRecords
			Union ALL
			select MAX(RecordID) FROM hst.tblHistoryRecords
			Union ALL
			select MAX(HistoryID) FROM hst.tblHistoryFields
			Union ALL
			select MAX(Id) FROM hst.tblUniqueId) A)
END


GO
