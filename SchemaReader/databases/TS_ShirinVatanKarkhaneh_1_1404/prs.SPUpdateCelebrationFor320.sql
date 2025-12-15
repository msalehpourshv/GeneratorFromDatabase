USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Jafari
-- Create date   : 1401/12/08
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- ================================================
Create PROCEDURE prs.SPUpdateCelebrationFor320
	@MonthCode		TinyInt,
	@ExtraParams		VARCHAR(200)
	
WITH ENCRYPTION
AS
BEGIN 
    --  در صورتی که عیدی در ماههای قبلی ذخیره شود و سپس حکم تغییر داده شود هنگام پرداخت مبالغ مابه التفاوت علاوه بر افزایش مبلغ در فیلد محاسبه و ذخیره میشود
 declare @PersonnelID as varchar(20)
 declare @ProcessID as int 
 declare @MinMonthCode as int 
 declare @Basepay as Float 
 declare @Cost as Float 
 declare @CelebrationDays as int 
 declare @intDaysOfYears as int 

 SET @intDaysOfYears			    = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
 SELECT @CelebrationDays=SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'CelebrationDays'

 declare @CelebrationCeiling as int	 
 declare @CostYear as int	 
 select @CelebrationCeiling=SettingValue from pub.tblSettings where SettingKey='CelebrationCeiling'

 set @ProcessID=320

 DECLARE csr CURSOR FOR 		
	SELECT  Distinct  PersonnelID
		FROM prs.tblCelebrationDtl
		WHERE (ProcessID = @ProcessID) 
			and MonthCode=@MonthCode 
			and Update320=0

 OPEN csr
 FETCH NEXT FROM csr INTO @PersonnelID

 WHILE @@Fetch_Status = 0
	BEGIN
		set @MinMonthCode=0
		set @Basepay=0
		
		select @MinMonthCode=isnull(max(MonthCode) ,0)   
			from prs.tblCelebrationDtl
			where PersonnelID=@PersonnelID
			 and ProcessID=@ProcessID
			 and MonthCode<@MonthCode and Payable=1
			
		select @Basepay=isnull(Basepay  ,0)  
			from prs.tblCelebrationDtl
			where PersonnelID=@PersonnelID
				and ProcessID=@ProcessID
				and MonthCode=@MonthCode and Payable=1

		select  @Cost=Sum( cast ((@Basepay*@CelebrationDays *TotalDays /@intDaysOfYears) as int)- cast((Basepay*@CelebrationDays *TotalDays/@intDaysOfYears)as int)  )
			from prs.tblCelebrationDtl
			where PersonnelID=@PersonnelID
				and ProcessID=@ProcessID
				and MonthCode>@MinMonthCode
				and Payable=0

		Set @Cost=isnull(@Cost,0)
		if @Cost>0		
		Update prs.tblCelebrationDtl
			set Cost=Cost+@Cost
				,BaseCost=BaseCost+@Cost 
				,Update320=@Cost
			from prs.tblCelebrationDtl
			where PersonnelID=@PersonnelID
				 and ProcessID=@ProcessID
				 and MonthCode=@MonthCode
				 and Payable=1
				 and Update320=0
	--------برای اینکه از سقف  عیدی بالاتر نباشد-------------------------------------------------------------------------------------- 
	--select Sum(Cost), Sum(TotalDays) from prs.tblCelebrationDtl
		select  @CostYear= 1.0*( Sum(Cost)-(  1.0*@CelebrationCeiling *Sum(TotalDays)/@intDaysOfYears))
			from prs.tblCelebrationDtl
			where PersonnelID=@PersonnelID
				and ProcessID=@ProcessID
				and MonthCode<=@MonthCode
	
		if isnull(@CostYear,0)>0
			Update prs.tblCelebrationDtl
				set Cost=Cost-@CostYear
					,BaseCost=BaseCost-@CostYear 
					,Update320=Update320-@CostYear
				from prs.tblCelebrationDtl
				where PersonnelID=@PersonnelID
					and ProcessID=@ProcessID
					and MonthCode=@MonthCode
					and Payable=1
	---------------------------------------------------------------------------------------------- 
		FETCH NEXT FROM csr INTO @PersonnelID
	END

	CLOSE csr
	DEALLOCATE csr
		
END	
GO
