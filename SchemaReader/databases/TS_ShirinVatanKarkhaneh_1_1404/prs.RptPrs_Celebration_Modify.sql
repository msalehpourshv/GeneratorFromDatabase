USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 90/11/17
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- ================================================
Create PROCEDURE [prs].[RptPrs_Celebration_Modify]
	@ProcessID			Int = 330,
	@FrMonthCode		TinyInt = Null,
	@ToMonthCode		TinyInt = Null,
	@FromPersonnelID	Varchar(20) = Null,
	@ToPersonnelID		Varchar(20) = Null,
	@FrDate				Varchar(20) = Null,
	@ToDate				Varchar(20) = Null
	
WITH ENCRYPTION
AS
BEGIN 
	DECLARE @StrSelect	NVarChar(max);
	DECLARE @StrWhere	NVarChar(max);
	
	SET @StrSelect = ''
	SET @StrWhere = 'H.ProcessID = ' + LTrim(Str(@ProcessID))
	
	-- =============================== Where
	IF @FrMonthCode Is Not Null And @FrMonthCode <> 0
		SET @StrWhere += ' and H.MonthCode >= ' + LTrim(Str(@FrMonthCode))
	IF @ToMonthCode Is Not Null And @ToMonthCode <> 0
		SET @StrWhere += ' and H.MonthCode <= ' + LTrim(Str(@ToMonthCode))	
		
	IF @FromPersonnelID Is Not Null And @FromPersonnelID <> ''
		SET @StrWhere += ' and D.PersonnelID >= ' + LTrim(RTrim(@FromPersonnelID))
	IF @ToPersonnelID Is Not Null And @ToPersonnelID <> ''
		SET @StrWhere += ' and D.PersonnelID <= ' + LTrim(RTrim(@ToMonthCode))			
	
	IF @FrDate Is Not Null And @FrDate <> ''
		SET @StrWhere += ' and D.Date >= ''' + LTrim(RTrim(@FrDate))+''''
	IF @ToDate Is Not Null And @ToDate <> ''
		SET @StrWhere += ' and D.Date <= ''' + LTrim(RTrim(@ToDate))+''''
			
	-- =============================== Select
	--IF @ProcessID = 330
	BEGIN
		SET @StrSelect = '
			SELECT D.* ,prs.funGetPersonnelName( D.PersonnelID , 1) AS PersonnelName
			FROM prs.tblCelebrationHdr H
			INNER JOIN prs.tblCelebrationDtl D ON H.ProcessID = D.ProcessID  and H.MonthCode = D.MonthCode
			WHERE  ' + @StrWhere
	END
	  	
	------------------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------	  	
	
END
GO
