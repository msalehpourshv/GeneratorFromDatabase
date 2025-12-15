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
-- Description	 : < مشخصات انبار  >
-- ==============================================
Create PROCEDURE iw.SpGetStoresByID
	@UserID		int,
	@StationID	varchar(20) ,
	@StoreID		varchar(20) 
WITH ENCRYPTION
AS
BEGIN	
	Declare @StrSelect	NVarChar(max);
	Declare @StrWhareIn	NVarChar(MAX);

	set @StrWhareIn='  LTRIM(H.StoreID) <> '''' '	
	if @StoreID<>'' --AND  left(D.StoreID,1 ) ='2' 
		set @StrWhareIn+=' and left(H.StoreID,'+ str(len(@StoreID)) +') ='''+@StoreID+'''   '	
	
	set @StrSelect='select   Count(*)over () TotalCount, D.StoreID,isnull(D.StoreName,'''') StoreName 
					from  inv.tblStores  H
					inner join 		inv.tblStoresDtl D on H.StoreID=D.StoreID
					where 1= 1 '

	if isnull(@StrWhareIn,'')<>''
		set @StrSelect +=' and ' +@StrWhareIn

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
--1- کد انبار
--2- نام انبار
GO
