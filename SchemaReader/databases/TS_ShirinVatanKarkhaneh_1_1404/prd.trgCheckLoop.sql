USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ahmadnejad
-- Create date: 2008-01-22
-- Description:	Prevents Loop in formula
-- =============================================
Create TRIGGER [prd].[trgCheckLoop] 
   ON  [prd].[tblFormulasDtl] 
WITH ENCRYPTION 
   FOR INSERT, UPDATE
AS 
--============================== START TRIGGER CODE ===================================
BEGIN 
   SET NOCOUNT ON;
	DECLARE @StrMsg AS NVarChar(max) 
	declare @ProductID as varchar(Max)--='91040402001'
	declare @GoodsID as varchar(20)--='41040221002012'
	declare @OldGoodsID		VARCHAR(20) 
	
--return 
SELECT	@ProductID=ProductID, @GoodsID=GoodsID 
	FROM	inserted 

SELECT	@OldGoodsID=GoodsID
FROM	Deleted

IF @GoodsID	= @OldGoodsID
	RETURN

CREATE TABLE #PG 
	(
		ProductID VarChar(max)COLLATE SQL_Latin1_General_CP1_CI_AS ,		
		GoodsID VarChar(20) COLLATE SQL_Latin1_General_CP1_CI_AS
	)
	
CREATE TABLE #PG2 
	(
		ProductID VarChar(max) COLLATE SQL_Latin1_General_CP1_CI_AS,		
		GoodsID VarChar(20) COLLATE SQL_Latin1_General_CP1_CI_AS
	)

insert into #PG
select distinct  ProductID,GoodsID --into  #PG   
FROM   prd.tblFormulasDtl          where ProductID= @GoodsID 

while (select COUNT(*) from  #PG where GoodsID=@ProductID)<=0 and  (select COUNT(*) from  #PG)>0  
begin
	insert into  #PG2
	select distinct  b.ProductID +'--->'+b.GoodsID ProductID,a.GoodsID 
		FROM   prd.tblFormulasDtl a
		inner join #PG b 
		on  a.ProductID collate DATABASE_DEFAULT =b.GoodsID collate DATABASE_DEFAULT
		
	delete  from  #PG

	insert   into  #PG
	select * from  #PG2

	delete  from  #PG2

end


	IF (select Count(*) from  #PG where GoodsID=@ProductID)>0
	BEGIN 
		select top 1 @ProductID= ProductID +'--->' + GoodsID from  #PG where GoodsID=@ProductID
		SELECT	@StrMsg = TS.pub.funGetMessages(16001, 1) 
		RAISERROR (@StrMsg, 16, 1, @ProductID); 
      
	End 
               
End 
GO
