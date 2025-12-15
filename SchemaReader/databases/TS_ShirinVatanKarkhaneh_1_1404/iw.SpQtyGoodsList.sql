USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1403/08/30
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- ----------------------------------------------
-- Description	 : < موجودی کالا ها >
-- ==============================================
Create PROCEDURE iw.SpQtyGoodsList
	@UserID		int,
	@StationID	varchar(20) ,
	@StrWhare		NVarChar(MAX),
	@Skip			int,
	@Take			int	,
	@BarCode		varchar(20) ='',
	@GoodsID		varchar(20) ='',
	@GoodsName		Nvarchar(200)='',
	@StoreID		varchar(20) ='',
	@ExtraField1 	nvarchar(200)='',
	@ExtraField2	nvarchar(200)='',
	@ExtraField3 	nvarchar(200)='',
	@ExtraField4	nvarchar(200)='',
	@ExtraField5 	nvarchar(200)=''

WITH ENCRYPTION
AS
BEGIN	
	Declare @StrSelect	NVarChar(max);
	Declare @StrWhareIn	NVarChar(MAX);
	Declare @PosSaleType varchar(20) =''
	Declare @POSStoreID	 varchar(20) =''

	Select @PosSaleType=PosSaleType,@POSStoreID=POSStoreID from   pub.tblStation where StationID=@StationID

	set @StrWhareIn='  LTRIM(H.GoodsID) <> '''' '	

	if @GoodsID<>'' --AND  left(D.GoodsID,1 ) ='2' 
		set @StrWhareIn+=' and left(H.GoodsID,'+ str(len(@GoodsID)) +') ='''+@GoodsID+'''   '	
	if @GoodsName<>'' --AND  REPLACE (D.GoodsName,' ','') LIKE N'%1%'   
		set @StrWhareIn+=' and upper(REPLACE (D.GoodsName,'' '','''')) LIKE N''%'+Upper(@GoodsName)+'%'' '	
	if @BarCode<>'' 
		set @StrWhareIn+=' and H.BarCode LIKE N''%'+@BarCode+'%'''	
	if @ExtraField1<>''
		set @StrWhareIn+=' and H.ExtraField1 LIKE N''%'+@ExtraField1+'%'''	
	if @ExtraField2<>''
		set @StrWhareIn+=' and H.ExtraField2 LIKE N''%'+@ExtraField2+'%'''	
	if @ExtraField3>'' 
		set @StrWhareIn+=' and H.ExtraField3 LIKE N''%'+@ExtraField3+'%'''	
	if @ExtraField4<>''
		set @StrWhareIn+=' and H.ExtraField4 LIKE N''%'+@ExtraField4+'%'''	
	if @ExtraField5<>''
		set @StrWhareIn+=' and H.ExtraField5 LIKE N''%'+@ExtraField5+'%'''	
	if @StoreID<>'' --AND  left(D.StoreID,1 ) ='2' 
		set @StrWhareIn+=' and left(S.StoreID,'+ str(len(@StoreID)) +') ='''+@StoreID+'''   '	
	 
	
	if isnull(@Take,0)=0
		set @Take=1
	
	set @StrSelect='
				SELECT Count(*)over () TotalCount,  H.GoodsID,D.GoodsName,H.BarCode,[sal].[funGetGoodsAmountSaleType](H.GoodsID,'''','''','+@PosSaleType+',1,0,0) SalePrice, 
				ISNULL(S.Qty,0) GoodsQuantity,
				ISNULL(S.StoreID,'''') StoreID,[pub].[GetStoreName](S.StoreID,1) StoreName 
				,H.ExtraField1,H.ExtraField2,H.ExtraField3,H.ExtraField4,H.ExtraField5 
				FROM  inv.tblGoods AS H 
				INNER JOIN  inv.tblGoodsDtl AS D ON H.GoodsID = D.GoodsID 
				LEFT JOIN  (SELECT StoreID,GoodsID,CAST(SUM( GoodsQuantity*EnterKind) as float) Qty FROM inv.tblStorageDocsDtl S WHERE 1=1 GROUP BY StoreID,GoodsID) S ON H.GoodsID = S.GoodsID 
				where 1= 1 '

	if isnull(@StrWhare,'')<>''
		set @StrSelect +=' and ' +@StrWhare

	if isnull(@StrWhareIn,'')<>''
		set @StrSelect +=' and ' +@StrWhareIn

	set @StrSelect += ' Order by   H.GoodsID
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
--6- قسمت اول باركد
--7- قسمت اول كد کالا
--8- قسمتي از نام کالا  
--7- قسمت اول كد انبار
--8- فیلد اضافی1
--9- فیلد اضافی2
--10- فیلد اضافی3
--11- فیلد اضافی4
--12- فیلد اضافی5

-- ليست خروجي
--0- تعداد سطر
--1-کد کالا
--2-نام کالا
--3-بارکد
--4- قیمت فروش 
--5- موجودی
--6- کد انبار
--7- نام انبار
--8-فيلد اضافي 1
--9-فيلد اضافي 2
--10-فيلد اضافي 3
--11-فيلد اضافي 4
--12-فيلد اضافي 5
GO
