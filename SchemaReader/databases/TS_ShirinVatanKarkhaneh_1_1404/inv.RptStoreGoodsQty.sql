USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Jafari	
-- Create date   : 1396/06/22
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : گزارش موجودی کالا ها به تفکیک انبار
-- ==============================================
Create PROCEDURE [inv].[RptStoreGoodsQty]
	@ExtraParams		NVarChar(Max) = '',
	@RepOptions			VarChar(20) = '111' ,-- bit array	
	@RepInfo			NVarChar(100) = '1@1@1'
	
WITH ENCRYPTION
AS
---- Declarations ---------------
Declare @StrSelect			NVarChar(max);
Declare @StrFrom			NVarChar(max);
Declare @StrWhereH			NVarChar(max);
Declare @StrWhereD			NVarChar(max);


DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;
DECLARE	@UserID		Int;
DECLARE	@UserIsAdmin bit;

DECLARE	@NotShowZeroQty bit;
Declare @StoreID varchar(20)
Declare @StoreName nvarchar(200)
Declare @GoodsID varchar(20)
Declare @Stores varchar(max)
Declare @Stores2 varchar(max)
Declare @StoresSum varchar(max)
DECLARE	@Round		Int;
DECLARE	@DocDateTo			Char(10) 
SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	----------------------------------------------------

SET @StoreID			    = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
SET @GoodsID			    = LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
SET @DocDateTo			    = LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
SET @NotShowZeroQty			    = LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
set @Stores =''
set @Stores2 =''
set @StoresSum =''
set @StrWhereH=''
set @StrWhereD=''
IF (@StoreID > 0)
		SET @StrWhereH = @StrWhereH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @StoreID, 'a.StoreID')
	IF (@GoodsID > 0)
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @GoodsID, 'GoodsID')
	
If (@DocDateTo Is Not Null  and  LTRIM(rtrim(@DocDateTo ))<>'')
begin
		SET @StrWhereH = @StrWhereH + ' AND (DocDate <= ''' + @DocDateTo + ''')'
		SET @StrWhereD = @StrWhereD + ' AND (DocDate <= ''' + @DocDateTo + ''')'
end

	set @Round = 1;

	select @Round = SettingValue
	from pub.tblSettings
	where SettingKey = 'QuantityDecimals'


		BEGIN TRY
			DROP TABLE ##tblStores
		END TRY
		BEGIN CATCH
		END CATCH
	
	CREATE TABLE ##tblStores
	(		StoreID VarChar(20) ,
			StoreName nVarChar(200)
	)
	
	set @StrSelect='   insert into ##tblStores select  Distinct a.StoreID  , b.StoreName From inv.tblStorageDocsDtl a inner join inv.tblStoresDtl b on a.StoreID =b.StoreID   and b.LanguageID=1 where isnull(a.StoreID,'''') <>'''' ' + @StrWhereH +' order by a.StoreID'
	print @StrSelect
	
	Exec sp_executesql @StrSelect; 


-- select StoreID from #tblStores 
 
Declare	curStoreID CURSOR For 
 select StoreID,StoreName from ##tblStores 

Open  curStoreID; 

Fetch NEXT From curStoreID Into @StoreID,@StoreName

While (@@Fetch_Status = 0)
	BEGIN
	set @Stores=@Stores+',['+@StoreID+']'
	set @StoresSum=@StoresSum+'+isnull(['+@StoreID+'],0)'
	set @Stores2=@Stores2+', cast (isnull(['+@StoreID+'],0) as float) as ['+ @StoreName+' ' +@StoreID+ ' ] '
	--set @Stores2=@Stores2+', ['+@StoreID+'] '
	
	Fetch NEXT From curStoreID Into @StoreID,@StoreName
	END

Close curStoreID;  
Deallocate curStoreID; 

--Select @Stores,@Stores2

	if LEN(@Stores)>1
		set  @Stores= SUBSTRING(@Stores,2,LEN(@Stores)-1)
	if LEN(@StoresSum)>1
	begin
		set  @StoresSum= SUBSTRING(@StoresSum,2,LEN(@StoresSum)-1)
		set @StoresSum= ' cast ('+@StoresSum+' as float) '
	end

if LEN(@Stores)>1
set  @Stores2= SUBSTRING(@Stores2,2,LEN(@Stores2)-1)

		
SET @StrSelect = '
select GoodsID [کد کالا],pub.funGetGoodsName (GoodsID,'+@LangID +')  [نام کالا],'+@Stores2+' ,'+@StoresSum+' [مجموع]      from
		(select GoodsID,'+@Stores+' from
		( 
			select GoodsID, StoreID ,  Qty
			from
			(
				select GoodsID, StoreID , sum( GoodsQuantity*EnterKind) Qty  from inv.tblStorageDocsDtl where 1=1 '+@StrWhereD+'
				GROUP BY  GoodsID,StoreID 
			) T
		) 
		P	PIVOT 
			(
				Sum(P.Qty)
				for P.StoreID In ('+@Stores+')--([0101],[0102],[0109],[0110],[0111],[0112],[0113],[0114])
			) AS PVT 
)a	'
if @NotShowZeroQty=1
SET @StrSelect = @StrSelect + ' where '+@StoresSum+'>0'

	print @StrSelect
	
	Exec sp_executesql @StrSelect; 
GO
