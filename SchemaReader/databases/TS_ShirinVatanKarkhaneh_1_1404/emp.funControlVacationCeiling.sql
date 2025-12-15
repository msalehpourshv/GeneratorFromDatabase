USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-EMP:Created ====================
-- Author		 : TakroSystem\Nogrepasand
-- Create date   : 1391/06/13
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE FUNCTION [emp].[funControlVacationCeiling]
(
	@VacationTypeID VarChar(20), 
	@PersonnelID AS VarChar(20),
	@MinuteOfDay AS int,
	@CurrentMounth AS TINYINT
)
	RETURNS  int 
WITH ENCRYPTION
AS

Begin -- ====================================================

	Declare @Ceiling AS INT
	DECLARE @VacationSum AS INT
	
	SET @Ceiling=0
	SET @VacationSum=0
	
	IF @CurrentMounth=1
	BEGIN
		SELECT @Ceiling=Month1*@MinuteOfDay + (LastYearRemain * @MinuteOfDay)  +prs.funGetMinutes(LastYearRemainT)+prs.funGetMinutes(MonthT1)  FROM emp.tblVacationMaxDtl
		WHERE PersonnelID=@PersonnelID AND VacationTypeID=@VacationTypeID
		
	END
	ELSE IF @CurrentMounth=2
	BEGIN
		SELECT @Ceiling=(Month1+Month2)*@MinuteOfDay + (LastYearRemain * @MinuteOfDay)+prs.funGetMinutes(LastYearRemainT)+prs.funGetMinutes(MonthT1)+prs.funGetMinutes(MonthT2) FROM emp.tblVacationMaxDtl
		WHERE PersonnelID=@PersonnelID AND VacationTypeID=@VacationTypeID
	END
	ELSE IF @CurrentMounth=3
	BEGIN
		SELECT @Ceiling=(Month1+Month2+Month3)*@MinuteOfDay + (LastYearRemain * @MinuteOfDay)+prs.funGetMinutes(LastYearRemainT)+prs.funGetMinutes(MonthT1)+prs.funGetMinutes(MonthT2)+prs.funGetMinutes(MonthT3) FROM emp.tblVacationMaxDtl
		WHERE PersonnelID=@PersonnelID AND VacationTypeID=@VacationTypeID
	END	
	ELSE IF @CurrentMounth=4
	BEGIN
		SELECT @Ceiling=(Month1+Month2+Month3+ Month4)*@MinuteOfDay + (LastYearRemain * @MinuteOfDay)+prs.funGetMinutes(LastYearRemainT)+prs.funGetMinutes(MonthT1)+prs.funGetMinutes(MonthT2)+prs.funGetMinutes(MonthT3)+prs.funGetMinutes(MonthT4)  FROM emp.tblVacationMaxDtl
		WHERE PersonnelID=@PersonnelID AND VacationTypeID=@VacationTypeID
	END	
	ELSE IF @CurrentMounth=5
	BEGIN
		SELECT @Ceiling=(Month1+Month2+Month3+Month4+Month5)*@MinuteOfDay + (LastYearRemain * @MinuteOfDay) +prs.funGetMinutes(LastYearRemainT)+prs.funGetMinutes(MonthT1)+prs.funGetMinutes(MonthT2)+prs.funGetMinutes(MonthT3)+prs.funGetMinutes(MonthT4)+prs.funGetMinutes(MonthT5) FROM emp.tblVacationMaxDtl
		WHERE PersonnelID=@PersonnelID AND VacationTypeID=@VacationTypeID
	END	
	ELSE IF @CurrentMounth=6
	BEGIN
		SELECT @Ceiling=(Month1+Month2+Month3+Month4+Month5+Month6)*@MinuteOfDay + (LastYearRemain * @MinuteOfDay) +prs.funGetMinutes(LastYearRemainT)+prs.funGetMinutes(MonthT1)+prs.funGetMinutes(MonthT2)+prs.funGetMinutes(MonthT3)+prs.funGetMinutes(MonthT4)+prs.funGetMinutes(MonthT5)+prs.funGetMinutes(MonthT6) FROM emp.tblVacationMaxDtl
		WHERE PersonnelID=@PersonnelID AND VacationTypeID=@VacationTypeID
	END	
	ELSE IF @CurrentMounth=7
	BEGIN
		SELECT @Ceiling=(Month1+Month2+Month3+Month4+Month5+Month6+Month7)*@MinuteOfDay + (LastYearRemain * @MinuteOfDay) +prs.funGetMinutes(LastYearRemainT)+prs.funGetMinutes(MonthT1)+prs.funGetMinutes(MonthT2)+prs.funGetMinutes(MonthT3)+prs.funGetMinutes(MonthT4)+prs.funGetMinutes(MonthT5)+prs.funGetMinutes(MonthT6)+prs.funGetMinutes(MonthT7) FROM emp.tblVacationMaxDtl
		WHERE PersonnelID=@PersonnelID AND VacationTypeID=@VacationTypeID
	END	
	ELSE IF @CurrentMounth=8
	BEGIN
		SELECT @Ceiling=(Month1+Month2+Month3+Month4+Month5+Month6+Month7+Month8)*@MinuteOfDay + (LastYearRemain * @MinuteOfDay) +prs.funGetMinutes(LastYearRemainT)+prs.funGetMinutes(MonthT1)+prs.funGetMinutes(MonthT2)+prs.funGetMinutes(MonthT3) +prs.funGetMinutes(MonthT4)+prs.funGetMinutes(MonthT5)+prs.funGetMinutes(MonthT6)+prs.funGetMinutes(MonthT7)+prs.funGetMinutes(MonthT8) FROM emp.tblVacationMaxDtl
		WHERE PersonnelID=@PersonnelID AND VacationTypeID=@VacationTypeID
	END	
	ELSE IF @CurrentMounth=9
	BEGIN
		SELECT @Ceiling=(Month1+Month2+Month3+Month4+Month5+Month6+Month7+Month8+Month9)*@MinuteOfDay + (LastYearRemain * @MinuteOfDay) +prs.funGetMinutes(LastYearRemainT)+prs.funGetMinutes(MonthT1)+prs.funGetMinutes(MonthT2)+prs.funGetMinutes(MonthT3)+prs.funGetMinutes(MonthT4)+prs.funGetMinutes(MonthT5)+prs.funGetMinutes(MonthT6)+prs.funGetMinutes(MonthT7)+prs.funGetMinutes(MonthT8)+prs.funGetMinutes(MonthT9) FROM emp.tblVacationMaxDtl
		WHERE PersonnelID=@PersonnelID AND VacationTypeID=@VacationTypeID
	END	
	ELSE IF @CurrentMounth=10
	BEGIN
		SELECT @Ceiling=(Month1+Month2+Month3+Month4+Month5+Month6+Month7+Month8+Month9+Month10)*@MinuteOfDay + (LastYearRemain * @MinuteOfDay) +prs.funGetMinutes(LastYearRemainT)+prs.funGetMinutes(MonthT1)+prs.funGetMinutes(MonthT2)+prs.funGetMinutes(MonthT3)+prs.funGetMinutes(MonthT4)+prs.funGetMinutes(MonthT5)+prs.funGetMinutes(MonthT6)+prs.funGetMinutes(MonthT7)+prs.funGetMinutes(MonthT8)+prs.funGetMinutes(MonthT9)+prs.funGetMinutes(MonthT10) FROM emp.tblVacationMaxDtl
		WHERE PersonnelID=@PersonnelID AND VacationTypeID=@VacationTypeID
	END	
	ELSE IF @CurrentMounth=11
	BEGIN
		SELECT @Ceiling=(Month1+Month2+Month3+Month4+Month5+Month6+Month7+Month8+Month9+Month10+Month11)*@MinuteOfDay + (LastYearRemain * @MinuteOfDay) +prs.funGetMinutes(LastYearRemainT)+prs.funGetMinutes(MonthT1)+prs.funGetMinutes(MonthT2)+prs.funGetMinutes(MonthT3)+prs.funGetMinutes(MonthT4)+prs.funGetMinutes(MonthT5)+prs.funGetMinutes(MonthT6)+prs.funGetMinutes(MonthT7)+prs.funGetMinutes(MonthT8)+prs.funGetMinutes(MonthT9)+prs.funGetMinutes(MonthT10)+prs.funGetMinutes(MonthT11) FROM emp.tblVacationMaxDtl
		WHERE PersonnelID=@PersonnelID AND VacationTypeID=@VacationTypeID
	END	
		
	ELSE IF @CurrentMounth=12
	BEGIN
		SELECT @Ceiling=(Month1+Month2+Month3+Month4+Month5+Month6+Month7+Month8+Month9+Month10+Month11+Month12)*@MinuteOfDay + (LastYearRemain * @MinuteOfDay) +prs.funGetMinutes(LastYearRemainT)+prs.funGetMinutes(MonthT1)+prs.funGetMinutes(MonthT2)+prs.funGetMinutes(MonthT3)+prs.funGetMinutes(MonthT4)+prs.funGetMinutes(MonthT5)+prs.funGetMinutes(MonthT6)+prs.funGetMinutes(MonthT7)+prs.funGetMinutes(MonthT8)+prs.funGetMinutes(MonthT9)+prs.funGetMinutes(MonthT10)+prs.funGetMinutes(MonthT11)+prs.funGetMinutes(MonthT12) FROM emp.tblVacationMaxDtl
		WHERE PersonnelID=@PersonnelID AND VacationTypeID=@VacationTypeID
	END
	
	IF @Ceiling=0
		RETURN 0
	
	SELECT @VacationSum = ISNULL(SUM(Interval),0)
	FROM emp.tblVacationHdr 
	WHERE VacationTypeID=@VacationTypeID AND 
	      PersonnelID=@PersonnelID AND ProcessID IN (351) AND CAST(SUBSTRING(StartDate,6,2) AS tinyint)<=@CurrentMounth

	SELECT @VacationSum = @VacationSum + ISNULL(SUM(-Interval),0)
	FROM emp.tblVacationHdr 
	WHERE VacationTypeID=@VacationTypeID AND 
	      PersonnelID=@PersonnelID AND ProcessID IN (355) AND CAST(SUBSTRING(StartDate,6,2) AS tinyint)<=@CurrentMounth

	SELECT @VacationSum = @VacationSum + ISNULL(SUM(Interval*@MinuteOfDay),0) 
	FROM emp.tblVacationHdr 
	WHERE VacationTypeID=@VacationTypeID AND 
	      PersonnelID=@PersonnelID AND ProcessID IN (350) AND CAST(SUBSTRING(EndDate,6,2) AS tinyint)<=@CurrentMounth

	SELECT @VacationSum = @VacationSum + ISNULL(SUM(-Interval*@MinuteOfDay),0)
	FROM emp.tblVacationHdr 
	WHERE VacationTypeID=@VacationTypeID AND 
	      PersonnelID=@PersonnelID AND ProcessID IN (356) AND CAST(SUBSTRING(EndDate,6,2) AS tinyint)<=@CurrentMounth
    	
	
	Return @Ceiling - @VacationSum

END -- ======================================================
GO
