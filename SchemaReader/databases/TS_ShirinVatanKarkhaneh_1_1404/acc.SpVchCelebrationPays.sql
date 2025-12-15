USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 90/11/18
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [acc].[SpVchCelebrationPays]
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
	Declare @AcntSalary				Varchar(20)
	Declare @strRecDesc				NVarChar(1000)
	Declare @SumSalary				Float
	Declare @Amount					Float
	DECLARE @DepartmentID			VARCHAR(20)
	DECLARE @AcntCelebrationPayable	VARCHAR(20)
	--------------------------------------------------------------------------------------------------------
	SET @SumSalary = 0
	-----
	
	SET @strRecDesc = 'سند پرداخت عيدي ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 
	
		Declare	curCelebration CURSOR For 
		SELECT	PersonnelID, Amount
		FROM prs.tblSalaryPaysDtl
		WHERE ProcessID = @intSourceProcessID AND SerialNo = @intSourceSerialNo
	
 		Open  curCelebration; 
			
		Fetch NEXT From curCelebration Into @PersonnelID,@Amount
	
		While (@@Fetch_Status = 0)
			BEGIN
				IF @Amount <> 0
					BEGIN
						SET @AcntSalary = ''
					
						SELECT TOP 1 @AcntSalary = AcntSalary ,@DepartmentID=DepartmentID
						FROM prs.tblDecreeHdr
						WHERE PersonnelID = @PersonnelID
						ORDER BY SerialNo Desc

						IF @AcntSalary = ''
							BEGIN
								
								Close curCelebration;
								Deallocate curCelebration; 	

								--کد حقوق به شماره پرسنلی %s خالی است
								SET @strMsgText=TS.pub.funGetMessages(20002,@LanguageID)
								Raiserror (@strMsgText,16,1,@PersonnelID)
								Return

							END
						
						SELECT @AcntCelebrationPayable=AcntCelebrationPayable
						FROM prs.tblDepartments 
						WHERE DepartmentID=	@DepartmentID
						
						SELECT @AcntSalary = pub.funMergCode(@AcntCelebrationPayable,@AcntSalary)
						
						SET @SumSalary = @SumSalary + @Amount 
						
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
			
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @AcntSalary,@Amount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	
					END
	
				Fetch NEXT From curCelebration Into @PersonnelID,@Amount
			END
	
		Close curCelebration;
		Deallocate curCelebration; 	

	---------- 

	SELECT @AcntCode = AcntCode 
	FROM prs.tblSalaryPaysHdr 
	WHERE ProcessID = @intSourceProcessID AND SerialNo = @intSourceSerialNo 

	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @AcntCode,0,@SumSalary,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	


END
GO
