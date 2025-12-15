USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 1401/06/20
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [inv].[spSaleTempReceiptSave] 
 @ProcessID		Tinyint,
 @ProcessNo		Tinyint,
 @FiscalYear	Smallint,
 @SerialNo		Int
 WITH ENCRYPTION
AS

BEGIN
SET NOCOUNT ON;

	SELECT a.ProcessID,a.ProcessNo,a.FiscalYear,a.SerialNo,a.DocRowNo,a.GoodsID ,a.ConfirmQuantity,b.ConfimedCount 
	FROM inv.tblInvTempReceiptDtl a
	INNER JOIN (
	SELECT  ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo,COUNT(*) ConfimedCount
	FROM inv.tblStorageDocsSerials 
	WHERE ProcessID =@ProcessID 
	  AND ProcessNo = 1 
	  AND ProcessNo = @ProcessNo 
	  AND FiscalYear = @FiscalYear 
	  AND SerialNo = @SerialNo 
	  AND Confirmed='True'
	GROUP BY ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo) b
	ON a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo and a.DocRowNo=b.DocRowNo
	WHERE a.ConfirmQuantity<>b.ConfimedCount
END




GO
