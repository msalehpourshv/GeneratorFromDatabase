USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : M.Jafari/M.Mostafavi
-- Create date   : 1404/02/30
-- Viewed By	 : 
-- Last Modified : 
-- Modifier		 : 
-- Description	 : دریافت اطلاعات کارکرد ماه از پایگاه‌داده دستگاه تردد
-- ==============================================
Create PROCEDURE prs.spConvertFromIODB2tblFunctionsDtl
	@ExtraParams	NVarChar(1000) = Null

WITH ENCRYPTION
AS 
DECLARE @PersonelID	nVarChar(20);
DECLARE @ColumnName	NVarChar(50);
DECLARE @Value		nVarChar(50);

BEGIN --============== S T A R T  C O D E =======================================
            
	-- =========================================================================================
	SET @PersonelID	= LTrim(pub.funSplitString(@ExtraParams, '@', 1));
	SET @ColumnName	= LTrim(pub.funSplitString(@ExtraParams, '@', 2));
	SET @Value		= LTrim(pub.funSplitString(@ExtraParams, '@', 3));
	-- =========================================================================================
	IF @ColumnName='KasrKarJobrani'
		SELECT 'WorkDeduction' FieldName ,prs.funGetHourMinutesStandard(CAST(@Value as INT)) Value
	ELSE IF @ColumnName='Month_'
		SELECT 'MonthCode' FieldName ,@Value Value	
	ELSE IF @ColumnName='PersonelID'
		SELECT 'PersonnelID' FieldName ,@Value Value	
	ELSE IF  @ColumnName = 'Abcent'
		SELECT 'Absence' FieldName ,@Value Value
	ELSE IF  @ColumnName = 'DayCount'
		SELECT 'MonthlyFunction' FieldName ,@Value Value
		UNION  all
		SELECT 'InsuranceFunction' FieldName ,@Value Value
	ELSE IF  @ColumnName = 'DelayTime'
		SELECT 'Delay' FieldName ,prs.funGetHourMinutesStandard(CAST(@Value as INT)) Value
	ELSE IF  @ColumnName = 'dailySick'
		SELECT 'SickLeave' FieldName ,@Value Value
	ELSE IF  @ColumnName = 'cstEzafe'
		SELECT 'HourlyOvertime' FieldName ,prs.funGetHourMinutesStandard(CAST(@Value as INT)) Value
	ELSE IF  @ColumnName = 'cntShift1'
		SELECT 'PeriodWork001' FieldName ,@Value Value
	ELSE IF  @ColumnName = 'cntShift2'
		SELECT 'PeriodWork002' FieldName ,@Value Value
	ELSE IF  @ColumnName = 'cntShift3'
		SELECT 'PeriodWork003' FieldName ,@Value Value
	ELSE IF  @ColumnName = 'Daily2HourAbsent'
		SELECT 'WithoutContactWorkDeduction' FieldName ,prs.funGetHourMinutesStandard(CAST(@Value as INT)) Value
	ELSE
	SELECT '' FieldName ,'' Value

END
GO
