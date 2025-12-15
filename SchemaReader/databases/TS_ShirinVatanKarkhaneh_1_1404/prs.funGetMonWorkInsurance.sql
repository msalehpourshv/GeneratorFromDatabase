USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create Date   : 1393/12/20
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : صورت وضعیت تسویه کارکنان
-- ==============================================
Create FUNCTION prs.funGetMonWorkInsurance
(
	@BasePay int,
	@MonthCode Tinyint ,
	@PersonnelID VarChar(20) 
)
RETURNS NVarChar(2044)
WITH ENCRYPTION
AS
BEGIN

Declare @Ret as integer
Declare @InsuranceFunction as integer
Declare @BasePay2 as integer
Declare @MonthCode2 as integer

select top 1 @InsuranceFunction =InsuranceFunction  from prs.tblFunctionsDtl
where PersonnelID=@PersonnelID and MonthCode=@MonthCode

select top 1 @MonthCode2=min(MonthCode) from prs.tblCelebrationDtl
where PersonnelID=@PersonnelID and MonthCode>=@MonthCode
and ProcessID in (320,325)

select top 1 @BasePay2=Basepay  from prs.tblCelebrationDtl
where PersonnelID=@PersonnelID and MonthCode=@MonthCode2
and ProcessID in (320,325)

	if @BasePay2=@BasePay
		set @Ret=@InsuranceFunction
	else
	BEGIN
		if  @InsuranceFunction<>0
			RETURN 0
		set @Ret=0
		IF @MonthCode = 12 
		BEGIN
			SET @Ret=prs.funGetMonWork(@BasePay,11,@PersonnelID)
			IF @Ret>0
			BEGIN
				select @InsuranceFunction =InsuranceFunction  from prs.tblFunctionsDtl
				where PersonnelID=@PersonnelID and MonthCode=@MonthCode
			
				set @Ret=@InsuranceFunction
			END
		END	
	END
	RETURN @Ret
	
END
GO
