USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =========== TS-QC:UPDATED ====================
-- Author		 : jafari
-- Create date   : 1393/12/09
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : سند حسابداری بیمه
-- ==============================================
Create PROCEDURE [acc].[RptAcc_Voucher]
	@Vchno		int=1,
	@ExtraOption		NVarChar(100) = Null,
	@RepOptions		VarChar(10) = '10000',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
As
DECLARE @LangID		Char(1);
DECLARE @SessionNo	VarChar(10);
DECLARE @ReportID	VarChar(10);
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);
Begin   
	SET NoCount On;


	-- Init --------------------------------------------------
	If (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1'
	IF (@RepOptions	Is Null)	SET @RepOptions = '1100'


	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	-----------------------------------------------------------

	set @StrWhere = '(H.SerialNo = ' + LTrim(Str(@Vchno)) + ')'

	
	Set @StrSelect ='
	SELECT	H.* ,D.*,		pub.GetCodeName(D.AcntCode, '+@LangID+') AcntName
	FROM         acc.tblVoucherHdr H INNER JOIN
                      acc.tblVoucherDtl D ON H.SerialNo = D.SerialNo
                      
	WHERE   ' + @StrWhere

	Print @StrSelect;
	Exec sp_executesql @StrSelect;
End
GO
