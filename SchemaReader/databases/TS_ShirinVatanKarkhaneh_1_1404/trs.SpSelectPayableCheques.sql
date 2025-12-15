USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- ==============================================
-- Author: Sadeghi, Hadi
-- Create Date:(1386/07/07)
-- Description: <Store Documents>
-- ==============================================
Create PROCEDURE [trs].[SpSelectPayableCheques]
    @CreditCode				VarChar(20)= Null,
	@SerialNoFrom			Int = Null,
	@SerialNoTo				Int = Null,
    @DateFrom				VarChar(10) = Null,
	@DateTo					VarChar(10) = Null,
    @DebitFrom				VarChar(20) = Null,
	@DebitTo				VarChar(20) = Null,
    @ChqFrom				BigInt = Null,
	@ChqTo					BigInt = Null,
    @AmountFrom				BigInt = Null,
	@AmountTo				BigInt = Null,
    @DDateFrom				VarChar(10) = Null,
	@DDateTo				VarChar(10) = Null,
	@VolumeFiscalYearFrom	smallint=Null,
	@VolumeRowNoFrom		Int=Null,
	@VolumeFiscalYearTo  	smallint=Null,
	@VolumeRowNoTo		    Int=Null,
	@ProcessID		        TinyInt=Null,
	@ProcessNo		        TinyInt=Null,
	@LanguageID		        Int=Null
WITH ENCRYPTION
AS

BEGIN

DECLARE @strSelect NVarChar(4000) 
DECLARE @PayTypeID VarChar(10) 
DECLARE @TempProcessID VarChar(10) 

--	UPDATE trs.tblPayDtl SET LockerSessionNo = 0
--	WHERE DateAdd(Minute,5,ModifiedDate) < GetDate()
	
--	UPDATE trs.tblPayHdr SET LockerSessionNo = 0
--	WHERE DateAdd(Minute,5,ModifiedDate) < GetDate()
	
IF @ProcessID=27 OR @ProcessID=28
BEGIN	
	SET @PayTypeID='8,28'
	SET @TempProcessID='2,25'
END
ELSE IF @ProcessID=32
BEGIN
	SET @PayTypeID='16,31,34'
	SET @TempProcessID='31'
END
ELSE IF @ProcessID=34
BEGIN
	SET @PayTypeID='18,32,33'
	SET @TempProcessID='33'
END
ELSE IF @ProcessID=0
BEGIN
	SET @PayTypeID='8,28'
	SET @TempProcessID='2,25'
END

	DECLARE @Acc_VchKindInRow BIT
	SET @Acc_VchKindInRow  = 'False'

	SELECT @Acc_VchKindInRow = isnull(SettingValue, 0)
	FROM pub.tblSettings
	WHERE SettingKey = 'Acc_VchKindInRow'

if @LanguageID IS NULL set @LanguageID=1
set @strSelect=
   'SELECT PD4.EventNo ,PD4.VolumeFiscalYear,PD4.VolumeRowNo,
   PD4.ChequeDate,PD4.ChequeNo,PD4.Amount,
   [pub].[funGetLockerSessionNo](PD4.ProcessID,PD4.ProcessNo,
   PD4.FiscalYear,PD4.SerialNo,'''',''trs.tblPayHdr'') LockerSessionNo,
   pub.funGetBankTypeName(PD4.BankTypeID,' + LTRIM(STR(@LanguageID)) + ') AS BankTypeName,
    case when PD3.ProcessID in (2,25,33) then    PD3.DebitCode    else  PD3.CreditCode    end   AS AcntCode ,
   case when PD3.ProcessID in (2,25,33) then    pub.GetCodeName(PD3.DebitCode, ' + LTRIM(STR(@LanguageID)) + ') 
    else  pub.GetCodeName(PD3.CreditCode, ' + LTRIM(STR(@LanguageID)) + ')     end   AS ChequeOwner,
    PD4.PayTypeID
	FROM trs.tblPayDtl PD3,
	(SELECT PD1.*,MaxEventNo 
	 FROM trs.tblPayDtl PD1,
	(SELECT VolumeFiscalYear,VolumeRowNo,MAX(EventNo) AS MaxEventNo ,ProcessNo
	 FROM trs.tblPayDtl 
	 WHERE PayTypeID IN (' + @PayTypeID + ') 
	 group by VolumeFiscalYear,VolumeRowNo,ProcessNo) PD2
	WHERE PD1.VolumeFiscalYear=PD2.VolumeFiscalYear AND 
		  PD1.VolumeRowNo=PD2.VolumeRowNo AND 
		  PD1.ProcessNo=PD2.ProcessNo AND 
		  PD1.PayTypeID IN (' + @PayTypeID + ') AND 
		  ProcessID IN (' + @TempProcessID + ') AND '
IF @ProcessNo >0		   
	set @strSelect=		@strSelect +  ' PD1.ProcessNo IN (' + str(@ProcessNo) + ') AND '
	 
set @strSelect= @strSelect +  ' PD1.EventNo=MaxEventNo) PD4
	WHERE PD3.PayTypeID IN (' + @PayTypeID + ') AND 
		  PD3.EventNo=1 AND
		  PD3.VolumeFiscalYear=PD4.VolumeFiscalYear AND 
		  PD3.VolumeRowNo=PD4.VolumeRowNo AND
		  PD3.ProcessNo = PD4.ProcessNo'

IF @Acc_VchKindInRow = 'True'
   SET @strSelect=@strSelect + ' AND [trs].[funPayedChequeVchKind](PD4.VolumeFiscalYear,PD4.VolumeRowNo)=0 '
 
If not(@CreditCode IS Null)
   SET @strSelect=@strSelect + ' AND PD3.CreditCode=''' + @CreditCode + ''''

If not(@DateFrom IS Null)
   SET @strSelect=@strSelect + ' AND PD3.ChequeDate >=''' + @DateFrom + ''''

If not(@DateTo IS Null)
   SET @strSelect=@strSelect + ' AND PD3.ChequeDate <=''' + @DateTo + ''''
	
If not(@DDateFrom IS Null)
   SET @strSelect=@strSelect + ' AND PD3.DocDate >=''' + @DateFrom + ''''
If not(@DDateTo IS Null)
   SET @strSelect=@strSelect + ' AND PD3.DocDate <=''' + @DateTo + ''''

If not(@ChqFrom IS Null)
   SET @strSelect=@strSelect + ' AND PD3.ChequeNo >=' + LTrim(Str(@ChqFrom)) 
If not(@ChqTo IS Null)
   SET @strSelect=@strSelect + ' AND PD3.ChequeNo <=' + LTrim(Str(@ChqTo)) 

If not(@AmountFrom IS Null)
   SET @strSelect=@strSelect + ' AND PD3.Amount >=' + LTrim(Str(@AmountFrom,30)) 
If not(@AmountTo IS Null)
   SET @strSelect=@strSelect + ' AND PD3.Amount <=' + LTrim(Str(@AmountTo,30)) 

If not(@DebitFrom IS Null)
   SET @strSelect=@strSelect + ' AND PD3.DebitCode >=''' + @DebitFrom + ''''
If not(@DebitTo IS Null)
   SET @strSelect=@strSelect + ' AND PD3.DebitCode <=''' + @DebitTo + ''''

If	Not @SerialNoFrom Is Null 
	SET @strSelect = @strSelect + ' AND PD3.SerialNo >= ' + Str(@SerialNoFrom)
If	Not @SerialNoTo Is Null 
	SET @strSelect = @strSelect + ' AND PD3.SerialNo <= ' + Str(@SerialNoTo) 


If not(@VolumeFiscalYearFrom IS Null)
   SET @strSelect=@strSelect + ' AND PD3.VolumeFiscalYear >=' + LTRIM(STR(@VolumeFiscalYearFrom ))
	
If not(@VolumeRowNoFrom IS Null)
   SET @strSelect=@strSelect + ' AND PD3.VolumeRowNo >=' + LTRIM(STR(@VolumeRowNoFrom ))

If not(@VolumeFiscalYearTo IS Null)
   SET @strSelect=@strSelect + ' AND PD3.VolumeFiscalYear <=' + LTRIM(STR(@VolumeFiscalYearTo ))

If not(@VolumeRowNoTo IS Null)
   SET @strSelect=@strSelect + ' AND PD3.VolumeRowNo <=' + LTRIM(STR(@VolumeRowNoTo))
   
SET @strSelect=@strSelect + ' ORDER BY ChequeDate'
   print @strSelect
	Exec sp_executesql @strSelect;
END
GO
