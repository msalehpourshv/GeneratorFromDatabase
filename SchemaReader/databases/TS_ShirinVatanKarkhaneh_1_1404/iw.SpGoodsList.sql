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
-- Description	 : < ليست کالا ها >
-- ==============================================
Create PROCEDURE iw.SpGoodsList
	@UserID			int	,
	@StationID		varchar(20) ,
	@StrWhare		NVarChar(MAX),
	@Skip			int,
	@Take			int,
	@GoodsID		varchar(20)='',
	@GoodsName		nvarchar(200)='',
	@TechnicalNo	nvarchar(200)='',
	@TechnicalSp	nvarchar(200)='',
	@BarCode		nvarchar(200)='',
	@ExtraField1 	nvarchar(200)='',
	@ExtraField2	nvarchar(200)='',
	@ExtraField3 	nvarchar(200)='',
	@ExtraField4	nvarchar(200)='',
	@ExtraField5 	nvarchar(200)='',
	@MasterCode 	nvarchar(200)='',
	@SearchLstLyr	bit=1,
	@ShowCodeClosed	bit=0,
	@MatchCase		bit=0,
	@OnlyExists		bit=0 
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

	if @OnlyExists='True'
		set @StrWhareIn+=' AND  (H.GoodsID IN (SELECT GoodsID FROM inv.tblStorageDocsDtl where StoreID='''+@POSStoreID+''' GROUP BY GoodsID HAVING SUM(GoodsQuantity * EnterKind)>0))  '

	if @ShowCodeClosed='False'
		set @StrWhareIn+=' AND  H.CodeClosed = ''False''' 

	if @SearchLstLyr='True'
	begin

		Declare @Len as int

		select @Len=Layer1+Layer2	+Layer3	+Layer4	+Layer5	+Layer6	+Layer7	+Layer8	+Layer9
		from pub.tblCodeLayer
		where TableName ='inv.tblGoods'	and PartNumber=1

		set @StrWhareIn+=' AND LEN(H.GoodsID)='+Str(@Len)+' ' 
	end

	if @MatchCase='True'
	begin
		if @GoodsName<>'' --AND  REPLACE (D.GoodsName,' ','') LIKE N'%1%'   
			set @StrWhareIn+=' and REPLACE (D.GoodsName,'' '','''') LIKE N''%'+@GoodsName+'%'' '	
		if @TechnicalNo<>'' 
			set @StrWhareIn+=' and H.TechnicalNo LIKE N''%'+@TechnicalNo+'%'''	
		if @TechnicalSp<>'' 
			set @StrWhareIn+=' and H.TechnicalSpecifications LIKE N''%'+@TechnicalSp+'%'''	
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
		if @MasterCode<>'' 
			set @StrWhareIn+=' and H.MasterCode LIKE N''%'+@MasterCode+'%'''	
	end
	else
		begin
		if @GoodsName<>'' --AND  REPLACE (D.GoodsName,' ','') LIKE N'%1%'   
			set @StrWhareIn+=' and upper(REPLACE (D.GoodsName,'' '','''')) LIKE N''%'+Upper(@GoodsName)+'%'' '	
		if @TechnicalNo<>'' 
			set @StrWhareIn+=' and upper(H.TechnicalNo) LIKE N''%'+Upper(@TechnicalNo)+'%'''	
		if @TechnicalSp<>'' 
			set @StrWhareIn+=' and upper(H.TechnicalSpecifications) LIKE N''%'+Upper(@TechnicalSp)+'%'''	
		if @BarCode<>'' 
			set @StrWhareIn+=' and upper(H.BarCode) LIKE N''%'+Upper(@BarCode)+'%'''	
		if @ExtraField1<>''
			set @StrWhareIn+=' and upper(H.ExtraField1) LIKE N''%'+Upper(@ExtraField1)+'%'''	
		if @ExtraField2<>''
			set @StrWhareIn+=' and upper(H.ExtraField2) LIKE N''%'+Upper(@ExtraField2)+'%'''	
		if @ExtraField3>'' 
			set @StrWhareIn+=' and upper(H.ExtraField3) LIKE N''%'+Upper(@ExtraField3)+'%'''	
		if @ExtraField4<>''
			set @StrWhareIn+=' and upper(H.ExtraField4) LIKE N''%'+Upper(@ExtraField4)+'%'''	
		if @ExtraField5<>''
			set @StrWhareIn+=' and upper(H.ExtraField5) LIKE N''%'+Upper(@ExtraField5)+'%'''	
		if @MasterCode<>'' 
			set @StrWhareIn+=' and upper(H.MasterCode) LIKE N''%'+Upper(@MasterCode)+'%'''	
	end

	if isnull(@Take,0)=0
		set @Take=1

	set @StrSelect=' select   Count(*)over () TotalCount, H.GoodsID,MasterCode,TechnicalNo,BarCode,TechnicalSpecifications
					,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5
					, UnitID,inv.funGetUnitName(UnitID,1) UnitName ,isnull(D.GoodsName,'''') GoodsName 
					,[sal].[funGetGoodsAmountSaleType](H.GoodsID,'''','''','''+@PosSaleType+''',1,0,0) SalePrice
					,ISNULL(CAST((SELECT SUM(GoodsQuantity*EnterKind) FROM inv.tblStorageDocsDtl SD WHERE SD.GoodsID=D.GoodsID  and SD.StoreID='''+@POSStoreID+''') AS Float),0) GoodsQuantity
						from   inv.tblGoods H
						Left Join inv.tblGoodsDtl D on D.GoodsID=H.GoodsID and D.LanguageID=1
						where 1= 1 '

	if isnull(@StrWhare,'')<>''
		set @StrSelect +=' and ' +@StrWhare 

	if isnull(@StrWhareIn,'')<>''
		set @StrSelect +=' and ' + @StrWhareIn

		
	set @StrSelect += ' Order by  H.GoodsID
						OFFSET ' +str(@Skip) +' Rows 
						FETCH NEXT ' +Str(@Take) +' Rows ONLY '
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
--7- قسمتي از نام کالا
--8- شماره فني
--9- مشخصات فني
--10- بارکد
--11- فیلد اضافی1
--12- فیلد اضافی2
--13- فیلد اضافی3
--14- فیلد اضافی4
--15- فیلد اضافی5
--16- كد كارفرما
--17- جستجو فقط از لایه آخر
--18- نمایش کدهای غیر فعال
--19- حساس به حروف بزرگ و کوچک
--20- فقط کالاهای دارای موجودی

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
