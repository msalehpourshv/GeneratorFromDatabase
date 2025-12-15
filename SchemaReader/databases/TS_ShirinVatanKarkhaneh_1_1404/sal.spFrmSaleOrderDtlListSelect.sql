USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/12/04
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [sal].[spFrmSaleOrderDtlListSelect]
	@DocDate	Char(10),
	@ProcessID	Smallint,
	@ProcessNo	Tinyint,
	@AcntCode	Nvarchar(20),
	@GoodsID	Nvarchar(20),
	@LanguageID int,
	@ExtraParams		NVarChar(Max) = ''

WITH ENCRYPTION
AS
BEGIN

SET NOCOUNT ON;

	 
	Declare @ConfirmCount	int;
	DECLARE @Sgn1			BIT;
	DECLARE @Sgn2			BIT;
	DECLARE @Sgn3			BIT;
	DECLARE @Sgn4			BIT;
	DECLARE @Sgn5			BIT;
	DECLARE @Confirm		BIT;

	SET @ProcessNo			= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @ConfirmCount		= pub.funSplitString(@ExtraParams, '@', 2);
	SET @Sgn1				= pub.funSplitString(@ExtraParams, '@', 3);
	SET @Sgn2				= pub.funSplitString(@ExtraParams, '@', 4);
	SET @Sgn3				= pub.funSplitString(@ExtraParams, '@', 5);
	SET @Sgn4				= pub.funSplitString(@ExtraParams, '@', 6);
	SET @Sgn5				= pub.funSplitString(@ExtraParams, '@', 7);
	SET @Confirm			= pub.funSplitString(@ExtraParams, '@', 8);
	if @ProcessNo is null 	set @ProcessNo=0



	--select pub.funSplitString(@ExtraParams, '@', 1)
	--select pub.funSplitString(@ExtraParams, '@', 2)
	--select pub.funSplitString(@ExtraParams, '@', 3)
	--select pub.funSplitString(@ExtraParams, '@', 4)
	--select pub.funSplitString(@ExtraParams, '@', 5)
	--select pub.funSplitString(@ExtraParams, '@', 6)

DECLARE @SalOrder_ConfirmDocStep Nvarchar(100)
DECLARE @SalRet_RetToSalOdr AS BIT
DECLARE @DocStep tinyint
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

SET @SalOrder_ConfirmDocStep = 'False'
SET @SalRet_RetToSalOdr = 'False'
	
SELECT @SalRet_RetToSalOdr = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'SalRet_RetToSalOdr' 
	
SELECT @SalOrder_ConfirmDocStep=SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'SalOrder_ConfirmDocStep'

IF @SalOrder_ConfirmDocStep = 'False' 
	SET @DocStep = 1
ELSE
	SET @DocStep = 2
IF 	@ProcessID = 185
BEGIN
SELECT * FROM (
	SELECT  acc.funIsCodeClosed(Cd1.AcntCode) IsCodeClosed, Cd1.ProcessID, Cd1.ProcessNo, Cd1.FiscalYear, Cd1.SerialNo, Cd1.RowNo, Cd1.DocRowNo,
			Cd1.DocStep, Cd1.DocDate, Cd1.AcntCode, Cd1.GoodsID, Cd1.SubUnitID, IsNull(Cd1.SubUnitQuantity,0) SubUnitQuantity,
			IsNull(Cd1.ConfirmQuantity,0) GoodsQuantity, IsNull(Drv.ConfirmQuantity,0) ConfirmQuantity, IsNull(Cd1.GoodsPrice,0) GoodsPrice, 
			Cd1.DescDtl, Cd1.OrderDate, Cd1.BaseProcessID, Cd1.BaseProcessNo, Cd1.BaseFiscalYear, Cd1.BaseSerialNo, Cd1.BaseDocRowNo, 
			Cd1.AgreeNo,pub.funGetGoodsName(Cd1.GoodsID,@LanguageID) AS GoodsName, 
			[inv].[funGetTechnicalSpecifications](Cd1.GoodsID) AS TechnicalSpecifications,
			inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName,Cd1.ConstText1,Cd1.ConstText2,Cd1.ConstText3,Cd1.ConstText4
			,SgnSN1,SgnSN2,SgnSN3,SgnSN4,SgnSN5,Cd1.OtherIncomePerentDtl,Cd1.OtherIncomeDtl
	FROM	sal.tblSaleOrderDtl AS Cd1 
		INNER JOIN
		(
			SELECT ProcessID, ProcessNo,FiscalYear,SerialNo,DocRowNo,ConfirmQuantity,SgnSN1,SgnSN2,SgnSN3,SgnSN4,SgnSN5
			FROM cmr.FunGetSaleOrder(@AcntCode,@DocDate,@DocStep,@SalRet_RetToSalOdr,0,0)
			WHERE ProcessNo=@ProcessNo
		 )	Drv

	ON	Cd1.ProcessID  = Drv.ProcessID  AND  Cd1.ProcessNo = Drv.ProcessNo AND  
		Cd1.FiscalYear = Drv.FiscalYear AND  Cd1.SerialNo  = Drv.SerialNo  AND  
		Cd1.DocRowNo   = Drv.DocRowNo
	INNER JOIN
	(SELECT GoodsID FROM inv.tblGoods WHERE CodeClosed = 'False' AND PartNumber = @UnitPart) G
	ON SUBSTRING(Cd1.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID 
	WHERE (@GoodsID IS NULL OR Cd1.GoodsID = @GoodsID)
) A WHERE IsCodeClosed = 0
 and (
				(@ConfirmCount=0 and (	(@Confirm=0 and DocStep in (1,2))
									  or(@Confirm=1 and DocStep=2)
									  )
				)or 
				(@ConfirmCount>0 and ((@Sgn1=0 and SgnSN1=0) or (@Sgn1>0 and SgnSN1>0)  )
				  				 and ((@Sgn2=0 and SgnSN2=0) or (@Sgn2>0 and SgnSN2>0)  )
								 and ((@Sgn3=0 and SgnSN3=0) or (@Sgn3>0 and SgnSN3>0)  )
								 and ((@Sgn4=0 and SgnSN4=0) or (@Sgn4>0 and SgnSN4>0)  )
								 and ((@Sgn5=0 and SgnSN5=0) or (@Sgn5>0 and SgnSN5>0)  )
				)	)			
END
ELSE
BEGIN
	DECLARE @DocStep1 tinyint
	DECLARE @HasConfirmForPreSale AS BIT
	
	SET @HasConfirmForPreSale = 'False'
	
	SELECT @HasConfirmForPreSale=SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'HasConfirmForPreSale'

	Declare @InSaleOrderDonotShowWithoutVchNoInPreSale AS bit
	SELECT @InSaleOrderDonotShowWithoutVchNoInPreSale = SettingValue FROM pub.tblSettings WHERE SettingKey = 'InSaleOrderDonotShowWithoutVchNoInPreSale'
	set @InSaleOrderDonotShowWithoutVchNoInPreSale=isnull(@InSaleOrderDonotShowWithoutVchNoInPreSale,'False')	

	IF @HasConfirmForPreSale = 'False' 
		SET @DocStep1 = 1
	ELSE
		SET @DocStep1 = 2
		
	SELECT acc.funIsCodeClosed(Cd1.AcntCode) IsCodeClosed, 
			Cd1.ProcessID, 
			Cd1.ProcessNo, 
			Cd1.FiscalYear, 
			Cd1.SerialNo, 
			Cd1.RowNo, 
			Cd1.DocRowNo, 
			Cd1.DocStep, 
			Cd1.DocDate, 
			Cd1.AcntCode, 
			Cd1.GoodsID, 
			UnitID SubUnitID, 
			IsNull(Drv.GoodsQuantity,0) SubUnitQuantity, 
			IsNull(Cd1.Discount,0) DiscountDtl, 
			IsNull(Cd1.DiscountPercent,0) DiscountPercentDtl,
			IsNull(Drv.GoodsQuantity,0) GoodsQuantity,
			IsNull(GoodsAmount,0) GoodsPrice,
			Cd1.DescDtl, 
			pub.funGetGoodsName(Cd1.GoodsID,@LanguageID) AS GoodsName,
			Cd1.TaxOverWorthCostDtl, 
			Cd1.TollOverWorthCostDtl,
			0 BaseProcessID, 
			0 BaseProcessNo, 
			0 BaseFiscalYear, 
			0 BaseSerialNo,
			0 BaseDocRowNo,
			[inv].[funGetTechnicalSpecifications](Cd1.GoodsID) AS TechnicalSpecifications, 
			Cd1.SaleTypeID, 
			STD.SaleTypeName, 
			inv.funGetUnitName(UnitID,@LanguageID) AS SubUnitName,
			Cd1.ConstText1,
			Cd1.ConstText2,
			Cd1.ConstText3,
			Cd1.ConstText4,
			Cd1.UserPriceID,
			IsNull((Select UParams From inv.tblGoodsUserPrice p Where p.ID=Cd1.UserPriceID) ,'') as UserPrice, 
			isnull(Cd1.SubUnitPrice, 0) SubUnitPrice
	FROM	inv.tblPreSaleDtl AS Cd1 
	INNER JOIN inv.tblPreSaleHdr AS Cd2
		ON Cd1.ProcessID = Cd2.ProcessID AND Cd1.ProcessNo = Cd2.ProcessNo AND Cd1.FiscalYear = Cd2.FiscalYear AND Cd1.SerialNo = Cd2.SerialNo
	INNER JOIN (SELECT ProcessID,ProcessNo,FiscalYear,SerialNo from inv.tblPreSaleHdr 
				except	
				SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo from inv.tblStorageDocsDtl where ProcessID=90 and BaseProcessID=240)S
		ON Cd1.ProcessID = S.ProcessID AND Cd1.ProcessNo = S.ProcessNo AND Cd1.FiscalYear = S.FiscalYear AND Cd1.SerialNo = S.SerialNo
	INNER JOIN inv.tblGoods G ON SUBSTRING(Cd1.GoodsID,@str_Goods+1,@str_GoodsSum)=G.GoodsID AND G.PartNumber = @UnitPart
	INNER JOIN
		(
			Select	Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo , Cnf.DocRowNo 
					,Cnf.ConfirmQuantity - ISNULL(Rtn.ConfirmQuantity,0)  AS GoodsQuantity ,DocDate,AcntCode
			From 
				(
					Select ProcessID , ProcessNo , FiscalYear , SerialNo , DocRowNo ,GoodsQuantity ConfirmQuantity  ,DocDate,AcntCode
					From inv.tblPreSaleDtl
					Where ProcessID=@ProcessID   AND ProcessNo=@ProcessNo AND (@AcntCode IS NULL OR AcntCode=@AcntCode ) 
				) Cnf
				LEFT JOIN 
				(
					Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo 
							, BaseDocRowNo , SUM(GoodsQuantity) ConfirmQuantity
					From sal.tblSaleOrderDtl 
					Where BaseProcessID = @ProcessID AND BaseProcessNo=@ProcessNo  AND (@AcntCode IS NULL OR AcntCode=@AcntCode ) 
					Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo
				) Rtn
				ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
					Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
					Cnf.DocRowNo = Rtn.BaseDocRowNo
			Where Cnf.ConfirmQuantity - ISNULL(Rtn.ConfirmQuantity,0) > 0  
			) Drv
		ON	Cd1.ProcessID = Drv.ProcessID AND  Cd1.ProcessNo = Drv.ProcessNo AND  
			Cd1.FiscalYear = Drv.FiscalYear AND  Cd1.SerialNo = Drv.SerialNo AND  
			Cd1.DocRowNo = Drv.DocRowNo 
		LEFT JOIN sal.tblSaleTypesDtl STD ON Cd1.SaleTypeID = STD.SaleTypeID
	WHERE Cd1.DocStep = @DocStep1 and (@AcntCode IS NULL OR Cd1.AcntCode=@AcntCode ) AND Cd1.DocDate <= @DocDate AND Cd2.ConfirmState <> 2
	and (@InSaleOrderDonotShowWithoutVchNoInPreSale='False' or VchNo<>0)
	 and (
				(@ConfirmCount=0 and (	(@Confirm=0 and Cd1.DocStep=1)
									  or(@Confirm=1 and Cd1.DocStep=2)
									  )
				)or 
				(@ConfirmCount>0 and ((@Sgn1=0 and SgnSN1=0) or (@Sgn1>0 and SgnSN1>0)  )
				  				 and ((@Sgn2=0 and SgnSN2=0) or (@Sgn2>0 and SgnSN2>0)  )
								 and ((@Sgn3=0 and SgnSN3=0) or (@Sgn3>0 and SgnSN3>0)  )
								 and ((@Sgn4=0 and SgnSN4=0) or (@Sgn4>0 and SgnSN4>0)  )
								 and ((@Sgn5=0 and SgnSN5=0) or (@Sgn5>0 and SgnSN5>0)  )
				)
				)		
	
  END

END
GO
