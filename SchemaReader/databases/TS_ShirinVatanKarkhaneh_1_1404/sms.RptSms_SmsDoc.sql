USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid
-- Create date   : 1392/10/09
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [sms].[RptSms_SmsDoc]

	@SerialNo	Int = Null,
	@DBID		Int = Null,
	@DocDate    Char(10) = Null,
	@DateFr     Char(10) = Null,
	@PartNumber		Tinyint = Null,
	@RepOptions	VarChar(10) = '111011111',  -- bit array options
	@RepInfo	NVarChar(100) = '1@1@1'
	
WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect	NVarChar(4000);
Declare @StrFrom	NVarChar(4000);
Declare @StrWhere	NVarChar(4000);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;

DECLARE	@DBName	Varchar(200);

Begin -- ============== S T A R T  C O D E ====================================

	SET NOCOUNT ON;

	-- Init Variables -------------------------------------

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @DBName = '';
	
	Select @DBName = DBName From pub.tblDatabases 
	Where DBID = IsNull(@DBID,0)

	-- Where Clause -----------------------------------------
	
	SET @StrWhere = '1 = 1'

	IF (@SerialNo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND H.SerialNo = ' + Str(LTrim(RTrim(@SerialNo)))

	IF (@DBID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND H.DBID = ' + Str(LTrim(RTrim(@DBID)))

	-- Select Clause -------------------------------------------

	SET @StrSelect = '
	Select H.SerialNo, H.DBID, H.DateFr, D.AcntCode, A.AcntName, D.Tel, D.Message
	From sms.tblSmsDocsHdr H
	Inner Join sms.tblSmsDocsDtl D 
			   ON H.ProcessID = D.ProcessID And H.SerialNo = D.SerialNo And H.DBID = D.DBID
	Inner Join ' + @DBName + '.acc.tblAcntDtl A
			   ON A.AcntCode = D.AcntCode And A.PartNumber = ' + Str(LTrim(RTrim(ISNULL(@PartNumber,0)))) + '
	Where ' + @StrWhere + '
	ORDER BY H.DateFr'
	
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
