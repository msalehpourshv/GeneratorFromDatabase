USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Mohammad Jafari & r.moayed
-- Create date   : 1403/03/22
-- Viewed By	 : 
-- Last Modified : 1403/03/27 r.moayed
-- Description   : 
-- =============================================
CREATE PROCEDURE acc.sp_api_AppService_GetAllDebitRemain

@MaxResultCount as nvarchar(50),
@UserID as int,
@Skip as nvarchar(50),
--@AcntCode as VarChar(20) ,
@DocDate as	Char(10) ,
@AcntCustomerCode as nvarchar(100)

WITH ENCRYPTION
 AS
BEGIN

	DECLARE @PartNumber Int;
	DECLARE @PStart Int;
	DECLARE @PLen Int;
	DECLARE @Part1End			TinyInt;
	
	DECLARE @PLenSubString Int;

	DECLARE @StrErrorMessage AS NVARCHAR(MAX)
	BEGIN TRY
	

	
	select @PartNumber=[acc].[FunGetAcntInfoForRemain](1)

	select @PStart= acc.funGetAcntLayerStartandLen(@PartNumber,1)
	select @PLen= acc.funGetAcntLayerStartandLen(@PartNumber,2)

	if( @AcntCustomerCode<>'')
		begin
			
			select @PLenSubString = Len(pub.funSplitString('' + @AcntCustomerCode + '',',',1))

			
	--print(@PLenSubString)
	end


SELECT	@Part1End = Layer1 
	FROM	pub.tblCodeLayer 
	WHERE  (TableName = 'acc.tblAcnt') AND (PartNumber = 1)


DECLARE @StrSelect	NVarChar(Max);
	set @StrSelect= '   SELECT IsNull(Sum(Debit - Credit),0) Debit, Substring(  M.AcntCode ,' + LTrim(Str(@PStart)) + ',' + LTrim(Str(@PLen)) + ') AcntCode
						FROM acc.tblVoucherDtl M 
						INNER JOIN acc.tblVoucherHdr VH ON VH.SerialNo = M.SerialNo
						INNER join acc.tblAcnt b ON b.PartNumber = 1 AND SUBSTRING(M.AcntCode, 1, ' + LTrim(RTrim(STR(@Part1End))) + ') = SUBSTRING(b.AcntCode, 1, ' + LTrim(RTrim(STR(@Part1End))) + ') AND LEN(b.AcntCode) = ' + LTrim(RTrim(STR(@Part1End))) + '
						WHERE  b.AcntType NOT IN (91, 92) AND M.VchKind <> 0 AND VH.DocRegisterState > 0  AND (M.DocDate <= '''+@DocDate+''')
						and  isnull( Substring(  M.AcntCode ,' + LTrim(Str(@PStart)) + ',' + LTrim(Str(@PLen)) + '),'''')<>''''
						'
		if(@AcntCustomerCode<>'')
						set @StrSelect += 'and  Substring(  M.AcntCode ,' + LTrim(Str(@PStart)) + ',' + LTrim(Str(@PLenSubString)) + ') in (' + @AcntCustomerCode + ')'

	set @StrSelect +=	' Group by Substring(  M.AcntCode ,' + LTrim(Str(@PStart)) + ',' + LTrim(Str(@PLen)) + ')
						ORDER by Substring(  M.AcntCode ,' + LTrim(Str(@PStart)) + ',' + LTrim(Str(@PLen)) + ')
						OFFSET '+ @Skip+'  Rows 
						FETCH NEXT '+ @MaxResultCount+'  Rows ONLY 
 	'
	--print @StrSelect;
	exec sp_executesql @StrSelect;
		  	
END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
