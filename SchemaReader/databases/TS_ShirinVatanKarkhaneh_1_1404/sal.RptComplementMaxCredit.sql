USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED =====================
-- Author		 : jafari
-- Creation Date : 1399/05/08
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
Create PROCEDURE sal.RptComplementMaxCredit	
	@SerialNo			Int = NULL,
	@ExtraParams		NVarChar(Max) = '',
	@RepOptions			VarChar(20) = '111' ,-- bit array	
	@RepInfo			NVarChar(100) = '1@1@1'	
WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect		NVarChar(4000);
Declare @StrWhere		NVarChar(4000);
DECLARE @LangID		Char(1);
DECLARE @SessionNo	Int;
DECLARE @ReportID	Int;
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init Variables --------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1'

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	-- --------------------------------------------------
	-- Where Clause -----------------------------------------------------------
	SET @StrWhere = '';
	Select @StrWhere = ' 1=1 '

	IF (@SerialNo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.SerialNo = ' + LTrim(Str(@SerialNo)) + ' ' 
	
	-- Select Clause -------------------------------------------
	SET @StrSelect = '
	SELECT D.*, [pub].[GetCodeName](CustomerAcntCode,1) AS CustomerAcntName 
	,H.RecID,H.DocDate
	FROM sal.tblComplementMaxCreditDtl  D 
	inner join sal.tblComplementMaxCreditHdr H
	on H.SerialNo=D.SerialNo
	WHERE	' + @StrWhere + '
	ORDER BY DocRowNo '

	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End

GO
