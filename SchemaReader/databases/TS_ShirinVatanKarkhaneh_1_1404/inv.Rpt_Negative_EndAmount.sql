USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem  \ Nogrehpasand
-- Create date   : 1393/10/11
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 :    
-- =============================================
create PROCEDURE [inv].[Rpt_Negative_EndAmount] --2 
		
	@GoodsID		VarChar(20)=null,
	@StoreID		VarChar(20)=null,
	@FromDate		char(10)=null,
	@ToDate			char(10)=null,
	@RepType		tinyint=1
	
WITH ENCRYPTION
AS

DECLARE @StrSelect		NVarChar(4000);

DECLARE @StrWhere		NVarChar(2000);
 

BEGIN 
	-- ============================ S T A R T =====================================================

	-- Init --------------------------
	SET NOCOUNT ON;

	
	
-- ================ WHERE ===========================

	set @StrWhere = '  '
	
	IF (@GoodsID IS NOT null)
		SET @StrWhere = @StrWhere + ' AND D.GoodsID =''' + @GoodsID + ''''
	
	IF (@StoreID IS NOT null)
		SET @StrWhere = @StrWhere + ' AND D.StoreID =''' + @StoreID + ''''
	
		
	IF (@FromDate IS NOT null)
		SET @StrWhere = @StrWhere + ' AND D.DocDate >=''' + @FromDate + ''''
	
	
	IF (@ToDate IS NOT null)
		SET @StrWhere = @StrWhere + ' AND D.DocDate <=''' + @ToDate + ''''
	
-- ================ SELECT ===========================


if @RepType=1
begin
	SET @StrSelect ='SELECT top 1 p.ProcessName,aa.*,aa.GoodsQuantity Balance,pub.GetGoodsName(aa.GoodsID,1)GoodsName  
	from (SELECT StoreID,GoodsID,
		(SELECT TOP 1 EnterKind 
		 from inv.tblStorageDocsDtl  D
		 where GoodsID NOT IN (SELECT GoodsID FROM inv.tblGoods WHERE IsService = ''True'') and 
		 D.StoreID= c.StoreID and D.GoodsID=c.GoodsID 
		 '+ @StrWhere +'
		 order by StoreID,GoodsID,DocDate,VolumeRowNo ) E
		FROM inv.tblStorageDocsDtl c
		group by StoreID,GoodsID
		) a
		inner join inv.tblStorageDocsDtl aa
		on a.StoreID=aa.StoreID and a.GoodsID=aa.GoodsID
		inner join pub.tblProcess p
		on p.ProcessID=aa.ProcessID and p.ProcessNo=aa.ProcessNo
	where E=-1 
	order by StoreID,GoodsID,DocDate,VolumeRowNo'
end		
	
if @RepType=2
begin
	SET @StrSelect ='SELECT  p.ProcessName,D.*,pub.GetGoodsName(D.GoodsID,1)GoodsName  
	from (
		SELECT * ,
		   (
			 SELECT ISNULL (Sum(GoodsQuantity * EnterKind), 0) 
			 FROM inv.tblStorageDocsDtl a
			 WHERE GoodsID NOT IN (SELECT GoodsID FROM inv.tblGoods WHERE IsService = ''True'') and 
			       a.StoreID = b.StoreID AND a.GoodsID = b.GoodsID AND 
				   (a.DocDate < b.DocDate OR 
				   (a.DocDate = b.DocDate AND a.VolumeRowNo <= b.VolumeRowNo))
		   ) AS Balance 

		from inv.tblStorageDocsDtl b) D
		inner join pub.tblProcess p
		on p.ProcessID=D.ProcessID and p.ProcessNo=D.ProcessNo
		WHERE Balance<0 '  + @StrWhere +  '
		order by StoreID,GoodsID,DocDate,VolumeRowNo'		
		           
	end
				 
 	 
-- ================ SELECT ===========================

	-- Exeute --------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	--=========================================================================================
END
GO
