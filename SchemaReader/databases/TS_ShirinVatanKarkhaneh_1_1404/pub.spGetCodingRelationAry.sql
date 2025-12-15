USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--[pub].[spGetCodingRelationAry] '10000','inv.tblGoods',1
CREATE PROCEDURE [pub].[spGetCodingRelationAry]
@StrCode VarChar(20),
@TableName nvarchar(200),
@LinkedPartNo Tinyint
WITH ENCRYPTION
As 
BEGIN

declare @tblPartsRelation TABLE ([IsRelation] bit ) 

DECLARE @PartNo tinyint
DECLARE @IsRelation bit

DECLARE @Part1Len as TINYINT
DECLARE @Part2Len as TINYINT
DECLARE @Part3Len as TINYINT
DECLARE @Part4Len as TINYINT
DECLARE @Part5Len as TINYINT

SELECT @Part1Len = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 FROM pub.tblCodeLayer WHERE TableName = @TableName AND PartNumber=1
SELECT @Part2Len = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 FROM pub.tblCodeLayer WHERE TableName = @TableName AND PartNumber=2
SELECT @Part3Len = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 FROM pub.tblCodeLayer WHERE TableName = @TableName AND PartNumber=3
SELECT @Part4Len = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 FROM pub.tblCodeLayer WHERE TableName = @TableName AND PartNumber=4
SELECT @Part5Len = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 FROM pub.tblCodeLayer WHERE TableName = @TableName AND PartNumber=5


IF @LinkedPartNo >= 1 AND @Part2Len>0
BEGIN
	SELECT @IsRelation =COUNT(*) 
	FROM pub.tblCodingRelation
	WHERE TableName = @TableName AND LinkedPartNo = 1
	 AND (Code = left(SUBSTRING(@StrCode,1,@Part1Len),len(Code))) AND (PartNo = 2) 
		  
	INSERT INTO @tblPartsRelation values ( @IsRelation )
	IF @LinkedPartNo = 1
	BEGIN
		INSERT INTO @tblPartsRelation values ( 'False' )
		INSERT INTO @tblPartsRelation values ( 'False' )
		INSERT INTO @tblPartsRelation values ( 'False' )
	END	
END

IF @LinkedPartNo >= 2 AND @Part3Len>0
BEGIN
	
	SELECT @IsRelation =COUNT(*) 
	FROM pub.tblCodingRelation
	WHERE TableName = @TableName AND LinkedPartNo = 2
	 AND (Code = left(SUBSTRING(@StrCode,@Part1Len+1,@Part2Len),len(Code))) AND (PartNo = 3) 
	
	IF @IsRelation	= 'True'
		INSERT INTO @tblPartsRelation values ( @IsRelation )
	ELSE
	BEGIN
		SELECT @IsRelation =COUNT(*) 
		FROM pub.tblCodingRelation
		WHERE TableName = @TableName AND LinkedPartNo = 1
		 AND (Code = left(SUBSTRING(@StrCode,1,@Part1Len),len(Code))) AND (PartNo = 3) 
		 
		INSERT INTO @tblPartsRelation values ( @IsRelation )
	END
	
	IF @LinkedPartNo = 2
	BEGIN
		INSERT INTO @tblPartsRelation values ( 'False' )
		INSERT INTO @tblPartsRelation values ( 'False' )
	END
	
END

IF @LinkedPartNo >= 3 AND @Part4Len>0
BEGIN

	SELECT @IsRelation =COUNT(*) 
	FROM pub.tblCodingRelation
	WHERE TableName = @TableName AND LinkedPartNo = 3
	 AND (Code = left(SUBSTRING(@StrCode,@Part1Len+@Part2Len+1,@Part3Len),len(Code))) AND (PartNo = 4) 
	
	IF @IsRelation	= 'True'
		INSERT INTO @tblPartsRelation values ( @IsRelation )
	ELSE
	BEGIN
		SELECT @IsRelation =COUNT(*) 
		FROM pub.tblCodingRelation
		WHERE TableName = @TableName AND LinkedPartNo = 1
		 AND (Code = left(SUBSTRING(@StrCode,1,@Part1Len),len(Code))) AND (PartNo = 4) 
		IF @IsRelation	= 'True'
			INSERT INTO @tblPartsRelation values ( @IsRelation )
		ELSE
		BEGIN
			SELECT @IsRelation =COUNT(*) 
			FROM pub.tblCodingRelation
			WHERE TableName = @TableName AND LinkedPartNo = 2
			 AND (Code = left(SUBSTRING(@StrCode,@Part1Len+1,@Part2Len),len(Code))) AND (PartNo = 4) 
		 
			INSERT INTO @tblPartsRelation values ( @IsRelation )
		END	
	END
	IF @LinkedPartNo = 2
	BEGIN	
		INSERT INTO @tblPartsRelation values ( 'False' )
	END	
END

IF @LinkedPartNo >= 4 AND @Part5Len>0
BEGIN

	SELECT @IsRelation =COUNT(*) 
	FROM pub.tblCodingRelation
	WHERE TableName = @TableName AND LinkedPartNo = 4
	 AND (Code = left(SUBSTRING(@StrCode,@Part1Len+@Part2Len+@Part3Len+1,@Part4Len),len(Code))) AND (PartNo = 5) 
	
	IF @IsRelation	= 'True'
		INSERT INTO @tblPartsRelation values ( @IsRelation )
	ELSE
	BEGIN
		SELECT @IsRelation =COUNT(*) 
		FROM pub.tblCodingRelation
		WHERE TableName = @TableName AND LinkedPartNo = 1
		 AND (Code = left(SUBSTRING(@StrCode,1,@Part1Len),len(Code))) AND (PartNo = 5) 
		 
		IF @IsRelation	= 'True'
			INSERT INTO @tblPartsRelation values ( @IsRelation )
		ELSE
		BEGIN
			SELECT @IsRelation =COUNT(*) 
			FROM pub.tblCodingRelation
			WHERE TableName = @TableName AND LinkedPartNo = 2
			 AND (Code = left(SUBSTRING(@StrCode,@Part1Len+1,@Part2Len),len(Code))) AND (PartNo = 5) 
		 
			IF @IsRelation	= 'True'
				INSERT INTO @tblPartsRelation values ( @IsRelation )
			ELSE
			BEGIN
				SELECT @IsRelation =COUNT(*) 
				FROM pub.tblCodingRelation
				WHERE TableName = @TableName AND LinkedPartNo = @LinkedPartNo
				 AND (Code = left(SUBSTRING(@StrCode,@Part1Len+@Part2Len+1,@Part3Len),len(Code))) AND (PartNo = 5) 
				
				INSERT INTO @tblPartsRelation values ( @IsRelation )
			END
		END	
	END
END

	SELECT IsRelation FROM @tblPartsRelation

END
GO
