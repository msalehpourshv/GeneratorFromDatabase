USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--SELECT [sal].[funGetLineVisitorPercent]('111201 04002001','110116','1394/06/07','') 
CREATE FUNCTION [sal].[funGetLineVisitorPercent]
(
	@AcntCode	VarChar(20)=NULL, 
	@GoodsID	VarChar(20)=NULL, 
	@DocDate	Char(10), 
	@GoodsPrice		Float,
	@GoodsQuantity	Float, 
	@SaleTypeID	VarChar(20)=NULL
)
RETURNS Float
WITH ENCRYPTION
AS
Begin -- === S T A R T ===========================================
		
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
	
	SET @LayerLen = 0
	SET @Result = 0
	SET @AcntPartNumber = 0
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
		
	set @CustomerKindID=isnull(@CustomerKindID,'') 

	SELECT  TOP 1  @Result = VisitorPercent
	FROM    sal.tblDiscountPoliciesDtl D INNER JOIN sal.tblDiscountPoliciesHdr H 
			ON	D.ProcessID = H.ProcessID AND D.SerialNo = H.SerialNo 
	WHERE (VisitorPercent > 0) AND D.ProcessID = 200 AND ((FromDate<=@DocDate AND ToDate>=@DocDate)) 
		AND ((ForQty > 0 AND ForQty <= @GoodsQuantity) OR  (@GoodsPrice >= FromAmount AND @GoodsPrice <= ToAmount) OR  (@GoodsQuantity >= FromQty And @GoodsQuantity <= ToQty)) 
		AND (SaleTypeID='' or SaleTypeID=SUBSTRING(@SaleTypeID,1,LEN(SaleTypeID)))
			AND (CustomerKindID='' or CustomerKindID = SUBSTRING(@CustomerKindID,1,LEN(CustomerKindID)))
			AND (AcntCode1='' or  AcntCode1= SUBSTRING(@AcntCode1,1,LEN(AcntCode1)))
			AND (AcntCode2='' or  AcntCode2= SUBSTRING(@AcntCode2,1,LEN(AcntCode2)))
			AND (AcntCode3='' or  AcntCode3= SUBSTRING(@AcntCode3,1,LEN(AcntCode3)))
			AND (AcntCode4='' or  AcntCode4= SUBSTRING(@AcntCode4,1,LEN(AcntCode4)))
			AND (GoodsGroupID='' or   GoodsGroupID in (SELECT GoodsGroupID FROM inv.tblGoodsGroupsGoodsListDtl	WHERE GoodsID = @GoodsID))
			AND (GoodsID='' or  SUBSTRING(GoodsID,1,LEN(GoodsID)) = SUBSTRING(@GoodsID,1,LEN(GoodsID)))
	ORDER BY FromDate Desc,DocRowNo		
 
	Return @Result
	
End   -- === E N D ===============================================
GO
