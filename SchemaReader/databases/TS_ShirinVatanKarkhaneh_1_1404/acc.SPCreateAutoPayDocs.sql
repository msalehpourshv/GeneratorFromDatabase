USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Hamid
-- Create date   : 1395/10/21
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : ایجاد یا اصلاح سند اتوماتیک
-- =============================================
--EXEC [acc].[SPCreateAutoDocs1] @VolumeRowNo, @VolumeFiscalYear, @VoucherCreateMetod, @DocFormType, @SelectedUserVchNoType, '', ''  
CREATE PROCEDURE [acc].[SPCreateAutoPayDocs]
	@VolumeRowNo			BigInt = Null,
	@VolumeFiscalYear		BigInt = Null,
	@VoucherCreateMetod		tinyint=2,
	@DocFormType			tinyint=2,
	@SelectedUserVchNoType	tinyint=1,
	@RepOptions				NVarChar(max) = '1', -- bit array
	@RepInfo				NVarChar(max) = '1@1@1'
WITH ENCRYPTION
AS 
Begin --============== S T A R T  C O D E ===================================================

	Set NoCount On;

	Declare @VchNo int 
	Declare @DocStep int  
	Declare @VchDate varchar(10)  
	Declare @ProcessID Smallint  
	Declare @ProcessNo tinyint  
	Declare @FiscalYear Smallint  
	Declare @CurrFiscalYear Smallint  
	Declare @SerialNo int  

	SET @CurrFiscalYear		= pub.funSplitString(@RepInfo, '@', 1);
	  
	Declare  aa_curs cursor for   
	   Select  a.VchNo,a.VchDate,a.ProcessID,a.ProcessNo,a.FiscalYear,a.SerialNo
	   From   trs.tblPayHdr a
	   Inner Join trs.tblPayDtl b ON a.ProcessID = b.ProcessID And a.ProcessNo = b.ProcessNo And
									 a.FiscalYear = b.FiscalYear And a.SerialNo = b.SerialNo
	   where b.VolumeRowNo = @VolumeRowNo AND  b.VolumeFiscalYear = @VolumeFiscalYear AND a.FiscalYear = @CurrFiscalYear
		
	Open aa_curs  
	  
	FETCH NEXT FROM aa_curs into @VchNo,@VchDate,@ProcessID,@ProcessNo,@FiscalYear,@SerialNo  
	  
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
	  
		delete from acc.tblVoucherDtl 
		where SourceProcessID = @ProcessID  and 
			  SourceProcessNo = @ProcessNo  and 
			  SourceFiscalYear= @FiscalYear and 
			  SourceSerialNo  = @SerialNo

		if @VchNo <> 0   
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
				@VoucherCreateMetod= @VoucherCreateMetod ,  
				@DocFormType        = @DocFormType ,  
				@SelectedUserVchNoType = @SelectedUserVchNoType , 
				@intOldVchNo = @VchNo 
	  
		FETCH NEXT FROM aa_curs into @VchNo,@VchDate,@ProcessID,@ProcessNo,@FiscalYear,@SerialNo  
	  
	END   
	  
	close aa_curs  
	deallocate aa_curs

End
GO
