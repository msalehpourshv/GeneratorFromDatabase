USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/09/03
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : 
-- =============================================
CREATE PROCEDURE [cnt].[RptContractsBill]
	@ExtraParams		NVarChar(Max) = '',
	@RepInfo			NVarChar(100) = '1@1@1',
	@RepOptions			VarChar(20) = '111' -- bit array	
	
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrFrom	NVarChar(1000);
DECLARE @StrWhere	NVarChar(4000);

DECLARE	@LangID		Int;
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 
DECLARE	@CheckConfirm	bit; 
DECLARE	@Confirm1	bit; 
DECLARE	@Confirm2	bit; 
DECLARE	@Confirm3	bit; 

BEGIN -- ====================================================
	SET NOCOUNT ON;

	-- Init -------------------------------------------------
	IF (@RepInfo Is Null)		SET @RepInfo = '1@1@1';
	IF (@RepOptions Is Null)	SET @RepOptions = '11111111';

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	DECLARE	
		@FiscalYearFr		Int ,
		@SerialNoFr			Int ,
		@FiscalYearTo		Int ,
		@SerialNoTo			Int
		
	SET @SerialNoFr			    = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @SerialNoTo		    	= LTrim(pub.funSplitString(@ExtraParams, '@', 2));
	
	---------------------------------------------------------

	-- Where Clause -----------------------------------------
	set @StrWhere = '(1=1)' 
	If (@SerialNoFr >0)
		SET @StrWhere = @StrWhere + ' AND (SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')' 
		
		
   If (@SerialNoTo >0)
		SET @StrWhere = @StrWhere + ' AND (SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')' 
		
	SET @StrSelect = '
	SELECT	*	FROM	cnt.tblContractsBillHdr
		WHERE 	' + @StrWhere
	------------------------------------------------------------
	-- RUN -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
