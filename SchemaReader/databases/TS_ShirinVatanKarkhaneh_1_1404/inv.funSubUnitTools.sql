USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\jafari
-- Create date   : 1399/10/24
-- Viewed By	 : 
-- Last Modified : 
-- Modifier		 : 
-- Description	 : نسبت واحد فرعی واصلی
-- ==============================================
Create FUNCTION [inv].[funSubUnitTools]
(
	@GoodsID	varchar(20),
	@Qty		Float,
	@CallType	int
)
returns Nvarchar(100)
WITH ENCRYPTION
AS
Begin
declare @UnitName1	nvarchar(50)
declare @UnitName2	nvarchar(50)
declare @UnitName3	nvarchar(50)
declare @UnitName4	nvarchar(50)
declare @UnitID1	varchar(20)
declare @UnitID2	varchar(20)
declare @UnitID3	varchar(20)
declare @UnitID4	varchar(20)
declare @Quantity1	float
declare @Quantity2	float
declare @Quantity3	float
declare @Quantity4	float

declare @UnitValue	float
declare @MainUnitValue	float

---- @CallType=1 or @CallType=11 or @CallType=12 or @CallType=13 معادل واحد اصلی و نام واحد اصلی   
---- @CallType=2 or @CallType=21 or @CallType=22 or @CallType=23   معادل واحد فرعی و نام واحد فرعی 
---- @CallType=3 or @CallType=31 or @CallType=32 or @CallType=33  معادل رند شده واحد بزرگتر و نام واحد 
---- @CallType=4 or @CallType=41 or @CallType=42 or @CallType=43  معادل رند شده واحد کوچکتر و نام واحد 
 
select @Quantity1=@Qty
select @UnitID1=UnitID from inv.tblGoods  where GoodsID=@GoodsID	
SELECT @UnitName1=UnitName FROM         inv.tblUnitsDtl where  UnitID=@UnitID1 and  LanguageID =1

 if @CallType=2 or @CallType=21 or @CallType=22 or @CallType=23
 begin 
 	SELECT   @UnitID2= isnull(SubUnitID,'') ,@UnitValue=UnitValue, @MainUnitValue=MainUnitValue--, ShowInInvoice, UnitID
	FROM     inv.tblSubUnitsDtl
	where	GoodsID=@GoodsID	and ShowInInvoice=1
	if @UnitID2 is not Null
	begin
		select  @Quantity2=@Quantity1*@UnitValue/@MainUnitValue
		SELECT   @UnitName2=UnitName FROM         inv.tblUnitsDtl where  UnitID=@UnitID2 and  LanguageID =1		
		if @CallType=2 		
			return cast(@Quantity2 as varchar(15))+'@'+@UnitID2+'@'+@UnitName2
		if @CallType=21 		
			return cast(@Quantity2 as varchar(15))
		if @CallType=22 		
			return  @UnitID2
		if @CallType=23
			return @UnitName2		
	end 
  end
 if @CallType=3 or @CallType=31 or @CallType=32 or @CallType=33
 begin 
 	SELECT   @UnitID3= SubUnitID ,@UnitValue=UnitValue, @MainUnitValue=MainUnitValue--, ShowInInvoice, UnitID
	FROM     inv.tblSubUnitsDtl
	where	GoodsID=@GoodsID	and ShowInInvoice=1
	if @UnitID3 is not Null
	begin
		if @MainUnitValue>@UnitValue
		begin
			select  @Quantity4=@Quantity1*@UnitValue/@MainUnitValue
			set @Quantity3=cast (@Quantity4 as int)
			SELECT   @UnitName3=UnitName FROM         inv.tblUnitsDtl where  UnitID=@UnitID3 and  LanguageID =1
			 if @CallType=3 
				return cast(@Quantity3 as varchar(15))+'@'+@UnitID3+'@'+@UnitName3
			 if @CallType=31 
				return cast(@Quantity3 as varchar(15))
			 if @CallType=32 
				return @UnitID3
			 if @CallType=33 
				return @UnitName3		 
		end 
		else 
		begin			
			set @Quantity3=cast (@Quantity1 as int)			
			 if @CallType=3 
				 return cast(@Quantity3 as varchar(15))+'@'+@UnitID1+'@'+@UnitName1
			 if @CallType=31 
				return cast(@Quantity3 as varchar(15))
			 if @CallType=32 
				return @UnitID1
			 if @CallType=33 
				return @UnitName1	
		end 
	end 	
  end
 if @CallType=4 or @CallType=41 or @CallType=42 or @CallType=43
 begin 
 	SELECT   @UnitID4= SubUnitID ,@UnitValue=UnitValue, @MainUnitValue=MainUnitValue--, ShowInInvoice, UnitID
	FROM     inv.tblSubUnitsDtl
	where	GoodsID=@GoodsID	and ShowInInvoice=1
	if @UnitID4 is not Null
	begin
		if @MainUnitValue>@UnitValue
		begin		
			select  @Quantity4=@Quantity1*@UnitValue/@MainUnitValue
			set @Quantity3=cast (@Quantity4 as int)		
			set @Quantity4=@Quantity4 -	@Quantity3		
			set @Quantity4=@Quantity4*@MainUnitValue/@UnitValue			
			if @CallType=4
				return cast(@Quantity4 as varchar(15))+'@'+@UnitID1+'@'+@UnitName1			 
			if @CallType=41
				return cast(@Quantity4 as varchar(15))
			if @CallType=42
				return @UnitID1
			if @CallType=43
				return @UnitName1			 
			
		end 
		else 
		begin			
			set @Quantity4=cast (@Quantity1 as int)		
			set @Quantity4=@Quantity1-@Quantity4 
			set @Quantity4=@Quantity4 *@UnitValue	/@MainUnitValue					
			SELECT   @UnitName4=UnitName FROM         inv.tblUnitsDtl where  UnitID=@UnitID4 and  LanguageID =1			
			if @CallType=4
				return cast(@Quantity4 as varchar(15))+'@'+@UnitID4+'@'+@UnitName4
			if @CallType=41
				return cast(@Quantity4 as varchar(15))
			if @CallType=42
				return @UnitID4
			if @CallType=43
				return @UnitName4
		end 
	end 	
  end
	if @CallType<5
		return cast(@Quantity1 as varchar(15))+'@'+@UnitID1+'@'+@UnitName1
	if @CallType%10=1		
		return cast(@Quantity1 as varchar(15))
	if @CallType%10=2		
		return @UnitID1
	if @CallType%10=3		
		return @UnitName1

	return cast(@Quantity1 as varchar(15))+'@'+@UnitID1+'@'+@UnitName1

End
GO
