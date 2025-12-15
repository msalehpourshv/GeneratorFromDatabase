USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : jafari
-- Create date   : 1395/10/18
-- Viewed By	 : 
-- Last Modified : 1395/10/18
-- Description   : 
-- =============================================
Create PROCEDURE  inv.Insert2GoodsUserPrice
	@GoodsID as varchar(20)='',
	@StoreID as varchar(20)='',
	@UserPrice as bigint=0,
	@CurrentDate as char(10)='', 
	@Inserttype as Integer = 0,
	@Qty as Integer=0,
	@ExtraParams	NVarChar(Max) = ''
WITH ENCRYPTION
AS
BEGIN

Declare @StrSelect	NVarChar(max);
Declare @ID			BigInt = 0
Declare @MaxID		BigInt = 0
Declare @Active		Bit
Declare @ExpirDate as Char(10)
Declare @GoodsWeight as float
Declare @GoodsHeight as float
Declare @GoodsWidth as float
Declare @GoodsLength as float
Declare @ExtraField1 as NVarChar(200)
Declare @ExtraField2 as NVarChar(200)
Declare @ExtraField3 as NVarChar(200)
Declare @ExtraField4 as NVarChar(200)
Declare @ExtraField5 as NVarChar(200)


	SET @ExpirDate			= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @GoodsWeight		= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
	SET @GoodsHeight		= LTrim(pub.funSplitString(@ExtraParams, '@', 3));
	SET @GoodsWidth			= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
	SET @GoodsLength		= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
	SET @ExtraField1		= LTrim(pub.funSplitString(@ExtraParams, '@', 6));
	SET @ExtraField2		= LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 
	SET @ExtraField3		= LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
	SET @ExtraField4  	    = LTrim(pub.funSplitString(@ExtraParams, '@', 9));
	SET @ExtraField5  	    = LTrim(pub.funSplitString(@ExtraParams, '@', 10)); 
	
	if @ExpirDate	 is null set @ExpirDate	=''
	if @GoodsWeight is null set @GoodsWeight=0
	if @GoodsHeight is null set @GoodsHeight=0
	if @GoodsWidth	 is null set @GoodsWidth=0
	if @GoodsLength is null set @GoodsLength=0
	if @ExtraField1 is null set @ExtraField1=''
	if @ExtraField2 is null set @ExtraField2=''
	if @ExtraField3 is null set @ExtraField3=''
	if @ExtraField4 is null set @ExtraField4=''
	if @ExtraField5 is null set @ExtraField5=''
	
	

SELECT @Active= ActiveUserPrice|ActiveExpirDate|ActiveGoodsWeight|ActiveGoodsHeight|ActiveGoodsWidth|ActiveGoodsLength|ActiveExtraField1|ActiveExtraField2|ActiveExtraField3|ActiveExtraField4|ActiveExtraField5   FROM inv.tblGoods WHERE GoodsID=@GoodsID 

if  @Active=0
begin
	    return 
end

if @Inserttype = 0 or  @Inserttype = 1   ---           ورود اطلاعات
begin
		SELECT @ID = COUNT(*) FROM inv.tblGoodsUserPrice
		WHERE GoodsID = @GoodsID
		and ( @UserPrice =0 or UserPrice = @UserPrice )
		and ( @ExpirDate ='' or UExpirDate	=@ExpirDate	)
		and ( @GoodsWeight =0 or UGoodsWeight=@GoodsWeight)
		and ( @GoodsHeight =0 or UGoodsHeight=@GoodsHeight)
		and ( @GoodsWidth =0 or UGoodsWidth	=@GoodsWidth)	
		and ( @GoodsLength =0 or UGoodsLength=@GoodsLength)
		and ( @ExtraField1 ='' or UExtraField1=@ExtraField1)
		and ( @ExtraField2 ='' or UExtraField2=@ExtraField2)
		and ( @ExtraField3 ='' or UExtraField3=@ExtraField3)
		and ( @ExtraField4 ='' or UExtraField4=@ExtraField4)
		and ( @ExtraField5 ='' or UExtraField5= @ExtraField5)

        If @ID <= 0
        begin

			CREATE TABLE #GoodsUserPrice (ID  INT)
			INSERT INTO #GoodsUserPrice
			EXEC [inv].[SpGetMaxUserPriceID]

			SELECT @MaxID=ID FROM #GoodsUserPrice

			SELECT @MaxID = ISNULL(MAX(ID),0) + 1 FROM inv.tblGoodsUserPrice
		        
			insert into inv.tblGoodsUserPrice (ID, GoodsID, UserPrice, DocDate,UExpirDate ,UGoodsWeight,UGoodsHeight,UGoodsWidth	,UGoodsLength,UExtraField1,UExtraField2,UExtraField3,UExtraField4,UExtraField5)
								 Select @MaxID, @GoodsID ,@UserPrice ,@CurrentDate,@ExpirDate	,@GoodsWeight,@GoodsHeight,@GoodsWidth,@GoodsLength,@ExtraField1,@ExtraField2,@ExtraField3,@ExtraField4,@ExtraField5            
             
		end
      	SELECT ID, GoodsID, UserPrice, DocDate, 
			   isnull((Select Sum(GoodsQuantity * EnterKind) from inv.tblStorageDocsDtl b where a.GoodsID=b.GoodsID and a.ID=b.UserPriceID and (@StoreID='' OR (@StoreID<>'' AND b.StoreID=@StoreID ))),0) GoodsQuantity
				 ,UExpirDate ,UGoodsWeight,UGoodsHeight,UGoodsWidth	,UGoodsLength,UExtraField1,UExtraField2,UExtraField3,UExtraField4,UExtraField5
				 FROM inv.tblGoodsUserPrice a
                  WHERE GoodsID = @GoodsID
		and ( @UserPrice =0 or UserPrice = @UserPrice )
		and ( @ExpirDate ='' or UExpirDate	=@ExpirDate	)
		and ( @GoodsWeight =0 or UGoodsWeight=@GoodsWeight)
		and ( @GoodsHeight =0 or UGoodsHeight=@GoodsHeight)
		and ( @GoodsWidth =0 or UGoodsWidth	=@GoodsWidth)	
		and ( @GoodsLength =0 or UGoodsLength=@GoodsLength)
		and ( @ExtraField1 ='' or UExtraField1=@ExtraField1)
		and ( @ExtraField2 ='' or UExtraField2=@ExtraField2)
		and ( @ExtraField3 ='' or UExtraField3=@ExtraField3)
		and ( @ExtraField4 ='' or UExtraField4=@ExtraField4)
		and ( @ExtraField5 ='' or UExtraField5= @ExtraField5)
		order by DocDate Desc
        return 
end

if @Inserttype=-1    ----- بررسی موجود 
begin
		if @UserPrice=  0      --    بررسی موجود بودن و  
		begin
			select @ID= COUNT(*)  from  inv.tblGoodsUserPrice a
					where GoodsID=@GoodsID  
					and isnull((Select Sum(GoodsQuantity*EnterKind) from inv.tblStorageDocsDtl b where a.GoodsID=b.GoodsID and a.ID=b.UserPriceID and (@StoreID='' OR (@StoreID<>'' AND b.StoreID=@StoreID ))),0)>=@Qty --and DocDate<=@CurrentDate 
						If @ID <= 0 
						select ID, GoodsID, UserPrice, DocDate, 
						 isnull((Select Sum(GoodsQuantity*EnterKind) from inv.tblStorageDocsDtl b where a.GoodsID=b.GoodsID and a.ID=b.UserPriceID and (@StoreID='' OR (@StoreID<>'' AND b.StoreID=@StoreID ))),0) GoodsQuantity
						 ,UExpirDate ,UGoodsWeight,UGoodsHeight,UGoodsWidth	,UGoodsLength,UExtraField1,UExtraField2,UExtraField3,UExtraField4,UExtraField5
				 from  inv.tblGoodsUserPrice a
							where GoodsID=@GoodsID and UserPrice=(select UserPrice From inv.tblGoods  where GoodsID=@GoodsID)
						else
						select top 1  ID, GoodsID, UserPrice, DocDate, 
						 isnull((Select Sum(GoodsQuantity*EnterKind) from inv.tblStorageDocsDtl b where a.GoodsID=b.GoodsID and a.ID=b.UserPriceID and (@StoreID='' OR (@StoreID<>'' AND b.StoreID=@StoreID ))),0) GoodsQuantity
				 ,UExpirDate ,UGoodsWeight,UGoodsHeight,UGoodsWidth	,UGoodsLength,UExtraField1,UExtraField2,UExtraField3,UExtraField4,UExtraField5
						from  inv.tblGoodsUserPrice a
							where GoodsID=@GoodsID  
							and isnull((Select Sum(GoodsQuantity*EnterKind) from inv.tblStorageDocsDtl b where a.GoodsID=b.GoodsID and a.ID=b.UserPriceID and (@StoreID='' OR (@StoreID<>'' AND b.StoreID=@StoreID ))),0)>=@Qty --and DocDate<=@CurrentDate 
							order by DocDate 
			 return 
      
		end
		else
		begin
		select top 1  ID, GoodsID, UserPrice, DocDate, 
						 isnull((Select Sum(GoodsQuantity*EnterKind) from inv.tblStorageDocsDtl b where a.GoodsID=b.GoodsID and a.ID=b.UserPriceID and (@StoreID='' OR (@StoreID<>'' AND b.StoreID=@StoreID ))),0) GoodsQuantity
				 ,UExpirDate ,UGoodsWeight,UGoodsHeight,UGoodsWidth	,UGoodsLength,UExtraField1,UExtraField2,UExtraField3,UExtraField4,UExtraField5
					  					    from  inv.tblGoodsUserPrice a
							where GoodsID=@GoodsID 
							and ( @UserPrice =0 or UserPrice = @UserPrice )
		and ( @ExpirDate ='' or UExpirDate	=@ExpirDate	)
		and ( @GoodsWeight =0 or UGoodsWeight=@GoodsWeight)
		and ( @GoodsHeight =0 or UGoodsHeight=@GoodsHeight)
		and ( @GoodsWidth =0 or UGoodsWidth	=@GoodsWidth)	
		and ( @GoodsLength =0 or UGoodsLength=@GoodsLength)
		and ( @ExtraField1 ='' or UExtraField1=@ExtraField1)
		and ( @ExtraField2 ='' or UExtraField2=@ExtraField2)
		and ( @ExtraField3 ='' or UExtraField3=@ExtraField3)
		and ( @ExtraField4 ='' or UExtraField4=@ExtraField4)
		and ( @ExtraField5 ='' or UExtraField5= @ExtraField5)
			
			order by DocDate Desc
			return
		end
		
	END
END
GO
