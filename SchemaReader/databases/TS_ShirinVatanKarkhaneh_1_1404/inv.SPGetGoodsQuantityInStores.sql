USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\H Sadeghi
-- Create date   : 1400/07/17
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : 
-- ==============================================
Create PROCEDURE [inv].[SPGetGoodsQuantityInStores]
	@strFilter as NVARCHAR(4000),
	@UserID as varCHAR(10),
	@IsAdmin as bit
	
WITH ENCRYPTION
AS

BEGIN

	DECLARE @StrSelect		NVarChar(4000);
	DECLARE @StrPemition	NVarChar(4000);
	Declare @PosStoreIDMain  	Varchar(20)
	SELECT @PosStoreIDMain = SettingValue FROM pub.tblSettings WHERE SettingKey = 'PosStoreIDMain'	

	set @strFilter=REPLACE(@strFilter,'@','%')

	SET @StrPemition=''
	IF @IsAdmin = 'False'
		SET @StrPemition = 	'AND ((SELECT COUNT(*) 
						FROM inv.tblGoodsRng R 
						WHERE UserID =' + @UserID + ' AND 
							R.PartNumber=1 AND
							AllowCodeView=1 AND 
							LEFT(D.GoodsID,LEN(FromCode)) >= FromCode AND 
							LEFT(D.GoodsID, LEN(ToCode)) <= ToCode) > 0)'

if isnull(@PosStoreIDMain,'')<>''
begin 	
	select SDD.StoreID ,ST.StoreName,SDD.GoodsID,pub.GetGoodsName(SDD.GoodsID,1) GoodsName,H.BarCode,0 SalePrice
	,SUM(GoodsQuantity*EnterKind) GoodsQuantity, SUM(GoodsQuantity*EnterKind) OrderQuantity
	,SUM(GoodsQuantity*EnterKind) RemainQuantity,SUM(GoodsQuantity*EnterKind) RemainQuantityBase
	into #StorageDocsDtl 
	from inv.tblStorageDocsDtl  SDD
	inner join inv.tblStoresDtl ST	ON SDD.StoreID=ST.StoreID and ST.LanguageID=1
	inner join inv.tblGoods  H		ON H.GoodsID=SDD.GoodsID 
	inner join inv.tblGoodsDtl  D	ON D.GoodsID=SDD.GoodsID and D.LanguageID=1
	where 1=0
	group by SDD.StoreID,SDD.GoodsID,StoreName,H.BarCode

	SET @StrSelect=
	N' insert into  #StorageDocsDtl  
	select SDD.StoreID ,ST.StoreName,SDD.GoodsID,pub.GetGoodsName(SDD.GoodsID,1) GoodsName,H.BarCode,0 SalePrice,SUM(GoodsQuantity*EnterKind) GoodsQuantity
		,0	,0,0
	from inv.tblStorageDocsDtl SDD
	inner join inv.tblStores S	ON SDD.StoreID=S.StoreID 
	inner join inv.tblStoresDtl ST	ON SDD.StoreID=ST.StoreID and ST.LanguageID=1
	inner join inv.tblGoods  H		ON H.GoodsID=SDD.GoodsID 
	inner join inv.tblGoodsDtl  D	ON D.GoodsID=SDD.GoodsID and D.LanguageID=1
	where SDD.StoreID in (
				select StoreID from inv.tblStores
				where InventoryType=2
				) ' + @StrPemition + @strFilter +  '
	group by SDD.StoreID,SDD.GoodsID,StoreName,H.BarCode
	--having SUM(GoodsQuantity*EnterKind)>0	'

	Print @StrSelect;
	Exec sp_executesql @StrSelect;


	if isnull(@PosStoreIDMain,'')<>''
	begin 
		Declare @DocDate as char(10)
		select @DocDate =[pub].[funChangeDate_GergorianToPersian](GETDATE())

		-------بروز رسانی تعداد سفارشات------------------------------------------------------------
		update #StorageDocsDtl 
		set OrderQuantity =b.OrderQuantity
		from #StorageDocsDtl a
		inner join (
			SELECT GoodsID,StoreID, Sum( [inv].[funGetGoodsQuantityFromSubUnit]( GoodsID ,SubUnitID ,SubUnitQuantity))  OrderQuantity
			FROM  [cmr].[FunGetSaleOrder](Null,@DocDate,1,0,0,0)
			Group by GoodsID,StoreID) b on a.GoodsID =b.GoodsID and a.StoreID=b.StoreID

		-------آضافه کردن سفارشاتی که موجودی ندارند ولی سفارش دارند------------------------------------------------------------			
		SET @StrSelect='insert into  #StorageDocsDtl 
		SELECT SDD.StoreID	,pub.GetStoreName(SDD.StoreID,1) StoreName	,SDD.GoodsID	,pub.GetGoodsName(SDD.GoodsID,1) GoodsName	,'''' BarCode	,0 SalePrice,0	GoodsQuantity,[inv].[funGetGoodsQuantityFromSubUnit]( SDD.GoodsID ,SDD.SubUnitID ,SDD.SubUnitQuantity)	OrderQuantity,0	RemainQuantity,0 RemainQuantityBase
		FROM  [cmr].[FunGetSaleOrder](Null,+'''+@DocDate+''',1,0,0,0)  SDD 
		inner join inv.tblStores S	ON SDD.StoreID=S.StoreID 
		inner join inv.tblGoods  H		ON H.GoodsID=SDD.GoodsID 
		inner join inv.tblGoodsDtl  D	ON D.GoodsID=SDD.GoodsID and D.LanguageID=1
		where SDD.StoreID+''@''+SDD.GoodsID not in ( Select  StoreID+''@''+GoodsID from #StorageDocsDtl )
		' + @StrPemition + @strFilter 
	
		Print @StrSelect;
		Exec sp_executesql @StrSelect;
		----بروز رسانی مانده نهایی---------------------------------------------------------------
		update #StorageDocsDtl 
		set RemainQuantity=GoodsQuantity-OrderQuantity 
		
		Update #StorageDocsDtl 
			set RemainQuantityBase= b.RemainQuantity
		From #StorageDocsDtl a
		inner join (select Sum(RemainQuantity) RemainQuantity, GoodsID from  #StorageDocsDtl	 
						Group by GoodsID
						Having Sum(OrderQuantity)>0 ) b 
						on a.GoodsID=b.GoodsID
		where StoreID=@PosStoreIDMain
	end 

	select * from  #StorageDocsDtl 
END
ELSE
BEGIn
	SET @StrSelect=
	N'select SDD.StoreID ,ST.StoreName,SDD.GoodsID,pub.GetGoodsName(SDD.GoodsID,1) GoodsName,H.BarCode,0 SalePrice,SUM(GoodsQuantity*EnterKind) GoodsQuantity
	from inv.tblStorageDocsDtl SDD
	inner join inv.tblStoresDtl ST
	ON SDD.StoreID=ST.StoreID and ST.LanguageID=1
	inner join inv.tblGoods  H
		ON H.GoodsID=SDD.GoodsID 
	inner join inv.tblGoodsDtl  D
		ON D.GoodsID=SDD.GoodsID and D.LanguageID=1
	where SDD.StoreID in (
				select StoreID from inv.tblStores
				where InventoryType=2
				) ' + @StrPemition + @strFilter +  '
	group by SDD.StoreID,SDD.GoodsID,StoreName,H.BarCode
	having SUM(GoodsQuantity*EnterKind)>0'


	Print @StrSelect;
	Exec sp_executesql @StrSelect;
END
END
GO
