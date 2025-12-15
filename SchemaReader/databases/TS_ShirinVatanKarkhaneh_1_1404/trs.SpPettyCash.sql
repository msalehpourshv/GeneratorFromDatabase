USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- ==============================================
-- Author: Sadeghi, Hadi
-- Create Date: (1386/07/15)
-- ==============================================
Create PROCEDURE [trs].[SpPettyCash]
	@ProcessID		tinyint,
	@ProcessNo		tinyint,
	@FiscalYear		smallint,
	@SerialNo		int,
	@BankState		TinyInt,
    @OurBankcode	VarChar(20),
	@LanguageID		Tinyint
WITH ENCRYPTION
AS

BEGIN

DECLARE @strMsgText		NVarChar(200)
DECLARE @AcntCode1		varchar(20)
DECLARE @AcntCode2		varchar(20)
DECLARE @AcntCode3		varchar(20)
DECLARE @SumCostAmount	BIGINT
DECLARE @SumAcntCode1	BIGINT
DECLARE @SumAcntCode2	BIGINT
DECLARE @SumAcntCode3	BIGINT
DECLARE @CreditRoof     BIGINT
DECLARE @Difference		BIGINT

SET @SumAcntCode1=0
SET @SumAcntCode2=0
SET @SumAcntCode3=0
SET @Difference=0
SET @SumCostAmount=0

SELECT @AcntCode1=AcntCode1,@AcntCode2=AcntCode2,@AcntCode3=AcntCode3,@CreditRoof=CreditRoof
FROM trs.tblOurBanks
WHERE BankCode= @OurBankcode  

IF (@AcntCode1)=''
  BEGIN 
    --'کد حسابداری موجودی بانک خالی است'
	SET @strMsgText=TS.pub.funGetMessages(12056,@LanguageID)
    raiserror( @strMsgText,16,1)
	Return
  END

SELECT @SumCostAmount=ISNULL(SUM(CostAmount),0)
FROM trs.tblPettyCashDtl PD
WHERE  PD.ProcessID=@ProcessID AND
       PD.ProcessNo=@ProcessNo AND
       PD.FiscalYear=@FiscalYear AND
       PD.SerialNo= @SerialNo
           
SELECT @SumAcntCode1=ISNULL(SUM(Credit-Debit),0) 
FROM acc.tblVoucherDtl
WHERE AcntCode=@AcntCode1 AND 
	  NOT (SourceProcessID=@ProcessID AND
		   SourceProcessNo=@ProcessNo AND
           SourceFiscalYear=@FiscalYear AND
           SourceSerialNo= @SerialNo)

IF @AcntCode2<>'' AND @AcntCode1 <> @AcntCode2
	SELECT @SumAcntCode2=ISNULL(SUM(Credit-Debit),0)  
	FROM acc.tblVoucherDtl
	WHERE AcntCode=@AcntCode2 AND
		  NOT (SourceProcessID=@ProcessID AND
			   SourceProcessNo=@ProcessNo AND
			   SourceFiscalYear=@FiscalYear AND
			   SourceSerialNo= @SerialNo)

IF @AcntCode3 <> '' AND @AcntCode1 <> @AcntCode3 AND @AcntCode2 <> @AcntCode3
	SELECT @SumAcntCode3=ISNULL(SUM(Credit-Debit),0)
	FROM acc.tblVoucherDtl
	WHERE AcntCode=@AcntCode3 AND
		  NOT (SourceProcessID=@ProcessID AND
			   SourceProcessNo=@ProcessNo AND
			   SourceFiscalYear=@FiscalYear AND
			   SourceSerialNo= @SerialNo) 

IF @BankState=2
   BEGIN 
		set @Difference =  (@SumAcntCode1+@SumAcntCode2+@SumAcntCode3)+ @SumCostAmount-@CreditRoof
		if @Difference > 0
			BEGIN 
				DECLARE @strDifference nvarchar(50)
				SET @strDifference = LTRIM(RTRIM(STR(@Difference,20)))
				set @strDifference='   ' +@strDifference + '   '
				 		--' از سقف اعتباری بیشتر است
				SET @strMsgText=TS.pub.funGetMessages(12059,@LanguageID)
				raiserror( @strMsgText,16,1,@strDifference)
				Return
			END 
   END
   
END
GO
