USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =========== TS-QC:UPDATED ====================
-- Author		 : Takrosystem\Hadi Sadeghi
-- Create date   : 1391/05/24
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- =============================================
CREATE PROCEDURE [prs].[spControlCeilingOfDailyVacation]
	@ProcessID		Int = 350,
	@PersonnelID	VARCHAR(20)= '',
	@DocDate		Char(10) = ''
WITH ENCRYPTION
AS
BEGIN
	
	DECLARE @SumVacation AS VARCHAR(7)
	DECLARE @SettingValue AS VARCHAR(7)
	SET @SettingValue = ''
	
	SELECT  @SumVacation = prs.funGetHourMinutesStandard(SUM(prs.funGetMinutes(EndTime)-prs.funGetMinutes(StartTime)))
	FROM emp.tblVacationHdr
	WHERE ProcessID=@ProcessID AND PersonnelID=@PersonnelID AND StartDate=@DocDate 
	
	IF (SELECT IsStudent FROM prs.tblPersonnels WHERE PersonnelID=@PersonnelID )='True'
		BEGIN
			SELECT	@SettingValue = SettingValue FROM pub.tblSettings WHERE SettingKey='CeilingOfDailyVacationForStudent' 	
		END
	ELSE
		BEGIN
			SELECT	@SettingValue = SettingValue FROM pub.tblSettings WHERE SettingKey='CeilingOfDailyVacation' 	
		END	 
		
	IF @SettingValue = ''
		SELECT '' Ret
	ELSE
		BEGIN
			IF @SumVacation> @SettingValue
				SELECT prs.funGetHourMinutesStandard(prs.funGetMinutes(@SumVacation) - prs.funGetMinutes(@SettingValue))
			ELSE
				SELECT '' Ret
					
		END 	
		
END

GO
