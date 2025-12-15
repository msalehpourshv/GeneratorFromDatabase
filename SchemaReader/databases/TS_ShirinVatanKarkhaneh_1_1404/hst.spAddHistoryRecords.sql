USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Pishadast
-- Create date   : 1388/05/17
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : 
-- =============================================
CREATE procedure [hst].[spAddHistoryRecords] 
	@HistoryID	  	bigint,
	@RecordID	  	bigint,
	@ProcessID	  	int,
	@ProcessNo    	int,
	@FiscalYear   	int,
	@SerialNo     	int,
	@Code         	varchar(20),
	@DocStep      	int,
	@DocRowNo     	int,
	@DocAtomRowNo 	int,
	@ActionID     	int,
	@SessionNo    	int,
	@HistoryDate  	char(10),
	@HistoryTime  	char(5),
	@HistoryBatch	bigint,
	@xml			xml=null
	
WITH ENCRYPTION
AS

BEGIN
	
    INSERT INTO hst.tblHistoryRecords
    VALUES (@HistoryID,@RecordID,@ProcessID, @ProcessNo,@FiscalYear,@SerialNo,@Code,
            @DocStep,@DocRowNo,@DocAtomRowNo,@ActionID,@SessionNo,@HistoryDate,
            @HistoryTime,@HistoryBatch,@xml);

END
GO
