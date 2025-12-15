USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Jabbari
-- Create date   : 1396/03/01
-- Viewed By	 : 
-- Last Modified : 1396/03/04 - Hamid
-- Description   : 
-- =============================================
CREATE PROCEDURE [sal].[SpShowGoodsPrice]
	@LanguageID 			Smallint	   = 1,
	@SaleTypeID 			varchar(20),
	@PartNumber 			Smallint,
	@PartNumber1 			Smallint,
	@PartNumber2 			Smallint,
	@PartNumber3 			Smallint,
	@GoodsIDLen				smallint,
	@GoodsName				nvarchar(100)  = '',
	@LastLevelMinesOneVal	as varchar(10) = '',
	@LastLevelMinesTwoVal	as varchar(10) = '',
	@LastLevelMinesThreeVal as varchar(10) = '',
	@LastLevelVal			as varchar(10) = '',
	@ShowInMainUnit			as varchar(1)  = 1
	
WITH ENCRYPTION            
AS

DECLARE @Part1Start	Int;
DECLARE @Part2Start	Int;
DECLARE @Part3Start	Int;
DECLARE @Part4Start	Int;
DECLARE @Part1Len	Int;
DECLARE @Part2Len	Int;
DECLARE @Part3Len	Int;
DECLARE @Part4Len	Int;

BEGIN
	SET NOCOUNT ON;
	
	-- =============================
	Declare @SaleTypeIncrease	 As Float;
	Declare @SaleTypeIncreaseSrv As Float;
	
	Select @SaleTypeIncrease = IncDecPercent, @SaleTypeIncreaseSrv = IncDecPercentSrv
	From sal.tblSaleTypes
	Where SaleTypeID = @SaleTypeID
	
	-- =============================
	SET		@Part1Start = 1;
	SELECT	@Part1Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'inv.tblGoods') AND (PartNumber = 1)

	SET	@Part2Start = @Part1Start + @Part1Len;
	SELECT	@Part2Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'inv.tblGoods') AND (PartNumber = 2)

	SET	@Part3Start = @Part2Start + @Part2Len;
	SELECT	@Part3Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'inv.tblGoods') AND (PartNumber = 3)

	SET	@Part4Start = @Part3Start + @Part3Len;
	SELECT	@Part4Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'inv.tblGoods') AND (PartNumber = 4)
		
	-- =============================
	 SELECT Distinct  b.GoodsID, b.GoodsName, 
					  [inv].[FunGoods_PartInfo] (IsNull(@PartNumber3,0),b.GoodsID ) part2,
					  [inv].[FunGoods_PartInfo]  (IsNull(@PartNumber2,0), b.GoodsID) part3,
					  [inv].[FunGoods_PartInfo]  (IsNull(@PartNumber1,0), b.GoodsID) part4,
					  b.GoodsID2 LastLevel, b.GoodsName2,
					  Case When @ShowInMainUnit = '0' Then
							[inv].[funGetUnitName] (b.Unit, @LanguageID)
					  Else 
							[inv].[funGetUnitName] (b.MainUnitID, @LanguageID)
					  End  UnitName,
					  SalePrice + (SalePrice* IsNull(@SaleTypeIncrease,0) / 100) SalePriceInc,
					  ServicePrice + ((ServicePrice) * IsNull(@SaleTypeIncreaseSrv,0) / 100) ServicePriceInc,
					  Case When @ShowInMainUnit = '0' Then
							ROUND(IsNull(((b.SalePrice + b.ServicePrice) * b.MainUnitValue / UnitValue) +
								  (((b.SalePrice * IsNull(@SaleTypeIncrease,0) + b.ServicePrice * IsNull(@SaleTypeIncreaseSrv,0)) * b.MainUnitValue / UnitValue) / 100),0),0) 
					  Else  
							ROUND(IsNull(((b.SalePrice) + b.ServicePrice) + 
								 ((b.SalePrice * IsNull(@SaleTypeIncrease,0) / 100) + 
								  (b.ServicePrice * IsNull(@SaleTypeIncreaseSrv,0) / 100)),0),0)
					  End TotalPriceInc,
					  [pub].[funChangeDate_GergorianToPersian] (getdate()) currentDate
	 FROM 
     (
		SELECT DISTINCT * 
        FROM 
        (
			SELECT Cast(SA.GoodsID  as varchar(20)) GoodsID,
				   IsNull(SP.Price,0) +IsNull(SP.TaxTellPrice,0) ServicePrice,
				   [pub].[funGetGoodsName](SA.GoodsID,@LanguageID) GoodsName,
				   [pub].[funGetServiceNameByPartNumber](SP.GoodsID2,@LanguageID,@PartNumber) GoodsName2, SP.GoodsID2,
				   IsNull((Price1+Price2+Price3+Price4+Price5+Price6+Price7+Price8+Price9+Price10),0)  SalePrice,
				   --Get UnitID
				   Case When G.UnitID = SP.UnitID Then SP.UnitID
			 		    When SP.UnitID IS null Then (Select UnitID From inv.tblGoods Where GoodsID = SubString(SA.GoodsID ,1,@GoodsIDLen))
				   Else (select top 1 SubUnitID  from  inv.tblSubUnitsDtl where GoodsID=left(SP.GoodsID1,len(SP.GoodsID1)- len(SP.GoodsID2)) + SP.GoodsID2 and ShowInInvoice =1) 
				   End Unit,
				   --Get UnitValue
				   Case When G.UnitID = SP.UnitID  Then 1     
					    When SP.UnitID IS null Then 1    
				   Else (Select Top 1 MainUnitValue From inv.tblSubUnitsDtl Where GoodsID=left(SP.GoodsID1,len(SP.GoodsID1)- len(SP.GoodsID2)) + SP.GoodsID2 and ShowInInvoice =1) 
				   End MainUnitValue,   
				   --Get MainUnitValue
				   Case When G.UnitID = SP.UnitID  Then 1   
				        When SP.UnitID IS null Then 1     
				   Else  (select top 1 UnitValue  From inv.tblSubUnitsDtl Where GoodsID=left(SP.GoodsID1,len(SP.GoodsID1)- len(SP.GoodsID2)) + SP.GoodsID2  and ShowInInvoice =1) 
				   End UnitValue, G.UnitID MainUnitID
			FROM sal.tblServicePriceDtl SP  
            Left Join sal.tblSalePriceAnalysisDtl SA On SP.GoodsID1 = SA.GoodsID And 
													   (SP.GoodsID2 = @LastLevelVal or @LastLevelVal = '')  
            Inner Join inv.tblGoods G on G.GoodsID = SubString(SA.GoodsID ,1,@GoodsIDLen) And
										 SA.SerialNo = (Select max(SerialNo) 
														From sal.tblSalePriceAnalysisDtl SAA 
														Where SAA.GoodsID=SA.GoodsID)
        ) a  
        WHERE a.GoodsName Like '%' + @GoodsName + '%' Or @GoodsName Is Null 
     ) b  
     WHERE (SubString(b.GoodsID, @Part4Start, @Part4Len) Like '%' + @LastLevelMinesOneVal + '%' AND SubString(b.GoodsID, @Part3Start, @Part3Len) Like '%' + @LastLevelMinesTwoVal + '%' AND 
		    SubString(b.GoodsID, @Part2Start, @Part2Len) Like '%' + @LastLevelMinesThreeVal + '%')
END
GO
