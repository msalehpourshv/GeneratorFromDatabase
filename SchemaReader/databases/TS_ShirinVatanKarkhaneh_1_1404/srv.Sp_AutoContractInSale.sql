USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Reza
-- Create date   : 1393/12/03
-- Viewed By	 : 
-- Last Modified :  
-- Last Modifier : 
-- Description	 : 
-- ==============================================
create PROCEDURE [srv].[Sp_AutoContractInSale]

	@ConractTypeID		Varchar(20) = Null,
	@DocDate			Char(10) = Null,
	@ConractDate		Char(10) = Null,
	@FinishDate			Char(10) = Null,
	@ContractNo			nVarchar(20) = Null,
	@ConractTitle		nVarchar(100) = Null,
	@Amount				float,
	@Discount			float,
	@Duration			int,
	@BaseProcessID		int,
	@BaseProcessNo		int,
	@BaseFiscalYear		int,
	@BaseSerialNo		int,
	@TimeType			tinyint,
	@Desc				nVarchar(1000) = Null
	 
	
WITH ENCRYPTION

AS 

 Begin -- ============== S T A R T  C O D E ====================================

SET NOCOUNT ON;


	Declare @SerialNo	int;
	set @SerialNo=0;
	

	-- Init Variables -------------------------------------
	
	if (select  count(*) from acc.tblContratctsHdr
		where BaseProcessID=@BaseProcessID and
		  BaseProcessNo=@BaseProcessNo and 
		  BaseFiscalYear=@BaseFiscalYear and
		  BaseSerialNo=@BaseSerialNo)>0
	begin
		select  @SerialNo=SerialNo from acc.tblContratctsHdr
		where BaseProcessID=@BaseProcessID and
		  BaseProcessNo=@BaseProcessNo and 
		  BaseFiscalYear=@BaseFiscalYear and
		  BaseSerialNo=@BaseSerialNo
	end


	delete  from acc.tblContratctsHdr
	where BaseProcessID=@BaseProcessID and
		  BaseProcessNo=@BaseProcessNo and 
		  BaseFiscalYear=@BaseFiscalYear and
		  BaseSerialNo=@BaseSerialNo
  
   if @SerialNo=0
	begin
		select @SerialNo=isnull(MAX(SerialNo),0) from acc.tblContratctsHdr
		set @SerialNo=@SerialNo+1
	 end
	 
	INSERT INTO acc.tblContratctsHdr
	(SerialNo,DocDate, ContractDate,StartDate,EndDate,ContractNo,
	ContractTitle,CustomerAcntCode,Duration, TimeType,EstimateAmount,
	ContractTypeID,[Description], Confirm1,Discount,
	BaseProcessID,BaseProcessNo,BaseFiscalYear, BaseSerialNo)
	 
	SELECT @SerialNo,@DocDate,@ConractDate,@ConractDate,@FinishDate,@ContractNo,
	@ConractTitle, R.AcntCode,@Duration,@TimeType,@Amount,
	@ConractTypeID,@Desc,'True',@Discount,
	@BaseProcessID,@BaseProcessNo,@BaseFiscalYear,@BaseSerialNo
  FROM
	(SELECT * FROM 
	 inv.tblStorageDocsHdr
	 WHERE ProcessID=@BaseProcessID and ProcessNo=@BaseProcessNo
	 and FiscalYear=@BaseFiscalYear and
	 SerialNo=@BaseSerialNo) R	  
		
End
GO
