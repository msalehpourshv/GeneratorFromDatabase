USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem  \ Nogrehpasand
-- Create date   : 1391/05/18
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : گزارش تماسهای مشتریان در يک بازه زماني  
-- =============================================
CREATE PROCEDURE [srv].[RptSrv_TelLog_FromToDate] 
	
	@DateFr				Char(10)= '0000/00/00',
	@DateTo				Char(10)= '9999/99/99',
	@DialNumber			VarChar(50) = NULL, 
	@SelectedPers		INT = 0,
	@RepOptions			VarChar(10) = '000',
	@RepInfo			NVarChar(100) = '1@1@1'

WITH ENCRYPTION
AS

DECLARE @StrSelect		NVarChar(4000);

DECLARE @StrWhere		NVarChar(2000);
DECLARE @IsSolved			int ;
DECLARE	@Unsuccess			INT ;
DECLARE @Incoming			INT ;
DECLARE	@LangID				Char(1);
DECLARE	@SessionNo			Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID			Int; -- برای حالت کدهای انتخابی


BEGIN 
	-- ============================ S T A R T =====================================================

	-- Init --------------------------
	SET NOCOUNT ON;

	IF (@DateFr Is Null)		SET @DateFr  = '0000/00/00';
	IF (@DateTo Is Null)		SET @DateTo  = '9999/99/99';
	IF (@RepInfo Is Null)		SET @RepInfo = '1@1@1';
	
	IF (@RepOptions Is Null)	SET @RepOptions = '1';

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @IsSolved	= Substring(@RepOptions, 1, 1);
	SET @Unsuccess	= Substring(@RepOptions, 2, 1);
	SET @Incoming	= Substring(@RepOptions, 3, 1);


	set @StrWhere = '(1=1)'
	
	
	IF (@DateFr IS NOT null)
		SET @StrWhere = @StrWhere + ' AND DocDate >= ''' + @DateFr + ''''
		
	IF (@DateTo IS NOT null)
		SET @StrWhere = @StrWhere + ' AND DocDate <= ''' + @DateTo + ''''
		
	IF (@DialNumber IS NOT null)
		SET @StrWhere = @StrWhere + ' AND DialNumber = ''' + @DialNumber + ''''
	
	IF (@SelectedPers > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPers, 'PersonnelID') 

	
	IF (@IsSolved <> 2)	
		SET @StrWhere = @StrWhere + ' AND IsSolved = ' + LTRIM(str(@IsSolved))
	
	IF (@Unsuccess<> 2)	
		SET @StrWhere = @StrWhere + ' AND Unsuccess = ' + LTRIM(str(@Unsuccess))
		
	IF (@Incoming <> 2)	
		SET @StrWhere = @StrWhere + ' AND Incoming = ' + LTRIM(str(@Incoming)) 

-- ================ SELECT ===========================

	SET @StrSelect = '
	SELECT  ID, DocDate, DocTime, CompanyID, PhonerName, PersonnelID, PersonnelName, DocDesc, IsSolved, Unsuccess, EventID, DialNumber, Incoming, LineNumber, Duration, IsPersonal,
	DurationBySec,AcntName
	FROM pub.tblTelLog t
	LEFT JOIN acc.tblAcntDtl a
	ON t.CompanyID=a.AcntCode
	
	where ' + @StrWhere

-- ================ SELECT ===========================

	-- Exeute --------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	--=========================================================================================
END


GO
