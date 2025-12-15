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
-- Description	 : < لیست مشتریان>
-- ==============================================
 Create PROCEDURE iw.SpCustomerInfo
	@UserID		int,
	@StationID	varchar(20) ,
	@StrWhare		NVarChar(MAX),
	@Skip			int,
	@Take			int,
	@CustomerInfoID	varchar(20) ='',
	@FirstName		Nvarchar(200)='' ,
	@LastName		Nvarchar(200)='' ,
	@MobileNumber	Nvarchar(200)='' ,
	@ShowCodeClosed	bit=0

WITH ENCRYPTION
AS
BEGIN	
	Declare @StrSelect	NVarChar(max);
	Declare @StrWhareIn	NVarChar(MAX);

	set @StrWhareIn='  LTRIM(H.CustomerInfoID) <> '''' '	
	if @CustomerInfoID<>'' --AND  left(D.CustomerInfoID,1 ) ='2' 
		set @StrWhareIn+=' and left(H.CustomerInfoID,'+ str(len(@CustomerInfoID)) +') ='''+@CustomerInfoID+'''   '	

	if @FirstName<>'' --AND  REPLACE (D.FirstName,' ','') LIKE N'%1%'   
		set @StrWhareIn+=' and upper(REPLACE (D.FirstName,'' '','''')) LIKE N''%'+Upper(@FirstName)+'%'' '	

	if @LastName<>'' --AND  REPLACE (D.LastName,' ','') LIKE N'%1%'   
		set @StrWhareIn+=' and upper(REPLACE (D.LastName,'' '','''')) LIKE N''%'+Upper(@LastName)+'%'' '	
	
	if @MobileNumber<>'' --AND  REPLACE (D.MobileNumber,' ','') LIKE N'%1%'   
		set @StrWhareIn+=' and upper(REPLACE (D.MobileNumber,'' '','''')) LIKE N''%'+Upper(@MobileNumber)+'%'' '	
	
	if @ShowCodeClosed='False'
		set @StrWhareIn+=' AND  H.CodeClosed = ''False''' 
		
	if isnull(@Take,0)=0
		set @Take=1

	set @StrSelect='select  Count(*)over () TotalCount, H.CustomerInfoID	,NationalNumber	,IDNumber	,BirthDate	,RegisterDate	,MobileNumber	,PhoneNumber	
							,LoyalTimeLimit	,DefaultPrivilegeDate	,DefaultPrivilege	,Gender	,H.CustomerScoreID	
							,ISNULL(FirstName , '''')FirstName,ISNULL(LastName , '''')LastName,ISNULL(Adress , '''')Adress	
						from lyl.tblCustomerInfo H
						left Join lyl.tblCustomerInfoDtl D On D.CustomerInfoID=H.CustomerInfoID and 	D.LanguageID=1
					where 1= 1'

	if isnull(@StrWhare,'')<>''
		set @StrSelect +=' and ' +@StrWhare
	if isnull(@StrWhareIn,'')<>''
		set @StrSelect +=' and ' + @StrWhareIn

	set @StrSelect += ' Order by  H.CustomerInfoID	
						OFFSET ' +str(@Skip) +' Rows 
						FETCH NEXT ' +Str(@Take) +' Rows ONLY '
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
--7- قسمتي از نام  
--8- قسمتي از نام خانوادگی   
--9- موبایل
--10- نمایش کدهای غیر فعال


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
