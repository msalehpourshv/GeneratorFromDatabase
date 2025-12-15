USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--EXEC [lyl].[SPGetCustomerPrivilegeDtl] 1, 95, Null, '15291'
CREATE PROCEDURE [lyl].[SPGetCustomerPrivilegeDtl]
(
	@ProcessNo		Int,
	@FiscalYear		Int,
	@Date   		Varchar(20) = Null,
	@CustomerCardNo	VarChar(20) = '',
	@ExtraParams	NVarChar(200) = ''
)
WITH ENCRYPTION
AS

Begin -- ====================================================
	
	DECLARE	@LangID	Char(1);
	SET @LangID = 1;

	Declare @CustomerCardPrivilege AS Float
	SET @CustomerCardPrivilege = 0;

	Select H1.ProcessID, H1.SerialNo, H1.CCNo, H1.DocDate, D1.GoodsID, pub.funGetGoodsName(D1.GoodsID,@LangID) AS GoodsName,
		   D1.SubUnitQuantity, D1.GoodsPrice
	From inv.tblStorageDocsHdr H1
	Inner Join inv.tblStorageDocsDtl D1 On H1.ProcessID = D1.ProcessID And H1.ProcessNo = D1.ProcessNo And
										   H1.FiscalYear = D1.FiscalYear And H1.SerialNo = D1.SerialNo
	Where H1.ProcessID IN (90, 100) And H1.ProcessNo = @ProcessNo And H1.FiscalYear = @FiscalYear And H1.CCNo = @CustomerCardNo
		
	------==================================
     
END
GO
