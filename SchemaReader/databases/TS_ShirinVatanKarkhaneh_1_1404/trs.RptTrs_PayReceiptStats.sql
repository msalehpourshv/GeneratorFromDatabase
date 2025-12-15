USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1391/03/21
-- Viewed By	 : 
-- Last Modified : 1392/01/06
-- Last Modifier : TakroSystem\Zia
-- Description   : <Store Stock>
-- ==============================================
Create PROCEDURE [trs].[RptTrs_PayReceiptStats]
	@ProcessList		varchar(50) = '1,3,10',
	@PayTypeList		varchar(50) = null,
	@ProcessNo			Int = 1,
	@SelectedDebit1		Int = 0,
	@SelectedDebit2		Int = 0,
	@SelectedDebit3		Int = 0,
	@SelectedDebit4		Int = 0,
	@SelectedCredit1	Int = 0,
	@SelectedCredit2	Int = 0,
	@SelectedCredit3	Int = 0,
	@SelectedCredit4	Int = 0,
	@FiscalFr			Int = NULL,
	@SerialFr			Int = NULL,
	@FiscalTo			Int = NULL,
	@SerialTo			Int = NULL,
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@RepOptions			VarChar(20) = '00',
	@SortFields			VarChar(100) = Null,
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrFrom	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);
DECLARE @IsDebit	bit;
DECLARE @UseBank	bit;

DECLARE @StrCodeField	VarChar(100);
DECLARE @StrNameField	VarChar(100);
DECLARE @ExtraNameField	VarChar(100);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;
DECLARE	@ProcessList2	varchar(10);

DECLARE @DescMaskDtl  NVarChar(200)

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init Variables ----------------------------------------------------------
	IF (@SelectedDebit1	Is Null)	SET @SelectedDebit1 = 0;
	IF (@SelectedDebit2	Is Null)	SET @SelectedDebit2 = 0;
	IF (@SelectedDebit3	Is Null)	SET @SelectedDebit3 = 0;
	IF (@SelectedDebit4	Is Null)	SET @SelectedDebit4 = 0;
	IF (@SelectedCredit1 Is Null)	SET @SelectedCredit1 = 0;
	IF (@SelectedCredit2 Is Null)	SET @SelectedCredit2 = 0;
	IF (@SelectedCredit3 Is Null)	SET @SelectedCredit3 = 0;
	IF (@SelectedCredit4 Is Null)	SET @SelectedCredit4 = 0;
	IF (@FiscalFr	Is Null)	SET @SerialFr = Null;
	IF (@FiscalTo	Is Null)	SET @SerialTo = Null;
	IF (@SerialFr	Is Null)	SET @FiscalFr = Null;
	IF (@SerialTo	Is Null)	SET @FiscalTo = Null;

	SET @LangID		 = pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	 = pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	 = pub.funSplitString(@RepInfo, '@', 3);
	SET @DescMaskDtl = pub.funSplitString(@RepInfo, '@', 6);

	SET @IsDebit	= Substring(@RepOptions, 1, 1)
	SET @UseBank	= Substring(@RepOptions, 1, 1)
	
	DECLARE @UserIDEx			VarChar(10);
	DECLARE @StrWhereSession		NVarChar(Max);

	SET @UserIDEx = '-1'
	SET @StrWhereSession=''
	SET @UserIDEx = pub.funSplitString(@RepInfo, '@', 7);

IF (@UserIDEx <> '' and @UserIDEx <> '-1')
	begin

		Create Table #tblSessionNo
		(
		SessionNo	Int
		)

		SET @StrSelect = '
		Insert Into #tblSessionNo
		Select * From [' + pub.funGetBranchDBName() + '].[pub].[funSessionNoList2](' + IsNull(Ltrim(@UserIDEx),0) + ')'

		Print @StrSelect;
		Exec sp_executesql @StrSelect;	

		SET @StrWhereSession =  ' (U.SessionNo = H.SessionNo) '		
		 
	end
	
	----------------------------------------------------------------------------
	-- Where Clause ------------------------------------------------------------
	if (@IsDebit = 1)
	begin
		set @StrCodeField = 'D.DebitCode'
		--set @StrCodeField = 'D.DebitName'
	end
	else
	begin
		set @StrCodeField = 'D.CreditCode'
	end
	
	if (@UseBank = 1)
	begin
		set @StrNameField = 'pub.GetBankName(T.Code,1)'
		set @ExtraNameField = 'pub.GetCodeName(T.Code,1)'
	end
	else
	begin
		set @StrNameField = 'pub.GetCodeName(T.Code,1)'
		set @ExtraNameField = 'pub.GetBankName(T.Code,1)'
	end
	
	SET @StrWhere = '(D.ProcessNo=' + ltrim(STR(@ProcessNo)) + ')';
	
	if (@ProcessList is not null)
		SET @StrWhere = @StrWhere + ' AND (D.ProcessID in (' + @ProcessList + '))'
	if (@PayTypeList is not null)
		SET @StrWhere = @StrWhere + ' AND (D.PayTypeID in (' + @PayTypeList + '))'
	
	If (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate>=''' + @DocDateFr + ''')'
	If (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate<=''' + @DocDateTo + ''')'

	If (@FiscalFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear>' + LTrim(Str(@FiscalFr)) + ' OR (D.FiscalYear=' + LTrim(Str(@FiscalFr)) + ' AND D.SerialNo>=' + LTrim(Str(@SerialFr)) + ')) '
	If (@FiscalTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear<' + LTrim(Str(@FiscalTo)) + ' OR (D.FiscalYear=' + LTrim(Str(@FiscalTo)) + ' AND D.SerialNo<=' + LTrim(Str(@SerialTo)) + ')) '
		
	IF	(@SelectedDebit1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedDebit1, 'D.DebitCode')
	IF	(@SelectedDebit2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedDebit2, 'D.DebitCode')
	IF	(@SelectedDebit3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedDebit3, 'D.DebitCode')
	IF	(@SelectedDebit4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedDebit4, 'D.DebitCode')
		
	If (@SelectedCredit1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedCredit1, 'D.CreditCode')
	If (@SelectedCredit2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedCredit2, 'D.CreditCode')
	If (@SelectedCredit3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedCredit3, 'D.CreditCode')
	If (@SelectedCredit4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedCredit4, 'D.CreditCode')
		
	If (@DescMaskDtl Is Not Null) And (@DescMaskDtl <> '')
		SET @StrWhere = @StrWhere + ' AND (Replace(D.RowDesc, '' '', '''') LIKE N''%' + RTrim(Replace(@DescMaskDtl, ' ', '')) + '%'')'
				
	--------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------
	DECLARE @DonotFilterAcc2Trs AS bit
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
		
			if @IsDebit =0 
			 begin
				Insert into  #tblOurBanks (CreditCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
				exec pub.SpFilterByPermission2 '#tblOurBanks', 'CreditCode', 'trs.tblOurBanks', @UserID; 
				Insert into  #tblAcntCode (AcntCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
				exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID; 
				SET @StrWhere =  @StrWhere + '  and  ( D.CreditCode in (SELECT   CreditCode	FROM  #tblOurBanks    ) 
													or   D.CreditCode in (SELECT   AcntCode	FROM  #tblAcntCode    ) )'
			end 
		 if @IsDebit =1 
			begin 
				Insert into  #tblOurBanks (CreditCode) SELECT  Distinct DebitCode	FROM       trs.tblPayDtl
				exec pub.SpFilterByPermission2 '#tblOurBanks', 'CreditCode', 'trs.tblOurBanks', @UserID; 
				Insert into  #tblAcntCode (AcntCode) SELECT  Distinct DebitCode	FROM       trs.tblPayDtl
				exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID; 
				SET @StrWhere =  @StrWhere + '  and (  D.DebitCode in (SELECT   CreditCode	FROM  #tblOurBanks     ) 
													or   D.DebitCode in (SELECT   AcntCode	FROM  #tblAcntCode    ) )'
			end 

		end 
		
		Delete From  #tblAcntCode where AcntCode='' or AcntCode is null
		Delete From  #tblOurBanks where CreditCode='' or CreditCode is null

	end
	
	-- Select Clause -----------------------------------------------------------------
	SET @StrSelect = '
	select T.*, ' + @StrNameField + ' Name, ' + @ExtraNameField + ' Name2
	from
	(
		SELECT	' + @StrCodeField + ' as Code, SUM(D.Amount) SumAmount
		FROM	trs.tblPayDtl D
		'
	IF (@UserIDEx <> '' and @UserIDEx <> '-1')
		SET @StrSelect = @StrSelect + ' 
		INNER JOIN trs.tblPayHdr		H ON D.ProcessID=H.ProcessID AND D.ProcessNo=H.ProcessNo AND D.FiscalYear=H.FiscalYear AND D.SerialNo=H.SerialNo
		INNER JOIN (Select * From #tblSessionNo) U ON ' + @StrWhereSession		
	
	SET @StrSelect =@StrSelect + '
		 WHERE	' + @StrWhere + '
		GROUP BY ' + @StrCodeField + '
	) T '
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
