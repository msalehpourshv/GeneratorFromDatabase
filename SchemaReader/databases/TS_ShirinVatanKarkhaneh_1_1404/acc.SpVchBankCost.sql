USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/07/04
-- Viewed By	 : Majid Mohammadi
-- Last Modified : 86/11/23
-- Description   : 
-- =============================================
CREATE PROCEDURE [acc].[SpVchBankCost]
	@intVchNo				Int,
	@intDocStep				TinyInt,
    @strVchDate				Char(10),
	@intSourceProcessID		TinyInt,
	@intSourceProcessNo		TinyInt,
	@intSourceFiscalYear	SmallInt,
	@intSourceSerialNo		Int,
	@intMaxRowNo			Int,
	@intMaxDocRowNo			Int,
	@SessionNo				Int,
	@LanguageID				TinyInt
	WITH ENCRYPTION
AS

BEGIN

	-----
	Declare @strMsgText	 NVarChar(2044)
	Declare @PayTypeID	Tinyint
	Declare @CostAmount		Bigint
	Declare @DescDtl	Nvarchar(200)	
	Declare @DebitCode	Varchar(20)
	Declare @ChequeNo	Bigint
	Declare @ChequeDate	Char(10)
	Declare @CostAcntCode	Varchar(20)
	Declare @AcntCode1	Varchar(20)
	Declare @strInsertOfBankCostsAtVoucher VarChar(6)
    Declare @intSum		INT
	DECLARE @strSourceProcessNo VARCHAR(100)
	IF  @intSourceProcessNo< 2
		SET @strSourceProcessNo = ''
	ELSE
		SET @strSourceProcessNo = LTRIM(RTRIM(STR(@intSourceProcessNo)))
		
	Declare @strRecDesc NVarChar(500)
	SET @strRecDesc=' سند هزینه بانکی ' + @strSourceProcessNo + ' شماره' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) +
					' - ' + @strVchDate
	SET @intSum=0
	--------------------------------------------------------------------------------------------------------
	SELECT @strInsertOfBankCostsAtVoucher = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'InsertOfBankCostsAtVoucher'

	-----
	DECLARE @DescHdr NVarchar(300)

	SELECT	@AcntCode1 = AcntCode1, @DescHdr = DescHdr
	FROM trs.tblOurBanks OB ,
		(SELECT OurBankCode,DescHdr
		 FROM	trs.tblPettyCashHdr
		 WHERE	ProcessID=@intSourceProcessID AND
				ProcessNo=@intSourceProcessNo AND
				FiscalYear=@intSourceFiscalYear AND
				SerialNo=@intSourceSerialNo ) PC
	WHERE OB.BankCode=PC.OurBankCode

	IF @AcntCode1 = ''
		BEGIN
			--کد حسابداری موجودی بانک خالی است
			SET @strMsgText=TS.pub.funGetMessages(11004,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END
	-----
	
	Declare	Cursor_PayDtl CURSOR For 
	SELECT	CostAcntCode,CostAmount,DescDtl
	FROM trs.tblPettyCashDtl RD
	WHERE RD.ProcessID=@intSourceProcessID AND
		  RD.ProcessNo=@intSourceProcessNo AND
		  RD.FiscalYear=@intSourceFiscalYear AND
		  RD.SerialNo=@intSourceSerialNo 

	Open  Cursor_PayDtl; 

	Fetch NEXT From Cursor_PayDtl Into @CostAcntCode,@CostAmount,@DescDtl

	While (@@Fetch_Status = 0)
		BEGIN
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@CostAcntCode,@CostAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@DescDtl,0 )			

			IF @strInsertOfBankCostsAtVoucher = 'False'
				BEGIN
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								@AcntCode1,0,@CostAmount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@DescHdr,0)			

				END
			ELSE		
				SET @intSum=@intSum + @CostAmount

			Fetch NEXT From Cursor_PayDtl Into @CostAcntCode,@CostAmount,@DescDtl
		END

	Close Cursor_PayDtl;
	Deallocate Cursor_PayDtl; 

	IF @strInsertOfBankCostsAtVoucher = 'True'
		BEGIN
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@AcntCode1,0,@intSum,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@DescHdr,0)			
		END
		
END






























GO
