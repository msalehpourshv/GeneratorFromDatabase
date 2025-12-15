USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [trs].[SpCreatePayVch]
	@ProcessID		tinyint,
	@ProcessNo		tinyint,
	@FiscalYear		smallint,
	@SerialNo		int,
	@LanguageID		Tinyint
WITH ENCRYPTION
AS

BEGIN
declare @VchNo int 
declare @DocStep int  
declare @VchDate varchar(10)  
  
declare  aa_curs cursor for   
   select  VchNo,VchDate,ProcessID,ProcessNo,FiscalYear,SerialNo  
   from   trs.tblPayHdr
   where ProcessID = @ProcessID
    and  ProcessNo = @ProcessNo
    and  FiscalYear = @FiscalYear
    and  SerialNo = @SerialNo
	
open aa_curs  
  
FETCH NEXT FROM aa_curs into @VchNo,@VchDate,@ProcessID,@ProcessNo,@FiscalYear,@SerialNo  
  
WHILE @@FETCH_STATUS = 0  
BEGIN  
  
	delete from acc.tblVoucherDtl 
    where SourceProcessID = @ProcessID  and 
		  SourceProcessNo = @ProcessNo  and 
		  SourceFiscalYear= @FiscalYear and 
		  SourceSerialNo  = @SerialNo

		exec [acc].[SpVch_CreateDoc]   
			@intVchNo			= @VchNo,  
			@intDocStep		    = 0,  
			@strVchDate			= @VchDate, 
			@strOldVchDate		= @VchDate,  
			@intSourceProcessID	= @ProcessID,  
			@intSourceProcessNo	= @ProcessNo,  
			@intSourceFiscalYear= @FiscalYear,  
			@intSourceSerialNo	= @SerialNo,  
			@strHdrTblName		= 'trs.tblPayHdr',  
			@strVchNoFieldName	= 'VchNo',  
			@VoucherCreateMetod= 2 ,  
			@DocFormType        = 2 ,  
            @SelectedUserVchNoType = 1 , 
			@intOldVchNo = @VchNo 
  
	FETCH NEXT FROM aa_curs into @VchNo,@VchDate,@ProcessID,@ProcessNo,@FiscalYear,@SerialNo  
  
END   
  
close aa_curs  
deallocate aa_curs 
end
GO
