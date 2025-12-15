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
-- Description	 : < ایجاد مشتریان>
-- ==============================================
Create PROCEDURE iw.SpCustomerInfoInsert
	@UserID			int,
	@StationID		varchar(20) ,
	@CustomerInfoID	varchar(20) ,
	@NationalNumber	char(10) ,
	@IDNumber		char(10) ,
	@BirthDate		char(10) ,
	@RegisterDate	char(10) ,
	@MobileNumber	char(20) ,
	@PhoneNumber	char(20) ,	
	@LoyalTimeLimit	char(20),
	@DefaultPrivilegeDate	char(10) ,
	@DefaultPrivilege	char(20),
	@Gender				char(1),
	@CustomerScoreID	varchar(20) ,
	@FirstName			nvarChar(1000),
	@LastName			nvarChar(1000),
	@Adress				nvarChar(1000)
WITH ENCRYPTION
AS
BEGIN	
	Declare @StrSelect	NVarChar(max);
 
	set @StrSelect	=' Insert into lyl.tblCustomerInfo (CustomerInfoID,NationalNumber,IDNumber,BirthDate,RegisterDate,MobileNumber,PhoneNumber,LoyalTimeLimit
	,DefaultPrivilegeDate,DefaultPrivilege,Gender,CustomerScoreID)'
		+ 'Select ''' +@CustomerInfoID+ ''',''' +@NationalNumber+''',''' +@IDNumber+ ''',''' +@BirthDate+ ''',''' +@RegisterDate+ ''',''' +@MobileNumber+ ''',
		''' +@PhoneNumber+ ''',''' +@LoyalTimeLimit+ ''',''' +@DefaultPrivilegeDate+ ''',''' +@DefaultPrivilege+ ''',''' +@Gender+ ''',
		''' +@CustomerScoreID+ ''''
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;  	 

	set @StrSelect	=' Insert into lyl.tblCustomerInfoDtl (CustomerInfoID,FirstName,LastName,Adress,LanguageID)
	Select ''' +@CustomerInfoID+ ''',''' +@FirstName+ ''',''' +@LastName+ ''',''' +@Adress+ ''',1 '

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	   
	set @StrSelect='select  Count(*)over () TotalCount, H.CustomerInfoID	,NationalNumber	,IDNumber	,BirthDate	,RegisterDate	,MobileNumber	,PhoneNumber	
							,LoyalTimeLimit	,DefaultPrivilegeDate	,DefaultPrivilege	,Gender	,H.CustomerScoreID	
							,ISNULL(FirstName , '''')FirstName,ISNULL(LastName , '''')LastName,ISNULL(Adress , '''')Adress	
						from lyl.tblCustomerInfo H
						left Join lyl.tblCustomerInfoDtl D On D.CustomerInfoID=H.CustomerInfoID and 	D.LanguageID=1
					where H.CustomerInfoID=''' +@CustomerInfoID+ ''' '
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	
END

--لیست ورودی 
--1- کد کاربر
--2- کد شعبه
--3- کد
--4- کد ملی
--5- ش شناسنامه
--6- تاریخ تولد
--7-  تاریخ ثبت نام
--8- موبایل
--9- تلفن
--10- محدوده زمانی
--11- تاریخ شروع
--12-امتیاز اولیه
--13-جنسیت
--14-نوع مشتری
--15-نام 
--16-نام خانوادگی
--17- آدرس


-- لیست خروجی
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
