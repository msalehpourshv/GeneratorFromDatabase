USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Creation Date : 1391/09/25
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : TakroSystem\Zia
-- Description	 : 
-- ==============================================
Create PROCEDURE srv.RptSrv_RequestServiceTaskAtm2
	
	@Extraparams		NVarChar(100) = '1@1@97', 
	@RepOptions			NVarChar(100) = '1111111@1@1', 
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 

---- Declarations ---------------
Declare @StrSelect	NVarChar(max);
Declare @StrWhere	NVarChar(max);
DECLARE	@UserID				Int=1,
		@IsAdmin			bit=1
DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int;
DECLARE	@ReportID	Int;
DECLARE	@SerialNo	Int;
DECLARE	@DocRowNo	Int;
DECLARE	@FiscalYear	Int;

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init -------------------------------------------------
	IF (@RepInfo Is Null)			SET @RepInfo = '1@1@1'
	IF (@RepOptions Is Null)		SET @RepOptions = '1111111@1@1';
	
	SET @SerialNo		= pub.funSplitString(@Extraparams, '@', 1);
	SET @DocRowNo	= pub.funSplitString(@Extraparams, '@', 2);
	SET @FiscalYear	= pub.funSplitString(@Extraparams, '@', 3);
	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID		= pub.funSplitString(@RepInfo, '@', 4);
	SET @IsAdmin	= pub.funSplitString(@RepInfo, '@', 5);
	---------------------------------------------------------

	-- Where Clause -----------------------------------------
	Set @StrWhere = '(1=1)'

 If @SerialNo>0
        SET @StrWhere = @StrWhere + ' AND SerialNo  = ' + LTrim(RTrim(str(@SerialNo))) 
 If @DocRowNo>0
        SET @StrWhere = @StrWhere + ' AND DocRowNo  = ' + LTrim(RTrim(str(@DocRowNo))) 
 If @FiscalYear>0
        SET @StrWhere = @StrWhere + ' AND FiscalYear  = ' + LTrim(RTrim(str(@FiscalYear))) 
   
	---------------------------------------------------------

	-- SELECT Clause ----------------------------------------
	Set @StrSelect = '
	SELECT	*
	FROM  srv.tblServiceTaskAtm2
			
	WHERE ' + @StrWhere
	
	-- RUN -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
