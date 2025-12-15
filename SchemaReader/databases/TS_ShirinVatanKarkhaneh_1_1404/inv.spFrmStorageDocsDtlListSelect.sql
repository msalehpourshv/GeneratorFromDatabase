USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hadi Sadeghi
-- Create date   : 86/10/15
-- Viewed By	 : 
-- Last Modified : 1393/08/11 - Hamid
-- Description   : 
-- =============================================
Create PROCEDURE [inv].[spFrmStorageDocsDtlListSelect]
	@ProcessID	Smallint,
	@ProcessNo	TinyInt,
	@DocDate	Char(10),
	@AcntCode	varchar(20),
	@GoodsID	varchar(20),
	@StoreID	varchar(20),
	@LanguageID int
WITH ENCRYPTION
 AS
BEGIN

--	SET @LanguageID = pub.funGetCurrentLanguageID();

SET NOCOUNT ON;
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

DECLARE @ReturnProcessID INT
IF @ProcessID=60
	BEGIN
		set @ReturnProcessID = 55
	END
ELSE IF @ProcessID=100
	BEGIN
		set @ReturnProcessID = 90
	END
ELSE IF @ProcessID=115
	BEGIN
		set @ReturnProcessID = 110
	END

IF @ProcessID=60 OR @ProcessID=100 OR @ProcessID=115
	BEGIN
	Declare @SaleOrderAcntCode Varchar(20)=''
	IF  @ProcessID=100
		SELECT @SaleOrderAcntCode = SettingValue FROM pub.tblSettings WHERE SettingKey = 'SaleOrderAcntCode'
	IF  @ProcessID=60
		SELECT @SaleOrderAcntCode = SettingValue FROM pub.tblSettings WHERE SettingKey = 'BuyOrderAcntCode'	
	
	SELECT * FROM (
		SELECT DISTINCT	acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, 
				OD.RowNo, OD.VolumeRowNo, OD.DocStep, OD.DocDate, OD.StoreID, OD.EnterKind, OD.StoreID2, OD.AcntCode, 
				OD.VisitorAcntCode, OD.VisitorPercent, OD.VisitorAcntCode2, OD.VisitorPercent2, OD.OrderAcntCode, OD.GoodsID, 
				OD.SubUnitID, inv.funGetGoodsSubQuantity(OD.GoodsID,OD.SubUnitID,Cn.GoodsQuantity) SubUnitQuantity, Cn.GoodsQuantity, 
				OD.QtyRemain, OD.GoodsAmount, OD.AtomAmount, OD.GoodsPrice, OD.DescDtl, OD.BaseProcessID, IsReward, OD.BaseProcessNo, 
				OD.BaseFiscalYear, OD.BaseSerialNo, OD.BaseDocRowNo, OD.AgreeNo, OD.DocRowNo, OD.TaxOverWorthCostDtl, OD.UserPriceID,
					IsNull((Select UParams From inv.tblGoodsUserPrice p Where p.ID=OD.UserPriceID) ,'') as UserPrice,
				OD.TollOverWorthCostDtl, [inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,
				pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName, inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName,
				[inv].[funGetMaxGoodsRemain](OD.ProcessID,OD.ProcessNo,OD.FiscalYear,OD.SerialNo,OD.ProcessID,OD.ProcessNo,
				OD.FiscalYear,OD.SerialNo,OD.DocRowNo,StoreID,OD.GoodsID,OD.BatchNo,@DocDate,1)  AS BaseRemain,SubUnitPrice,SubUnitPrice2,SubUnitQuantity2,
				OD.DiscountPercentDtl,(DiscountDtl * Cn.GoodsQuantity )/OD.GoodsQuantity as DiscountDtl, OD.SaleTypeID,OD.Var1,OD.Var2,OD.Var3,OD.Var4
				,[inv].[funGetTechnicalNo](OD.GoodsID) AS TechnicalNo
		FROM inv.tblStorageDocsDtl OD 
				--	-------------------------------------------------------------------			

			INNER JOIN
			(
				Select	Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo,Cnf.DocRowNo,
						Cnf.GoodsQuantity - ISNULL(Rtn.GoodsQuantity,0) GoodsQuantity
				From
					(
						Select	OD.ProcessID , OD.ProcessNo , OD.FiscalYear , OD.SerialNo , 
								OD.DocRowNo , OD.GoodsQuantity
						From inv.tblStorageDocsDtl OD
						Where OD.ProcessID = @ReturnProcessID AND OD.ProcessNo = @ProcessNo AND (@GoodsID IS NULL OR GoodsID = @GoodsID) AND 
							 (@AcntCode IS NULL OR AcntCode = @AcntCode) AND 
							  DocDate<=@DocDate AND	OD.DocStep in (0,1,2,3,11) 
					) Cnf
				LEFT JOIN 
				(
					Select	OD.BaseProcessID , OD.BaseProcessNo , OD.BaseFiscalYear , OD.BaseSerialNo , 
							OD.BaseDocRowNo , Sum(OD.GoodsQuantity) GoodsQuantity
					From inv.tblStorageDocsDtl OD
					Where OD.BaseProcessID = @ReturnProcessID AND OD.ProcessNo = @ProcessNo AND (@AcntCode IS NULL OR AcntCode = @AcntCode) 
					Group BY OD.BaseProcessID , OD.BaseProcessNo , OD.BaseFiscalYear , 
							 OD.BaseSerialNo , OD.BaseDocRowNo
				) Rtn
				ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
					Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
					Cnf.DocRowNo = Rtn.BaseDocRowNo
			) Cn ON Cn.ProcessID = OD.ProcessID AND Cn.ProcessNo = OD.ProcessNo AND 
					Cn.FiscalYear = OD.FiscalYear AND Cn.SerialNo = OD.SerialNo AND 
					Cn.DocRowNo = OD.DocRowNo AND OD.DocDate<=@DocDate AND 
					(@AcntCode IS NULL OR OD.AcntCode   = @AcntCode) AND  Cn.GoodsQuantity>0
		INNER JOIN
		(SELECT GoodsID FROM inv.tblGoods WHERE CodeClosed = 'False'   AND PartNumber = @UnitPart  ) G
		ON SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID		
	) A WHERE IsCodeClosed = 0 and 
		((
							------------حذف اطلاعاتی که اسناد آنها ازنوع یادداشت است------------------------------------------------------
					SELECT COUNT(*)	from acc.tblVoucherDtl  v 
								WHERE v.SourceProcessID= A.ProcessID and  v.SourceProcessNo= A.ProcessNo
								and  v.SourceFiscalYear= A.FiscalYear and  v.SourceSerialNo= A.SerialNo
								and (v.AcntCode= A.AcntCode or v.AcntCode=[pub].[funMergCode](@SaleOrderAcntCode,A.AcntCode)) and v.VchKind<>0  
		) > 0 OR @ProcessID=115) 

	END
	
END
GO
