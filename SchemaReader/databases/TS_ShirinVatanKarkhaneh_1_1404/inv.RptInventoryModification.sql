USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Creation Date : 1403/12/20
-- Viewed By	 : 
-- Last Modified : 1404/01/15
-- Last Modifier : TakroSystem\Jafari
-- Description   : 
-- ==============================================
Create PROCEDURE inv.RptInventoryModification
	@ProcessID int, 
	@ProcessNo int, 
	@FiscalYear int, 
	@SerialNo int, 
	@FiscalYearTo int, 
	@SerialNoTo int, 
	@Extraparams NVarChar(100)='' ,
	@RepOptions		varchar(20) = '0011101',
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS


BEGIN -- ============================ S T A R T =====================================================

	SET NOCOUNT ON;
	
	-- Init -------------------------------------------------
	IF (@RepInfo Is Null)		SET @RepInfo = '1@1@1';

	IF (@RepOptions Is Null)	SET @RepOptions = '0011101';
	
	SELECT pub.funGetGoodsName(D.GoodsID, 1) AS GoodsName, D.StoreID, inv.funGetUnitName(D.SubUnitID, 1) AS SubUnitName, 
	       pub.funLockStatus(D.ProcessID,D.ProcessNo, D.FiscalYear, D.SerialNo, D.DocRowNo, 1) AS Locked, D.ProcessID, D.ProcessNo, 
		   D.FiscalYear, D.SerialNo, D.RowNo, D.DocRowNo,D.VolumeRowNo, D.DocStep, D.DocDate, D.PhysicallyEffected, D.EnterKind, D.AcntCode, 
		   pub.GetCodeName(D.AcntCode, 1) AS AcntName, D.GoodsID, D.SubUnitID,D.GoodsPrice, D.DescDtl, H.VchNo, H.DocDesc, 
		   H.RecID, H.SessionNo, H.VchDate, D.BatchNo, pub.GetUserName(H.SessionNo) AS UserName
	FROM   inv.tblStorageDocsDtl AS D 
	INNER JOIN inv.tblStorageDocsHdr AS H 
	ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
	WHERE D.ProcessID = @ProcessID AND 
	      D.ProcessNo = @ProcessNo AND 
		  D.FiscalYear >= @FiscalYear AND 
		  D.FiscalYear <= @FiscalYearTo AND 
		  D.SerialNo >= @SerialNo AND 
		  D.SerialNo <= @SerialNoTo
	ORDER BY D.DocRowNo	 
						 
END
GO
