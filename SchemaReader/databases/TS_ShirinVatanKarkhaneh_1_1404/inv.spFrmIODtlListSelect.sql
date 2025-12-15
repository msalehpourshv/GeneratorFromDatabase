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

CREATE PROCEDURE [inv].[spFrmIODtlListSelect] 
	@DocDate	Char(10),
	@ProcessID	SMALLINT,
	@ProcessNo	Tinyint,
	@AcntCode	Nvarchar(20),
	@GoodsID	Nvarchar(20),
	@LanguageID int
WITH ENCRYPTION
 AS
BEGIN
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

		SELECT DISTINCT S.ProcessID , S.ProcessNo , S.FiscalYear , S.SerialNo ,S.DocRowNo ,S.ProcessID BaseProcessID , S.ProcessNo BaseProcessNo, S.FiscalYear BaseFiscalYear, S.SerialNo BaseSerialNo,S.DocRowNo BaseDocRowNo
			,DocDate,AcntCode,S.GoodsID,UnitID,[pub].[GetCodeName](AcntCode,@LanguageID) AcntName,inv.funGetUnitName(UnitID,@LanguageID) AS SubUnitName,
			S.GoodsQuantity - ISNULL(I.GoodsQuantity,0) GoodsQuantity,pub.funGetGoodsName(S.GoodsID,@LanguageID) AS GoodsName
	FROM (
	Select ProcessID , ProcessNo , FiscalYear , SerialNo , DocRowNo ,GoodsID, GoodsQuantity ,DocDate,AcntCode
	From inv.tblStorageDocsDtl 
	Where ProcessID = @ProcessID  and ProcessNo= @ProcessNo AND (@GoodsID IS NULL OR GoodsID = @GoodsID)) S
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
	INNER JOIN inv.tblGoods G
	ON G.GoodsID=SUBSTRING(S.GoodsID,@str_Goods+1,@str_GoodsSum) AND G.PartNumber = @UnitPart 
	WHERE	S.GoodsQuantity - ISNULL(I.GoodsQuantity,0) > 0  AND
			DocDate<=@DocDate AND
			( @AcntCode IS NULL OR AcntCode=@AcntCode) 	
END
GO
