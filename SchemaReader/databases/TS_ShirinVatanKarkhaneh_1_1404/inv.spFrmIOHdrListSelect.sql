USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 90/12/28
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [inv].[spFrmIOHdrListSelect] 
	@ProcessID	Smallint,
	@ProcessNo	tinyint,
	@DocDate	Char(10),
	@AcntCode	Varchar(20),
	@LanguageID	TinyInt
WITH ENCRYPTION
 AS
BEGIN
SET NOCOUNT ON;

	SELECT DISTINCT S.ProcessID , S.ProcessNo , S.FiscalYear , S.SerialNo 
			,DocDate,AcntCode,[pub].[GetCodeName](AcntCode,@LanguageID) AcntName
	FROM (
	Select ProcessID , ProcessNo , FiscalYear , SerialNo , DocRowNo , GoodsQuantity ,DocDate,AcntCode
	From inv.tblStorageDocsDtl 
	Where ProcessID = @ProcessID  and ProcessNo= @ProcessNo) S
	LEFT JOIN 
	(
		Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo 
				, BaseDocRowNo , SUM(GoodsQuantity) GoodsQuantity
		From inv.tblIODtl  
		Where BaseProcessID = @ProcessID and BaseProcessNo= @ProcessNo
		Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
				BaseDocRowNo
	) I
	ON	S.ProcessID  = I.BaseProcessID  AND S.ProcessNo = I.BaseProcessNo AND 
		S.FiscalYear = I.BaseFiscalYear AND S.SerialNo  = I.BaseSerialNo AND 
		S.DocRowNo   = I.BaseDocRowNo
	WHERE	S.GoodsQuantity - ISNULL(I.GoodsQuantity,0) > 0  AND
			DocDate<=@DocDate AND
			( @AcntCode IS NULL OR AcntCode=@AcntCode) 	
			
END
GO
