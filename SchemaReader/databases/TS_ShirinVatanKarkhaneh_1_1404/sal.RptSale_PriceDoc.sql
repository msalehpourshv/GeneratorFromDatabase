USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/08/05
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : 
-- =============================================
CREATE PROCEDURE [sal].[RptSale_PriceDoc]
	@SerialNoFr		int = Null,
	@SerialNoTo		int = Null,
	@RepInfo		varchar(10) = '1@1@1'
	
WITH ENCRYPTION
AS
DECLARE	@LangID		int;
DECLARE	@SessionNo	int; 
DECLARE	@ReportID	int; 

Begin

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
	
	--==============
	if (@RepInfo Is Null)	set @RepInfo = '1@1@1';

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SELECT	D.*, H.FromDate, H.ToDate, H.FromTime, H.ToTime, [pub].[funGetGoodsName](D.GoodsID,@LangID) GoodsName, 
			IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '') BarCode, UD.UnitName, 
			pub.GetUserName(H.SessionNo) AS UserName,
			ISNULL(U.ID,0) ID,  ISNULL(U.UserPrice,0)UserPrice, ISNULL(U.DocDate,'') DocDate, 
			ISNULL(U.GoodsQuantity,0) GoodsQuantity, ISNULL(U.UExpirDate,'') UExpirDate, ISNULL(U.UGoodsWeight,0) UGoodsWeight , 
			ISNULL(U.UGoodsHeight,0) UGoodsHeight, ISNULL(U.UGoodsWidth,0) UGoodsWidth, ISNULL(U.UGoodsLength,0)UGoodsLength,
			ISNULL(U.UExtraField1,'')UExtraField1, ISNULL(U.UExtraField2,'')UExtraField2, ISNULL(U.UExtraField3,'')UExtraField3, 
			ISNULL(U.UExtraField4,'') UExtraField4, ISNULL(U.UExtraField5,'') UExtraField5, ISNULL(U.UParams,'') UParams,
			ISNULL(SU.UnitValue,1) UnitValue,ISNULL(SU.MainUnitValue,1) MainUnitValue,[inv].[funGetUnitName](SU.SubUnitID,@LangID) SubUnitName
	FROM	sal.tblGoodsPriceForCustomerKindDtl D 
 INNER JOIN sal.tblGoodsPriceForCustomerKindHdr H ON H.SerialNo = D.SerialNo
 INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID = SUBSTRING(D.GoodsID,@str_Goods+1, @str_GoodsSum) AND GD.PartNumber= @UnitPart AND GD.LanguageID = @LangID
 INNER JOIN inv.tblGoods G ON G.GoodsID = SUBSTRING(D.GoodsID,@str_Goods+1, @str_GoodsSum) AND G.PartNumber= @UnitPart
 INNER JOIN inv.tblUnitsDtl UD ON UD.UnitID = G.UnitID 
 LEFT JOIN inv.tblGoodsUserPrice U ON U.ID = D.UserPriceID 
 LEFT JOIN  (SELECT * FROM inv.tblSubUnitsDtl WHERE ShowInInvoice='True')  SU ON SU.GoodsID=D.GoodsID
	WHERE 	D.SerialNo >= @SerialNoFr AND D.SerialNo <= @SerialNoTo
End
GO
