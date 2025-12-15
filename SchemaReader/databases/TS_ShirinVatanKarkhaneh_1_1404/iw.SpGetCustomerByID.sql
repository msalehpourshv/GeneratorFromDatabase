USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1403/08/19
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- ----------------------------------------------
-- Description	 : < مشخصات مشتری>
-- ==============================================
 Create PROCEDURE iw.SpGetCustomerByID
	@UserID		int,
	@StationID	varchar(20) ,
	@CustomerInfoID	varchar(20)

WITH ENCRYPTION
AS
BEGIN	
	Declare @StrSelect	NVarChar(max);
	Declare @StrWhareIn	NVarChar(MAX);

	set @StrWhareIn='  LTRIM(H.CustomerInfoID) <> '''' '	
	if @CustomerInfoID<>'' --AND  left(D.CustomerInfoID,1 ) ='2' 
		set @StrWhareIn+=' and left(H.CustomerInfoID,'+ str(len(@CustomerInfoID)) +') ='''+@CustomerInfoID+'''   '	

	set @StrSelect='select  Count(*)over () TotalCount, H.CustomerInfoID	,NationalNumber	,IDNumber	,BirthDate	,RegisterDate	,MobileNumber	,PhoneNumber	
							,LoyalTimeLimit	,DefaultPrivilegeDate	,DefaultPrivilege	,Gender	,H.CustomerScoreID	
							,ISNULL(FirstName , '''')FirstName,ISNULL(LastName , '''')LastName,ISNULL(Adress , '''')Adress	
						from lyl.tblCustomerInfo H
						left Join lyl.tblCustomerInfoDtl D On D.CustomerInfoID=H.CustomerInfoID and 	D.LanguageID=1
					where 1= 1'

	if isnull(@StrWhareIn,'')<>''
		set @StrSelect +=' and ' + @StrWhareIn

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	   	 

END

--لیست ورودی 
--1- کد کاربر
--2- کد شعبه
--3- شروط ورودی
--4- از سطر
--5- تعداد سطر
--6- قسمت اول كد

-- لیست خروجی
--0- تعداد سطر
--1- کد
--2- کد ملی
--3- ش شناسنامه
--4- تاریخ تولد
--5-  تاریخ ثبت نام
--6- موبایل
--7- تلفن
--8- محدوده زمانی
--9- تاریخ شروع
--10-امتیاز اولیه
--11-جنسیت
--12-نوع مشتری
--13-نام 
--14-نام خانوادگی
--15- آدرس
GO
