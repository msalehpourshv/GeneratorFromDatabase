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
-- Description	 : < لیست تخفیفات خرید 2 عددی>
-- ==============================================
Create PROCEDURE iw.Sp2BuyDiscount
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

	set @StrSelect='select  Count(*)over () TotalCount, H.SerialNo	,H.FiscalYear	,H.DocDate	,H.FromDate	,H.ToDate	,H.DayOfWeek1	,H.DayOfWeek2	,H.DayOfWeek3	,H.DayOfWeek4	
							,H.DayOfWeek5	,H.DayOfWeek6	,H.DayOfWeek7	
							,D.RowNo	,D.DocRowNo	,D.Model	,D.OneBuyPrice	,D.TwoBuyPrice
					from   sal.tbl2BuyDiscountHdr H
					left Join sal.tbl2BuyDiscountDtl D On D.SerialNo=H.SerialNo and 	D.FiscalYear=H.FiscalYear
					where 1= 1'

	if isnull(@StrWhare,'')<>''
		set @StrSelect +=' and ' +@StrWhare

	set @StrSelect += ' Order by  H.SerialNo	,H.FiscalYear,D.RowNo
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
--13- شماره سطر
--14- مدل
--15- قیمت خرید 1
--16- قیمت خرید 2
GO
