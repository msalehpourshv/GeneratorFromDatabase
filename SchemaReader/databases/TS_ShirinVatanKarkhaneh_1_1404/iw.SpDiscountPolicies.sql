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
-- Description	 : < لیست تخفیفات درصدی کالا >
-- ==============================================
Create PROCEDURE iw.SpDiscountPolicies
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
			
--select * FROM sal.tblDiscountPoliciesHdr
--select * FROM sal.tblDiscountPoliciesDtl 

	set @StrSelect='select  Count(*)over () TotalCount, H.SerialNo	,H.ProcessID	,H.FromDate	,H.ToDate
					,GoodsID,DiscountPercent,.pub.funGetGoodsName(GoodsID,1) AS GoodsName
					from   sal.tblDiscountPoliciesHdr H
					left Join sal.tblDiscountPoliciesDtl D On D.SerialNo=H.SerialNo and 	D.ProcessID=H.ProcessID
					where H.ProcessID	= 201 '
	if isnull(@StrWhare,'')<>''
		set @StrSelect +=' and ' +@StrWhare

	set @StrSelect += ' Order by  H.SerialNo,	H.ProcessID, FromDate
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
--2- شماره پروسس
--3- از تاریخ
--4- تا تاریخ
--5- کد کالا
--6- درصد تخفیف
--7- نام کالا
GO
