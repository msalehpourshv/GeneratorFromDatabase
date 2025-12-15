USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1397/02/08
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : 
-- ----------------------------------------------
-- گزارش چکهای ترتیب اثر داده نشده
-- ==============================================

Create PROCEDURE [trs].[SpUnConfirmedReturnChequeList]
	@ExtraParams		NVarChar(Max) 
	WITH ENCRYPTION
AS

BEGIN

	DECLARE	@LangID		 Char(1);
	DECLARE	@UserID		 Int;
	DECLARE	@UserIsAdmin bit;
	DECLARE	@ProcessNo	 Int;
	DECLARE	@UnConfirmed bit;
	
	SET @LangID			 = pub.funSplitString(@ExtraParams, '@', 1);
	SET @UserID			 = pub.funSplitString(@ExtraParams, '@', 2);
	SET @UserIsAdmin	 = pub.funSplitString(@ExtraParams, '@', 3);
	SET @ProcessNo		 = pub.funSplitString(@ExtraParams, '@', 4);
	SET @UnConfirmed	 = pub.funSplitString(@ExtraParams, '@', 5);
	
	
	
DECLARE @StrWhereH	NVarChar(Max);
Declare @StrSelect	NVarChar(max);
			
			
Set @StrWhereH	=''
	if @UserIsAdmin=0
	begin
	
		SELECT  Distinct DebitCode	CreditCode into  #tblOurBanks  FROM       trs.tblPayDtl
			
		SELECT  Distinct DebitCode	AcntCode into  #tblAcntCode FROM       trs.tblPayDtl
		
		--SELECT   CreditCode	FROM  #tblOurBanks 
		--SELECT   AcntCode	FROM  #tblAcntCode 
	
		exec pub.SpFilterByPermission2 '#tblOurBanks', 'CreditCode', 'trs.tblOurBanks', @UserID; 
	
		exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID; 
			
		SET @StrWhereH =  '  and (  DebitCode in (SELECT   CreditCode	FROM  #tblOurBanks     ) 
												or   DebitCode in (SELECT   AcntCode	FROM  #tblAcntCode    ) )'
		
		
	END
	
	--SELECT   CreditCode	FROM  #tblOurBanks 
	--SELECT   AcntCode	FROM  #tblAcntCode 
	-----------------------------------------------------------------
	--SET @StrWhereH = '  and  acc.funAllowAcntCode('+ltrim(str(@UserID))+','+ ltrim(str(@UserIsAdmin))+',	H.AcntCode,'+ltrim(str(@PartNumber))+') =1 '

SET @StrSelect = '

SELECT * ,CASE WHEN ProcessID = 18 THEN pub.GetCodeName(CreditCode,1) ELSE [pub].[GetBankName](CreditCode,1) END AS CreditName,
[pub].[funGetBankTypeName] (BankTypeID,1) BankTypeName,pub.GetCodeName(DebitCode,1) As DebitName, [pub].[GetCodeName](WithAcntCode, 1) As WithName FROM trs.tblPayDtl 

WHERE ProcessID IN (13,18,24) '
if @ProcessNo>0
	SET @StrSelect += ' AND ProcessNo =' + str(@ProcessNo)
if @UnConfirmed=0
	SET @StrSelect += ' 	AND IsConfirmed ='+'''False'''+''

SET @StrSelect += @StrWhereH

	Print @StrSelect
	Exec sp_executesql @StrSelect;

	
	
END
GO
