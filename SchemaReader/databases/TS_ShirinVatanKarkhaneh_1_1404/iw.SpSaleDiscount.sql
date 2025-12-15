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
-- Description	 : < لیست تخفیفات فروش>
-- ==============================================
Create PROCEDURE iw.SpSaleDiscount
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

		 

	set @StrSelect='select  Count(*)over () TotalCount, H.SaleDiscountID	,H.DiscountPercent	,H.Discount	,isnull(D.SaleDiscountName,'''') SaleDiscountName 
					from   sal.tblSaleDiscount H
					left Join sal.tblSaleDiscountDtl D On D.SaleDiscountID=H.SaleDiscountID  
					where 1= 1'

	if isnull(@StrWhare,'')<>''
		set @StrSelect +=' and ' +@StrWhare

	set @StrSelect += ' Order by  H.SaleDiscountID	 
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
--1-کد تخفیف
--2-درصد تخفیف
--3-مبلغ تخفیف
--4-نام تخفیف
GO
