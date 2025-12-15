USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1402/07/15
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- ----------------------------------------------
-- Description	 : < جدول اعتباری ویزیتور ها برای فروش >
-- ==============================================
Create PROCEDURE sal.SP_CheckCustDebitForVisitorSale
	@ExtraParams		NVarChar(Max) = '',
	@RepInfo			NVarChar(100) = '1@1@1',
	@RepOptions			VarChar(20) = '111' -- bit array	
WITH ENCRYPTION
AS
BEGIN

	DECLARE @AcntCode		VarChar(20) 	
	DECLARE @DocDate		Char(10) 	
	DECLARE	@UserID			Int;
	DECLARE	@UserIsAdmin	bit;
	DECLARE	@MaxDebitRemain	float;
	DECLARE	@MaxReceivableRemain1	float;
	DECLARE	@MaxReceivableRemain2	float;
		
	DECLARE @StrSelect		NVarChar(Max);
	DECLARE @StrWhereH		NVarChar(Max);
		
	declare @Layer1Lan				int;
	declare @PartNumber				int;
	declare @PartStart				int;
	declare @PartLen				int;

	select @PartNumber=[acc].[FunGetAcntInfoForRemain](1)
	select @PartStart=[acc].[FunGetAcntInfoForRemain](2)
	select @PartLen=[acc].[FunGetAcntInfoForRemain](3)

	select @Layer1Lan=Layer1 from pub.tblCodeLayer   where TableName='acc.tblAcnt' and PartNumber=1

	SET @UserID			= pub.funSplitString(@ExtraParams, '@', 1);
	SET @UserIsAdmin	= pub.funSplitString(@ExtraParams, '@', 2);
	     
	BEGIN TRY
		DROP TABLE #tblAcntCode
		DROP TABLE #tblVisitPath1
		DROP TABLE #tblVisitPath2
		DROP TABLE #tblVisitPath3
		DROP TABLE #tblVisitPath4		
	END TRY
	BEGIN CATCH
	END CATCH
	 
	
	SET @StrWhereH = ' and  1=1 '

	if @UserIsAdmin=0
	begin	
		
		
		CREATE TABLE #tblAcntCode
		(
		AcntCode 			Varchar(20)collate arabic_cs_as null
		)
		
		Insert into  #tblAcntCode (AcntCode) SELECT Distinct AcntCode FROM acc.tblVoucherDtl
		
		 exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID;

		SET @StrWhereH += ' and a.AcntCode in (SELECT AcntCode FROM  #tblAcntCode ) ' 

		Declare @PermissonForVisitPath as bit
		SELECT @PermissonForVisitPath = SettingValue FROM pub.tblSettings WHERE SettingKey = 'PermissonForVisitPath'	
		set @PermissonForVisitPath=isnull(@PermissonForVisitPath,0)
		
		if @PermissonForVisitPath='True'
		Begin
		
		 
		CREATE TABLE #tblVisitPath1
		(
		VisitPathID 			Varchar(20)collate arabic_cs_as null
		)	
		CREATE TABLE #tblVisitPath2
		(
		VisitPathID 			Varchar(20)collate arabic_cs_as null
		)
		CREATE TABLE #tblVisitPath3
		(
		VisitPathID 			Varchar(20)collate arabic_cs_as null
		)
		CREATE TABLE #tblVisitPath4
		(
		VisitPathID 			Varchar(20)collate arabic_cs_as null
		)

		Insert into  #tblVisitPath1 (VisitPathID) SELECT Distinct VisitPathID1 FROM acc.tblAcnt where VisitPathID1<>''
		Insert into  #tblVisitPath2 (VisitPathID) SELECT Distinct VisitPathID2 FROM acc.tblAcnt where VisitPathID2<>''
		Insert into  #tblVisitPath3 (VisitPathID) SELECT Distinct VisitPathID3 FROM acc.tblAcnt where VisitPathID3<>''
		Insert into  #tblVisitPath4 (VisitPathID) SELECT Distinct VisitPathID4 FROM acc.tblAcnt where VisitPathID4<>''
	
		exec pub.SpFilterByPermission3 '#tblVisitPath1', 'VisitPathID', 'acc.tblVisitPath',1, @UserID; 
		exec pub.SpFilterByPermission3 '#tblVisitPath2', 'VisitPathID', 'acc.tblVisitPath',2, @UserID; 
		exec pub.SpFilterByPermission3 '#tblVisitPath3', 'VisitPathID', 'acc.tblVisitPath',3, @UserID;
		exec pub.SpFilterByPermission3 '#tblVisitPath4', 'VisitPathID', 'acc.tblVisitPath',4, @UserID;

		SET @StrWhereH += ' and ((SELECT Count(*) FROM acc.tblVisitPath where PartNumber=1)=0 OR (Select COUNT(*) from acc.tblVisitPathRng where  acc.tblVisitPathRng.PartNumber=1 )=0 OR c.VisitPathID1 in (SELECT VisitPathID FROM  #tblVisitPath1 ) )' 
		SET @StrWhereH += ' and ((SELECT Count(*) FROM acc.tblVisitPath where PartNumber=2)=0 OR (Select COUNT(*) from acc.tblVisitPathRng where  acc.tblVisitPathRng.PartNumber=2 )=0 OR c.VisitPathID2 in (SELECT VisitPathID FROM  #tblVisitPath2 ) )' 
		SET @StrWhereH += ' and ((SELECT Count(*) FROM acc.tblVisitPath where PartNumber=3)=0 OR (Select COUNT(*) from acc.tblVisitPathRng where  acc.tblVisitPathRng.PartNumber=3 )=0 OR c.VisitPathID3 in (SELECT VisitPathID FROM  #tblVisitPath3 ) )' 
		SET @StrWhereH += ' and ((SELECT Count(*) FROM acc.tblVisitPath where PartNumber=4)=0 OR (Select COUNT(*) from acc.tblVisitPathRng where  acc.tblVisitPathRng.PartNumber=4 )=0 OR c.VisitPathID4 in (SELECT VisitPathID FROM  #tblVisitPath4 ) )' 
		end 	

	END
		
	SELECT	Debit, Credit,AcntCode
		into #tblRemain
	FROM	acc.tblVoucherDtl where 1=0
 
	set @StrSelect='
	insert into #tblRemain
		Select 0,0,''''
		union all 
		SELECT	IsNull(Sum(Debit), 0) Debit, IsNull(Sum(Credit), 0) Credit,a.AcntCode
		FROM	acc.tblVoucherDtl a
		INNER join acc.tblAcnt b	ON b.PartNumber= 1 and SUBSTRING(a.AcntCode,1,'+ str(@Layer1Lan) +') = SUBSTRING(b.AcntCode,1,'+ str(@Layer1Lan) +') AND LEN(b.AcntCode)='+ str(@Layer1Lan) +'
		INNER join acc.tblAcnt c	ON c.PartNumber= '+ str(@PartNumber) +' and  c.AcntCode =SUBSTRING(a.AcntCode,'+ str(@PartStart) +','+ str(@PartLen) +')
		WHERE b.AcntType NOT IN (91,92) AND VchKind <> 0  '+@StrWhereH +' Group by   a.AcntCode'

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	
	 ----حذف بستانکاران
	delete 	from #tblRemain	 where Debit<Credit

	select @MaxDebitRemain=Sum( abs(Debit-Credit))	  	from #tblRemain	

	--------------------------------------------------------------------------------------------

	CREATE TABLE #tblAcntCode2
		(
		AcntCode 			Varchar(20)collate arabic_cs_as null
		)
		
		Insert into  #tblAcntCode2 (AcntCode) SELECT Distinct AcntCode FROM acc.tblVoucherDtl where 1=0
		
	set @StrSelect='
		insert into #tblAcntCode2
		Select Distinct a.AcntCode
		FROM	acc.tblVoucherDtl a
		INNER join acc.tblAcnt b	ON b.PartNumber= 1 and SUBSTRING(a.AcntCode,1,'+ str(@Layer1Lan) +') = SUBSTRING(b.AcntCode,1,'+ str(@Layer1Lan) +') AND LEN(b.AcntCode)='+ str(@Layer1Lan) +'
		INNER join acc.tblAcnt c	ON c.PartNumber= '+ str(@PartNumber) +' and  c.AcntCode =SUBSTRING(a.AcntCode,'+ str(@PartStart) +','+ str(@PartLen) +')
		WHERE b.AcntType NOT IN (91,92) AND VchKind <> 0  '+@StrWhereH +' '

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;


	
  select Amount	,0 UseCurrency	,RowDesc CurrencyTypeName	,0 CurrencyRateH	,RowDesc CurrencyTypeIDH	
  ,ProcessID	,ProcessNo	,FiscalYear	,SerialNo	,RowNo	,DocDate	,PayTypeID	,DebitCode	,CreditCode	,CurrencyTypeID	,CurrencyRate	
  ,ChequeNo	,ChequeBookFiscalYear	,ChequeBookID	,ChequeDate	,VolumeFiscalYear	,VolumeRowNo	,EventNo	,LocationID	,BankTypeID	,BranchCode	
  ,BranchName	,BankSnNo	,AccountNo	,AccOwnerName	,LocationID2	,BankTypeID2	,BranchCode2	,BranchName2	,AccountNo2	,AccOwnerName2	
  ,DeliverTo	,RowDesc	,DocRowNo	,IsConfirmed	,AccountOwnerType	,BaseSerialNo	,BaseFiscalYear	,WithdrawType	,CurrencyAmount	,VisitorAcntCode	
  ,EndDate_PayableTrust	,SourceSerialNo	,SourceProcessNo	,WithAcntCode	, SerialNo ID	,FollowAcntCode	,ReceiptAcntCode	,ChequeNoNew	,RegChequeNoNewIN	,RegChequeNoNewOut	
  ,NationalIDNumber	,TargetBankID	,TargetLocationID	,TargetChequeNoNew	,TargetCustomerName,ChequeIsDigital,FollowUpNumber	,  RowDesc  ChequeCryptNo, RowDesc BankCity	, RowDesc BankTypeName	,DebitCode FirstCreditCode	
  ,RowDesc DebitName	,RowDesc CreditName	,RowDesc FirstCreditName	,Amount DateDuration	, SerialNo VchNo	,RowDesc VisitorAcntName
  Into #ReceivableDocs
   from trs.tblPayDtl
   where 1=0
  
   insert into #ReceivableDocs

   --select * from #ReceivableDocs
   exec trs.RptReceivableDocs;1 1, 1, NULL, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0, N'ChequeDate', N'111111110', N'1@199621@120014@0@1@0@0@0@0@0@0'


 select ProcessID	,ProcessNo	,FiscalYear	,SerialNo	,RowNo	,DocDate	,PayTypeID	,DebitCode	,CreditCode	,Amount	,CurrencyTypeID	,CurrencyRate	
 ,ChequeNo	,ChequeBookFiscalYear	,ChequeBookID	,ChequeDate	,VolumeFiscalYear	,VolumeRowNo	,EventNo	,LocationID	,BankTypeID	,BranchCode	
 ,BranchName	,BankSnNo	,AccountNo	,AccOwnerName	,LocationID2	,BankTypeID2	,BranchCode2	,BranchName2	,AccountNo2	,AccOwnerName2	
 ,DeliverTo	,RowDesc	,DocRowNo	,IsConfirmed	,AccountOwnerType	,BaseSerialNo	,BaseFiscalYear	,WithdrawType	,CurrencyAmount	,VisitorAcntCode	
 ,EndDate_PayableTrust	,SourceSerialNo	,SourceProcessNo	,WithAcntCode	, SerialNo ID	,FollowAcntCode	,ReceiptAcntCode	,ChequeNoNew	,RegChequeNoNewIN	
 ,RegChequeNoNewOut	,NationalIDNumber	,TargetBankID	,TargetLocationID	,TargetChequeNoNew	,TargetCustomerName,ChequeIsDigital,FollowUpNumber,ChequeCryptNo, SerialNo ChequeState	,RowDesc LocationName	
 ,RowDesc BankTypeName	,RowDesc DebitName	,SerialNo VchNo	,RowDesc CreditName	, DebitCode  ChequeOwnerCode	,SerialNo DateDuration	, RowDesc ChequeOwnerName
 into  #ReceivableDocsBank
  from trs.tblPayDtl
   where 1=0

     insert into #ReceivableDocsBank
   exec trs.RptReceivableDocsBank;1 20, 1, NULL, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, N'ChequeDate', N'1@199621@120019@0@1@0@0@0@0@0@0'

   
   --select * from #ReceivableDocsBank
   
   --return
   
	select @MaxReceivableRemain1=Sum( Amount) from #ReceivableDocs	
	where CreditCode  in (	SELECT  AcntCode FROM #tblAcntCode2) 

	select @MaxReceivableRemain2=Sum( Amount) from #ReceivableDocsBank	
	where ChequeOwnerCode in (	SELECT  AcntCode FROM #tblAcntCode2) 

	select @MaxDebitRemain MaxDebitRemain ,isnull(@MaxReceivableRemain1 ,0) +isnull(@MaxReceivableRemain2 ,0)   MaxReceivableRemain

	--------------------------------------------------------------------------------------------

	end 
GO
