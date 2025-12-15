USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1394/07/30
-- Viewed By	 : 
-- Last Modified : 1394/07/30
-- Last Modifier :
-- ----------------------------------------------
-- Description	 : < گزارش مانده های مشتریان ویزیتورها>
-- ==============================================
Create PROCEDURE [acc].[RptAcc_AccountStatusDtl]
	@SelectedAcnt1		int = 0,
	@SelectedAcnt2		int = 0,
	@SelectedAcnt3		int = 0,
	@SelectedAcnt4		int = 0,
	@SelectedVisitor1	int = 0, 
	@SelectedVisitor2	int = 0, 
	@SelectedVisitor3	int = 0, 
	@SelectedVisitor4	int = 0,
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@ExtraOptions			VarChar(1000) = '111', -- bit array options
	@RepOptions			VarChar(100) = '111', -- bit array options
	@RepInfo			NVarChar(100) = '1@1@1' -- bit array options
WITH ENCRYPTION
AS
Declare @StrSelectVoucher	NVarChar(max);
Declare @StrWhereVisitor	NVarChar(4000);
Declare @StrSelect	NVarChar(max);
Declare @StrWhere	NVarChar(4000);
Declare @StrWhereM	NVarChar(4000);

Declare @SortByName		int; -- مرتب بر اساس اسامی حسابها باشد یا کد حسابها؟
Declare @UseDateFilter	Bit; 
Declare @WithVisitor	bit;
Declare @WithBase	bit;
Declare @ShowZero	bit;
Declare @ShowNoVisitorAccount bit;
Declare @ShowAmountZero bit;
Declare @DateFilterSale bit;
Declare @ShowDebits bit;
	
Declare @AcntCode Varchar(20);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
DECLARE	@Amount		Int; 
BEGIN -- ============================ S T A R T =====================================================

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	SET @Amount		 = LTrim(pub.funSplitString(@ExtraOptions, '@', 1)); 
	SET @SortByName		 = LTrim(pub.funSplitString(@ExtraOptions, '@', 2)); 

SET @StrWhereVisitor = ''
	
	if (@SelectedAcnt1	Is Null)	set @SelectedAcnt1 = 0
	if (@SelectedAcnt2	Is Null)	set @SelectedAcnt2 = 0
	if (@SelectedAcnt3	Is Null)	set @SelectedAcnt3 = 0
	if (@SelectedAcnt4	Is Null)	set @SelectedAcnt4 = 0
	if (@SelectedVisitor1 Is Null)	set @SelectedVisitor1 = 0;
	if (@SelectedVisitor2 Is Null)	set @SelectedVisitor2 = 0;
	if (@SelectedVisitor3 Is Null)	set @SelectedVisitor3 = 0;
	if (@SelectedVisitor4 Is Null)	set @SelectedVisitor4 = 0;
	
	--SET @SortByName		= Substring(@RepOptions, 1, 1)
	SET @UseDateFilter	= Substring(@RepOptions, 2, 1)
	SET @WithVisitor	= Substring(@RepOptions, 3, 1)
	SET @WithBase	= Substring(@RepOptions, 4, 1)
	SET @ShowZero	= Substring(@RepOptions, 5, 1)
	SET @ShowNoVisitorAccount	= Substring(@RepOptions, 6, 1)
	SET @ShowAmountZero	= Substring(@RepOptions, 7, 1)
	SET @DateFilterSale	= Substring(@RepOptions, 8, 1)
	SET @ShowDebits	= Substring(@RepOptions, 9, 1)

	set NOCOUNT ON;

	
	-----------------  ایجاد و تکمیل جدول میانی کلی
	exec acc.UpdateAlltblVoucher2AccState
	----------------------------------------------

	set @StrWhere = ' 1=1 '
	if (@SelectedAcnt1 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	if (@SelectedAcnt2 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	if (@SelectedAcnt3 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	if (@SelectedAcnt4 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')
		
	-- Visitor --
	if (@SelectedVisitor1 > 0)
		set @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'D.VisitorAcntCode') + ')'	
	if (@SelectedVisitor2 > 0)
		set @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'D.VisitorAcntCode') + ')'
	if (@SelectedVisitor3 > 0)
		set @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'D.VisitorAcntCode') + ')'
	if (@SelectedVisitor4 > 0)
		set @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'D.VisitorAcntCode') + ')'
	
	if (@DocDateFr Is Not Null)
		if (@DateFilterSale=0)
			set @StrWhere = @StrWhere + ' AND D.DocDate >= ''' + @DocDateFr + ''''
		else
			set @StrWhere = @StrWhere + ' AND (( D.SourceProcessID<>90) or ( D.SourceProcessID=90 and  D.DocDate >= ''' + @DocDateFr + ''' ))'
	if (@DocDateTo Is Not Null)
		if (@DateFilterSale=0)
			set @StrWhere = @StrWhere + ' AND D.DocDate <= ''' + @DocDateTo + ''''
		else
			set @StrWhere = @StrWhere + ' AND (( D.SourceProcessID<>90) or (D.SourceProcessID=90 and D.DocDate <= ''' + @DocDateTo + '''))'
	
	exec acc.SpAcc_AccState  '',44

	SET @StrSelect =  '
	Select * 
    From (Select ID, SerialNo, DocRowNo, RecDesc, SourceProcessID, SourceProcessNo, 
				 SourceFiscalYear, SourceSerialNo, BaseID, AcntCode,
				 Case when Debit=0 then 0 else Amount end Debit, Debit Debit1,Credit Credit1,
				 Case when Credit=0 then 0 else Amount end  Credit, DocDate, Amount, VisitorAcntCode, 
				 ID1, pub.GetCodeName(AcntCode,1) AS AcntName ,pub.GetCodeName(VisitorAcntCode,1) AS VisitorName, 
				 (Select Sum(case when Debit=0 then 0 else Amount end - case when Credit=0 then 0 else Amount end) 
				  From acc.tblVoucher2AccState  P1 
				  Where P1.AcntCode=D.AcntCode and P1.VisitorAcntCode=D.VisitorAcntCode) as Sum, F.Tel, F.Address1, F.Address2, F.Mobile
		   From acc.tblVoucher2AccState D  
		   OUTER APPLY acc.funGetCodeInfo(D.AcntCode) F 
		   where '+@StrWhere +') a 
	 Where 1=1 '
if (select Count(*) from acc.tblAcnt where HasAccState=1)>0
begin
	Declare @len as int
	set  @len =acc.funGetAcntLayerStartandLen(1,2)
		set @StrSelect = @StrSelect + ' and  SubString (AcntCode,1,'+str(@len)+') in (select AcntCode from acc.tblAcnt where HasAccState=1)'
end
if (@ShowZero=0)
	 set @StrSelect = @StrSelect + ' And Sum <> 0 ' 

 if (@ShowNoVisitorAccount=0)
 set @StrSelect = @StrSelect + ' And  VisitorAcntCode <> '''' ' 
	
if (@ShowAmountZero=0)
 set @StrSelect = @StrSelect + ' And  (Credit1 <> 0 or Debit1 <> 0)' 

 	 
if (@ShowDebits>0)
	 	 set @StrSelect = @StrSelect + ' And Sum > 0 ' 

if (@Amount>0)
	 set @StrSelect = @StrSelect + ' And (Amount > '+ LTrim(RTrim(str(@Amount))) + ')'
	
	DECLARE	@UserID			Int;
	DECLARE	@UserIsAdmin	bit;

		
	SET @LangID			= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo		= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID		= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID			= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin	= pub.funSplitString(@RepInfo, '@', 5);

	SET @StrWhere = ''

if @UserIsAdmin=0
	begin
	
	SET @UserIsAdmin	= pub.funSplitString(@RepInfo, '@', 5);
	BEGIN TRY
		DROP TABLE #tblAcntCode
		DROP TABLE #tblVisitorAcntCode
	END TRY
	BEGIN CATCH
	END CATCH

	CREATE TABLE #tblAcntCode
	(
	AcntCode 			Varchar(20)collate arabic_cs_as null
	)	
	CREATE TABLE #tblVisitorAcntCode
	(
	VisitorAcntCode 			Varchar(20)collate arabic_cs_as null
	)
	
	Insert into  #tblVisitorAcntCode (VisitorAcntCode)	SELECT Distinct VisitorAcntCode	FROM acc.tblVoucher2AccState
	Insert into  #tblAcntCode (AcntCode)				SELECT Distinct AcntCode		FROM acc.tblVoucher2AccState
	 
		 exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID;
		 exec pub.SpFilterByPermission2 '#tblVisitorAcntCode', 'VisitorAcntCode', 'acc.tblAcnt', @UserID;

		SET @StrWhere =  
			' and AcntCode in (SELECT AcntCode FROM  #tblAcntCode ) ' +
			' and VisitorAcntCode in (SELECT VisitorAcntCode FROM  #tblVisitorAcntCode ) ' 
	END		

	set @StrSelect = @StrSelect + @StrWhere
	 
	 if (@SortByName=1)
		set @StrSelect = @StrSelect + '  order by AcntCode' 
	 if (@SortByName=2)
		set @StrSelect = @StrSelect + '  order by AcntName' 
	if (@SortByName=3)
		set @StrSelect = @StrSelect + '  order by DocDate' 
 
	Print @StrSelect;	
	Exec sp_executesql @StrSelect;

--Drop table ##tblPays		

END
GO
