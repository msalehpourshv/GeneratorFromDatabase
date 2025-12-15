USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1399/05/15
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : تابعی برای بدس آوردن مقادیر مختلف براساس واحد های مختلف
-- =============مقادیر خروجی=================================
--واحد اصلی 
--مقدار واحد اصلی
--واحد فرعی 
--مقدار واحد فرعی
--واحد بزرگتر 
--مقدار واحد بزرگتر بصورت رند
--واحد کوچکتر 
--مقدار واحد کوچکتر مانده--
Create FUNCTION inv.funGetUnitValueWithAnyValue
(
@GoodsID	varchar (20)='13561014',
@SubUnitID	varchar (20)='33',
@SubUnitQuantity	Float=4000
)RETURNS	@tbl Table 
(MainUnitID varchar (20)
,GoodsQuantity Float
,SubUnitIDShowInInvoice varchar (20)
,SubUnitQuantityShowInInvoice Float
,SubUnitIDRemain1 varchar (20)
,SubUnitQuantityRemain1  Float
,SubUnitIDRemain2 varchar (20)
,SubUnitQuantityRemain2 Float
)
WITH ENCRYPTION
AS

BEGIN	
	
--declare @GoodsID						varchar (20)='51070423012002'
--declare @SubUnitID						varchar (20)='12'
--declare @GoodsID						varchar (20)='51070303002001'

--declare @SubUnitID						varchar (20)='09'
--declare @SubUnitQuantity				Float=40.25

declare @MainUnitID						varchar (20)
declare @GoodsQuantity					Float=0


declare @SubUnitIDShowInInvoice			varchar (20)=''
declare @SubUnitQuantityShowInInvoice	Float=0

declare @SubUnitIDRemain1				varchar (20)=''
declare @SubUnitQuantityRemain1			Float=0

declare @SubUnitIDRemain2				varchar (20)=''
declare @SubUnitQuantityRemain2			Float=0


declare @Inv_MultiGoodsID as bit
	select @Inv_MultiGoodsID =SettingValue from pub.tblSettings where SettingKey='Inv_MultiGoodsID'
	set @Inv_MultiGoodsID=isnull(@Inv_MultiGoodsID,0)
	
if @Inv_MultiGoodsID=0
begin

	select @MainUnitID=UnitID , @GoodsQuantity=inv.funGetGoodsQuantityFromSubUnit(@GoodsID,@SubUnitID,@SubUnitQuantity) 
	from inv.tblGoods where GoodsID = @GoodsID

	select @SubUnitIDShowInInvoice=SubUnitID, @SubUnitQuantityShowInInvoice =@GoodsQuantity*UnitValue/MainUnitValue
	from inv.tblSubUnitsDtl S
	where GoodsID = @GoodsID And ShowInInvoice = 1

	select
	 @SubUnitQuantityRemain1=Case when MainUnitValue<UnitValue then  cast( @GoodsQuantity as int ) else cast( @SubUnitQuantityShowInInvoice as int )   end 
	 ,@SubUnitIDRemain1=Case when MainUnitValue<UnitValue then  @MainUnitID else @SubUnitIDShowInInvoice   end 
	 
	, @SubUnitQuantityRemain2=Case when MainUnitValue<UnitValue then inv.funGetSubUnitFromGoodsQuantity(@GoodsID,@SubUnitIDShowInInvoice,@GoodsQuantity-cast( @GoodsQuantity as int )) else 
																	 inv.funGetGoodsQuantityFromSubUnit(@GoodsID,@SubUnitIDShowInInvoice,@SubUnitQuantityShowInInvoice-cast( @SubUnitQuantityShowInInvoice as int ) )  
																	 end 
	 ,@SubUnitIDRemain2=Case when MainUnitValue<UnitValue then   @SubUnitIDShowInInvoice  ELSE @MainUnitID end 
	from inv.tblSubUnitsDtl S
	where GoodsID = @GoodsID And ShowInInvoice =1


	insert into @tbl
	select 	@MainUnitID MainUnitID,@GoodsQuantity GoodsQuantity
	,@SubUnitIDShowInInvoice SubUnitIDShowInInvoice,@SubUnitQuantityShowInInvoice SubUnitQuantityShowInInvoice
	, case when @SubUnitIDRemain1='' then @MainUnitID else @SubUnitIDRemain1 end  SubUnitIDRemain1
	, case when @SubUnitIDRemain1='' then @GoodsQuantity else @SubUnitQuantityRemain1 end  SubUnitQuantityRemain1
	, @SubUnitIDRemain2 SubUnitIDRemain2,@SubUnitQuantityRemain2 SubUnitQuantityRemain2
end
else
begin



	declare @UnitPart as bit
	select @UnitPart =SettingValue from pub.tblSettings where SettingKey='UnitPart'


Declare @Part1Start	TinyInt,@Part1Len	TinyInt;
Declare @Part2Start	TinyInt,@Part2Len	TinyInt;
Declare @Part3Start	TinyInt,@Part3Len	TinyInt;
Declare @Part4Start	TinyInt,@Part4Len	TinyInt;

		-------- LAYERS LEN CLAUSE -----------------------------------------------------------------------
	SELECT	@Part1Start = 1;
	SELECT	@Part1Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'inv.tblGoods') AND (PartNumber = 1)

	SELECT	@Part2Start = @Part1Start + @Part1Len + 1;
	SELECT	@Part2Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'inv.tblGoods') AND (PartNumber = 2)

	SELECT	@Part3Start = @Part2Start + @Part2Len + 1;
	SELECT	@Part3Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'inv.tblGoods') AND (PartNumber = 3)

	SELECT	@Part4Start = @Part3Start + @Part3Len + 1;
	SELECT	@Part4Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'inv.tblGoods') AND (PartNumber = 4)
	
	Declare @GoodsID2 as varchar(20)=''

	if @UnitPart=1
		set @GoodsID2=substring(@GoodsID,1,@Part1Len)
	if @UnitPart=2
		set @GoodsID2=substring(@GoodsID,1+@Part1Len,@Part2Len)
	if @UnitPart=3
		set @GoodsID2=substring(@GoodsID,1+@Part1Len+@Part2Len,@Part3Len)
	if @UnitPart=4
		set @GoodsID2=substring(@GoodsID,1+@Part1Len+@Part2Len+@Part3Len,@Part4Len)
select @MainUnitID=UnitID , @GoodsQuantity=inv.funGetGoodsQuantityFromSubUnit(@GoodsID,@SubUnitID,@SubUnitQuantity) 
from inv.tblGoods where GoodsID = @GoodsID2

select @SubUnitIDShowInInvoice=SubUnitID, @SubUnitQuantityShowInInvoice =@GoodsQuantity*UnitValue/MainUnitValue
from inv.tblSubUnitsDtl S
where GoodsID = @GoodsID And ShowInInvoice = 1

select
 @SubUnitQuantityRemain1=Case when MainUnitValue<UnitValue then  cast( @GoodsQuantity as int ) else cast( @SubUnitQuantityShowInInvoice as int )   end 
 ,@SubUnitIDRemain1=Case when MainUnitValue<UnitValue then  @MainUnitID else @SubUnitIDShowInInvoice   end 
 
, @SubUnitQuantityRemain2=Case when MainUnitValue<UnitValue then inv.funGetSubUnitFromGoodsQuantity(@GoodsID,@SubUnitIDShowInInvoice,@GoodsQuantity-cast( @GoodsQuantity as int )) else 
																 inv.funGetGoodsQuantityFromSubUnit(@GoodsID,@SubUnitIDShowInInvoice,@SubUnitQuantityShowInInvoice-cast( @SubUnitQuantityShowInInvoice as int ) )  
																 end 
 ,@SubUnitIDRemain2=Case when MainUnitValue<UnitValue then   @SubUnitIDShowInInvoice  ELSE @MainUnitID end 
from inv.tblSubUnitsDtl S
where GoodsID = @GoodsID And ShowInInvoice =1

	insert into @tbl

select --@SubUnitID,@SubUnitQuantity,
isnull(@MainUnitID,'') MainUnitID,isnull(@GoodsQuantity ,0)GoodsQuantity
,isnull(@SubUnitIDShowInInvoice ,'')SubUnitIDShowInInvoice,isnull(@SubUnitQuantityShowInInvoice  ,0)SubUnitQuantityShowInInvoice
, isnull(case when @SubUnitIDRemain1='' then @MainUnitID else @SubUnitIDRemain1 end ,'') SubUnitIDRemain1
,isnull( case when @SubUnitIDRemain1='' then @GoodsQuantity else @SubUnitQuantityRemain1 end ,0)  SubUnitQuantityRemain1
--UNION 
, isnull(@SubUnitIDRemain2,'') SubUnitIDRemain2,isnull(@SubUnitQuantityRemain2 ,0) SubUnitQuantityRemain2

end

RETURN 

 END
GO
