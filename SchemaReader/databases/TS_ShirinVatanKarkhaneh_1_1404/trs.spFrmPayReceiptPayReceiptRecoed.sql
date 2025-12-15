USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/07/04
-- Viewed By	 : Majid Mohammadi
-- Last Modified : 86/11/23
-- Description   : Control Receipt Saving
-- =============================================
Create PROCEDURE [trs].[spFrmPayReceiptPayReceiptRecoed]
	@ProcessID		  tinyint,
	@ProcessNo		  tinyint,
	@FiscalYear       SmallInt=NULL,
	@VolumeFiscalYear SmallInt=NULL,
	@VolumeRowNo      int=NULL,
	@ChequeNo         Varchar(40)=NULL,
	@Code		      Varchar(20)=NULL,
	@LanguageID       int,
	@IsCounter        bit = 0,
	@LastFiscalYear   SmallInt=NULL	,
	@CallType  SmallInt=0
WITH ENCRYPTION
AS

BEGIN

Declare @strMsgText		NVarChar(2044)
DECLARE @LastProcessID	tinyint
DECLARE @strSql			NVARCHAR(4000)
DECLARE @ErrMessage		NVarChar(200)
DECLARE	@PayTypeID		VARCHAR(10)
DECLARE	@CreditOrDebit	VARCHAR(15)
DECLARE	@intCount		INT

SET @LastProcessID=0
SET @strMsgText = ''

DECLARE @Acc_VchKindInRow BIT
SET @Acc_VchKindInRow  = 'False'

SELECT @Acc_VchKindInRow = isnull(SettingValue, 0)
FROM pub.tblSettings
WHERE SettingKey = 'Acc_VchKindInRow'

-------------------------------------
IF @VolumeRowNo IS NULL
BEGIN
	-------------------------------------
	IF @ProcessID=27 OR @ProcessID=28
	BEGIN

		IF @IsCounter = 'True'
			BEGIN
				SELECT @intCount = COUNT(*)
				FROM (Select VolumeFiscalYear,VolumeRowNo,ChequeNo
					From trs.tblPayDtl 
					WHERE PayTypeID IN (7,8,28) AND ChequeNo = @ChequeNo
					--AND (@Acc_VchKindInRow='False' OR (@Acc_VchKindInRow='True' AND [trs].[funPayedChequeVchKind](VolumeFiscalYear,VolumeRowNo)=0 )  )
					GROUP BY VolumeFiscalYear,VolumeRowNo,ChequeNo)A
			
			    SELECT @intCount ChequeCount
			    return
			END
		ELSE
			Select TOP 1 @LastProcessID=ProcessID,@VolumeFiscalYear=VolumeFiscalYear,@VolumeRowNo=VolumeRowNo 
			From trs.tblPayDtl 
			WHERE PayTypeID IN (7,8,28) AND ChequeNo = @ChequeNo
			--AND (@Acc_VchKindInRow='False' OR (@Acc_VchKindInRow='True' AND [trs].[funPayedChequeVchKind](VolumeFiscalYear,VolumeRowNo)=0 )  )
			ORDER BY EventNo Desc
		
	END

	-------------------------------------
	ELSE IF @ProcessID=32 
	BEGIN
		IF @IsCounter = 'True'
			begin
				SELECT @intCount = COUNT(*)
				FROM (Select VolumeFiscalYear,VolumeRowNo,ChequeNo
					From trs.tblPayDtl 
					WHERE PayTypeID  IN (16,31,34)  AND ChequeNo = @ChequeNo
					GROUP BY VolumeFiscalYear,VolumeRowNo,ChequeNo) A
				
			    SELECT @intCount ChequeCount
			    RETURN
			END
		ELSE
			Select TOP 1 @LastProcessID=ProcessID,@VolumeFiscalYear=VolumeFiscalYear,@VolumeRowNo=VolumeRowNo 
			From trs.tblPayDtl 
			WHERE PayTypeID IN (16,31,34) AND ChequeNo = @ChequeNo
			ORDER BY EventNo Desc

	END

	-------------------------------------
	ELSE IF @ProcessID=34 
	BEGIN
		IF @IsCounter = 'True'
			BEGIN
				SELECT @intCount = COUNT(*)
				FROM (Select VolumeFiscalYear,VolumeRowNo,ChequeNo
						From trs.tblPayDtl 
						WHERE PayTypeID IN (18,32,33) AND ChequeNo = @ChequeNo
						GROUP BY VolumeFiscalYear,VolumeRowNo,ChequeNo ) A
				
			    SELECT @intCount ChequeCount
			    RETURN
			END
		ELSE
			Select TOP 1 @LastProcessID=ProcessID,@VolumeFiscalYear=VolumeFiscalYear,@VolumeRowNo=VolumeRowNo 
			From trs.tblPayDtl 
			WHERE PayTypeID  IN (18,32,33) AND ChequeNo = @ChequeNo
			ORDER BY EventNo Desc

	END

	-------------------------------------
	ELSE 
	BEGIN
		IF @IsCounter = 'True'
			BEGIN

				DECLARE @strQ Nvarchar(4000)
				SET @strQ = 'SELECT COUNT(*) ChequeCount --A.VolumeFiscalYear,A.VolumeRowNo,A.ChequeNo,ProcessID,ProcessNo,FiscalYear,SerialNo,B.EventNo
				FROM  (Select VolumeFiscalYear,VolumeRowNo,ChequeNo,MAX(EventNo) EventNo
				From trs.tblPayDtl 
				WHERE PayTypeID IN (6,26) AND ChequeNo = ''' + @ChequeNo + '''
				GROUP BY VolumeFiscalYear,VolumeRowNo,ChequeNo) A  
				INNER JOIN 
				(Select ProcessID,ProcessNo,FiscalYear,SerialNo,VolumeFiscalYear,VolumeRowNo,ChequeNo,EventNo
				From trs.tblPayDtl 
				WHERE PayTypeID IN (6,26) AND ChequeNo = ''' + @ChequeNo + ''') B
				ON A.EventNo=B.EventNo AND A.VolumeFiscalYear=B.VolumeFiscalYear AND A.VolumeRowNo=B.VolumeRowNo
				WHERE ProcessNo=' + LTRIM(STR(@ProcessNo)) + '  AND ( ProcessID IN (1,10,17,23,40) AND (' + LTRIM(STR(@ProcessID)) + ' IN (12,13,21))) OR 
				      (ProcessID = 2 AND (' + LTRIM(STR(@ProcessID)) + ' IN (17,18)))  OR 
				      ( ProcessID IN (20,21) AND (' + LTRIM(STR(@ProcessID)) + ' IN (22,23,24)))'

				Exec sp_executesql @strQ;
								
				RETURN			    
			END
		ELSE
			BEGIN
				DECLARE @strQ1 Nvarchar(4000)
				DECLARE @ParmDefinition Nvarchar(4000)
				SET @strQ1 = 'SELECT @LastProcessID1=ProcessID, @VolumeFiscalYear1=A.VolumeFiscalYear,@VolumeRowNo1=A.VolumeRowNo
				FROM  (Select VolumeFiscalYear,VolumeRowNo,ChequeNo,MAX(DocDate) DocDate,MAX(EventNo) EventNo
				From trs.tblPayDtl 
				WHERE PayTypeID IN (6,26) AND ChequeNo = ''' + @ChequeNo + '''
				GROUP BY VolumeFiscalYear,VolumeRowNo,ChequeNo) A  
				INNER JOIN 
				(Select ProcessID,ProcessNo,FiscalYear,SerialNo,VolumeFiscalYear,VolumeRowNo,ChequeNo,EventNo,DocDate
				From trs.tblPayDtl 
				WHERE PayTypeID IN (6,26) AND ChequeNo = ''' + @ChequeNo + ''') B
				ON A.EventNo=B.EventNo AND A.VolumeFiscalYear=B.VolumeFiscalYear AND A.VolumeRowNo=B.VolumeRowNo AND A.DocDate=B.DocDate
				WHERE ProcessNo=' + LTRIM(STR(@ProcessNo)) + '  AND ( ProcessID IN (1,10,17,23,40) AND (' + LTRIM(STR(@ProcessID)) + ' IN (12,13,21))) OR 
				      (ProcessID = 2 AND (' + LTRIM(STR(@ProcessID)) + ' IN (17,18)))  OR 
				      ( ProcessID IN (20,21) AND (' + LTRIM(STR(@ProcessID)) + ' IN (22,23,24)))'

				SET @ParmDefinition = N'@LastProcessID1 SmallInt OUTPUT,@VolumeFiscalYear1 SmallInt OUTPUT,@VolumeRowNo1 Int OUTPUT';

				Exec sp_executesql @strQ1,@ParmDefinition,@LastProcessID1 = @LastProcessID OUTPUT,@VolumeFiscalYear1 = @VolumeFiscalYear OUTPUT,@VolumeRowNo1 = @VolumeRowNo OUTPUT;
			
				IF @LastProcessID = 0
					BEGIN
						SET @strQ1 = 'SELECT TOP 1 @LastProcessID1=ProcessID, @VolumeFiscalYear1=A.VolumeFiscalYear,@VolumeRowNo1=A.VolumeRowNo
						FROM  (Select VolumeFiscalYear,VolumeRowNo,ChequeNo,MAX(DocDate) DocDate,MAX(EventNo) EventNo
						From trs.tblPayDtl 
						WHERE ProcessNo=' + LTRIM(STR(@ProcessNo)) + '  AND PayTypeID IN (6,26) AND ChequeNo = ''' + @ChequeNo + '''
						GROUP BY VolumeFiscalYear,VolumeRowNo,ChequeNo) A  
						INNER JOIN 
						(Select ProcessID,ProcessNo,FiscalYear,SerialNo,VolumeFiscalYear,VolumeRowNo,ChequeNo,EventNo,DocDate
						From trs.tblPayDtl 
						WHERE ProcessNo=' + LTRIM(STR(@ProcessNo)) + '  AND PayTypeID IN (6,26) AND ChequeNo = ''' + @ChequeNo + ''') B
						ON A.EventNo=B.EventNo AND A.VolumeFiscalYear=B.VolumeFiscalYear AND A.VolumeRowNo=B.VolumeRowNo AND A.DocDate=B.DocDate'

						SET @ParmDefinition = N'@LastProcessID1 SmallInt OUTPUT,@VolumeFiscalYear1 SmallInt OUTPUT,@VolumeRowNo1 Int OUTPUT';

						Exec sp_executesql @strQ1,@ParmDefinition,@LastProcessID1 = @LastProcessID OUTPUT,@VolumeFiscalYear1 = @VolumeFiscalYear OUTPUT,@VolumeRowNo1 = @VolumeRowNo OUTPUT;
					END

			END	
	END

END

-------------------------------------
ELSE -- IF @VolumeRowNo IS NOT NULL
BEGIN
	-------------------------------------
	IF @ProcessID=27 OR @ProcessID=28
	BEGIN

		Select TOP 1 @LastProcessID=ProcessID
        From trs.tblPayDtl
        WHERE PayTypeID IN (8,28) AND 
              VolumeFiscalYear =@VolumeFiscalYear AND
              VolumeRowNo = @VolumeRowNo
		-- AND (@Acc_VchKindInRow='False' OR (@Acc_VchKindInRow='True' AND [trs].[funPayedChequeVchKind](@VolumeFiscalYear,@VolumeRowNo)=0 )  )
        ORDER BY EventNo Desc

	END

	-------------------------------------
	ELSE IF @ProcessID=32 
	BEGIN

		Select TOP 1 @LastProcessID=ProcessID
        From trs.tblPayDtl
        WHERE PayTypeID  IN (16,31,34) AND 
              VolumeFiscalYear =@VolumeFiscalYear 
			  AND VolumeRowNo = @VolumeRowNo
			  AND ProcessNo = @ProcessNo
        ORDER BY EventNo Desc

	END

	-------------------------------------
	ELSE IF @ProcessID=34 
	BEGIN

		Select TOP 1 @LastProcessID=ProcessID
        From trs.tblPayDtl
        WHERE PayTypeID  IN (18,32,33) AND 
              VolumeFiscalYear =@VolumeFiscalYear AND
              VolumeRowNo = @VolumeRowNo
        ORDER BY EventNo Desc

	END

	-------------------------------------
	ELSE 
	BEGIN
		declare @LastTempFiscalYear smallint
		if NOT(@LastFiscalYear IS NULL)
			SET @LastTempFiscalYear = @VolumeFiscalYear
		ELSE
			SET @LastTempFiscalYear = @LastFiscalYear
			
		IF @FiscalYear <> @VolumeFiscalYear AND 
		   (select COUNT(*) from sys.databases WHERE [name]=LEFT(db_name(), Len(db_name()) - 4) +  LTRIM(STR(@LastFiscalYear)))=1
			BEGIN
				DECLARE @str Nvarchar(4000)
				
						SET @str = 'INSERT INTO trs.tblPayHdr
							SELECT A.* FROM ' + LEFT(db_name(), Len(db_name()) - 4) +  LTRIM(STR(@LastFiscalYear)) + '.trs.tblPayHdr A
							INNER JOIN 
							(SELECT H.ProcessID,H.ProcessNo,H.FiscalYear,H.SerialNo 
							 FROM (
									SELECT H.ProcessID,H.ProcessNo,H.FiscalYear,H.SerialNo FROM ' + LEFT(db_name(), Len(db_name()) - 4) + LTRIM(STR(@LastFiscalYear)) + '.trs.tblPayHdr H
									EXCEPT
									SELECT H.ProcessID,H.ProcessNo,H.FiscalYear,H.SerialNo FROM trs.tblPayHdr 	H
								  ) H
							 INNER JOIN ' + LEFT(db_name(), Len(db_name()) - 4) + LTRIM(STR(@LastFiscalYear)) + '.trs.tblPayDtl D
							 ON  H.ProcessID = D.ProcessID AND H.ProcessNo =D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo = D.SerialNo 
							 AND D.ProcessNo=' + LTRIM(STR(@ProcessNo)) + ' AND D.ProcessID <= 28 AND VolumeFiscalYear = ' + LTRIM(STR(@VolumeFiscalYear)) + ' AND VolumeRowNo =' + LTRIM(STR(@VolumeRowNo)) + '
							 EXCEPT 
							 SELECT H.ProcessID,H.ProcessNo,H.FiscalYear,H.SerialNo FROM trs.tblPayHdr H
							 INNER JOIN  trs.tblPayDtl D
							 ON  H.ProcessID = D.ProcessID AND H.ProcessNo =D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo = D.SerialNo 
							 AND D.ProcessID <= 28 AND VolumeFiscalYear =  ' + LTRIM(STR(@VolumeFiscalYear)) + ' AND VolumeRowNo =' + LTRIM(STR(@VolumeRowNo)) + ' ) B
							 ON A.ProcessID=B.ProcessID AND A.ProcessNo=B.ProcessNo AND A.FiscalYear=B.FiscalYear AND A.SerialNo=B.SerialNo; '

						SET @str = @str + '
						    INSERT INTO trs.tblPayDtl
							(ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocDate, PayTypeID, DebitCode, CreditCode, Amount, CurrencyTypeID, CurrencyRate, ChequeNo, ChequeBookFiscalYear, ChequeBookID, ChequeDate, VolumeFiscalYear, VolumeRowNo, EventNo, LocationID, BankTypeID, BranchCode, BranchName, BankSnNo, AccountNo, AccOwnerName, LocationID2, BankTypeID2, BranchCode2, BranchName2, AccountNo2, AccOwnerName2, DeliverTo, RowDesc, DocRowNo, IsConfirmed, AccountOwnerType, BaseSerialNo, BaseFiscalYear, WithdrawType, CurrencyAmount, VisitorAcntCode, EndDate_PayableTrust, SourceSerialNo, SourceProcessNo, WithAcntCode)
							SELECT A.ProcessID, A.ProcessNo, A.FiscalYear, A.SerialNo, A.RowNo, A.DocDate, A.PayTypeID, A.DebitCode, 
							       A.CreditCode, A.Amount, A.CurrencyTypeID, A.CurrencyRate, A.ChequeNo, A.ChequeBookFiscalYear, 
								   A.ChequeBookID, A.ChequeDate, A.VolumeFiscalYear, A.VolumeRowNo, A.EventNo, A.LocationID, A.BankTypeID, 
								   A.BranchCode, A.BranchName, A.BankSnNo, A.AccountNo, A.AccOwnerName, A.LocationID2, A.BankTypeID2, 
								   A.BranchCode2, A.BranchName2, A.AccountNo2, A.AccOwnerName2, A.DeliverTo, A.RowDesc, A.DocRowNo, 
								   A.IsConfirmed, A.AccountOwnerType, A.BaseSerialNo, A.BaseFiscalYear, A.WithdrawType, A.CurrencyAmount, 
								   A.VisitorAcntCode, A.EndDate_PayableTrust, A.SourceSerialNo, A.SourceProcessNo, A.WithAcntCode 
							FROM ' + LEFT(db_name(), Len(db_name()) - 4) + LTRIM(STR(@LastFiscalYear)) + '.trs.tblPayDtl A
							INNER JOIN 
							(SELECT ProcessID,ProcessNo,FiscalYear,SerialNo,RowNo,VolumeFiscalYear,VolumeRowNo 
							 FROM ' + LEFT(db_name(), Len(db_name()) - 4) + LTRIM(STR(@LastFiscalYear)) + '.trs.tblPayDtl
                             WHERE PayTypeID in (6,26) AND ProcessNo=' + LTRIM(STR(@ProcessNo)) + '  AND ProcessID <= 28 AND VolumeFiscalYear = ' + LTRIM(STR(@VolumeFiscalYear)) + 'AND VolumeRowNo =' + LTRIM(STR(@VolumeRowNo)) + '
 							 EXCEPT 
                             SELECT ProcessID,ProcessNo,FiscalYear,SerialNo,RowNo,VolumeFiscalYear,VolumeRowNo FROM trs.tblPayDtl
                             WHERE PayTypeID in (6,26) AND ProcessNo=' + LTRIM(STR(@ProcessNo)) + '  AND ProcessID <= 28 AND VolumeFiscalYear = ' + LTRIM(STR(@VolumeFiscalYear)) + 'AND VolumeRowNo =' + LTRIM(STR(@VolumeRowNo)) + ' 
                             ) B
                             ON A.ProcessID=B.ProcessID AND A.ProcessNo=B.ProcessNo AND A.FiscalYear=B.FiscalYear AND A.SerialNo=B.SerialNo AND A.RowNo=B.RowNo'
						PRINT @str
						Exec sp_executesql @str;
			END
		
		Select TOP 1 @LastProcessID=ProcessID 
        From trs.tblPayDtl
        WHERE PayTypeID IN (6,26) AND
              VolumeFiscalYear = @VolumeFiscalYear AND
              VolumeRowNo = @VolumeRowNo
		ORDER BY EventNo Desc
	
	END
	
END  --IF @ChequeNo<>""


IF (@LastProcessID=1 OR @LastProcessID=10 OR @LastProcessID=17 OR @LastProcessID=23) AND 
		(@ProcessID=12 OR @ProcessID=13 OR @ProcessID=21)
	BEGIN
		DECLARE @DebitCode VARCHAR(20)
		
		Select TOP 1 @DebitCode=DebitCode 
		From trs.tblPayDtl
		WHERE PayTypeID IN (6,26) AND
			  VolumeFiscalYear = @VolumeFiscalYear AND
			  VolumeRowNo = @VolumeRowNo
		ORDER BY EventNo Desc
		
		IF @DebitCode <> @Code
			BEGIN
				--اين چك در صندوق %s است
				SET @strMsgText=TS.pub.funGetMessages(12078,@LanguageID)
				Raiserror (@strMsgText,16,1,@DebitCode)
				return
			END
	END	
-------------------------------------
IF @LastProcessID=0
BEGIN
	--چنين شماره اي وجود ندارد
	SET @strMsgText=TS.pub.funGetMessages(12034,@LanguageID)
	Raiserror (@strMsgText,16,1)
	return
END

---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
IF  @ProcessID=27 OR @ProcessID=28
BEGIN 
	IF @LastProcessID=27 
		--اين چك قبلا وصول شده است
		SET @strMsgText=TS.pub.funGetMessages(12035,@LanguageID)

	ELSE IF @LastProcessID=28
		--اين چك قبلا برگشت داده شده است
		SET @strMsgText=TS.pub.funGetMessages(12036,@LanguageID)
	
	ELSE IF @Acc_VchKindInRow='True' AND (SELECT [trs].[funPayedChequeVchKind](@VolumeFiscalYear,@VolumeRowNo))>0 
		SET @strMsgText='سند پرداخت این چک یادداشت  می باشد'

 END

-------------------------------------
ELSE IF @ProcessID=12 OR @ProcessID=13 OR @ProcessID=17 OR @ProcessID=18 OR 
		@ProcessID=21 OR @ProcessID=22 OR @ProcessID=23 OR @ProcessID=24
BEGIN
	IF (@LastProcessID=1 OR @LastProcessID=10 OR @LastProcessID=17 OR @LastProcessID=23) AND 
		Not (@ProcessID=12 OR @ProcessID=13 OR @ProcessID=21)
		--این چک از صندوق خارج نشده است
		SET @strMsgText=TS.pub.funGetMessages(12076,@LanguageID)

	IF @LastProcessID=2 AND Not (@ProcessID=17 OR @ProcessID=18)
			--این چک به شخص واگذار شده است
			SET @strMsgText=TS.pub.funGetMessages(12075,@LanguageID)
	ELSE IF @LastProcessID=12
		--اين چك قبلا وصول شده است
		SET @strMsgText=TS.pub.funGetMessages(12035,@LanguageID)

	ELSE IF @LastProcessID=13 and @CallType=0
		--اين چك قبلا برگشت داده شده است
		SET @strMsgText=TS.pub.funGetMessages(12036,@LanguageID)

	ELSE IF @LastProcessID=18  and @CallType=0
		--اين چك قبلا از اشخاص به صاحبش برگشت داده شده است
		SET @strMsgText=TS.pub.funGetMessages(12038,@LanguageID)

	ELSE IF (@LastProcessID=20 OR @LastProcessID=21) AND 
			NOT (@ProcessID=22 OR @ProcessID=23 OR @ProcessID=24)
		--اين چك قبلا به بانك واگذار شده است
		SET @strMsgText=TS.pub.funGetMessages(12039,@LanguageID)

	ELSE IF @LastProcessID=22
		--اين چك قبلا در بانك وصول شده است
		SET @strMsgText=TS.pub.funGetMessages(12040,@LanguageID)

	ELSE IF @LastProcessID=24 and @CallType=0
		--اين چك قبلا از بانك به صاحبش برگشت داده شده است
		SET @strMsgText=TS.pub.funGetMessages(12041,@LanguageID)

END
-------------------------------------
ELSE IF @ProcessID=32 
BEGIN
	IF @LastProcessID=32
		--اين چك قبلا مسترد شده است
		SET @strMsgText=TS.pub.funGetMessages(12037,@LanguageID)
END

-------------------------------------
ELSE IF @ProcessID=34 
BEGIN
	IF @LastProcessID=34
		--اين چك قبلا مسترد شده است
		SET @strMsgText=TS.pub.funGetMessages(12037,@LanguageID)
END


-------------------------------------
IF @strMsgText <> ''
BEGIN
	Raiserror (@strMsgText,16,1)
	Return
END

-------------------------------------
IF @ProcessID=27 OR @ProcessID=28
	SET @PayTypeID='8,28'
ELSE IF @ProcessID=12 OR  @ProcessID=13
	SET @PayTypeID='6,26'
ELSE IF @ProcessID=32 
	SET @PayTypeID='16,31,34'
ELSE IF @ProcessID=34 
	SET @PayTypeID='18,32,33'
ELSE
	SET @PayTypeID='6,26'

-------------------------------------

set @strSql=
   N'SELECT TOP 1 
			ProcessID,
			ProcessNo,
			FiscalYear,
			SerialNo,
			RowNo,
			DocDate,
			PayTypeID,
			DebitCode,
			CreditCode,
			Amount,
			CurrencyTypeID,
			CurrencyRate,
			ChequeNo,
			ChequeBookFiscalYear,
			ChequeBookID,
			ChequeDate,
			VolumeFiscalYear,
			VolumeRowNo,
			EventNo,
			LocationID,
			BankTypeID,
			BranchCode,
			BranchName,
			BankSnNo,
			AccountNo,
			AccOwnerName,
			LocationID2,
			BankTypeID2,
			BranchCode2,
			BranchName2,
			AccountNo2,
			AccOwnerName2,
			DeliverTo,
			RowDesc,
			DocRowNo,
			IsConfirmed,
			AccountOwnerType,
			BaseSerialNo,
			BaseFiscalYear,
			WithdrawType,
			CurrencyAmount,
			EndDate_PayableTrust,
			SourceSerialNo,
			SourceProcessNo,
			WithAcntCode,
			ID,
			FollowAcntCode,
			ReceiptAcntCode,
			ChequeNoNew,
			ChequeCryptNo,
			RegChequeNoNewIN,
			RegChequeNoNewOut,
			NationalIDNumber,
			TargetBankID,
			TargetLocationID,
			TargetChequeNoNew,
			TargetCustomerName,
			ChequeIsDigital,
			FollowUpNumber,
			isnull((SELECT BankName FROM trs.tblOurBanksDtl b where b.BankCode = CreditCode and LanguageID = 1),'''') CreditName,
			pub.funGetBankTypeName(PD.BankTypeID,' + Ltrim(Str(@LanguageID)) + ') AS BankTypeName,
			isnull([trs].[funGetPayChequeCustomer](VolumeFiscalYear,VolumeRowNo) ,'''') AS CustomerCode,
			CASE WHEN ProcessID = 2 AND PayTypeID IN (6,26) THEN [pub].[GetCodeName](DebitCode,' + Ltrim(Str(@LanguageID)) + ') ELSE pub.GetCodeName([trs].[funGetPayChequeCustomer](VolumeFiscalYear,VolumeRowNo),' + Ltrim(Str(@LanguageID)) + ') END CustomerName,
			isnull([trs].[funGetPayChequeCustomer](VolumeFiscalYear,VolumeRowNo) ,'''') AS PayChequeCustomerCode,
			CASE WHEN ProcessID = 2 AND PayTypeID IN (6,26) THEN [pub].[GetCodeName](DebitCode,' + Ltrim(Str(@LanguageID)) + ') ELSE pub.GetCodeName([trs].[funGetPayChequeCustomer](VolumeFiscalYear,VolumeRowNo),' + Ltrim(Str(@LanguageID)) + ') END PayChequeCustomerName,
			pub.funGetLocationName(PD.LocationID,' + Ltrim(Str(@LanguageID)) + ') AS LocationName,
			pub.funGetCurrencyTypesName(PD.CurrencyTypeID,' + Ltrim(Str(@LanguageID)) + ') AS CurrencyTypeName,
			isnull(CASE WHEN PayTypeID in (7,8,27,18) THEN [trs].[funGetPayChequeOwner](VolumeFiscalYear,VolumeRowNo,PayTypeID) ELSE [trs].[funGetChequeOwner](VolumeFiscalYear,VolumeRowNo,PayTypeID) END ,'''') FirstCreditCode ,
			isnull([pub].[GetCodeName](CASE WHEN PayTypeID in (7,8,27,18) THEN [trs].[funGetPayChequeOwner](VolumeFiscalYear,VolumeRowNo,PayTypeID) ELSE [trs].[funGetChequeOwner](VolumeFiscalYear,VolumeRowNo,PayTypeID) END,' + Ltrim(Str(@LanguageID)) + ') ,'''') FirstCreditName,
			isnull([pub].[GetCodeName](PD.WithAcntCode,' + Ltrim(Str(@LanguageID)) + ')  ,'''')As WithName,
			Case when ' + Ltrim(Str(@ProcessID)) + ' in (13,18,24) then  isnull(CASE WHEN PayTypeID in (7,8,27,18) THEN [trs].[funGetPayChequeOwnerVisitor](VolumeFiscalYear,VolumeRowNo,PayTypeID) ELSE [trs].[funGetChequeOwnerVisitor](VolumeFiscalYear,VolumeRowNo,PayTypeID) END ,'''')  
			else VisitorAcntCode end  VisitorAcntCode,
			Case when ' + Ltrim(Str(@ProcessID)) + '  in (13,18,24) then  isnull([pub].[GetCodeName](CASE WHEN PayTypeID in (7,8,27,18) THEN [trs].[funGetPayChequeOwnerVisitor](VolumeFiscalYear,VolumeRowNo,PayTypeID) ELSE [trs].[funGetChequeOwnerVisitor](VolumeFiscalYear,VolumeRowNo,PayTypeID) END,' + Ltrim(Str(@LanguageID)) + ') ,'''')  
			else  pub.GetCodeName(VisitorAcntCode, 1) end VisitorAcntName
	FROM trs.tblPayDtl PD
	WHERE ProcessNo=' + LTRIM(STR(@ProcessNo)) + '  AND 
	      VolumeFiscalYear=' + Ltrim(Str(@VolumeFiscalYear)) + ' AND 
		  VolumeRowNo=' + Ltrim(Str(@VolumeRowNo)) + ' AND 
		  PayTypeID IN (' + @PayTypeID + ')
	ORDER BY EventNo Desc'

	PRINT @strSql
	EXEC sp_executesql @strSql;

END
GO
