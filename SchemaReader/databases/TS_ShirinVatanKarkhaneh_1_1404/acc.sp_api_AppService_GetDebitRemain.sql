USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/11/06
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
create PROCEDURE acc.sp_api_AppService_GetDebitRemain
@AcntCode	VarChar(20) ,
@DocDate	Char(10) 

WITH ENCRYPTION
 AS
BEGIN

DECLARE @PartNumber Int;
DECLARE @PStart Int;
DECLARE @PLen Int;
DECLARE @StrErrorMessage AS NVARCHAR(MAX)
BEGIN TRY
	
	
	select @PartNumber=[acc].[FunGetAcntInfoForRemain](1)

select @PStart= acc.funGetAcntLayerStartandLen(@PartNumber,1)
select @PLen= acc.funGetAcntLayerStartandLen(@PartNumber,2)



DECLARE @Eqal		NVarChar(2000);
DECLARE @Remain1	Bit;
DECLARE @Remain2	Bit;
DECLARE @Remain3	Bit;
DECLARE @Remain4	Bit;
DECLARE @Part1Start	Int;
DECLARE @Part2Start	Int;
DECLARE @Part3Start	Int;
DECLARE @Part4Start	Int;
DECLARE @Part1Len	Int;
DECLARE @Part2Len	Int;
DECLARE @Part3Len	Int;
DECLARE @Part4Len	Int;
DECLARE @Part1End			TinyInt;

SELECT	@Part1End = Layer1 
	FROM	pub.tblCodeLayer 
	WHERE  (TableName = 'acc.tblAcnt') AND (PartNumber = 1)

Select @Remain1=SettingValue from pub.tblSettings where SettingKey='SalIvcRemain1' 
Select @Remain2=SettingValue from pub.tblSettings where SettingKey='SalIvcRemain2' 
Select @Remain3=SettingValue from pub.tblSettings where SettingKey='SalIvcRemain3' 
Select @Remain4=SettingValue from pub.tblSettings where SettingKey='SalIvcRemain4' 

Set @Remain1=ISNULL(@Remain1,0)
Set @Remain2=ISNULL(@Remain2,0)
Set @Remain3=ISNULL(@Remain3,0)
Set @Remain4=ISNULL(@Remain4,0)

		declare @CountPartRemain tinyint
		SET @CountPartRemain=0;
	
		SET @Eqal = '1=1'

		IF (@Remain1 = 1)
			SET @CountPartRemain = @CountPartRemain + 1
		IF (@Remain2 = 1) AND @CountPartRemain = 1
			SET @CountPartRemain = @CountPartRemain + 1
		IF (@Remain3 = 1) AND @CountPartRemain = 2
			SET @CountPartRemain = @CountPartRemain + 1
		IF (@Remain4 = 1) AND @CountPartRemain = 3
			SET @CountPartRemain = @CountPartRemain + 1


			
	SET		@Part1Start = 1;
	SELECT	@Part1Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 1)

	SELECT	@Part2Start = @Part1Start + @Part1Len + 1;
	SELECT	@Part2Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 2)

	SELECT	@Part3Start = @Part2Start + @Part2Len + 1;
	SELECT	@Part3Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 3)

	SELECT	@Part4Start = @Part3Start + @Part3Len + 1;
	SELECT	@Part4Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 4)

		--IF (select COUNT(*) from pub.tblCodeLayer where TableName='acc.tblAcnt' and Layer1>0) = @CountPartRemain
		--	BEGIN
					SET @Eqal = @Eqal + ' AND  Substring(  M.AcntCode ,' + LTrim(Str(@PStart)) + ',' + LTrim(Str(@PLen)) + ')='''+ @AcntCode+''' '
			--END
			--ELSE
			--BEGIN
 
			--	IF (@Remain1 = 1)
			--		SET @Eqal = @Eqal + ' AND Substring(M.AcntCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + ')='''+@AcntCode +''''
			--	IF (@Remain2 = 1)
			--		SET @Eqal = @Eqal + ' AND Substring(M.AcntCode,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + ')='''+@AcntCode +''''
			--	IF (@Remain3 = 1)
			--		SET @Eqal = @Eqal + ' AND Substring(M.AcntCode,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + ')='''+@AcntCode +''''
			--	IF (@Remain4 = 1)
			--		SET @Eqal = @Eqal + ' AND Substring(M.AcntCode,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + ')='''+@AcntCode +''''
		
			--END

DECLARE @StrSelect	NVarChar(Max);
	set @StrSelect= '  SELECT	 IsNull(Sum(Debit - Credit),0) Debit
						 FROM	acc.tblVoucherDtl M 
						 INNER JOIN acc.tblVoucherHdr VH ON VH.SerialNo = M.SerialNo
						 INNER join acc.tblAcnt b ON b.PartNumber = 1 AND SUBSTRING(M.AcntCode, 1, ' + LTrim(RTrim(STR(@Part1End))) + ') = SUBSTRING(b.AcntCode, 1, ' + LTrim(RTrim(STR(@Part1End))) + ') AND LEN(b.AcntCode) = ' + LTrim(RTrim(STR(@Part1End))) + '
						 WHERE  b.AcntType NOT IN (91, 92) AND M.VchKind <> 0 AND VH.DocRegisterState > 0 AND (' + @Eqal + ') AND 
							   (M.DocDate <= '''+@DocDate+''')

 	'
	print @StrSelect;
	exec sp_executesql @StrSelect;
		  	
END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
