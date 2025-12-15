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
Create PROCEDURE sal.spFrmSaleOrder 
	 @CallType		tinyint,
	@ExtraParams		NVarChar(Max) = ''
WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON;
---------------------------------------------

declare 
	 @ProcessID		tinyint,
	 @ProcessNo		tinyint,
	 @FiscalYear	smallint,
	 @SerialNo		int,
	 @DocDate		char(10),
	 @AcntCode		Varchar(20),
	 @LanguageID	Tinyint
 
 if @CallType=1
 begin
	---  تست مانده پیش فاکتور در سفارش فروش
 		
	SET @ProcessID			    = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @ProcessNo			    = LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
	SET @FiscalYear		    = LTrim(pub.funSplitString(@ExtraParams, '@', 3));
	SET @SerialNo			    = LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 

	--==============
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


	DECLARE @DocStep1 tinyint
	DECLARE @HasConfirmForPreSale AS BIT
	DECLARE @salNotShowPresaleIfRemain AS BIT
	
	SET @HasConfirmForPreSale = 'False'
	SET @salNotShowPresaleIfRemain = 'False'
	
	SELECT @HasConfirmForPreSale=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'HasConfirmForPreSale'
	
	SELECT @salNotShowPresaleIfRemain = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'salNotShowPresaleIfRemain'	
	--=====
	IF @HasConfirmForPreSale = 'False' 
		SET @DocStep1 = 1
	ELSE
		SET @DocStep1 = 2
		
			Select	Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo , Cnf.DocRowNo 
					,Cnf.ConfirmQuantity - ISNULL(Rtn.ConfirmQuantity,0)  AS GoodsQuantity ,DocDate,AcntCode,Cnf.GoodsID
			From 
				(
					Select ProcessID , ProcessNo , FiscalYear , SerialNo , DocRowNo ,GoodsQuantity ConfirmQuantity  ,DocDate,AcntCode,GoodsID
					From inv.tblPreSaleDtl
					Where ProcessID=@ProcessID   AND ProcessNo=@ProcessNo AND 
						  FiscalYear=@FiscalYear AND SerialNo=@SerialNo  AND 
						 (@AcntCode IS NULL OR AcntCode LIKE  @AcntCode + '%' ) 

				) Cnf
				LEFT JOIN 
				(
					Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo 
							, BaseDocRowNo , SUM(GoodsQuantity) ConfirmQuantity,GoodsID
					From sal.tblSaleOrderDtl 
					Where BaseProcessID = @ProcessID AND BaseProcessNo=@ProcessNo AND 
						  BaseFiscalYear=@FiscalYear AND BaseSerialNo=@SerialNo  AND (@AcntCode IS NULL OR AcntCode LIKE  @AcntCode + '%' ) 
					Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo,GoodsID
				) Rtn
				ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
					Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
					Cnf.DocRowNo = Rtn.BaseDocRowNo AND Cnf.GoodsID = Rtn.GoodsID

	END

END
GO
