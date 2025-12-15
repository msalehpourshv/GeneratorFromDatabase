USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO


---- =========== TS-QC:UPDATED ====================
---- Author		 : TakroSystem\Ahmadnejad
---- Create date   : 1386/01/15
---- Viewed By	 : 
---- Last Modified : 1392/11/09
---- Last Modifier : TakroSystem\ZiA
---- Description   : <Gain And Loss Report>     
---- =============================================
create  PROCEDURE [acc].[RptAcc_BenefitLoss]
	@DateFrom			VarChar(max)=  '',
	@DateTo				VarChar(10) = '',
	@HasSecondLayer		int = NULL, -- شامل لایه دوم باشد یانه؟
	@HasThirdLayer		Bit = 1, -- شامل لایه سوم باشد یا نه؟
	@HasZeroRemain		Bit = 0, -- شامل حسابهای با مانده صفر باشد یا نه؟
	@IncludeFinishDocs	Bit = 1, -- اختتامیه
	@IncludeClosedDocs	Bit = 1 -- بستن حساب
WITH ENCRYPTION
AS


	--Declare @DateFrom			VarChar(10) = Null
	--Declare @DateTo				VarChar(10) = Null
	--Declare @HasSecondLayer		int = 11 -- شامل لایه دوم باشد یانه؟
	--Declare @HasThirdLayer		Bit = 0 -- شامل لایه سوم باشد یا نه؟
	--Declare @HasZeroRemain		Bit = 0 -- شامل حسابهای با مانده صفر باشد یا نه؟
	--Declare @IncludeFinishDocs	Bit = 0 -- اختتامیه
	--Declare @IncludeClosedDocs	Bit = 0 -- بستن حساب;
	
--1 NULL, NULL, 1, 0, 0, 0, 0
Declare @StrSelect		NVarChar(max)
Declare @StrWhere		NVarChar(max)

Declare @StrAcntCode1	VarChar(max)
Declare @StrAcntCode2	VarChar(max)
Declare @StrAcntCode3	VarChar(max)

Declare @StrLayer1Len	VarChar(2)
Declare @StrLayer2Len	VarChar(2)
Declare @StrLayer3Len	VarChar(2)
declare @LanguageID		int;
declare @DateFrom1  as varchar(10)
declare @Acnt1 as int
declare @Acnt2 as int
declare @Acnt3 as int
declare @Acnt4 as int


DECLARE @LangID		Char(1);
DECLARE @SessionNo	VarChar(10);
DECLARE @ReportID	VarChar(10);
BEGIN ------------------------------------------------------------------------

	SET NOCOUNT ON;
	
	
	SET @DateFrom1	= pub.funSplitString(@DateFrom, '@', 1);
	SET @Acnt1 	= pub.funSplitString(@DateFrom, '@', 2);
	SET @Acnt2	= pub.funSplitString(@DateFrom, '@', 3);
	SET @Acnt3 	= pub.funSplitString(@DateFrom, '@', 4);
	SET @Acnt4 	= pub.funSplitString(@DateFrom, '@', 5);
	
	
	SET	@LangID		= pub.funSplitString(@DateFrom, '@', 6);
	SET @SessionNo	= pub.funSplitString(@DateFrom, '@', 7);
	SET @ReportID	= pub.funSplitString(@DateFrom, '@', 8);
	
	print @DateFrom1
	

	SET @LanguageID = pub.funGetCurrentLanguageID();

	IF (@IncludeFinishDocs Is Null)	SET @IncludeFinishDocs = 1
	IF (@IncludeClosedDocs Is Null)	SET @IncludeClosedDocs = 1
		-- Where Clause --
	Set @StrWhere = '(VchKind <> 0) AND (A.AcntType in  ( 41,51,61,62,81))'

	If (@DateFrom1 <> '')
		Set @StrWhere = @StrWhere + ' AND (DocDate >= ''' + @DateFrom1 + ''')'

	If (@DateTo <>'')
		Set @StrWhere = @StrWhere + ' AND (DocDate <= ''' + @DateTo + ''')'

	If (@IncludeFinishDocs = 0)
		Set @StrWhere = @StrWhere + ' AND (VchKind <> 3)'

	If (@IncludeClosedDocs = 0)
		Set @StrWhere = @StrWhere + ' AND (VchKind <> 4)'
		
	if (@Acnt1 <> 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Acnt1, 'D.AcntCode')
	if (@Acnt2 <> 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Acnt2, 'D.AcntCode')
	if (@Acnt3 <> 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Acnt3, 'D.AcntCode')
	if (@Acnt4 <> 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Acnt4, 'D.AcntCode')

		
		
	Begin
		BEGIN TRY
			DROP TABLE ##Layers		
		END TRY
		BEGIN CATCH
		END CATCH
	End


	SELECT	top 0  PartNumber,Layer1 as LayerLen ,Layer2 	as SumLayer,0 as Layer into  ##Layers FROM	pub.tblCodeLayer 	
	
	
insert into ##Layers  SELECT	PartNumber,Layer1  ,(Layer1 ),1  FROM	pub.tblCodeLayer 	WHERE	(TableName = 'acc.tblAcnt')
insert into ##Layers  SELECT	PartNumber,Layer2  ,(Layer1 )+(Layer2 ),2  FROM	pub.tblCodeLayer 	WHERE	(TableName = 'acc.tblAcnt')
insert into ##Layers  SELECT	PartNumber,Layer3  ,(Layer1 )+(Layer2 )+(Layer3 ),3  FROM	pub.tblCodeLayer 	WHERE	(TableName = 'acc.tblAcnt')
insert into ##Layers  SELECT	PartNumber,Layer4  ,(Layer1 )+(Layer2 )+(Layer3 )+(Layer4 ),4  FROM	pub.tblCodeLayer 	WHERE	(TableName = 'acc.tblAcnt')
insert into ##Layers  SELECT	PartNumber,Layer5   ,(Layer1 )+(Layer2 )+(Layer3 )+(Layer4 )+(Layer5 ),5  FROM	pub.tblCodeLayer 	WHERE	(TableName = 'acc.tblAcnt')
insert into ##Layers  SELECT	PartNumber,Layer6   ,(Layer1 )+(Layer2 )+(Layer3 )+(Layer4 )+(Layer5 )+(Layer6 ),6  FROM	pub.tblCodeLayer 	WHERE	(TableName = 'acc.tblAcnt')
insert into ##Layers  SELECT	PartNumber,Layer7   ,(Layer1 )+(Layer2 )+(Layer3 )+(Layer4 )+(Layer5 )+(Layer6 )+(Layer7 ),7  FROM	pub.tblCodeLayer 	WHERE	(TableName = 'acc.tblAcnt')
insert into ##Layers  SELECT	PartNumber,Layer8  ,(Layer1 )+(Layer2 )+(Layer3 )+(Layer4 )+(Layer5 )+(Layer6 )+(Layer7 )+(Layer8 ),8  FROM	pub.tblCodeLayer 	WHERE	(TableName = 'acc.tblAcnt')
insert into ##Layers  SELECT	PartNumber,Layer9  ,(Layer1 )+(Layer2 )+(Layer3 )+(Layer4 )+(Layer5 )+(Layer6 )+(Layer7 )+(Layer8 )+(Layer9 ),9  FROM	pub.tblCodeLayer 	WHERE	(TableName = 'acc.tblAcnt')
	
--select * from ##Layers order by PartNumber,Layer
	


Declare @Layer as int=0
Declare @LayerLen as int=0
Declare @BaseLayerLen as int=0
Declare @SumLayer as int=0
Declare @SumLayer2 as int=0
Declare @OldSumLayer as int=0
Declare @PartNumber as int=0


set @PartNumber	 =isnull(@HasSecondLayer,11)/10
Set @Layer= isnull(@HasSecondLayer,11)-@PartNumber	 *10


	set @StrSelect='' 
	
	--select @PartNumber,@Layer
	--select * from ##Layers 
	--	where LayerLen<>0 and (PartNumber<@PartNumber 
	--	or (PartNumber=@PartNumber  and Layer<=@Layer ))
	--	order by PartNumber,Layer
		
DECLARE csrPartNumber CURSOR FOR 
		select * from ##Layers 
		where LayerLen<>0 and (PartNumber<@PartNumber 
		or (PartNumber=@PartNumber  and Layer<=@Layer ))
		order by PartNumber,Layer

	OPEN csrPartNumber
	FETCH NEXT FROM csrPartNumber INTO @PartNumber,@LayerLen,@SumLayer,@Layer

	WHILE @@Fetch_Status = 0
	BEGIN
	
	
if @LayerLen<>0
begin 

if (@Layer=1 and  @PartNumber=1 )set @BaseLayerLen=@LayerLen


--if @Layer=1 set @OldSumLayer=@SumLayer 

if @StrSelect<>'' set @StrSelect=@StrSelect+' UNION ALL '

set @SumLayer2=@SumLayer2+@LayerLen

if (@Layer=1 and  @PartNumber>1 )set @SumLayer2=@SumLayer2+1

set @StrSelect=@StrSelect+' SELECT	CAST(LEFT(D.AcntCode,  '+ str(@SumLayer2) +') AS VARCHAR(20)) AS AcntCode,
Sum(D.Debit - D.Credit) AS Remain, CASE WHEN (A.AcntType=81) then 41 else A.AcntType end AS AcntType,
pub.GetCodeName(LEFT(D.AcntCode,  '+ str(@SumLayer2) +'), 1) AS AcntName
FROM	acc.tblVoucherDtl D INNER JOIN acc.tblAcnt A ON	(A.PartNumber =  1) AND (LEFT(D.AcntCode, '+ str(@BaseLayerLen) +') = A.AcntCode)	
WHERE	Len(D.AcntCode) >  '+ str(@OldSumLayer) +' and ' + @StrWhere + '
GROUP BY LEFT(D.AcntCode,  '+ str(@SumLayer2) +') , A.AcntType '
		
	END

Set @OldSumLayer=@SumLayer2 



		FETCH NEXT FROM csrPartNumber INTO @PartNumber,@LayerLen,@SumLayer,@Layer
	END

	CLOSE csrPartNumber
	DEALLOCATE csrPartNumber
	
	
	
	
	Set @StrSelect = '
		SELECT T.*
		FROM 
		(' + @StrSelect + '
		) T '
	If (@HasZeroRemain = 0) 
		Set @StrSelect = @StrSelect + '
		WHERE (T.Remain <> 0) '

	Set @StrSelect = @StrSelect + '
		ORDER BY T.AcntType  , AcntCode, Len(T.AcntCode )'

	Print @StrSelect
	Exec sp_executesql @StrSelect
	
	END
GO
