USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:========================
-- Author        : Jafari
-- Create date   : 1399/07/09
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create FUNCTION ast.funGetLastAssetState
(
	@AssetPlaque	Varchar(20) ,
	@DocDate		char(10),
	@ProcessID		Int
)
RETURNS int
WITH ENCRYPTION
AS
BEGIN

--'1'AssetPrimary = 450         'استقرار اول دوره دارایی
--'1'AssetPurchaseByStore = 455 'خرید دارایی از طریق انبار
--'1'AssetPurchaseDirect = 460  'خرید دارایی مستقیم

--'   بعدا بررسی شود'?'AssetRequstRepair = 469      'درخواست تعمیرات    

--'?'AssetRenovation = 470      'تعمیرات اساسی
--'?'AssetPriceChanging = 471   'افزایش یا کاهش قیمت
--'?'AssetReNew = 472   'تجدید ارزیابی
--'1'AssetTransfer = 480        'نقل و انتقال
--'3'AssetDelete = 485          'حذف یا اسقاط
--'2'AssetMakeUnuse = 486       'بلا استفاده کردن
--'1'AssetMakeReuse = 490       'استفاده مجدد
--'3'AssetSale = 495            'فروش اموال
--'2'AssetTempExit = 500        'خروج موقت دارایی
--'1'AssetTempEnter = 505       'بازگشت داراییهای خارج شده
--'?'AssetDepreciation = 520    'محاسبه استهلاک 

--'Enter = 1       '  در داخل شرکت
--'Delete = 2      'حذف یا اسقاط
--'MakeUnuse = 3   'بلا استفاده کردن
--'Sale = 4        'فروش اموال
--'TempExit = 5    'خروج موقت دارایی



declare @AssetState as int 

set @AssetState=1

        if @ProcessID =450 or @ProcessID =455 or @ProcessID =460 or @ProcessID =480 or @ProcessID =490 or  @ProcessID =505
                set @AssetState = 1
		else if @ProcessID =485 
				set @AssetState = 2
		else if @ProcessID =486
				set @AssetState = 3
		else if @ProcessID =495 
				set @AssetState = 4
		else if @ProcessID =500 
				set @AssetState = 5

        Else
		begin
			if(SELECT count(*) FROM ast.tblAssetsDtl WHERE ProcessID in( 486,500,485,495) and  AssetPlaque=@AssetPlaque and DocDate <=@DocDate )<=0
				set @AssetState = 1
			else
			begin
			
				
				DECLARE @FLG AS bit
					set @FLG =0				
				DECLARE csr CURSOR FOR 
					SELECT ProcessID FROM ast.tblAssetsDtl WHERE    AssetPlaque=@AssetPlaque and DocDate <=@DocDate order by DocDate Desc ,EventNo Desc

				OPEN csr
				FETCH NEXT FROM csr INTO @ProcessID

				WHILE @@Fetch_Status = 0 and @FLG =0
				BEGIN

				  if @ProcessID =450 or @ProcessID =455 or @ProcessID =460 or @ProcessID =480 or @ProcessID =490 or  @ProcessID =505
					begin
						set @AssetState = 1
						set @FLG =1				
					end 
					else if @ProcessID =485
					begin
						set @AssetState = 2
						set @FLG =1				
					end 					
					else if @ProcessID =486
					begin
						set @AssetState = 3
						set @FLG =1				
					end 					
					else if @ProcessID =495
					begin
						set @AssetState = 4
						set @FLG =1				
					end 					
					 else if @ProcessID =500
					begin
						set @AssetState = 5
						set @FLG =1				
					end 					
					    
				FETCH NEXT FROM csr INTO @ProcessID
				
				end		
				CLOSE csr
				DEALLOCATE csr
			end		
		end		
	Return @AssetState

END
 
GO
