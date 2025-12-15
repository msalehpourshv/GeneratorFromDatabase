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
-- Description	 : < لیست تخفیفات درصدی قیمت یکسان>
-- ==============================================
Create PROCEDURE iw.SpBuyDiscountPercentHdr
	@UserID		int,
	@StationID	varchar(20) ,
	@StrWhare		NVarChar(MAX),
	@Skip			int,
	@Take			int	

WITH ENCRYPTION
AS
BEGIN	
	Declare @StrSelect	NVarChar(max);
		
	if isnull(@Take,0)=0
		set @Take=1

	
--select * from sal.tblBuyDiscountPercentHdr
	 

	set @StrSelect='select  Count(*)over () TotalCount, SerialNo	,FiscalYear	,DocDate	,FromDate	,ToDate	,ExtraField	,ForQty	,DiscountPercent
					from   sal.tblBuyDiscountPercentHdr H
					where 1= 1'

	if isnull(@StrWhare,'')<>''
		set @StrSelect +=' and ' +@StrWhare

	set @StrSelect += ' Order by  H.SerialNo,	FiscalYear, FromDate
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


-- لیست خروجی
--1- شماره سریال
--2- سال مالی
--3- تاریخ
--4- از تاریخ
--5- تا تاریخ
--6- فیلد اضافی
--7- به ازای
--8- درصد تخفیف
GO
