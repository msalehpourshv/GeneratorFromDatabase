USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : jafari
-- Create date   : 1401/08/18
-- Viewed By	 : 
-- Last Modified : 

-- Description	 : 
-- ==============================================
Create PROCEDURE sal.SpSaleTempReceiptSerial
	@ExtraParams		NVarChar(Max) = '',
	@RepInfo			NVarChar(100) = '1@1@1',
	@RepOptions			VarChar(20) = '111' -- bit array	

WITH ENCRYPTION
AS
 
Declare @StrSelect			NVarChar(max);		
Declare @StrWhere			NVarChar(max);		
Declare @PSerial			NVarChar(20);		

 Begin 
 
 	SET @PSerial		    = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
 	 
	 if (Select Count(*) from pub.tblProcess where ProcessID=171)<=0
			insert into pub.tblProcess (	 ProcessID	,ProcessNo,	ProcessName	,ProcessSchema	,ProcessOrder)
			select 171,1,'رسید موقت فروش', 'inv', 1000


	
	  select  @StrWhere=' 1=1 '
	
		if isnull(@PSerial, '')<>''
			set @StrWhere =@StrWhere+ ' AND s.PSerialNo=''' +isnull(@PSerial, '') + ''' '
 
		set @StrSelect = '
				select  s.ProcessID,s.FiscalYear,s.SerialNo,case when isnull(d.DocDate, '''')<>''''  then d.DocDate else sd.DocDate end DocDate,p.ProcessName
					from inv.tblStorageDocsSerials s
					Left join inv.tblStorageDocsDtl d on s.ProcessID=d.ProcessID And s.ProcessNo=d.ProcessNo And s.FiscalYear=d.FiscalYear And s.SerialNo=d.SerialNo and s.DocRowNo=d.DocRowNo
					Left join inv.tblInvTempReceiptDtl sd on s.ProcessID=sd.ProcessID And s.ProcessNo=sd.ProcessNo And s.FiscalYear=sd.FiscalYear And s.SerialNo=sd.SerialNo  and s.DocRowNo=sd.DocRowNo
					Left join pub.tblProcess p on s.ProcessID=p.ProcessID  and s.ProcessNo=p.ProcessNo 
		where '+ @StrWhere +'	'
	
		print @StrSelect
	Exec sp_executesql @StrSelect;

END----end
GO
