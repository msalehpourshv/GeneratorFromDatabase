USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create FUNCTION [sal].[funGetDiscountForDistPercent]
(
	@ProcessID			Tinyint,
	@AcntCode			VarChar(20) = NULL, 
	@DocDate			Char(10),
	@Price				Float,
	@Qty				Float,
	@ReturnIsDiscount	Bit,
	@SaleTypeID			VarChar(20) = '',
	@RowCount			int ,
	@SubUnitQty			int 
)
RETURNS Float
WITH ENCRYPTION
AS
Begin -- === S T A R T ===========================================


	Declare @CustomerKindID	VarChar(20);
	Declare @StartLayerIndex AS tinyint;
	Declare @AcntPartNumber tinyint;
	Declare @Result			Float;
	Declare @LayerLen AS tinyint;
	Declare @AcntCode1		VarChar(20);
	Declare @AcntCode2		VarChar(20);
	Declare @AcntCode3		VarChar(20);
	Declare @AcntCode4		VarChar(20);
	Declare @CodeLayer1 AS tinyint;
	Declare @CodeLayer2 AS tinyint;
	Declare @CodeLayer3 AS tinyint;
	Declare @CodeLayer4 AS tinyint;
	Declare @StartLayerIndex2 AS tinyint;
	Declare @StartLayerIndex3 AS tinyint;
	Declare @StartLayerIndex4 AS tinyint;
	
	SET @Result = 0
	SET @AcntPartNumber = 0
	SET @StartLayerIndex = 0
	SET @LayerLen = 0
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
			SET @AcntCode1=''
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
	WHERE PartNumber = @AcntPartNumber AND AcntCode = RTRIM(SUBSTRING(@AcntCode,@StartLayerIndex ,@LayerLen))

	SELECT  TOP 1 @Result = CASE WHEN @ReturnIsDiscount = 0 THEN DiscountPercent ELSE Discount END
	FROM    sal.tblDiscountPoliciesDtl D 
	INNER JOIN sal.tblDiscountPoliciesHdr H ON	D.ProcessID = H.ProcessID AND D.SerialNo = H.SerialNo 
	WHERE   D.ProcessID = @ProcessID AND 
			(@DocDate >= FromDate AND @DocDate <= ToDate) AND 
			(SaleTypeID='' or SaleTypeID=SUBSTRING(@SaleTypeID,1,LEN(SaleTypeID))) AND  (
			(CustomerKindID = @CustomerKindID AND 
			 	(LEN(AcntCode1) = 0 OR (LEN(AcntCode1) > 0 AND SUBSTRING(AcntCode1,1,LEN(AcntCode1)) = SUBSTRING(@AcntCode1,1 ,LEN(AcntCode1)))) AND 
				(LEN(AcntCode2) = 0 OR (LEN(AcntCode2) > 0 AND SUBSTRING(AcntCode2,1,LEN(AcntCode2)) = SUBSTRING(@AcntCode2,1 ,LEN(AcntCode2)))) AND	
				(LEN(AcntCode3) = 0 OR (LEN(AcntCode3) > 0 AND SUBSTRING(AcntCode3,1,LEN(AcntCode3)) = SUBSTRING(@AcntCode3,1 ,LEN(AcntCode3)))) AND
				(LEN(AcntCode4) = 0 OR (LEN(AcntCode4) > 0 AND SUBSTRING(AcntCode4,1,LEN(AcntCode4)) = SUBSTRING(@AcntCode4,1 ,LEN(AcntCode4))))	
			) OR  
			(LEN(CustomerKindID) = 0 AND 
			 	(LEN(AcntCode1) = 0 OR (LEN(AcntCode1) > 0 AND SUBSTRING(AcntCode1,1,LEN(AcntCode1)) = SUBSTRING(@AcntCode1,1 ,LEN(AcntCode1)))) AND 
				(LEN(AcntCode2) = 0 OR (LEN(AcntCode2) > 0 AND SUBSTRING(AcntCode2,1,LEN(AcntCode2)) = SUBSTRING(@AcntCode2,1 ,LEN(AcntCode2)))) AND	
				(LEN(AcntCode3) = 0 OR (LEN(AcntCode3) > 0 AND SUBSTRING(AcntCode3,1,LEN(AcntCode3)) = SUBSTRING(@AcntCode3,1 ,LEN(AcntCode3)))) AND
				(LEN(AcntCode4) = 0 OR (LEN(AcntCode4) > 0 AND SUBSTRING(AcntCode4,1,LEN(AcntCode4)) = SUBSTRING(@AcntCode4,1 ,LEN(AcntCode4))))	
			) OR
			(
			 	(LEN(AcntCode1) = 0 AND LEN(AcntCode2) = 0 AND LEN(AcntCode3) = 0 AND LEN(AcntCode4) = 0) AND CustomerKindID = @CustomerKindID)
			) AND 
				(	(
						FromQty=0 and ToQty=0 And (@Price >= FromAmount  AND @Price <= ToAmount)
						and (( RowCountFrom<=@RowCount and  RowCountTo>=@RowCount)or ( RowCountFrom=0 and  RowCountTo=0))
					)OR(
						FromAmount=0 and ToAmount=0 And ( ( SubUnitType=0 and FromQty <= @Qty AND ToQty >= @Qty) or ( SubUnitType=1 and FromQty <= @SubUnitQty AND ToQty >= @SubUnitQty))
						and (( RowCountFrom<=@RowCount and  RowCountTo>=@RowCount)or ( RowCountFrom=0 and  RowCountTo=0))
					)OR(
						((FromQty>0 OR ToQty>0) And (@Price >= FromAmount  AND @Price <= ToAmount)) AND
						(FromAmount>0 OR ToAmount>0 And ((SubUnitType=0 and FromQty <= @Qty AND ToQty >= @Qty)) or ( SubUnitType=1 and FromQty <= @SubUnitQty AND ToQty >= @SubUnitQty))
						and (( RowCountFrom<=@RowCount and  RowCountTo>=@RowCount)or ( RowCountFrom=0 and  RowCountTo=0))
					)OR(
						ForQty=0 and FromQty=0 and ToQty=0 And FromAmount=0 and ToAmount=0 and RowCountFrom<=@RowCount and  RowCountTo>=@RowCount
					)
				)			 			
	ORDER BY FromDate Desc, DocRowNo		
 
	RETURN @Result
	
END
GO
