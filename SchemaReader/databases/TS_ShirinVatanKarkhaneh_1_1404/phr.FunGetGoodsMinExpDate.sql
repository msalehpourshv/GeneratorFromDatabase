USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- select [phr].[FunGetGoodsMinExpDate] ('1010003887')

CREATE FUNCTION [phr].[FunGetGoodsMinExpDate]
(
	@GoodsID VarChar(20)
	)
	RETURNS VarChar(10)
WITH ENCRYPTION
AS

Begin -- ====================================================




--Declare @GoodsID varchar(20)='1010003887'
Declare @ExpireDate varchar(10)=''
Declare @ExpireDateEnd varchar(10)=''
Declare @Counter Float=0
Declare @GoodsQuantity Float=0



select @Counter= isnull(sum(GoodsQuantity*EnterKind),0) from  inv.tblStorageDocsDtl d
where GoodsID=@GoodsID



declare  ExpDate cursor for   
	select  GoodsQuantity ,ExpireDate from  inv.tblStorageDocsDtl d
	where GoodsID=@GoodsID and EnterKind=1
	order by ExpireDate Desc

open ExpDate  
  
FETCH NEXT FROM ExpDate into @GoodsQuantity,@ExpireDate
  
WHILE @@FETCH_STATUS = 0  and @Counter>0
BEGIN 
set @Counter=@Counter-@GoodsQuantity
set @ExpireDateEnd=@ExpireDate

	FETCH NEXT FROM ExpDate into @GoodsQuantity,@ExpireDate
  
END   
  
close ExpDate  
deallocate ExpDate 
 
 
	
	Return @ExpireDateEnd

END -- ======================================================
GO
