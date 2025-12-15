USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/11/06
-- Viewed By	 : 
-- Last Modified : 1403/03/09 -1403/03/27 r.moayed
-- Description   : 
-- =============================================
create PROCEDURE trs.sp_api_AppService_GetPays
@MaxResultCount as nvarchar(50),
@Skip as nvarchar(50),
@ProcessID as nvarchar(50),
@PayTypeID as nvarchar(50),
@AcntCustomerCode as nvarchar(200)

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @strQuery  NVARCHAR(Max)
BEGIN TRY

	DECLARE @PartNumber Int;
	DECLARE @PStart Int;
	DECLARE @PLen Int;
	DECLARE @PLenSubString Int;

	if( @AcntCustomerCode<>'')
		begin
			select @PartNumber = [acc].[FunGetAcntInfoForRemain](1)

			select @PStart = acc.funGetAcntLayerStartandLen(@PartNumber,1)
			--select @PLen = acc.funGetAcntLayerStartandLen(@PartNumber,2)
		
			select @PLenSubString = Len(pub.funSplitString('' + @AcntCustomerCode + '',',',1))


			--print(@PLenSubString)
			--print(pub.funSplitString('' + @AcntCustomerCode + '',',',1))

			--DECLARE @AcntCustomerCode nvarchar
			--SET @AcntCustomerCode='01,02,03'
			--DECLARE @Aaaa int;
			--select @Aaaa = 'select (value) from string_split('+ @AcntCustomerCode +','')'
			--print(@Aaaa);
			--SET @AcntCustomerCode=' and SubString(CreditCode,' + LTrim(Str(@PStart)) + ',' + LTrim(Str(@PLen)) + ') in ('''+@AcntCustomerCode+''')'
			
			if( @ProcessID='1')
				SET @AcntCustomerCode=' and SubString(CreditCode,' + LTrim(Str(@PStart)) + ',' + LTrim(Str(@PLenSubString)) + ') in (' + @AcntCustomerCode + ')'
			else
				SET @AcntCustomerCode=' and SubString(DebitCode,' + LTrim(Str(@PStart)) + ',' + LTrim(Str(@PLenSubString)) + ') in (' + @AcntCustomerCode + ')'

		end


	SET @strQuery='
	SELECT SerialNo,FiscalYear,ProcessNo,DebitCode,CreditCode,ChequeNo,Amount,DocDate,AccountNo,cast(PayTypeID as int ) as PayTypeID,
		    EventNo,WithdrawType,ChequeBookFiscalYear,ChequeBookID,VolumeFiscalYear,BaseFiscalYear,VolumeRowNo,BankSnNo,DocRowNo,BaseSerialNo,SourceSerialNo,
		    SourceProcessNo,CurrencyRate,CurrencyAmount,IsConfirmed,AccountOwnerType,RegChequeNoNewIN,RegChequeNoNewOut,ChequeIsDigital,CurrencyTypeID,LocationID,
		    D.BankTypeID,BankTypeName,BranchCode,LocationID2,BankTypeID2,ChequeNoNew,NationalIDNumber,TargetBankID,TargetLocationID,BranchCode2,AccountNo2,VisitorAcntCode,WithAcntCode,
		    FollowAcntCode,ReceiptAcntCode,ChequeDate,EndDate_PayableTrust,BranchName,AccOwnerName,BranchName2,AccOwnerName2,DeliverTo,RowDesc,
		    TargetChequeNoNew,TargetCustomerName,FollowUpNumber,ChequeCryptNo,BranchName,AccOwnerName,BranchName2,AccOwnerName2,DeliverTo,RowDesc,
		    TargetChequeNoNew,TargetCustomerName,FollowUpNumber,ChequeCryptNo
	FROM trs.tblPayDtl D
	join trs.tblBankTypesDtl T on D.BankTypeID=T.BankTypeID
	WHERE ProcessID=' + @ProcessID + ' and PayTypeID in ' + @PayTypeID + @AcntCustomerCode

	
	SET @strQuery=@strQuery+' 
				   ORDER BY SerialNo
				   OFFSET ' +@Skip +' Rows 
				   FETCH NEXT ' +@MaxResultCount +' Rows ONLY '	

	PRINT @strQuery
EXEC sp_executesql @strQuery
	  	
END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
