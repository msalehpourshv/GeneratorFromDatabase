USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
 -- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1399/09/09
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- ----------------------------------------------
-- Description	 : <  فروش کالا برای CRM  >
-- ==============================================
Create PROCEDURE crm.SpGoodsRemainAndPriceForTSCRM
	@GoodsID			Varchar(20), 
	@DocDate				char(10)
WITH ENCRYPTION
AS
BEGIN

	Declare @StoreIDCrm			Varchar(20) 
	Declare @CustomerKindIDCrm	Varchar(20) 
	Declare @SaleTypeCrm		Varchar(20) 

	Declare @StrSelect	nVarchar(max)
	Declare @StrWhere	nVarchar(max)
	declare @UserID		int;	
	
	declare @CRM_GoodsRemainAndPrice as bit 
	select @CRM_GoodsRemainAndPrice=SettingValue from pub.tblSettings where SettingKey='CRM_GoodsRemainAndPrice'

	set @CRM_GoodsRemainAndPrice=isnull(@CRM_GoodsRemainAndPrice,'False') 
	IF @CRM_GoodsRemainAndPrice='False'
		BEGIN
			Raiserror (' لایسنس نمایش موجودی و قیمت کالا برای CRM فعال نشده است',16,1)
			Return
		END
	select @StrWhere=''
	select @StrSelect=''
	SELECT @UserID				= isnull(SettingValue,-1) FROM pub.tblSettings	WHERE SettingKey = 'UserExternalCRM'	
	SELECT @StoreIDCrm			= isnull(SettingValue,-1) FROM pub.tblSettings	WHERE SettingKey = 'StoreIDCrm'	
	SELECT @SaleTypeCrm			= isnull(SettingValue,-1) FROM pub.tblSettings	WHERE SettingKey = 'SaleTypeCrm'	
	SELECT @CustomerKindIDCrm	= isnull(SettingValue,-1) FROM pub.tblSettings	WHERE SettingKey = 'CustomerKindIDCrm'	

	if @UserID=0
		set @UserID=-1
	
	set @StoreIDCrm			=isnull(@StoreIDCrm,'')
	set @SaleTypeCrm		=isnull(@SaleTypeCrm,'')
	set @CustomerKindIDCrm	=isnull(@CustomerKindIDCrm,'')
	--IF @StoreIDCrm = ''  
	--	BEGIN
	--		Raiserror (' کد انبار درتنظیمات خالی است',16,1)
	--		Return
	--	END
	IF @SaleTypeCrm = ''  and @CustomerKindIDCrm = ''  
		BEGIN
			Raiserror ('نوع فروش و یا نوع مشتری درتنظیمات خالی است',16,1)
			Return
		END
	select  GoodsID , GoodsQuantity,GoodsPrice,StoreID,DescDtl GoodsName  into #GoodsQTYRmain from inv.tblStorageDocsDtl where 1=0 
	
	set @StrSelect='insert into #GoodsQTYRmain 
						select  D.GoodsID , sum(GoodsQuantity*EnterKind ) QTY,0   ,StoreID,GoodsName
						from inv.tblStorageDocsDtl D
						inner join  inv.tblGoodsDtl  g  on D.GoodsID =g.GoodsID and g.LanguageID=1
						where 1=1 '
	IF @StoreIDCrm <> ''  
	set @StrSelect= @StrSelect+ '	and StoreID='''+@StoreIDCrm+''' '
	if (@DocDate<> '' and  not (@DocDate is null))
			set @StrSelect= @StrSelect+ '	and DocDate<='''+@DocDate+''' '
	if (@GoodsID<> '' and  not (@GoodsID is null))
			set @StrSelect= @StrSelect+ '	and GoodsID='''+@GoodsID+''' '
	set @StrSelect= @StrSelect + @StrWhere
	set @StrSelect= @StrSelect+ ' group by  D.GoodsID,StoreID,GoodsName'
				
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	  
	update #GoodsQTYRmain
	set GoodsPrice= [sal].[funGetGoodsAmountSaleType] (GoodsID,@StoreIDCrm ,	@DocDate ,@SaleTypeCrm ,	1,0,0)

    select * from #GoodsQTYRmain

END
GO
