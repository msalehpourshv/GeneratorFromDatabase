USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NotOK ========================
-- Author        : jafari	
-- Create date   : 1400/10/19
-- Viewed By	 : 
-- Last Modified : 
-- Description   :  مراحل تولید محصول
-- =============================================
Create PROCEDURE pln.SpCheckLoop
  @GoodsID varchar(20)  
 WITH ENCRYPTION
AS

BEGIN


DECLARE @RET AS NVarChar(Max) 
DECLARE @PID AS NVarChar(50) 
   DECLARE @GID AS NVarChar(50) 
   DECLARE @SerialNo AS Int 
   DECLARE @RowNo AS Int 
   DECLARE @RETSTR AS NVarChar(500)
   DECLARE @Tree AS NVarChar(500)
 
    
	  DECLARE @Levels as int
	  DECLARE @Loop as int=1
	  DECLARE @Loop2 as int=1
 
 
 	BEGIN TRY
			DROP TABLE #tblFormulasDtl
			DROP TABLE #tblFormulasDtl2
		END TRY
		BEGIN CATCH
		END CATCH

 SELECT	Distinct ProductID, GoodsID, 0 Levels ,cast(ProductID+'-->'+GoodsID as NVarChar(Max))  Tree
 into #tblFormulasDtl 
	FROM	prd.tblFormulasDtl 
	WHERE ProductID =@GoodsID


 SELECT	Distinct ProductID, GoodsID, 0 Levels,cast(ProductID+'-->'+GoodsID as NVarChar(Max))  Tree
 into #tblFormulasDtl2 
	FROM	prd.tblFormulasDtl 
	WHERE ProductID =@GoodsID

	set @RET=@GoodsID

WHILE  @Loop>0 and @Loop2<25
begin
	
	select @Loop=Count(*) from #tblFormulasDtl 

	SELECT	top 1 @PID= ProductID, @GID=GoodsID,@Levels=Levels, @Tree=Tree
	FROM	#tblFormulasDtl	
	order by Levels,ProductID, GoodsID

	--select @PID,@GID,@Levels

	 if (select  Count(*) 	FROM	prd.tblFormulasDtl 	WHERE ProductID =@GID 	and GoodsID in (SELECT  ProductID	FROM	#tblFormulasDtl2	)) >0
		begin
			select  top 1 @Tree+'-->'+GoodsID  GoodsID	FROM	prd.tblFormulasDtl 	WHERE ProductID =@GID 	and GoodsID in (SELECT  ProductID	FROM	#tblFormulasDtl2)
			return 
		end 

		delete from #tblFormulasDtl  
		where  ProductID=@PID and  GoodsID=@GID and Levels=@Levels and  @Tree=Tree

	insert into #tblFormulasDtl 
	select  Distinct ProductID, GoodsID, @Levels+1 Levels,@Tree+'-->'+ GoodsID 
	--into #tblFormulasDtl 
	FROM	prd.tblFormulasDtl 
	WHERE ProductID =@GID 
	 
	 
	insert into #tblFormulasDtl2 
	select  Distinct ProductID, GoodsID, @Levels+1 Levels,@Tree+'-->'+ GoodsID 
	--into #tblFormulasDtl 
	FROM	prd.tblFormulasDtl 
	WHERE ProductID =@GID 


set @Loop2+=1
end 


select '' GoodsID


end 
GO
