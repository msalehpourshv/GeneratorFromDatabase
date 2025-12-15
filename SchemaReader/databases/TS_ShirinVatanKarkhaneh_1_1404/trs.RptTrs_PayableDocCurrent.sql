USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1386/09/22
-- Viewed By	 : 
-- Last Modified : 1386/08/28
-- Description	 : <Cheque Progress>
-- ----------------------------------------------
-- گردش یک چک پرداختی
-- ==============================================
Create PROCEDURE [trs].[RptTrs_PayableDocCurrent]
	@ProcessNo	int = 1,
	@VFiscal	int = 1, -- سال مالی چک
	@VRowNo		int = 1, -- شماره ردیف چک
	@RepOptions	NVarChar(100) = '', -- bit array options
	@RepInfo	NVarChar(100) = '1@1@1'
WITH ENCRYPTION
As
Begin -- =====================  B E G I N   T O   C O D E  =======================

   declare @StrSelect as nvarchar(4000)
   
   
   set @StrSelect = ' 
	SELECT	D.*, D.DocDate AS EventDate, D.RowDesc AS DescDtl, D.ProcessID AS ChequeState,
			D.DebitCode AS DebitAcntCode, D.CreditCode AS CreditAcntCode, 
			pub.GetCodeName(D.VisitorAcntCode,1) AS VisitorAcntCodeName,
			LD.LocationName AS BankCity, BTD.BankTypeName,
			pub.GetCodeName(D.DebitCode, 1) AS DebitAcntName,
			pub.GetCodeName(D.CreditCode, 1) AS CreditAcntName,
			pub.GetBankName(D.DebitCode, 1) AS DebitBankName,
			pub.GetBankName(D.CreditCode, 1) AS CreditBankName
	FROM	trs.tblPayDtl D 
				LEFT JOIN trs.tblBankTypesDtl AS BTD ON BTD.BankTypeID = D.BankTypeID
				LEFT JOIN pub.tblLocationsDtl AS LD ON LD.LocationID = D.LocationID 
	WHERE	D.ProcessNo = '+ cast(@ProcessNo as varchar(20)) +' 
			AND D.PayTypeID IN (7, 8, 28) 
			AND D.VolumeFiscalYear = '+CAST( @VFiscal as varchar(20)) +'
			AND D.VolumeRowNo = '+CAST( @VRowNo as varchar(20))
	
	
---------------------------------------------------------------------------------------------------
		Declare @DonotFilterAcc2Trs AS bit
	SET @DonotFilterAcc2Trs = 0
	SELECT @DonotFilterAcc2Trs = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'DonotFilterAcc2Trs'
		
if @DonotFilterAcc2Trs=0 	
begin

	DECLARE	@UserID		Int;
	DECLARE	@UserIsAdmin bit;

	SET @UserID				 = pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin		 = pub.funSplitString(@RepInfo, '@', 5);


	BEGIN TRY
		DROP TABLE #tblAcntCode
		DROP TABLE #tblOurBanks
	END TRY
	BEGIN CATCH
	END CATCH
	 CREATE TABLE #tblAcntCode
	(
	AcntCode 			Varchar(20)collate arabic_cs_as null
	)
	 CREATE TABLE #tblOurBanks
	(
		CreditCode 			Varchar(20)collate arabic_cs_as null
	)
	if (@UserIsAdmin = 0)
	begin
	 
			Insert into  #tblOurBanks (CreditCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblOurBanks', 'CreditCode', 'trs.tblOurBanks', @UserID; 
			Insert into  #tblAcntCode (AcntCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID; 
			SET @StrSelect =  @StrSelect + '  and  ( D.CreditCode in (SELECT   CreditCode	FROM  #tblOurBanks    ) 
												or   D.CreditCode in (SELECT   AcntCode	FROM  #tblAcntCode    ) )'
		 
	end 
	
Delete From  #tblAcntCode where AcntCode='' or AcntCode is null
Delete From  #tblOurBanks where CreditCode='' or CreditCode is null

end
------------------------------------------------------------------------------------------------------
	set @StrSelect = @StrSelect + '
	ORDER BY D.VolumeFiscalYear, D.VolumeRowNo, D.EventNo'
	
		print @StrSelect;
	Exec sp_executesql @StrSelect;
End
GO
