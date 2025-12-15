USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : jafari
-- Create date   : 1395/11/16
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : 
-- =============================================
Create PROCEDURE pln.spDefaultStoreID	
	@GoodsID	Varchar(20),
	@SerialNo Int,
	@RowNo Int,
	@ExtraParams		NVarChar(Max) 
WITH ENCRYPTION
AS
Begin

Declare @AcceptStoreID	Varchar(20);
Declare @FailedStoreID	Varchar(20);
Declare @UsageStoreID	Varchar(20);
Declare @LossStoreID	Varchar(20);
Declare @ProducerAcntCode	Varchar(20);

Set @AcceptStoreID=''
Set @FailedStoreID=''
Set @UsageStoreID=''
Set @LossStoreID=''
Set @ProducerAcntCode=''

declare @LangID		Int
declare @ProductID	Varchar(20)
declare @FormulaNo	Int
declare	@StepDflt	int
declare	@FrmlDflt	int

SET @LangID			    = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
SET @ProductID			= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
SET @FormulaNo		    = LTrim(pub.funSplitString(@ExtraParams, '@', 3));
SET @StepDflt		    = LTrim(pub.funSplitString(@ExtraParams, '@', 4));
SET @FrmlDflt		    = LTrim(pub.funSplitString(@ExtraParams, '@', 5));
	
 
	
select @AcceptStoreID=DefaultStoreID
 from prd.tblFormulasDtl 
where ProductID=@ProductID and SerialNo=@FormulaNo and GoodsID=@GoodsID
---------------------------------tblProduceStepDtl-------------------------------
if @GoodsID<>''
begin
if @SerialNo<>0
 select  top 1 @AcceptStoreID= case  when @AcceptStoreID ='' then AcceptStoreID else @AcceptStoreID end ,@FailedStoreID=FailedStoreID,@UsageStoreID=UsageStoreID,@LossStoreID=LossStoreID 
	from pln.tblProduceStepDtl A 		
		inner join pln.tblProduceStepHdr H 	on H.ProductID=A.ProductID and H.SerialNo=A.SerialNo 
		Left join pln.tblProduceOrderDtl B	on B.ProductID=A.ProductID and B.StepNo=A.SerialNo 
	where A.ProductID   like @GoodsID  +'%' and   ((@StepDflt=1 and IsDefaultMethod=1 ) or   B.SerialNo=@SerialNo  )
else
 select  @AcceptStoreID= case  when @AcceptStoreID ='' then AcceptStoreID else @AcceptStoreID end ,@FailedStoreID=FailedStoreID,@UsageStoreID=UsageStoreID,@LossStoreID=LossStoreID 
	from pln.tblProduceStepDtl 
	where ProductID   like @GoodsID +'%' 
		and (ProduceStepID=(select max(ProduceStepID) from pln.tblProduceStepDtl  where (ProductID like @GoodsID +'%') ))
 --select @UsageStoreID,@AcceptStoreID,@FailedStoreID,@LossStoreID
----------------------------------tblGoodsStores------------------------------

if @UsageStoreID='' or @UsageStoreID is  null
	select @UsageStoreID=StoreID From  pln.tblGoodsStores where GoodsID like @GoodsID +'%' and StoreType=1 	
if @AcceptStoreID='' or @AcceptStoreID is  null
	select @AcceptStoreID=StoreID From  pln.tblGoodsStores where GoodsID  like @GoodsID +'%' and StoreType=2 	
if @FailedStoreID='' or @FailedStoreID is  null
	select @FailedStoreID=StoreID From  pln.tblGoodsStores where GoodsID like @GoodsID +'%' and StoreType=3 	
if @LossStoreID='' or @LossStoreID is  null
	select @LossStoreID=StoreID From  pln.tblGoodsStores where GoodsID like @GoodsID +'%' and StoreType=4 	
if @ProducerAcntCode='' or @ProducerAcntCode is  null
	select @ProducerAcntCode=StoreID From  pln.tblGoodsStores where GoodsID like @GoodsID +'%' and StoreType=21 	
--select @UsageStoreID,@AcceptStoreID,@FailedStoreID,@LossStoreID
-------------------------------tblSettings---------------------------------
if @AcceptStoreID='' or @AcceptStoreID is  null
	select @AcceptStoreID=SettingValue From  pub.tblSettings where SettingKey='PlnTskProduceDefaultStore'	
if @FailedStoreID='' or @FailedStoreID is  null
	select @FailedStoreID=SettingValue From  pub.tblSettings where SettingKey='PlnTskFailedDefaultStore'	
if @UsageStoreID='' or @UsageStoreID is  null
	select @UsageStoreID=SettingValue From  pub.tblSettings where SettingKey='PlnTskReturnDefaultStore'	
if @LossStoreID='' or @LossStoreID is  null
	select @LossStoreID=SettingValue From  pub.tblSettings where SettingKey='PlnTskLossDefaultStore'	
	    	   
end     	    	   
Select   @GoodsID GoodsID, pub.funGetGoodsName(@GoodsID,@LangID) GoodsName
, @AcceptStoreID AcceptStoreID, @FailedStoreID FailedStoreID,@UsageStoreID UsageStoreID,@LossStoreID 	 LossStoreID
 ,pub.GetStoreName(@AcceptStoreID,@LangID) AcceptStoreName
 ,pub.GetStoreName(@FailedStoreID,@LangID) FailedStoreName
 ,pub.GetStoreName(@UsageStoreID,@LangID) UsageStoreName
 ,pub.GetStoreName(@LossStoreID,@LangID) LossStoreName
 ,@ProducerAcntCode ProducerAcntCode, pub.GetCodeName(@ProducerAcntCode,@LangID) AS ProducerName
End
GO
