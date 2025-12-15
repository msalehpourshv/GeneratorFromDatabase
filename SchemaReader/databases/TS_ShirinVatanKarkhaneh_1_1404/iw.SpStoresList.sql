USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1403/08/02
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- ----------------------------------------------
-- Description	 : < لیست انبار ها >
-- ==============================================
Create PROCEDURE iw.SpStoresList
	@UserID		int,
	@StationID	varchar(20) ,
	@StrWhare		NVarChar(MAX),
	@Skip			int,
	@Take			int	,
	@StoreID		varchar(20) ='',
	@StoreName		Nvarchar(200)='' ,
	@ShowCodeClosed	bit=0

WITH ENCRYPTION
AS
BEGIN	
	Declare @StrSelect	NVarChar(max);
	Declare @StrWhareIn	NVarChar(MAX);

	set @StrWhareIn='  LTRIM(H.StoreID) <> '''' '	
	if @StoreID<>'' --AND  left(D.StoreID,1 ) ='2' 
		set @StrWhareIn+=' and left(H.StoreID,'+ str(len(@StoreID)) +') ='''+@StoreID+'''   '	

	if @StoreName<>'' --AND  REPLACE (D.StoreName,' ','') LIKE N'%1%'   
		set @StrWhareIn+=' and upper(REPLACE (D.StoreName,'' '','''')) LIKE N''%'+Upper(@StoreName)+'%'' '	

	if @ShowCodeClosed='False'
		set @StrWhareIn+=' AND  H.CodeClosed = ''False''' 
	
	if isnull(@Take,0)=0
		set @Take=1
	
	set @StrSelect='select   Count(*)over () TotalCount, D.StoreID,isnull(D.StoreName,'''') StoreName 
					from  inv.tblStores  H
					inner join 		inv.tblStoresDtl D on H.StoreID=D.StoreID
					where 1= 1 '

	if isnull(@StrWhare,'')<>''
		set @StrSelect +=' and ' +@StrWhare

	if isnull(@StrWhareIn,'')<>''
		set @StrSelect +=' and ' +@StrWhareIn

	set @StrSelect += ' Order by  D.StoreID
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
--8- نمایش کدهای غیر فعال


-- لیست خروجی
--0- تعداد سطر
--1- کد انبار
--2- نام انبار
GO
