USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- ==============================================
-- Author:		 Sadeghi, Hadi
-- Create date: 
-- Description:
-- ==============================================
--[pub].[spGetPartsHasForceRelation] '111301',1
--[pub].[spGetPartsHasForceRelation] '00000',2
Create PROCEDURE [pub].[spGetPartsHasForceRelation]
@StrCode VarChar(20),
@PartNumber as tinyint
WITH ENCRYPTION
As 
BEGIN

	DECLARE @PartLen tinyint
	DECLARE @CurrentPartLen tinyint
	DECLARE @IsRelation bit

	set @IsRelation='False'
	
	SELECT  @PartLen= ISNULL(SUM(Layer1+ Layer2+ Layer3+ Layer4+ Layer5+ Layer6+ Layer7+ Layer8+ Layer9),0) + @PartNumber-1 
	from pub.tblCodeLayer
	where TableName = 'acc.tblAcnt' and PartNumber<@PartNumber-1

	SELECT  @CurrentPartLen= ISNULL(SUM(Layer1+ Layer2+ Layer3+ Layer4+ Layer5+ Layer6+ Layer7+ Layer8+ Layer9),0) 
	FROM pub.tblCodeLayer
	WHERE TableName = 'acc.tblAcnt' and PartNumber=@PartNumber

	SELECT TOP 1 @IsRelation = HasRelation 
	FROM acc.tblAcnt WHERE (PartNumber = @PartNumber) AND AcntCode = @StrCode

	select  @IsRelation as IsRelation

END
GO
