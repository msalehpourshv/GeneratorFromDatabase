USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1386/03/16
-- Viewed By	 : 
-- Last Modified : 1392/01/06
-- Description	 : <Cheque Progress>
-- ==============================================
Create PROCEDURE [trs].[RptTrs_ReceivableDocCurrent]
	@ProcessNo	Int = 1,
	@VFiscal	Int, -- سال مالی چک
	@VRowNo		Int, -- شماره ردیف چک
	@RepOptions	VarChar(20) = '00',
	@RepInfo	NVarChar(100) = '1@1@1'
WITH ENCRYPTION
As
DECLARE	@LangID			Int;
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int; 
Begin -- =====================  B E G I N   T O   C O D E  =======================

	-- Init -------------------------------------------------------------------
	IF (@RepInfo Is Null) SET @RepInfo = '1@1@1'

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	declare @AcntPartNumber as tinyint
	SELECT @AcntPartNumber = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'

	IF @AcntPartNumber =0 OR @AcntPartNumber IS NULL
		SELECT	@AcntPartNumber = MAX(PartNumber) 	FROM	pub.tblCodeLayer 	WHERE	(TableName = 'acc.tblAcnt') AND Layer1<>0
	---------------------------------------------------------------------------
    
     declare @StrSelect as nvarchar(4000)
   
      set @StrSelect = ' 
	  SELECT	PD.ProcessID, PD.ProcessNo, PS.ProcessName, PD.FiscalYear, PD.SerialNo, PD.VolumeFiscalYear, 
			PD.VolumeRowNo, PD.EventNo, PD.DocDate AS EventDate, PD.RowDesc AS DescDtl,
			PD.DebitCode AS DebitAcntCode, PD.CreditCode AS CreditAcntCode, 
			PD.BankTypeID, PD.BranchCode, PD.BranchName, PD.AccountNo, PD.AccOwnerName, 
			PD.ChequeDate, PD.Amount, PD.ChequeNo, PD.ChequeNoNew,PD.NationalIDNumber, PD.ProcessID AS ChequeState,
			LD.LocationName AS BankCity, BTD.BankTypeName,
			pub.GetCodeName(PD.VisitorAcntCode,1) AS VisitorAcntCodeName,
			acc.funPartAcntNameRecurcive(PD.DebitCode, '+cast(@AcntPartNumber as varchar(20))+') AS DebitAcntName,
			acc.funPartAcntNameRecurcive(PD.CreditCode, '+cast(@AcntPartNumber as varchar(20))+') AS CreditAcntName,
			--pub.GetCodeName(PD.DebitCode, '+CAST( @LangID as varchar(20))+') AS DebitAcntName,
			--pub.GetCodeName(PD.CreditCode, '+CAST( @LangID as varchar(20))+') AS CreditAcntName,
			pub.GetBankName(PD.DebitCode, '+ CAST( @LangID as varchar(20))+') AS DebitAcntNameB,
			pub.GetBankName(PD.CreditCode, '+ CAST( @LangID as varchar(20))+') AS CreditAcntNameB
	FROM	trs.tblPayDtl AS PD 
				LEFT JOIN trs.tblBankTypesDtl AS BTD ON	BTD.BankTypeID = PD.BankTypeID AND BTD.LanguageID ='+ CAST( @LangID as varchar(20))+'
				LEFT JOIN pub.tblLocationsDtl AS LD  ON LD.LocationID = PD.LocationID AND LD.LanguageID = '+ CAST( @LangID as varchar(20)) +'
				LEFT JOIN pub.tblProcess	  AS PS  ON PS.ProcessID = PD.ProcessID and PS.ProcessNo = '+CAST( @ProcessNo as varchar(20))+'
	WHERE	PD.ProcessNo = '+CAST( @ProcessNo as varchar(20))+' 
			AND PD.PayTypeID IN (6, 26)
			AND PD.VolumeFiscalYear = '+CAST( @VFiscal as varchar(20)) +'
			AND PD.VolumeRowNo = '+CAST( @VRowNo as varchar(20))  +' and PD.ProcessID <>41'
	
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
	
			Insert into  #tblOurBanks (CreditCode) SELECT  Distinct DebitCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblOurBanks', 'CreditCode', 'trs.tblOurBanks', @UserID; 
			Insert into  #tblAcntCode (AcntCode) SELECT  Distinct DebitCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID; 
			SET @StrSelect =  @StrSelect + '  and (  PD.DebitCode in (SELECT   CreditCode	FROM  #tblOurBanks     ) 
												or   PD.DebitCode in (SELECT   AcntCode	FROM  #tblAcntCode    ) )'
		
	end 
	
Delete From  #tblAcntCode where AcntCode='' or AcntCode is null
Delete From  #tblOurBanks where CreditCode='' or CreditCode is null

end
------------------------------------------------------------------------------------------------------

		set @StrSelect = @StrSelect + '
	ORDER BY  PD.DocDate,PD.VolumeFiscalYear, PD.VolumeRowNo, PD.EventNo'
	
	print @StrSelect;
	Exec sp_executesql @StrSelect;
End
GO
