USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [prd].[spOneStepProductVolumeSet]
	@ProcessNo	Int = Null,
	@FiscalYear Int = Null,
	@SerialNo	Int = Null
WITH ENCRYPTION
AS 
BEGIN
	DECLARE @maxRowNo as int
	DECLARE @maxRowNoS as int
	DECLARE @maxRowNoR as int
	DECLARE @DocDate as VARCHAR(20)

	--SELECT @DocDate = DocDate from inv.tblStorageDocsDtl 
	--WHERE ProcessID = 80 and ProcessNo = @ProcessNo AND FiscalYear = @FiscalYear AND  SerialNo=@SerialNo
	
	--SELECT @maxRowNo = ISNULL(MAX(VolumeRowNo),0) from inv.tblStorageDocsDtl 
	--WHERE DocDate = @DocDate
	
	----SELECT @maxRowNoS = ISNULL(MAX(VolumeRowNo),0) from inv.tblStorageDocsDtl WHERE ProcessID = 70 and ProcessNo = @ProcessNo AND FiscalYear = @FiscalYear AND SerialNo = @SerialNo
	----SELECT @maxRowNoR = ISNULL(MAX(VolumeRowNo),0) from inv.tblStorageDocsDtl WHERE ProcessID = 80 and ProcessNo = @ProcessNo AND FiscalYear = @FiscalYear AND SerialNo = @SerialNo

	----IF @maxRowNoS > @maxRowNoR
	----BEGIN

	--	UPDATE inv.tblStorageDocsDtl 
	--	SET VolumeRowNo = @maxRowNo + RwN
	--	from inv.tblStorageDocsDtl a
	--	inner join (
	--	SELECT *,Row_Number()over (order by RowNo) RwN FROM inv.tblStorageDocsDtl
	--	WHERE ProcessID = 80 AND ProcessNo = @ProcessNo AND FiscalYear = @FiscalYear AND  SerialNo=@SerialNo) b
	--	on a.ProcessID=b.ProcessID AND a.ProcessNo=b.ProcessNo AND a.FiscalYear=b.FiscalYear AND a.SerialNo=b.SerialNo 
	--	WHERE a.ProcessID = 80 AND a.ProcessNo = @ProcessNo AND a.FiscalYear = @FiscalYear AND  a.SerialNo=@SerialNo AND
	--	a.VolumeRowNo<@maxRowNo

	--END
END
GO
