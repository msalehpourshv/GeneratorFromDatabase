USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 87/06/21
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE acc.SpVchAdvance
	@intVchNo				Int,
	@intDocStep				TinyInt,
    @strVchDate				Char(10),
	@intSourceProcessID		SmallInt,
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
	
	Declare @strMsgText				NVarChar(2044)

	Declare @PersonnelID			Varchar(20)
	Declare @AcntCode				Varchar(20)
	Declare @AcntAdvance			Varchar(20)
	Declare @AcntPayedLoan			Varchar(20)
	Declare @strRecDesc				NVarChar(1000)
	Declare @SumAdvance				Float
	Declare @Amount					Float
	Declare @AdvanceType			Float
	Declare @DescHdr					NVarChar(1000)
	Declare @DescDtl					NVarChar(1000)

	--------------------------------------------------------------------------------------------------------
	-----
	SET @SumAdvance = 0

	-----
	
	SET @strRecDesc = 'سند مساعده ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 
	
	
	SELECT @AcntCode = AcntCode ,@AdvanceType = AdvanceType ,@DescHdr= DocDesc
	FROM prs.tblAdvancesHdr 
	WHERE SerialNo = @intSourceSerialNo 

	--SELECT  AcntCode , AcntCodeLoan , AdvanceType 
	--FROM prs.tblAdvancesHdr 
	--WHERE SerialNo = @intSourceSerialNo 


		Declare	curAdvance CURSOR For 
		SELECT	PersonnelID, Amount, AcntPayedLoan,DescDtl
		FROM prs.tblAdvancesDtl
		WHERE SerialNo = @intSourceSerialNo
	
		Open  curAdvance; 
			
		Fetch NEXT From curAdvance Into @PersonnelID,@Amount,@AcntPayedLoan,@DescDtl
	
		While (@@Fetch_Status = 0)
		
			BEGIN
			
				IF @Amount <> 0
					BEGIN
						SET @AcntAdvance = ''

						SELECT TOP 1 @AcntAdvance = AcntAdvance 
						FROM prs.tblDecreeHdr
						WHERE PersonnelID = @PersonnelID AND PersonnelID <>''
						ORDER BY SerialNo Desc
						if @AdvanceType=3
							BEGIN
								IF @AcntPayedLoan = ''
								BEGIN								
									Close curAdvance;
									Deallocate curAdvance; 	
								
									--کد حسابداری وام برای سند وام خالی است'
									SET @strMsgText=' کد حسابداری وام برای سند وام خالی است'
									Raiserror (@strMsgText,16,1,'')
									Return
								END
								set @strRecDesc=replace(@strRecDesc,'مساعده','وام')

								set @AcntAdvance=@AcntPayedLoan
							END
						IF @AcntAdvance = ''
							BEGIN
								
								Close curAdvance;
								Deallocate curAdvance; 	
								
								--کد مساعده به شماره پرسنلی %s خالی است
								SET @strMsgText=TS.pub.funGetMessages(20001,@LanguageID)
								Raiserror (@strMsgText,16,1,@PersonnelID)
								Return

							END

						SET @SumAdvance = @SumAdvance + @Amount 
						
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
			
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @AcntAdvance,@Amount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescDtl)) ,0)	
					END
	
				Fetch NEXT From curAdvance Into @PersonnelID,@Amount,@AcntPayedLoan,@DescDtl
			END
	
		Close curAdvance;
		Deallocate curAdvance; 	

	---------- 

	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @AcntCode,0,@SumAdvance,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0 )	


END
GO
