USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1403/09/02
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- ----------------------------------------------
-- Description	 : < تنظیمات  >
-- ==============================================
Create PROCEDURE iw.SpGetSetting
	@UserID		int,
	@StationID	varchar(20) 
WITH ENCRYPTION
AS
BEGIN	
	Declare @StrSelect	NVarChar(max);
	Declare @StrWhare	NVarChar(MAX);

	Select  SettingKey	,SettingValue	,SettingDesc
	into #tblSeting
	from pub.tblSettings 
	where 1=0	
	
	Declare @DbName0000	NVarChar(100);
	Declare @DbName 	NVarChar(100);
	
	select @DbName=DB_name()
	set @DbName0000	=SUBSTRING(@DbName,1, len(@DbName)-4)+'0000'

	set @StrSelect=' Insert into #tblSeting
		select ParameterEn, Access, ''bit'' from '+@DbName0000+'.usr.tblParameterAccess
		where UserID='+str(@UserID)+' and ParameterEn in(''AllowEditSalePrice'' ,''ShopManager'')'

		PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	   	 
	Insert into #tblSeting
	Select  SettingKey	,SettingValue	,'bit'
	from pub.tblSettings 
	where SettingKey in ('Inv_AllowNegativeRemain','GoodsPriceNotForce','StartGoodsWeightBarcode','LenGoodsWeightBarcode')

	select * from #tblSeting

END

--لیست ورودی 
--1- کد کاربر
--2- کد شعبه

-- لیست خروجی
--0- نام کلید
--1- مقدار
--2- نوع
GO
