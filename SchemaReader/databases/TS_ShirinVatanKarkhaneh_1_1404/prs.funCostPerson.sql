USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : jafari
-- Create date   : 1403/12/26
-- Viewed By	 : 
-- Last Modified : 
-- Modifier		 : 
-- Description	 :  محاسبه مانده عیدی و پایانکار
-- ==============================================
Create FUNCTION prs.funCostPerson
(
	@PersonnelID VarChar(20) ,
	@MonthCode 	int,
	@ProcessID int 	
)
returns int
WITH ENCRYPTION
AS
Begin


	Declare @Ret as int
	set @Ret=0

	if (SELECT count(*) FROM prs.tblCelebrationDtl WHERE (ProcessID = @ProcessID) and (Payable = 1) and MonthCode=@MonthCode and PersonnelID=@PersonnelID)>0	
		SELECT @Ret=Sum(Cost) FROM prs.tblCelebrationDtl WHERE (ProcessID = @ProcessID)and PersonnelID=@PersonnelID
			and Date > isnull(( Select  Max(Date) FROM prs.tblCelebrationDtl where  (ProcessID = @ProcessID) and (Payable = 1) and MonthCode<@MonthCode and PersonnelID=@PersonnelID ), '')
		group by PersonnelID, ProcessID

   return  ISnull(@Ret,0)
  
End
GO
