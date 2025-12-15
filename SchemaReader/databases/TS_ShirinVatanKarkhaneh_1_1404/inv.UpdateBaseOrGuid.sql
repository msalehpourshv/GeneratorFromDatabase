USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Jafari
-- Create date   : 1404/04/28
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier :
-- ----------------------------------------------
-- Description	 : 
-- ==============================================
Create PROCEDURE inv.UpdateBaseOrGuid
@UpdateType  as tinyint,
@ProcessID as tinyint,
@ProcessNo as tinyint,
@FiscalYear as SMALLINT,
@SerialNo as Int
WITH ENCRYPTION
 AS
BEGIN-- ============================ S T A R T =====================================================

	
	Declare @BaseFiscalYear Int;
	Declare @DbName 		NVarChar(100);
	Declare @StrSelect		NVarChar(max);

	DECLARE csr CURSOR FOR 
	Select Distinct BaseFiscalYear   from inv.tblStorageDocsDtl where ProcessID=100 and BaseFiscalYear<>0
		and (@ProcessID=0 or ProcessID=@ProcessID)
		and (@ProcessNo=0 or ProcessNo=@ProcessNo)
		and (@FiscalYear=0 or FiscalYear=@FiscalYear)
		and (@SerialNo=0 or SerialNo=@SerialNo)
	OPEN csr
	FETCH NEXT FROM csr INTO @BaseFiscalYear

	WHILE @@Fetch_Status = 0
	BEGIN

		select @DbName=DB_name()
		set @DbName	=SUBSTRING(@DbName,1, len(@DbName)-4)+ltrim(rtrim(str(@BaseFiscalYear)))
		if (SELECT Count(*) FROM sys.databases WHERE (state = 0) AND ([name] = @DbName))>0
		begin
			if 	@UpdateType=1
				SET @StrSelect = '	
							update inv.tblStorageDocsDtl  set GUID_BaseStorDocDtl=b.GUID_StorDocDtl
							 from inv.tblStorageDocsDtl a
							 inner join (Select * from '+@DbName+'.inv.tblStorageDocsDtl ) b
							 on a.BaseProcessID=b.ProcessID and  a.BaseProcessNo=b.ProcessNo and  a.BaseFiscalYear=b.FiscalYear
								 and  a.BaseSerialNo=b.SerialNo and  a.BaseDocRowNo=b.DocRowNo
							 where	 ('+ str(@ProcessID )+'=0 or a.ProcessID='+ str(@ProcessID )+'   )
								 and ('+ str(@ProcessNo )+'=0 or a.ProcessNo='+ str(@ProcessNo )+'	  )
								 and ('+ str(@FiscalYear )+'=0 or a.FiscalYear='+ str(@FiscalYear )+' )
								 and ('+ str(@SerialNo )+'=0 or a.SerialNo='+ str(@SerialNo)+' )
								 And a.GUID_BaseStorDocDtl<>b.GUID_StorDocDtl
								 '			
			if 	@UpdateType=2	
				SET @StrSelect = '	update inv.tblStorageDocsDtl 
				set BaseProcessID=b.ProcessID, BaseProcessNo =b.ProcessNo
				, BaseFiscalYear =b.FiscalYear, BaseSerialNo=b.SerialNo, BaseDocRowNo =b.DocRowNo
				from inv.tblStorageDocsDtl a
				inner join  (Select * from '+@DbName+'.inv.tblStorageDocsDtl where ProcessID=90)b
				on a.GUID_BaseStorDocDtl =b.GUID_StorDocDtl
				where a.ProcessID=100
				and ( a.BaseProcessID <>b.ProcessID or a.BaseProcessNo <>b.ProcessNo or a.BaseFiscalYear <>b.FiscalYear or a.BaseSerialNo<>b.SerialNo or a.BaseDocRowNo <>b.DocRowNo)
				And ('+ str(@ProcessID )+'=0 or a.ProcessID='+ str(@ProcessID )+'   )
								 and ('+ str(@ProcessNo )+'=0 or a.ProcessNo='+ str(@ProcessNo )+'	  )
								 and ('+ str(@FiscalYear )+'=0 or a.FiscalYear='+ str(@FiscalYear )+' )
								 and ('+ str(@SerialNo )+'=0 or a.SerialNo='+ str(@SerialNo)+'	  )'
				print @StrSelect
				Exec sp_executesql @StrSelect; 
				SET @StrSelect = '	update inv.tblStorageDocsHdr 
									set BaseSerialNo=b.BaseSerialNo
									from inv.tblStorageDocsHdr a
									inner join inv.tblStorageDocsDtl b
									on a.ProcessID=b.ProcessID
									and a.ProcessNo=b.ProcessNo
									and a.FiscalYear=b.FiscalYear
									and a.SerialNo=b.SerialNo
									where a.BaseSerialNo<>b.BaseSerialNo
									and a.BaseSerialNo<>0'

			print @StrSelect
			Exec sp_executesql @StrSelect; 
		end 
		FETCH NEXT FROM csr INTO  @BaseFiscalYear
	END

	CLOSE csr
	DEALLOCATE csr


END
GO
