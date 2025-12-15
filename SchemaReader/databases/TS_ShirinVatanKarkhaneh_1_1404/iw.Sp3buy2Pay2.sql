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
-- Description	 : <2 لیست تخفیفات 2 تا بخر 3 تا ببر>
-- ==============================================
Create PROCEDURE iw.Sp3buy2Pay2
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
	
	set @StrSelect='select  Count(*)over () TotalCount, H.SerialNo	,H.FiscalYear	,H.DocDate	,H.FromDate	,H.ToDate	
						,H.DayOfWeek1	,H.DayOfWeek2	,H.DayOfWeek3	,H.DayOfWeek4	,H.DayOfWeek5	,H.DayOfWeek6	,H.DayOfWeek7	
						,H.XBuy	,H.YPay,D1.DocRowNo	,D1.ExFld2
					from   sal.tbl3buy2PayHdr H
					left Join sal.tbl3buy2PayDtl2 D1 On D1.SerialNo=H.SerialNo and 	D1.FiscalYear=H.FiscalYear
					where 1= 1'

	if isnull(@StrWhare,'')<>''
		set @StrSelect +=' and ' +@StrWhare

	set @StrSelect += ' Order by  H.SerialNo	,H.FiscalYear,D1.DocRowNo
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
--6- روز شنبه
--7- روز یکشنبه
--8- روز دوشنبه
--9- روز سه شنبه
--10- روز چهارشنبه
--11- روز پنجشنبه
--12- روز جمعه
--13- تعداد خرید
--14- تعداد پرداخت
--15- شماره سطر
--16- فیلد اضاافی  1
GO
