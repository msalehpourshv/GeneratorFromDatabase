USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create FUNCTION [emp].[funGetAcntFromDecree]
(
	@PersonnelID VarChar(20), 
	@Type AS TinyInt, 
	@ProcessID AS Int
)
	RETURNS NVarChar(20) 
WITH ENCRYPTION
AS

Begin -- ====================================================
-- 1 AcntSalary
-- 2 AcntAdvance
-- 3 AcntBuy
	Declare @Acnt AS VarChar(20)
	Declare @SerialNo AS Integer
	if @ProcessID is null
		set @ProcessID =300
	
	set @Acnt=''
	Select @SerialNo  =max(SerialNo) From prs.tblDecreeHdr where PersonnelID=@PersonnelID

if @Type=1
begin
	if @ProcessID=321
			Select @Acnt=pub.funMergCode(AcntCelebrationPayable,AcntSalary)  From prs.tblDecreeHdr a 
			Left join prs.tblDepartments  b on a.DepartmentID=b.DepartmentID
			where PersonnelID=@PersonnelID and SerialNo  =@SerialNo  
	else if @ProcessID=326
			Select @Acnt=pub.funMergCode(AcntHistoryCalcDaysPayable,AcntSalary)  From prs.tblDecreeHdr a 
			Left join prs.tblDepartments  b on a.DepartmentID=b.DepartmentID
			where PersonnelID=@PersonnelID and SerialNo  =@SerialNo  
	else
			Select @Acnt=AcntSalary  From prs.tblDecreeHdr 
			where PersonnelID=@PersonnelID and SerialNo  =@SerialNo  
	end 	
if @Type=2
   Select @Acnt=AcntAdvance From prs.tblDecreeHdr where PersonnelID=@PersonnelID and SerialNo  =@SerialNo  

if @Type=3
   Select @Acnt=AcntBuy From prs.tblDecreeHdr where PersonnelID=@PersonnelID and SerialNo  =@SerialNo  
   
	Return isnull( @Acnt,'')

END -- ======================================================
GO
