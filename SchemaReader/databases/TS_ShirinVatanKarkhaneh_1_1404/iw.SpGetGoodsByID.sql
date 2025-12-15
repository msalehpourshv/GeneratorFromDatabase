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
-- Description	 : < مشخصات کالا  >
-- ==============================================
Create PROCEDURE iw.SpGetGoodsByID
	@UserID			int	,
	@StationID		varchar(20) ,
	@GoodsID		varchar(20)
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

	set @StrSelect=' select   Count(*)over () TotalCount, H.GoodsID,MasterCode,TechnicalNo,BarCode,TechnicalSpecifications
					,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5
					, UnitID,inv.funGetUnitName(UnitID,1) UnitName ,isnull(D.GoodsName,'''') GoodsName 
					,[sal].[funGetGoodsAmountSaleType](H.GoodsID,'''','''','''+@PosSaleType+''',1,0,0) SalePrice
					,ISNULL(CAST((SELECT SUM(GoodsQuantity*EnterKind) FROM inv.tblStorageDocsDtl SD WHERE SD.GoodsID=D.GoodsID  and SD.StoreID='''+@POSStoreID+''') AS Float),0) GoodsQuantity
						from   inv.tblGoods H
						Left Join inv.tblGoodsDtl D on D.GoodsID=H.GoodsID and D.LanguageID=1
						where 1= 1 '

	if isnull(@StrWhareIn,'')<>''
		set @StrSelect +=' and ' + @StrWhareIn

		
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;   	 

END

--ليست ورودي 
--1- کد کاربر
--2- کد شعبه
--3- شروط ورودي
--4- از سطر
--5- تعداد سطر
--6- قسمت اول كد

-- ليست خروجي
--0- تعداد سطر
--1-کد کالا
--2-کد کارفرما
--3-شماره فني 
--4-بارکد
--5-مشخصات فني
--6-فيلد اضافي 1
--7-فيلد اضافي 2
--8-فيلد اضافي 3
--9-فيلد اضافي 4
--10-فيلد اضافي 5
--11- کد واحد کالا
--12-نام واحد کالا
--13-نام کالا
--14-قیمت فروش
--15-موجودی
GO
