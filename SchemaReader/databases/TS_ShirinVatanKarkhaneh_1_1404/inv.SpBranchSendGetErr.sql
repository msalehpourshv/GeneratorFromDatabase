USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hadi Sadeghi
-- Create date   : 1401/05/30
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : 
-- ==============================================
Create PROCEDURE inv.SpBranchSendGetErr

WITH ENCRYPTION
AS

 Begin
  	
		UPDATE inv.tblStorageDocsDtl 
		SET BaseSerialNo= b.BaseSerialNo
		FROM inv.tblStorageDocsDtl a
		INNER JOIN inv.tblStorageDocsHdr b
		ON a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo
		 WHERE  a.ProcessID=124 and a.BaseSerialNo=0 and b.BaseSerialNo>0


		SELECT N'کالا در قبض  ثبت نشده / تعدادش درست نیست' Comment,*,
		(SELECT Top 1 b.SerialNo from inv.tblStorageDocsDtl b where a.ProcessID=b.BaseProcessID and a.SerialNo=b.BaseSerialNo and a.ProcessNo=b.BaseProcessNo) BaseSerialNo
		FROM (
		SELECT ProcessID,ProcessNo,FiscalYear,SerialNo,GoodsID,SUM(GoodsQuantity) GoodsQuantity 
		FROM inv.tblStorageDocsDtl a
		WHERE ProcessID = 123 and 
		(SELECT Count(*) from inv.tblStorageDocsDtl b where a.ProcessID=b.BaseProcessID and a.SerialNo=b.BaseSerialNo and a.ProcessNo=b.BaseProcessNo)>0
		GROUP BY ProcessID,ProcessNo,FiscalYear,SerialNo,GoodsID
		EXCEPT
		SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,GoodsID,SUM(GoodsQuantity)  GoodsQuantity
		FROM inv.tblStorageDocsDtl where  ProcessID=124 
		GROUP BY BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,GoodsID ) a
		union
		select N'قبض نشده است' Comment,ProcessID,ProcessNo,FiscalYear,SerialNo,'' GoodsID,0 GoodsQuantity ,0 BaseSerialNo
		from inv.tblStorageDocsHdr a
		where ProcessID = 123 
		and  (SELECT Count(*) from inv.tblStorageDocsDtl b where a.ProcessID=b.BaseProcessID and a.ProcessNo=b.BaseProcessNo and a.FiscalYear=b.BaseFiscalYear and a.SerialNo=b.BaseSerialNo)=0
		--group by ProcessID,ProcessNo,FiscalYear,SerialNo
		UNION
		select  N'قبض دارد حواله ندارد' Comment,ProcessID,ProcessNo,FiscalYear,SerialNo,a.GoodsID, a.GoodsQuantity ,0 BaseSerialNo
		from inv.tblStorageDocsDtl a
		inner join (
		select BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,GoodsID,SUM(GoodsQuantity)  GoodsQuantity
		from inv.tblStorageDocsDtl where  ProcessID=124 
		group by BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,GoodsID
		except 
		select ProcessID,ProcessNo,FiscalYear,SerialNo,GoodsID,SUM(GoodsQuantity) GoodsQuantity 
		from inv.tblStorageDocsDtl a
		where ProcessID = 123 
		group by ProcessID,ProcessNo,FiscalYear,SerialNo,GoodsID) b
		on a.BaseProcessID=b.BaseProcessID and a.BaseProcessNo=b.BaseProcessNo and a.BaseFiscalYear=b.BaseFiscalYear and a.BaseSerialNo=b.BaseSerialNo and a.GoodsID=b.GoodsID
		union
		select N'Hdr دارد Dtl ندارد' Comment,ProcessID,ProcessNo,FiscalYear,SerialNo,'' GoodsID,0 GoodsQuantity ,0 BaseSerialNo
		from inv.tblStorageDocsHdr a
		where ProcessID = 123 
		and  (SELECT Count(*) from inv.tblStorageDocsDtl b where a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo)=0


END----end
GO
