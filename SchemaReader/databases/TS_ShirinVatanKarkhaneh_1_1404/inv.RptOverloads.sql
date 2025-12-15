USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : MM
-- Creation Date : 1402/09/05
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
Create PROCEDURE inv.RptOverloads
	@ProcessID		Int = 90,  -- default is sale
	@ProcessNo		Int = Null,
	@FiscalYear		Int = Null,
	@SerialNo		Int = Null,
	@DocRowNo		Int = Null,
	@RepInfo		NVarChar(100) = Null,
	@ExtraParams	NVarChar(2000) = Null
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect				NVarChar(Max);
Begin
DECLARE	@LangID				Char(1);

	SET @LangID			 = pub.funSplitString(@RepInfo, '@', 1);
	--SET @SessionNo		 = pub.funSplitString(@RepInfo, '@', 2);
	--SET @ReportID		 = pub.funSplitString(@RepInfo, '@', 3);
	--SET @UserID			 = pub.funSplitString(@RepInfo, '@', 4);
	--SET @UserIsAdmin	 = pub.funSplitString(@RepInfo, '@', 5);

	SET @StrSelect = 
		'SELECT * ,pub.GetCodeName(AtomAcntCode ,'+ @LangID +') AcntName
		FROM inv.tblStorageDocsAtom a
		where  a.ProcessID= '+ str(@ProcessID) +' 
		and  a.ProcessNo='+ str(@ProcessNo) +' 
		and  a.FiscalYear='+ str(@FiscalYear) +' 
		and  a.SerialNo='+ str(@SerialNo) +'
		and  a.DocRowNo='+ str(@DocRowNo) +' '

	print @StrSelect
	Exec sp_executesql @StrSelect;

END

GO
