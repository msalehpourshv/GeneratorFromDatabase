USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1386/01/21
-- Viewed By	 : 
-- Last Modified : 1389/04/26
-- Last Modifier : TakroSystem\Zia
-- Description	 : 
-- ----------------------------------------------
-- مواد مورد نیاز برای تولید یک یا چند محصول بدون توجه به میزان موجودی 
-- ==============================================
CREATE PROCEDURE [prd].[RptPrd_ProductGoods_All]
	@UserID			int = Null,         
	@RepOptions		varchar(20) = '1',	-- bit array
	@RepInfo		nvarchar(100) = '1@1@1'
WITH ENCRYPTION
AS
declare @LangID		int;
declare @SessionNo  varchar(10);
declare @ReportID   varchar(10);

declare	@ProductID	varchar(20);
declare	@GoodsID	varchar(20);
declare	@ProductQty real;
declare	@GoodsQty	real;
Begin 
	SET NOCOUNT ON; 

	--========================
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  Tinyint,
			@str_GoodsSum Tinyint

	Select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	From pub.tblCodeLayer 
	Where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	Select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	From pub.tblCodeLayer 
	Where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart
	
	-- Init ---------------------------------------------------------------------
	if (@RepInfo Is Null)	 set @RepInfo = '1@1@1';
	if (@RepOptions Is Null) set @RepOptions = '1';

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	create table #tblResult
	(
		ProductID	varchar(20) collate Arabic_CS_AS  Not Null, 
		ProductQty	real Not Null,
		GoodsID		varchar(20) collate Arabic_CS_AS  Not Null, 
		GoodsQty	real Not Null,
		ConstPrdText1  nVarchar(100),
		ConstPrdText2  nVarchar(100),
		ConstPrdText3  nVarchar(100),
		ConstPrdText4  nVarchar(100),
		ConstPrdText5  nVarchar(100),
		ConstPrdText1Name  nVarchar(100),
		ConstPrdText2Name  nVarchar(100),
		ConstPrdText3Name  nVarchar(100),
		ConstPrdText4Name  nVarchar(100),
		ConstPrdText5Name  nVarchar(100)
	);
	Declare @ConstPrdText1Name  nVarchar(100)
	Declare @ConstPrdText2Name  nVarchar(100)
	Declare @ConstPrdText3Name  nVarchar(100)
	Declare @ConstPrdText4Name  nVarchar(100)
	Declare @ConstPrdText5Name  nVarchar(100)
	
	
	SELECT @ConstPrdText1Name=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText1'
	SELECT @ConstPrdText2Name=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText2'
	SELECT @ConstPrdText3Name=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText3'
	SELECT @ConstPrdText4Name=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText4'
	SELECT @ConstPrdText5Name=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText5'
	
	-----------------------------------------------------------------------------
	-- Fill ---------------------------------------------------------------------
	declare crs_Products cursor for
	    select	ProductID, Quantity
		from	prd.tblProductSlc
		where	(UserID = @UserID) AND (ReportID = @ReportID) AND (ObjectID = 1)

	open  crs_Products;
	fetch NEXT from crs_Products into @ProductID, @ProductQty

    while (@@FETCH_STATUS = 0) 
    begin
		insert	into #tblResult
		select	@ProductID, @ProductQty, D.GoodsID, (D.GoodsQuantity * @ProductQty) / H.ProductCount
		,D.ConstPrdText1,D.ConstPrdText2,D.ConstPrdText3,D.ConstPrdText4,D.ConstPrdText5,
	@ConstPrdText1Name  ConstPrdText1Name,@ConstPrdText2Name  ConstPrdText2Name,@ConstPrdText3Name  ConstPrdText3Name,
	@ConstPrdText4Name  ConstPrdText4Name,@ConstPrdText5Name ConstPrdText5Name
	
	from	prd.tblFormulasDtl D
					INNER JOIN prd.tblFormulasHdr H on D.SerialNo = H.SerialNo AND D.ProductID = H.ProductID and H.IsDefault = 1
		where  (H.ProductID = @ProductID)

		fetch NEXT from crs_Products into @ProductID, @ProductQty
    end 

	close		crs_Products;
	deallocate  crs_Products;
	-----------------------------------------------------------------------------
	-- select -------------------------------------------------------------------
	SELECT T.*, [pub].[funGetGoodsName](T.GoodsID, @LangID) As GoodsName, 
			    [pub].[funGetGoodsUnitName] (T.GoodsID, @LangID) As UnitName, I.GoodsImage 
	FROM 
	(
		Select GoodsID, Sum(GoodsQty) As GoodsQty, ConstPrdText1, ConstPrdText2, ConstPrdText3, 
			   ConstPrdText4,ConstPrdText5, ConstPrdText1Name, ConstPrdText2Name, ConstPrdText3Name,
			   ConstPrdText4Name, ConstPrdText5Name
		From	#tblResult 
		Group By GoodsID, ConstPrdText1, ConstPrdText2, ConstPrdText3, ConstPrdText4, ConstPrdText5,
				 ConstPrdText1Name, ConstPrdText2Name, ConstPrdText3Name, ConstPrdText4Name, ConstPrdText5Name
	) T	
	LEFT  JOIN inv.tblGoods GH ON GH.GoodsID = SUBSTRING(T.GoodsID,@str_Goods+1, @str_GoodsSum) AND GH.PartNumber= @UnitPart
	LEFT  JOIN inv.tblGoodsImages I ON I.GoodsID = GH.GoodsID	

	Order By GoodsID
	-----------------------------------------------------------------------------
END
GO
