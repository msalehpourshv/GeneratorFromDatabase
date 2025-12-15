USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 87/02/03
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE FUNCTION [prd].[FunGetProduct]
(
	@AcntCode Varchar(20),
	@DocDate  char(10),
	@DocStep TINYINT,
	@ProcessNo as TINYINT
)
RETURNS TABLE 
WITH ENCRYPTION
AS
RETURN 
(
	Select	Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo,Cnf.DocRowNo,
			Cnf.GoodsQuantity - ISNULL(Rtn.GoodsQuantity,0) ConfirmQuantity,AcntCode,ProductCount
	From
		(
			Select	D.ProcessID ,D.ProcessNo , D.FiscalYear , D.SerialNo , 
					D.DocRowNo , D.GoodsQuantity, D.AcntCode,H.ProductCount
			From inv.tblStorageDocsDtl D INNER JOIN inv.tblStorageDocsHdr H
			ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND 
			H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
			Where D.ProcessID = 70 AND D.ProcessNo=@ProcessNo AND (@AcntCode IS NULL OR D.AcntCode = @AcntCode) AND 
				  D.DocDate <= @DocDate AND D.DocStep in (0,@DocStep,2) 
		) Cnf
	LEFT JOIN 
	(
		Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
				BaseDocRowNo , Sum(GoodsQuantity) GoodsQuantity
		From inv.tblStorageDocsDtl 
		Where ProcessID = 75 AND ProcessNo=@ProcessNo AND BaseProcessID = 70 AND (@AcntCode IS NULL OR AcntCode = @AcntCode)
		Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , 
				 BaseSerialNo , BaseDocRowNo
	) Rtn
	ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
		Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
		Cnf.DocRowNo = Rtn.BaseDocRowNo
	WHERE Cnf.GoodsQuantity - ISNULL(Rtn.GoodsQuantity,0) > 0	
	--WHERE (SELECT COUNT(*) 
	--	   From inv.tblStorageDocsHdr  H
	--	   WHERE ProcessID = 80 AND Cnf.ProcessID = H.BaseProcessID AND  Cnf.ProcessNo=H.BaseProcessNo AND Cnf.FiscalYear=H.BaseFiscalYear AND Cnf.SerialNo=H.BaseSerialNo )=0
)
GO
