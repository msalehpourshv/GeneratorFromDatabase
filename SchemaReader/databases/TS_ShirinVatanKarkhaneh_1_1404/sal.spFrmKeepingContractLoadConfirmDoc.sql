USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/12/04
-- Viewed By	 : 
-- Last Modified : 93/07/26
-- Description   : 
-- =============================================
Create PROCEDURE [sal].[spFrmKeepingContractLoadConfirmDoc] 
	 @ProcessID		tinyint,
	 @ProcessNo		tinyint,
	 @FiscalYear	smallint,
	 @SerialNo		int,
	 @DocDate		char(10),
	 @AcntCode		Varchar(20),
	 @LanguageID	Tinyint,
	 @IsService	bit=0
 
WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON;
	---------------------------------------------
	--=====
	DECLARE @UnitPart TINYINT
DECLARE @StrSelect			NVarChar(max);
	IF @AcntCode IS NULL
		SET @AcntCode = ''
	SELECT @UnitPart = SettingValue FROM pub.tblSettings WHERE SettingKey = 'UnitPart'

	IF @UnitPart IS NULL OR @UnitPart = 0 OR @UnitPart = ' '
		SET @UnitPart = 1

	--=====
	DECLARE @str_Goods  tinyint, @str_GoodsSum tinyint

	SELECT @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	FROM pub.tblCodeLayer 
	WHERE TableName='inv.tblGoods' AND PartNumber<@UnitPart

	SELECT @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	FROM pub.tblCodeLayer 
	WHERE TableName= 'inv.tblGoods' AND PartNumber=@UnitPart
	
	Print @UnitPart
	Print @str_Goods
	Print @str_GoodsSum
	--===================
	--IF @ProcessID = 190 -- قرارداد نگهداری

		set @StrSelect = '
		Select SD.*, SH.Duration, SH.OrderDate, SH.DeliveryDate, SH.ChequeCount, SH.ChequeAmount, SH.DueDate1, 
			   SH.DueDate2, SH.DueDate3, SH.DueDate4, SH.DueDate5, SH.TaxPercent, SH.TaxChequeNo, SH.TaxBankName, 
			   SH.TaxChequeAmount, SH.TaxDueDate, pub.funGetGoodsName(SD.GoodsID,' + str(@LanguageID) + ') AS GoodsName,
			   inv.funGetUnitName(SD.SubUnitID,' + str(@LanguageID) + ') AS SubUnitName,G.IsService
		From sal.tblSaleOrderDtl SD
		INNER JOIN sal.tblSaleOrderHdr SH ON SH.ProcessID = SD.ProcessID And SH.ProcessNo = SD.ProcessNo And 
											 SH.FiscalYear = SD.FiscalYear And SH.SerialNo = SD.SerialNo
		INNER JOIN inv.tblGoods G ON SUBSTRING(SD.GoodsID,' + str(@str_Goods+1) + ',' + str(@str_GoodsSum) + ')=G.GoodsID AND G.PartNumber =' + str(@UnitPart) + ' 
		LEFT JOIN sal.tblSaleTypesDtl STD ON SD.SaleTypeID = STD.SaleTypeID
		WHERE SD.ProcessID = ' + str(@ProcessID) + ' And SD.ProcessNo = ' + str(@ProcessNo) + ' And SD.FiscalYear =' + str(@FiscalYear) + '  And 
			  SD.SerialNo =' + str(@SerialNo) + '  And (''' + @AcntCode + ''' ='''' OR SD.AcntCode=''' + @AcntCode + ''' ) AND SD.DocDate <=''' + @DocDate + '''  
			  '
			  
			  if @IsService=1
			  
			  SET @StrSelect = @StrSelect + ' and IsService=0'
			  SET @StrSelect = @StrSelect + ' ORDER BY SD.FiscalYear, SD.SerialNo, SD.DocRowNo		'
		
		
print @StrSelect;
	Exec sp_executesql @StrSelect;

END
GO
