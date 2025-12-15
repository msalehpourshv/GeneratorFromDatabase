USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem 
-- Create date   :  
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : TakroSystem\ 
-- Description   :  
-- ==============================================
-- این تابع در برنامه تبلت نیز استفاده شده است.در صورت انجام تغییرات در تابع، به برنامه نویس تبلت اطلاع داده شود
Create PROCEDURE sal.spLineDiscountGroup
(
	@AcntCode		VarChar(20)=NULL, 
	@GoodsID		VarChar(20)=NULL, 
	@DocDate		Char(10), 
	@GoodsPrice		Float,
	@GoodsQuantity	Float,
	@SaleTypeID		VarChar(20),
	@GoodsGroupID	VarChar(20),
	@PayOffTypeID	VarChar(20),
	@UserPriceID	int
)

WITH ENCRYPTION
AS
Begin -- === S T A R T ===========================================

--	Declare @GoodsGroupID	VarChar(20);
	Declare @CustomerKindID	VarChar(20);
	Declare @AcntCode1		VarChar(20);
	Declare @AcntCode2		VarChar(20);
	Declare @AcntCode3		VarChar(20);
	Declare @AcntCode4		VarChar(20);
	Declare @AcntPartNumber tinyint;
	Declare @Result			Float;
	Declare @LayerLen	AS tinyint;
	Declare @CodeLayer1 AS tinyint;
	Declare @CodeLayer2 AS tinyint;
	Declare @CodeLayer3 AS tinyint;
	Declare @CodeLayer4 AS tinyint;
	Declare @StartLayerIndex  AS tinyint;
	Declare @StartLayerIndex2 AS tinyint;
	Declare @StartLayerIndex3 AS tinyint;
	Declare @StartLayerIndex4 AS tinyint;
	Declare @CallType	as int;
	Declare @ProcessID as int;
	SET @CodeLayer1 = 0
	SET @CodeLayer2 = 0
	SET @CodeLayer3 = 0
	SET @CodeLayer4 = 0
	
	SELECT @CodeLayer1=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	FROM pub.tblCodeLayer 
	WHERE (TableName='acc.tblAcnt') AND (PartNumber=1) 

	SELECT @CodeLayer2=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	FROM pub.tblCodeLayer 
	WHERE (TableName='acc.tblAcnt') AND (PartNumber=2) 

	SELECT @CodeLayer3=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	FROM pub.tblCodeLayer 
	WHERE (TableName='acc.tblAcnt') AND (PartNumber=3) 

	SELECT @CodeLayer4=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	FROM pub.tblCodeLayer 
	WHERE (TableName='acc.tblAcnt') AND (PartNumber=4)
	
	SET @AcntCode1=SUBSTRING(@AcntCode,1,@CodeLayer1)
	
	IF @CodeLayer2>0
		BEGIN
			SET @StartLayerIndex2= @CodeLayer1 + 2
			SET @AcntCode2=SUBSTRING(@AcntCode,@StartLayerIndex2,@CodeLayer2)
		END
	ELSE
		BEGIN
			SET @StartLayerIndex2 = 0
			SET @AcntCode2=''
		END
		
	IF @CodeLayer3>0
		BEGIN
			SET @StartLayerIndex3= @CodeLayer1 + @CodeLayer2 + 3
			SET @AcntCode3=SUBSTRING(@AcntCode,@StartLayerIndex3,@CodeLayer3)
		END
	ELSE
		BEGIN
			SET @StartLayerIndex3 = 0	
			SET @AcntCode3=''
		END

	IF @CodeLayer4>0
		BEGIN
			SET @StartLayerIndex4= @CodeLayer1 + @CodeLayer2 + @CodeLayer3 + 4
			SET @AcntCode4=SUBSTRING(@AcntCode,@StartLayerIndex4,@CodeLayer4)
		END
	ELSE
		BEGIN
			SET @StartLayerIndex4 = 0	
			SET @AcntCode4=''
		END

	set @CallType=1
	set @ProcessID=200
	if @GoodsGroupID<>'' 
	begin
		set @CallType=2
		set @ProcessID=206
	end 
	--if @GoodsGroupID='' 
	--	SELECT @GoodsGroupID = GoodsGroupID 
	--	FROM inv.tblGoodsGroupsGoodsListDtl
	--	WHERE GoodsID = @GoodsID

	SELECT @LayerLen = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'LayerLen'

	SELECT @StartLayerIndex = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'StartLayerIndex'
	
	SELECT @AcntPartNumber = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'
	
	SELECT @CustomerKindID = CustomerKindID 
	FROM acc.tblAcnt
	WHERE PartNumber = @AcntPartNumber AND AcntCode=RTRIM(SUBSTRING(@AcntCode,@StartLayerIndex ,@LayerLen))

	-- ==============================================================
	SELECT  @AcntCode AcntCode,@GoodsID GoodsID,SUBSTRING(@GoodsID,1,LEN(GoodsID)) GoodsID2,@DocDate DocDate,@GoodsPrice GoodsPrice,@GoodsQuantity GoodsQuantity
	,@SaleTypeID SaleTypeID,@PayOffTypeID PayOffTypeID,DiscountPercent,Discount,FromAmount,ToAmount ,ForQty ,FromQty,ToQty,AwardUserPriceID UserPriceID
	,CASE WHEN DiscountPercent > 0 THEN 
								CASE WHEN ForQty = 0  THEN 
									(@GoodsPrice * DiscountPercent)/100
								ELSE 
									((floor(@GoodsQuantity / ForQty) * ForQty) * (@GoodsPrice / @GoodsQuantity)) * DiscountPercent / 100 
								END
							WHEN Discount > 0 THEN 
								CASE WHEN ForQty = 0 THEN 
									 Discount
								ELSE 
									 Discount * (floor(@GoodsQuantity / ForQty)) 
								END
							ELSE 
								0 
							END DiscountPrice
							
				,D.SerialNo	,DocRowNo,FromDate,ToDate	
				, Case when   @CallType=1 then '' else  @GoodsGroupID	end GoodsGroupID	
	FROM    sal.tblDiscountPoliciesDtl D 	INNER JOIN sal.tblDiscountPoliciesHdr H ON	D.ProcessID = H.ProcessID AND D.SerialNo = H.SerialNo 
	WHERE	--(Discount > 0 Or DiscountPercent > 0) AND 
			D.ProcessID = @ProcessID 	
			AND ((FromDate <= @DocDate AND ToDate >= @DocDate)) 
	AND (
	
	(ForQty > 0 AND ForQty <= @GoodsQuantity)
		OR  (@GoodsPrice >0 and @GoodsPrice >= FromAmount AND @GoodsPrice <= ToAmount) 
		OR  (@GoodsQuantity>0 and @GoodsQuantity >= FromQty And @GoodsQuantity <= ToQty)
			
			) 
			AND (SaleTypeID='' or SaleTypeID=SUBSTRING(@SaleTypeID,1,LEN(SaleTypeID)))
			AND (PayOffTypeID='' or PayOffTypeID=SUBSTRING(@PayOffTypeID,1,LEN(PayOffTypeID)))			
			AND (AwardUserPriceID=0 or AwardUserPriceID=@UserPriceID)			
			AND (CustomerKindID='' or CustomerKindID = SUBSTRING(@CustomerKindID,1,LEN(CustomerKindID)))
			AND (AcntCode1='' or  AcntCode1= SUBSTRING(@AcntCode1,1,LEN(AcntCode1)))
			AND (AcntCode2='' or  AcntCode2= SUBSTRING(@AcntCode2,1,LEN(AcntCode2)))
			AND (AcntCode3='' or  AcntCode3= SUBSTRING(@AcntCode3,1,LEN(AcntCode3)))
			AND (AcntCode4='' or  AcntCode4= SUBSTRING(@AcntCode4,1,LEN(AcntCode4)))
			AND ((@CallType=1  and GoodsGroupID='' ) or   GoodsGroupID = @GoodsGroupID)
			AND ((@CallType=2  and GoodsID='' ) or   GoodsID=@GoodsID ) 										 
	ORDER BY FromDate Desc,D.SerialNo Desc ,ForQty Desc, FromQty Desc ,DocRowNo Desc
	-- ==============================================================
	
	
END
GO
