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
Create PROCEDURE [acc].[SpVchSalaryPays]
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
	Declare @AcntSalary			Varchar(20)
	Declare @strRecDesc				NVarChar(1000)
	Declare @SumSalary				Float
	Declare @Amount					Float
	Declare @DescHdr					NVarChar(1000)
	Declare @DescDtl					NVarChar(1000)

	--------------------------------------------------------------------------------------------------------
	SET @SumSalary = 0
	-----
	
	SET @strRecDesc = 'سند حقوق ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 
	
		Declare	curSalary CURSOR For 
		SELECT	D.PersonnelID, D.Amount,DescDtl
		FROM prs.tblSalaryPaysDtl D inner join 
			 prs.tblSalaryPaysHdr H 
			 on H.SerialNo=D.SerialNo and H.ProcessID=D.ProcessID
			WHERE D.SerialNo = @intSourceSerialNo AND D.ProcessID =@intSourceProcessID
			and D.PersonnelID not IN
			(select D.PersonnelID
			 FROM prs.tblSalaryPaysDtl D inner join 
			 prs.tblSalaryPaysHdr H 
			 on H.SerialNo=D.SerialNo and H.ProcessID=D.ProcessID
			 inner Join prs.tblSalaryCalculation S  on 
			 S.PersonnelID=D.PersonnelID and S.MonthCode=	H.MonthCode
			  Inner Join prs.tblDecreeHdr m ON m.PersonnelID=S.PersonnelID AND 
                   m.SerialNo = S.DecreeSerialNo 
			   
			WHERE D.SerialNo = @intSourceSerialNo AND D.ProcessID =@intSourceProcessID
			 and m.RegSumSalaryUnit=1
			)


	
		-----  سطر به سطر  به حساب مشتری میرود
		Open  curSalary; 
			
		Fetch NEXT From curSalary Into @PersonnelID,@Amount,@DescDtl
	
		While (@@Fetch_Status = 0)
			BEGIN
				IF @Amount <> 0
					BEGIN
						SET @AcntSalary = ''

						SELECT TOP 1 @AcntSalary = AcntSalary 
						FROM prs.tblDecreeHdr
						WHERE PersonnelID = @PersonnelID
						ORDER BY SerialNo Desc

						IF @AcntSalary = ''
							BEGIN
								
								Close curSalary;
								Deallocate curSalary; 	

								--کد حقوق به شماره پرسنلی %s خالی است
								SET @strMsgText=TS.pub.funGetMessages(20002,@LanguageID)
								Raiserror (@strMsgText,16,1,@PersonnelID)
								Return

							END

						SET @SumSalary = @SumSalary + @Amount 
						
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
			
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @AcntSalary,@Amount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescDtl)) ,0 )	
					END
	
				Fetch NEXT From curSalary Into @PersonnelID,@Amount,@DescDtl
			END
	
		Close curSalary;
		Deallocate curSalary; 	



	DECLARE @lenas int
 
	select @lenas=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 from pub.tblCodeLayer
	where TableName = 'acc.tblAcnt' and PartNumber=1


	Declare	curSalary CURSOR For
		
		SELECT	SUBSTRING(m.AcntSalary,1,@lenas),Sum(D.Amount), H.DocDesc
		FROM prs.tblSalaryPaysDtl D inner join 
			 prs.tblSalaryPaysHdr H 
			 on H.SerialNo=D.SerialNo and H.ProcessID=D.ProcessID
			 inner Join prs.tblSalaryCalculation S  on 
			 S.PersonnelID=D.PersonnelID and S.MonthCode=	H.MonthCode
			  Inner Join prs.tblDecreeHdr m ON m.PersonnelID=S.PersonnelID AND 
                   m.SerialNo = S.DecreeSerialNo 
			   
		WHERE D.SerialNo = @intSourceSerialNo AND D.ProcessID =@intSourceProcessID
				and m.RegSumSalaryUnit=1
			Group by SUBSTRING(m.AcntSalary,1,@lenas),DocDesc
			
		
			
		-----   مجموع به حساب مشتری میرود
		Open  curSalary; 
			
		Fetch NEXT From curSalary Into @AcntSalary,@Amount,@DescHdr
	
		While (@@Fetch_Status = 0)
			BEGIN
				IF @Amount <> 0
					BEGIN
						IF @AcntSalary = ''
							BEGIN
								
								Close curSalary;
								Deallocate curSalary; 	

								--کد حقوق به شماره پرسنلی %s خالی است
								SET @strMsgText=TS.pub.funGetMessages(20002,@LanguageID)
								Raiserror (@strMsgText,16,1,@PersonnelID)
								Return

							END

						SET @SumSalary = @SumSalary + @Amount 
						
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
			
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @AcntSalary,@Amount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0 )	
					END
	
				Fetch NEXT From curSalary Into @AcntSalary,@Amount,@DescHdr
			END
	
		Close curSalary;
		Deallocate curSalary; 
		
	---------- 
	SELECT @AcntCode = AcntCode ,@DescHdr= DocDesc
	FROM prs.tblSalaryPaysHdr 
	WHERE SerialNo = @intSourceSerialNo  AND ProcessID =@intSourceProcessID
	
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @AcntCode,0,@SumSalary,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0 )	


END
GO
