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
-- Description	 : <  فروش کالا برای CRM  رز>
-- ==============================================
--crm.SpGoodsRemainAndPriceForRozCRMNew '1520009','1402/04/04'
Create PROCEDURE crm.SpGoodsRemainAndPriceForRozCRMNew
	@GoodsID			Varchar(20), 
	@DocDate				char(10)
WITH ENCRYPTION
AS
BEGIN

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

	if @UserID=0
		set @UserID=-1
	
	select  GoodsID , GoodsQuantity,GoodsPrice,StoreID,DescDtl GoodsName ,SaleTypeID  into #GoodsQTYRmain from inv.tblStorageDocsDtl where 1=0 
	
	set @StrSelect='insert into #GoodsQTYRmain 
						select  D.GoodsID , sum(GoodsQuantity*EnterKind ) QTY,0   ,StoreID,GoodsName,''''
						from inv.tblStorageDocsDtl D
						inner join  inv.tblGoodsDtl  g  on D.GoodsID =g.GoodsID and g.LanguageID=1
						where 1=1 '
	
	if  isnull(rtrim(ltrim(@DocDate)),'')=''
		set @DocDate=[pub].[funChangeDate_GergorianToPersian](GETDATE())
	if (@DocDate<> '' and  not (@DocDate is null))
			set @StrWhere= @StrWhere+ '	and D.DocDate<='''+@DocDate+''' '
	if (@GoodsID<> '' and  not (@GoodsID is null))
			set @StrWhere= @StrWhere+ '	and D.GoodsID='''+@GoodsID+''' '

	BEGIN TRY
		DROP TABLE #tblStoreID
		DROP TABLE #tblGoods
		DROP TABLE #tblSaleTypeID		
	END TRY
	BEGIN CATCH
	END CATCH
	 
	CREATE TABLE #tblGoods
	(
	GoodsID 			Varchar(20)collate arabic_cs_as null
	)
	CREATE TABLE #tblStoreID
	(
	StoreID 			Varchar(20)collate arabic_cs_as null
	)

	CREATE TABLE #tblSaleTypeID
	(
	SaleTypeID 			Varchar(20)collate arabic_cs_as null
	)
	Insert into  #tblGoods (GoodsID)					SELECT Distinct GoodsID			FROM inv.tblStorageDocsDtl
	Insert into  #tblStoreID (StoreID)					SELECT Distinct StoreID			FROM inv.tblStorageDocsDtl	  
	Insert into  #tblSaleTypeID (SaleTypeID)			SELECT Distinct SaleTypeID		FROM sal.tblSaleTypes  
	 
	exec pub.SpFilterByPermission2 '#tblGoods', 'GoodsID', 'inv.tblGoods', @UserID;
	exec pub.SpFilterByPermission2 '#tblStoreID', 'StoreID', 'inv.tblStores', @UserID;
	exec pub.SpFilterByPermission2 '#tblSaleTypeID', 'SaleTypeID', 'sal.tblSaleTypes', @UserID;

	set @StrWhere= @StrWhere+ 
		' and StoreID in (SELECT StoreID FROM  #tblStoreID )  
 		  and D.GoodsID in (SELECT GoodsID	FROM #tblGoods ) '

	set @StrSelect= @StrSelect + @StrWhere
	set @StrSelect= @StrSelect+ ' group by  D.GoodsID,StoreID,GoodsName '				

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	select * into #GoodsQTYRmain2 from #GoodsQTYRmain where 1=0

	insert into #GoodsQTYRmain2
	select a.GoodsID , a.GoodsQuantity,a.GoodsPrice,a.StoreID, a.GoodsName ,b.SaleTypeID 
	from #GoodsQTYRmain a, sal.tblSaleTypes b 
	where b.SaleTypeID in (SELECT SaleTypeID	FROM #tblSaleTypeID )	 

	update #GoodsQTYRmain2
	set GoodsPrice= [sal].[funGetGoodsAmountSaleType] (GoodsID,StoreID ,	@DocDate ,SaleTypeID ,	1,0,0)

    select GoodsID , GoodsName ,GoodsQuantity,GoodsPrice,a.StoreID,StoreName, a.SaleTypeID,SaleTypeName,
	[sal].[funGetSaleOrderGoodsRemain_Store](GoodsID,a.StoreID,@DocDate,RIGHT(DB_NAME(),4),0) SaleOrderGoodsRemain,
	[inv].[funGetGoodsRemainInPreSale](GoodsID,a.StoreID,@DocDate,'False',1,0,3) PreSaleGoodsRemain
	from #GoodsQTYRmain2 a
	left join sal.tblSaleTypesDtl sa on a.SaleTypeID=sa.SaleTypeID and sa.LanguageID=1
	left join inv.tblStoresDtl st on a.StoreID=st.StoreID and st.LanguageID=1

END
GO
