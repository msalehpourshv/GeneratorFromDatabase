USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- ==============================================
-- Author:		 Sadeghi, Hadi
-- Create date: 
-- Description:
-- ==============================================

--[pub].[spGetCodeNameAry] '110101','acc.tblAcnt','acc.tblAcntDtl','AcntCode','AcntName',1
--[pub].[spGetCodeNameAry] '1','trs.tblOurBanks','trs.tblOurBanksDtl','BankCode','BankName',1
--[pub].[spGetPartsRelationAry] '140201'
--pub.spGetPartsRelationAry '111301 06 1'
Create PROCEDURE [pub].[spGetPartsRelationAry]
(@StrCode VarChar(20))
WITH ENCRYPTION
As 
BEGIN

declare @tblPartsRelation TABLE ([IsRelation] bit ) 

DECLARE @PartCount tinyint
DECLARE @PartLen tinyint
DECLARE @PartLen2 tinyint
DECLARE @PartLen3 tinyint
DECLARE @CurrentPartLen tinyint
DECLARE @IsRelation bit

SET @PartCount=2
 
WHILE @PartCount<5
	BEGIN
	                   
		SELECT  @PartLen= ISNULL(SUM(Layer1+ Layer2+ Layer3+ Layer4+ Layer5+ Layer6+ Layer7+ Layer8+ Layer9),0) + @PartCount-1 
		from pub.tblCodeLayer
		where TableName = 'acc.tblAcnt' and PartNumber<@PartCount-1
		IF @PartCount = 3
			SET @PartLen2 = @PartLen
		IF @PartCount = 4
			SET @PartLen3 = @PartLen

		SELECT @IsRelation =COUNT(*) 
		FROM acc.tblAcntRelation 
		WHERE (AcntNumber = @PartCount) AND
		(
		(Acnt1PartNumber IN(0,1,2) AND  (Acnt1Code = SUBSTRING(@StrCode,@PartLen,len(Acnt1Code)) OR Acnt1Code = left(@StrCode,len(Acnt1Code))))
		OR ( @PartCount in(3,4) AND ( Acnt1PartNumber = 2 AND Acnt1Code =SUBSTRING(@StrCode,@PartLen2, len(Acnt1Code))))
		OR ( @PartCount = 4 AND ( Acnt1PartNumber = 3 AND Acnt1Code =SUBSTRING(@StrCode,@PartLen3, len(Acnt1Code))))
			   ) 

		IF @IsRelation = 'False'
		BEGIN
			SELECT  @CurrentPartLen= ISNULL(SUM(Layer1+ Layer2+ Layer3+ Layer4+ Layer5+ Layer6+ Layer7+ Layer8+ Layer9),0) 
			FROM pub.tblCodeLayer
			WHERE TableName = 'acc.tblAcnt' and PartNumber=@PartCount-1
		
			SELECT TOP 1 @IsRelation = HasRelation 
			FROM acc.tblAcnt WHERE (PartNumber = @PartCount-1) AND AcntCode = SUBSTRING(@StrCode,@PartLen,@CurrentPartLen)
		END

		INSERT INTO @tblPartsRelation values ( @IsRelation )
		
		SET @PartCount=@PartCount+1

	END

SELECT IsRelation FROM @tblPartsRelation

END
GO
