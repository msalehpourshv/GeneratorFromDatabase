USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : REZA NP 
-- Create date   : 94/04/25
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE  prd.SpGetContractListByProcessID
	@PartNumber as int=2,
	@ContractProcessID as  int=79,
	@ProcessID as int=70,
	@ProducerAcntCode as varchar(20)='',
	@ProductID as varchar(20)='',
	@DocDate  as char(10)=''	
WITH ENCRYPTION
AS
Begin
declare @strSelect as nvarchar(max)
declare @strWhere as nvarchar(max)
declare @strWhere2 as nvarchar(max)

set @strSelect=''
set @strWhere=' '
  
If @ProducerAcntCode is not null AND @ProducerAcntCode<>''
   SET @strWhere = @strWhere + ' AND  A.ProducerAcntCode =''' + @ProducerAcntCode + ''''

If @ProductID is not null AND @ProductID<>''
   SET @strWhere = @strWhere + ' AND  A.GoodsID =''' + @ProductID + ''''

   Declare @prd_ProducersWageDateVerification Bit;	
	SELECT @prd_ProducersWageDateVerification = SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'prd_ProducersWageDateVerification'

if @prd_ProducersWageDateVerification='true'
   SET @strWhere = @strWhere + ' AND ( A.DateFrom ='''' or A.DateFrom <=''' + @DocDate + ''' )AND  (  A.DateTo='''' or  A.DateTo >=''' + @DocDate + ''')  '


   SET @strWhere2 ='where ProcessID = 70 
							AND	(( hd.BaseProcessID =79  and  A.ProcessID=hd.SourceProcessID   and A.SerialNo=hd.SourceSerialNo )
										or 	( hd.BaseProcessID <>79  and  A.ProcessID=hd.BaseProcessID   and A.SerialNo=hd.BaseSerialNo )	) 
							AND A.ProducerAcntCode=hd.AcntCode'
if 	@ProcessID=70	
 set @strSelect=
 'SELECT A.*,(A.GoodsQuantity -      
   ISNULL((select top 1 [prd].[funGetMaxSendGoodsID] (A.ProducerAcntCode,A.GoodsID,A.SerialNo,hd.FormulaNo)    
	from inv.tblStorageDocsHdr hd '+@strWhere2 +' AND hd.ProductID=A.GoodsID),0) ) Remain  FROM (
 SELECT h.*,d.GoodsID,acc.funPartAcntName(h.ProducerAcntCode,'+str(@PartNumber)+')AcntName, WageAmount,      
   d.GoodsQuantity + [prd].[funGetProducersEditQty] (h.ProducerAcntCode,h.SerialNo,h.BatchNo,d.GoodsID) GoodsQuantity     
  FROM prd.tblProducersWageHdr h      
   inner join  prd.tblProducersWageDtl d on h.ProducerAcntCode=d.ProducerAcntCode AND h.SerialNo=d.SerialNo AND h.ProcessID=d.ProcessID      
   WHERE h.ProcessID='+str(@ContractProcessID)+' ) A   
   WHERE (A.GoodsQuantity -      
   ISNULL((select top 1 [prd].[funGetMaxSendGoodsID] (A.ProducerAcntCode,A.GoodsID,A.SerialNo,hd.FormulaNo)    
	from inv.tblStorageDocsHdr hd '+@strWhere2 +' AND hd.ProductID=A.GoodsID),0) ) >0  '
  + @strWhere
  
if 	@ProcessID=75	
  set  @strSelect=
 'SELECT A.*,(A.GoodsQuantity -      
   ISNULL((select top 1 [prd].[funGetMaxProductCanBuild] (A.ProducerAcntCode,A.GoodsID,A.SerialNo,hd.FormulaNo)    
	from inv.tblStorageDocsHdr hd '+@strWhere2 +' AND hd.ProductID=A.GoodsID),0) ) Remain  FROM (
 SELECT h.*,d.GoodsID,acc.funPartAcntName(h.ProducerAcntCode,'+str(@PartNumber)+')AcntName,  WageAmount,    
   d.GoodsQuantity + [prd].[funGetProducersEditQty] (h.ProducerAcntCode,h.SerialNo,h.BatchNo,d.GoodsID) GoodsQuantity     
  FROM prd.tblProducersWageHdr h      
   inner join  prd.tblProducersWageDtl d on h.ProducerAcntCode=d.ProducerAcntCode AND h.SerialNo=d.SerialNo AND h.ProcessID=d.ProcessID      
   WHERE h.ProcessID='+str(@ContractProcessID)+' ) A   
   WHERE (A.GoodsQuantity -      
   ISNULL((select top 1 [prd].[funGetMaxProductCanBuild] (A.ProducerAcntCode,A.GoodsID,A.SerialNo,hd.FormulaNo)    
	from inv.tblStorageDocsHdr hd '+@strWhere2 +' AND hd.ProductID=A.GoodsID),0) ) >0  '
  + @strWhere
  

if 	@ProcessID=80	
 set  @strSelect=
 'SELECT A.*,(A.GoodsQuantity -      
   ISNULL((select top 1 [prd].[funGetMaxProductCanReturn] (A.ProducerAcntCode,A.GoodsID,A.SerialNo,hd.FormulaNo)    
	from inv.tblStorageDocsHdr hd '+@strWhere2 +' AND hd.ProductID=A.GoodsID),0) ) Remain  FROM (
 SELECT h.*,d.GoodsID,acc.funPartAcntName(h.ProducerAcntCode,'+str(@PartNumber)+')AcntName,WageAmount,      
   d.GoodsQuantity + [prd].[funGetProducersEditQty] (h.ProducerAcntCode,h.SerialNo,h.BatchNo,d.GoodsID) GoodsQuantity     
  FROM prd.tblProducersWageHdr h      
   inner join  prd.tblProducersWageDtl d on h.ProducerAcntCode=d.ProducerAcntCode AND h.SerialNo=d.SerialNo AND h.ProcessID=d.ProcessID      
   WHERE h.ProcessID='+str(@ContractProcessID)+' ) A   
   WHERE (A.GoodsQuantity -      
   ISNULL((select top 1 [prd].[funGetMaxProductCanReturn](A.ProducerAcntCode,A.GoodsID,A.SerialNo,hd.FormulaNo)    
	from inv.tblStorageDocsHdr hd '+@strWhere2 +' AND hd.ProductID=A.GoodsID),0) ) >0  '
  + @strWhere
  
if 	@ProcessID=85	
  set  @strSelect=
  'SELECT A.*,d.GoodsID,acc.funPartAcntName(A.ProducerAcntCode,'+str(@PartNumber)+')AcntName,      
   d.GoodsQuantity,      
   ISNULL((select top 1 [prd].[funGetMaxProductCanReturn] (A.ProducerAcntCode,d.GoodsID,A.SerialNo,hd.FormulaNo)    
	from inv.tblStorageDocsHdr hd '+@strWhere2 +' AND hd.ProductID=d.GoodsID),0)  Remain     
  FROM prd.tblProducersWageHdr A      
   inner join  prd.tblProducersWageDtl d on A.ProducerAcntCode=d.ProducerAcntCode AND A.SerialNo=d.SerialNo AND A.ProcessID=d.ProcessID      
   WHERE A.ProcessID='+str(@ContractProcessID)+'    
   AND      
   ISNULL((select top 1 [prd].[funGetMaxProductCanReturn] (A.ProducerAcntCode,d.GoodsID,A.SerialNo,hd.FormulaNo)    
   from inv.tblStorageDocsHdr hd '+@strWhere2 +' AND hd.ProductID=d.GoodsID),0)>0 '
  + @strWhere
  
  
-- اصلاحیه قرارداد
if 	@ProcessID=89	
  set  @strSelect=
  'SELECT A.*,d.GoodsID,acc.funPartAcntName(A.ProducerAcntCode,'+str(@PartNumber)+')AcntName,      
   d.GoodsQuantity,(d.GoodsQuantity -      
   ISNULL((select top 1 [prd].[funGetMaxSendGoodsID] (A.ProducerAcntCode,d.GoodsID,A.SerialNo,hd.FormulaNo)    
	from inv.tblStorageDocsHdr hd '+@strWhere2 +' AND hd.ProductID=d.GoodsID),0) ) Remain     
  FROM prd.tblProducersWageHdr A      
   inner join  prd.tblProducersWageDtl d on A.ProducerAcntCode=d.ProducerAcntCode AND A.SerialNo=d.SerialNo AND A.ProcessID=d.ProcessID      
   WHERE A.ProcessID='+str(@ContractProcessID) + @strWhere

-- RUN -------------------------------------------------------
PRINT @strSelect;
EXEC sp_executesql @strSelect;
--------------------------------------------------------------
End
GO
