USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 06-13-2007
-- Viewed By	 : 
-- Last Modified : 1393/02/21
-- Last Modifier : TakroSystem\Zia
-- Description	 : <Voucher> -- چاپ اسناد حسابداری
-- ===============================================
Create PROCEDURE [acc].[RptAcc_Voucher_Detailed_Grouped_AcntCode2]
	@SelectLen		int = 20, -- not used in this report (just for sync with common report)
	@ReportType		int = 2,  -- not used in this report (use 2 for this report)
							  -- 1 = Continous Sort By DocRowNo (Not Used In this type)
							  -- 2 = Discrete  Sort By AcntCode 
							  -- 3 = Discrete  Sort By DocRowNo (Not Used In this type)
	@SerialNoFr		int = 1,
	@SerialNoTo		int = 10,
	@SerialOldFr	int = Null,
	@SerialOldTo	int = Null,
	@DocDateFr		char(10) = Null,
	@DocDateTo		char(10) = Null,
	@PortionLayer	tinyint = 1,
	@RepOptions		varchar(20) = '0000011000100',
	@RepInfo		nvarchar(100) = '1@1@1',
	@ExtraParams	nvarChar(200) = ''
WITH ENCRYPTION
AS

DECLARE @Layer1Len	TinyInt
DECLARE @Layer2Len	TinyInt
DECLARE @Layer3Len	TinyInt
DECLARE @Layer4Len	TinyInt
DECLARE @Layer1		Tinyint
DECLARE @Layer2		Tinyint
DECLARE @Layer3		Tinyint
DECLARE @Layer4		Tinyint
DECLARE @Layer5		Tinyint
DECLARE @Layer6		Tinyint
DECLARE @Layer7		Tinyint
DECLARE @Layer8		Tinyint
DECLARE @Layer9		Tinyint
DECLARE @LayerS		Tinyint
DECLARE @LayerLen	Tinyint
DECLARE @PrevPart	Tinyint
DECLARE @Source		nvarchar(50)
DECLARE	@SourceProcessNo	VARCHAR(30);
DECLARE @SourceProcessID	varchar(100)
DECLARE @UserName			NVarChar(4000)
DECLARE @UserFullName		NVarChar(4000)
DECLARE @ShowDocDesc1	Bit -- شامل شرح اول سند باشد یا نه؟
DECLARE @ShowDocDesc2	Bit -- شامل شرح دوم سند باشد یا نه؟
DECLARE @ShowRecDesc1	Bit -- شامل شرح ردیف اول باشد یا نه؟
DECLARE @ShowRecDesc2	Bit -- شامل شرح ردیف دوم باشد یا نه؟
DECLARE @ShowPortion	Bit -- شامل ستون جزء باشد یا نه؟
DECLARE @ShowDesc1		Bit -- نمایش گردش با شرح سند
DECLARE @AutoY			Bit
DECLARE @AutoN			Bit 
DECLARE @SortByOldSrl	Bit
DECLARE @FullParts		Bit
DECLARE	@UseCurrency	Bit; -- 1 = از واحد ارزی استفاده شود
DECLARE	@UserIsAdmin	bit;
DECLARE	@LockOnly		bit;
DECLARE	@StrQuery		NVarChar(4000);
DECLARE	@StrWhere		NVarChar(2000);
DECLARE	@LayerNumber	TinyInt; 
DECLARE	@UserID			Int;

SET @UserID			= pub.funSplitString(@RepInfo, '@', 4);
SET @UserIsAdmin	= pub.funSplitString(@RepInfo, '@', 5);

Create Table #tblAll
(
	SerialNo		Int	Null,
	DocDate			Char(10) COLLATE Arabic_CS_AS,
	AcntCode		VarChar(200) COLLATE Arabic_CS_AS Not Null,
	Debit			float Not Null,
	Credit			float Not Null,
	DC_State		TinyInt, -- 0 = Debit, 1 = Credit
	DocDesc1		NVarChar(4000) COLLATE Arabic_CS_AS Null,
	DocDesc2		NVarChar(4000) COLLATE Arabic_CS_AS Null,
	RecDesc1		NVarChar(4000) COLLATE Arabic_CS_AS Null,
	RecDesc2		NVarChar(4000) COLLATE Arabic_CS_AS Null,
	IsMainCode		Bit Not Null,
	OldSerialNo		Int	Null,
	RowNo			int Null,
	DocRowNo		int Null
);

Create Table #tblResult
(
	SerialNo		Int	Null,
	DocDate			Char(10) COLLATE Arabic_CS_AS,
	AcntCode		VarChar(30) COLLATE Arabic_CS_AS Not Null,
	AcntCode2		VarChar(30) COLLATE Arabic_CS_AS  Null,
	AcntName		NVarChar(4000) COLLATE Arabic_CS_AS Null,	
	Debit			float Not Null,
	Credit			float Not Null,
	DC_State		TinyInt, -- 0 = Debit, 1 = Credit
	DocDesc1		NVarChar(4000) COLLATE Arabic_CS_AS Null,
	DocDesc2		NVarChar(4000) COLLATE Arabic_CS_AS Null,
	RowDesc1		NVarChar(4000) COLLATE Arabic_CS_AS Null,
	RowDesc2		NVarChar(4000) COLLATE Arabic_CS_AS Null,
	IsMainCode		Bit Not Null,
	OldSerialNo		Int	Null,
	ParentCode		VarChar(20) COLLATE Arabic_CS_AS Null,
	RowNo			int Null,
	DocRowNo		int Null,
	IsExtended		Bit null,
	Acnt1			VarChar(30) COLLATE Arabic_CS_AS ,
	Acnt1Name		NVarChar(1000) COLLATE Arabic_CS_AS ,	
	Acnt2			VarChar(30) COLLATE Arabic_CS_AS ,
	Acnt2Name		NVarChar(1000) COLLATE Arabic_CS_AS ,	
	Acnt3			VarChar(30) COLLATE Arabic_CS_AS ,
	Acnt3Name		NVarChar(1000) COLLATE Arabic_CS_AS ,	
	Acnt4			VarChar(30) COLLATE Arabic_CS_AS ,
	Acnt4Name		NVarChar(1000) COLLATE Arabic_CS_AS 
);


BEGIN ---------------------------------------------------------------------

	SET NOCOUNT ON;

	SET @SourceProcessID = pub.funSplitString(@ExtraParams, '#', 1);
	SET @UserFullName	 = pub.funSplitString(@ExtraParams, '#', 2);
	SET @UserName		 = pub.funSplitString(@ExtraParams, '#', 3);

	set @LockOnly = 0;
	select @LockOnly = SettingValue
	from pub.tblSettings
	where SettingKey='Acc_ReportLockedOnly'

	-- Init -------------------------------------------------
	IF (@RepOptions Is Null)	SET @RepOptions = '00000110100';

	set @ShowDocDesc1	= Substring(@RepOptions, 1, 1)
	set @ShowDocDesc2	= Substring(@RepOptions, 2, 1)
	set @ShowRecDesc1	= Substring(@RepOptions, 3, 1)
	set @ShowRecDesc2	= Substring(@RepOptions, 4, 1)
	set @ShowPortion	= Substring(@RepOptions, 5, 1)
	set @AutoY			= Substring(@RepOptions, 6, 1)
	set @AutoN			= Substring(@RepOptions, 7, 1)
	set @SortByOldSrl	= Substring(@RepOptions, 8, 1)
	-- ~ 9 is used
	set @FullParts		= Substring(@RepOptions, 10, 1)
	set @UseCurrency	= Substring(@RepOptions, 11, 1)

	if LEN(@RepOptions) > 11
		SET @SourceProcessNo= Substring(@RepOptions, 12, 1)
	else
		SET @SourceProcessNo= '0'
	set @ShowDesc1	= Substring(@RepOptions, 15, 1)	
	
	---------------------------------------------------------
	if (@UseCurrency = 1) 
		set @Source = 'acc.vwVoucherDtl2'
	else
		set @Source = 'acc.tblVoucherDtl'
		
	SET @LayerLen = 0;
	SET @PrevPart = 0;

	SET @StrWhere = '(D.VchKind <> 0)';

	if (@SourceProcessID <> '')
		SET @StrWhere = @StrWhere  + ' AND (D.SourceProcessID in (' + LTrim(@SourceProcessID) + '))'

	If (@SourceProcessNo <> '0')
	begin
		Declare @DistributionSourceProcessNo AS varchar(2)
		SET @DistributionSourceProcessNo = '0'
	
		SELECT @DistributionSourceProcessNo = SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'DistributionSourceProcessNo'

		IF @DistributionSourceProcessNo<>'0' AND @DistributionSourceProcessNo=@SourceProcessNo
			SET @SourceProcessNo = @SourceProcessNo + ',10' 
		If (@AutoN = 1) 
			SET @StrWhere = @StrWhere  + ' AND ((D.IsAutoDoc = 0) OR D.SourceProcessNo IN (' + @SourceProcessNo + '))'
		Else
			SET @StrWhere = @StrWhere  + ' AND (D.SourceProcessNo IN (' + @SourceProcessNo + '))'
	end

	If (@SerialNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')'
	If (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')' 

	If (@SerialOldFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.OldSerialNo >= ' + LTrim(Str(@SerialOldFr)) + ')'
	If (@SerialOldTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.OldSerialNo <= ' + LTrim(Str(@SerialOldTo)) + ')'

	If (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
	If (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'

	If (@AutoY <> 1)
		SET @StrWhere = @StrWhere + ' AND (D.IsAutoDoc <> 1)'
	If (@AutoN <> 1)
		SET @StrWhere = @StrWhere + ' AND (D.IsAutoDoc <> 0)'

	if (@LockOnly = 1)
		SET @StrWhere = @StrWhere + ' AND (H.DocRegisterState > 1)'

	SET @StrQuery	= '
		INSERT	INTO #tblAll(SerialNo, DocDate, AcntCode, Debit, Credit, DC_State, DocDesc1, DocDesc2, RecDesc1, RecDesc2, IsMainCode, OldSerialNo,RowNo,DocRowNo)
		SELECT	D.SerialNo, D.DocDate, Left(LTrim(RTrim(D.AcntCode)), ' + LTrim(Str(@SelectLen)) + '), Debit, Credit, 
			CASE WHEN (Debit <> 0) THEN 0 ELSE 1 END AS DC_State, ' +
			CASE WHEN(@ShowDocDesc1 = 1) THEN 'H.DocDesc ' ELSE 'Cast('''' As NVarChar(4000))' END + ' AS DocDesc1, ' + 
			CASE WHEN(@ShowDocDesc2 = 1) THEN 'H.DocDesc2' ELSE 'Cast('''' As NVarChar(4000))' END + ' AS DocDesc2, ' + 
			CASE WHEN(@ShowRecDesc1 = 1) THEN 'D.RecDesc ' ELSE 'Cast('''' As NVarChar(4000))' END + ' AS RowDesc1, ' + 
			CASE WHEN(@ShowRecDesc2 = 1) THEN 'D.RecDesc2' ELSE 'Cast('''' As NVarChar(4000))' END + ' AS RowDesc2, 1, H.OldSerialNo,D.RowNo,D.DocRowNo
 		FROM	' + @Source + ' D 
 				INNER JOIN acc.tblVoucherHdr H On H.SerialNo = D.SerialNo 
		WHERE ' + @StrWhere

	print @StrQuery;
	exec sp_executesql @StrQuery;

	if @UserIsAdmin=0
	begin
		CREATE TABLE #tblAcntCode
		(
		AcntCode 			Varchar(20)collate arabic_cs_as null
		)	

		CREATE TABLE #tblSerialRowCount
		(
		SerialNo 			int,
		SerialRowCount 			int
		)

		Insert into  #tblAcntCode (AcntCode)	SELECT Distinct AcntCode	FROM  #tblAll
		Insert into  #tblSerialRowCount (SerialNo,SerialRowCount)	SELECT SerialNo, Count(*)	FROM  #tblAll group by SerialNo
		
		exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID;
	
		--حذف ردیف های سند که کاربر دسترسی ندارد
		delete  from #tblAll where AcntCode not in ( select AcntCode from #tblAcntCode )

		----حذف اسنادی که کاربری به تعدادی از ردیف های سند دسترسی ندارد
		delete  from #tblAll 
		from #tblAll a 
		inner join (SELECT SerialNo, Count(*)	 SerialRowCount FROM  #tblAll group by SerialNo )b 
		on a.SerialNo=b.SerialNo
		inner join #tblSerialRowCount c
		on b.SerialNo=c.SerialNo and b.SerialRowCount<c.SerialRowCount

	end
	
	if  @ShowDesc1=1
		UPDATE #tblAll
		SET RecDesc1 =N'[شرح خالی است]'
		where RecDesc1=''
	--*** ------------------------------------------------------------ ***
	--*** ------------------- First Section -------------------------- ***
	--*** ------------------------------------------------------------ ***
	SELECT	@Layer1 = Layer1, @Layer2 = Layer2, @Layer3 = Layer3, 
			@Layer4 = Layer4, @Layer5 = Layer5, @Layer6 = Layer6, 
			@Layer7 = Layer7, @Layer8 = Layer8, @Layer9 = Layer9
	FROM	pub.tblCodeLayer 
	WHERE	PartNumber = 1 AND TableName = 'acc.tblAcnt'

	SET	@LayerLen = @Layer1
	SET	@LayerNumber = 1
	SET	@LayerS = @Layer1+@Layer2+@Layer3+@Layer4+@Layer5+@Layer6+@Layer7+@Layer8+@Layer9

	If (@FullParts <> 1) and (@Layer1 > 0)
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode,IsExtended)
		SELECT A.*, Null,case when @PortionLayer=1 THEN 1 ELSE 0 END
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		if not((@ShowPortion = 1) and (@PortionLayer > 1)) 
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode,IsExtended)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 
				CASE WHEN (@ShowPortion = 1) and (@PortionLayer = 1) THEN
				(	
					SELECT	Sum(Debit)
					FROM	#tblAll B
					WHERE	B.SerialNo = A.SerialNo AND 
							B.DC_State = A.DC_State AND
							Left(B.AcntCode, @LayerLen) = Left(A.AcntCode, @LayerLen)
					GROUP	BY B.SerialNo, Left(B.AcntCode, @LayerLen), B.DC_State 
				)
				ELSE 0 END, 
				CASE WHEN (@ShowPortion = 1) and (@PortionLayer = 1) THEN
				(
					SELECT	Sum(Credit)
					FROM	#tblAll B
					WHERE	B.SerialNo = A.SerialNo AND 
							B.DC_State = A.DC_State AND
							Left(B.AcntCode, @LayerLen) = Left(A.AcntCode, @LayerLen)
					GROUP	BY B.SerialNo, Left(B.AcntCode, @LayerLen), B.DC_State 
				) 
				ELSE 0 END, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer1), case when (@ShowPortion = 1) and (@PortionLayer = 1) then 1 else 0 end
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer2

	If (@FullParts <> 1) and (@Layer2 > 0)
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode,IsExtended)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer2),case when @PortionLayer=2 THEN 1 ELSE 0 END
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		if not((@ShowPortion = 1) and (@PortionLayer > 2)) 
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode,IsExtended)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 
				CASE WHEN (@ShowPortion = 1) and (@PortionLayer = 2) THEN
				(	
					SELECT	Sum(Debit)
					FROM	#tblAll B
					WHERE	B.SerialNo = A.SerialNo AND 
							B.DC_State = A.DC_State AND
							Left(B.AcntCode, @LayerLen) = Left(A.AcntCode, @LayerLen)
					GROUP	BY B.SerialNo, Left(B.AcntCode, @LayerLen), B.DC_State 
				)
				ELSE 0 END, 
				CASE WHEN (@ShowPortion = 1) and (@PortionLayer = 2) THEN
				(
					SELECT	Sum(Credit)
					FROM	#tblAll B
					WHERE	B.SerialNo = A.SerialNo AND 
							B.DC_State = A.DC_State AND
							Left(B.AcntCode, @LayerLen) = Left(A.AcntCode, @LayerLen)
					GROUP	BY B.SerialNo, Left(B.AcntCode, @LayerLen), B.DC_State 
				) 
				ELSE 0 END, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer2), case when (@ShowPortion = 1) and (@PortionLayer = 2) then 1 else 0 end
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer3

	If (@FullParts <> 1) and (@Layer3 > 0) 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode,IsExtended)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer3),case when @PortionLayer=3 THEN 1 ELSE 0 END
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		if not((@ShowPortion = 1) and (@PortionLayer > 3)) 
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode,IsExtended)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 
				CASE WHEN (@ShowPortion = 1) and (@PortionLayer = 3) THEN
				(	
					SELECT	Sum(Debit)
					FROM	#tblAll B
					WHERE	B.SerialNo = A.SerialNo AND 
							B.DC_State = A.DC_State AND
							Left(B.AcntCode, @LayerLen) = Left(A.AcntCode, @LayerLen)
					GROUP	BY B.SerialNo, Left(B.AcntCode, @LayerLen), B.DC_State 
				)
				ELSE 0 END, 
				CASE WHEN (@ShowPortion = 1) and (@PortionLayer = 3) THEN
				(
					SELECT	Sum(Credit)
					FROM	#tblAll B
					WHERE	B.SerialNo = A.SerialNo AND 
							B.DC_State = A.DC_State AND
							Left(B.AcntCode, @LayerLen) = Left(A.AcntCode, @LayerLen)
					GROUP	BY B.SerialNo, Left(B.AcntCode, @LayerLen), B.DC_State 
				) 
				ELSE 0 END, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer3), case when (@ShowPortion = 1) and (@PortionLayer = 3) then 1 else 0 end
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer4

	If (@FullParts <> 1) and (@Layer4 > 0)
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode,IsExtended)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer4),case when @PortionLayer=4 THEN 1 ELSE 0 END
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		if not((@ShowPortion = 1) and (@PortionLayer > 4)) 
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode,IsExtended)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 
				CASE WHEN (@ShowPortion = 1) and (@PortionLayer = 4) THEN
				(	
					SELECT	Sum(Debit)
					FROM	#tblAll B
					WHERE	B.SerialNo = A.SerialNo AND 
							B.DC_State = A.DC_State AND
							Left(B.AcntCode, @LayerLen) = Left(A.AcntCode, @LayerLen)
					GROUP	BY B.SerialNo, Left(B.AcntCode, @LayerLen), B.DC_State 
				)
				ELSE 0 END, 
				CASE WHEN (@ShowPortion = 1) and (@PortionLayer = 4) THEN
				(
					SELECT	Sum(Credit)
					FROM	#tblAll B
					WHERE	B.SerialNo = A.SerialNo AND 
							B.DC_State = A.DC_State AND
							Left(B.AcntCode, @LayerLen) = Left(A.AcntCode, @LayerLen)
					GROUP	BY B.SerialNo, Left(B.AcntCode, @LayerLen), B.DC_State 
				) 
				ELSE 0 END, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer4), case when (@ShowPortion = 1) and (@PortionLayer = 4) then 1 else 0 end
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer5

	If (@FullParts <> 1) and (@Layer5 > 0)
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode,IsExtended)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer5),case when @PortionLayer=5 THEN 1 ELSE 0 END
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		if not((@ShowPortion = 1) and (@PortionLayer > 5)) 
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode,IsExtended)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen),
				CASE WHEN (@ShowPortion = 1) and (@PortionLayer = 5) THEN
				(	
					SELECT	Sum(Debit)
					FROM	#tblAll B
					WHERE	B.SerialNo = A.SerialNo AND 
							B.DC_State = A.DC_State AND
							Left(B.AcntCode, @LayerLen) = Left(A.AcntCode, @LayerLen)
					GROUP	BY B.SerialNo, Left(B.AcntCode, @LayerLen), B.DC_State 
				)
				ELSE 0 END, 
				CASE WHEN (@ShowPortion = 1) and (@PortionLayer = 5) THEN
				(
					SELECT	Sum(Credit)
					FROM	#tblAll B
					WHERE	B.SerialNo = A.SerialNo AND 
							B.DC_State = A.DC_State AND
							Left(B.AcntCode, @LayerLen) = Left(A.AcntCode, @LayerLen)
					GROUP	BY B.SerialNo, Left(B.AcntCode, @LayerLen), B.DC_State 
				) 
				ELSE 0 END, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer5), case when (@ShowPortion = 1) and (@PortionLayer = 5) then 1 else 0 end
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer6

	If (@FullParts <> 1) and (@Layer6 > 0)
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode,IsExtended)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer6),case when @PortionLayer=6 THEN 1 ELSE 0 END
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		if not((@ShowPortion = 1) and (@PortionLayer > 6)) 
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode,IsExtended)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 
				CASE WHEN (@ShowPortion = 1) and (@PortionLayer = 6) THEN
				(	
					SELECT	Sum(Debit)
					FROM	#tblAll B
					WHERE	B.SerialNo = A.SerialNo AND 
							B.DC_State = A.DC_State AND
							Left(B.AcntCode, @LayerLen) = Left(A.AcntCode, @LayerLen)
					GROUP	BY B.SerialNo, Left(B.AcntCode, @LayerLen), B.DC_State 
				)
				ELSE 0 END, 
				CASE WHEN (@ShowPortion = 1) and (@PortionLayer = 6) THEN
				(
					SELECT	Sum(Credit)
					FROM	#tblAll B
					WHERE	B.SerialNo = A.SerialNo AND 
							B.DC_State = A.DC_State AND
							Left(B.AcntCode, @LayerLen) = Left(A.AcntCode, @LayerLen)
					GROUP	BY B.SerialNo, Left(B.AcntCode, @LayerLen), B.DC_State 
				) 
				ELSE 0 END,
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer6), case when (@ShowPortion = 1) and (@PortionLayer = 6) then 1 else 0 end
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer7

	If (@FullParts <> 1) and (@Layer7 > 0)
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode,IsExtended)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer7),case when @PortionLayer=7 THEN 1 ELSE 0 END
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		if not((@ShowPortion = 1) and (@PortionLayer > 7)) 
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode,IsExtended)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 
				CASE WHEN (@ShowPortion = 1) and (@PortionLayer = 7) THEN
				(	
					SELECT	Sum(Debit)
					FROM	#tblAll B
					WHERE	B.SerialNo = A.SerialNo AND 
							B.DC_State = A.DC_State AND
							Left(B.AcntCode, @LayerLen) = Left(A.AcntCode, @LayerLen)
					GROUP	BY B.SerialNo, Left(B.AcntCode, @LayerLen), B.DC_State 
				)
				ELSE 0 END, 
				CASE WHEN (@ShowPortion = 1) and (@PortionLayer = 7) THEN
				(
					SELECT	Sum(Credit)
					FROM	#tblAll B
					WHERE	B.SerialNo = A.SerialNo AND 
							B.DC_State = A.DC_State AND
							Left(B.AcntCode, @LayerLen) = Left(A.AcntCode, @LayerLen)
					GROUP	BY B.SerialNo, Left(B.AcntCode, @LayerLen), B.DC_State 
				) 
				ELSE 0 END, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer7), case when (@ShowPortion = 1) and (@PortionLayer = 7) then 1 else 0 end
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer8

	If (@FullParts <> 1) and (@Layer8 > 0)
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode,IsExtended)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer8),case when @PortionLayer=8 THEN 1 ELSE 0 END
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		if not((@ShowPortion = 1) and (@PortionLayer > 8)) 
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode,IsExtended)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 
				CASE WHEN (@ShowPortion = 1) and (@PortionLayer = 8) THEN
				(	
					SELECT	Sum(Debit)
					FROM	#tblAll B
					WHERE	B.SerialNo = A.SerialNo AND 
							B.DC_State = A.DC_State AND
							Left(B.AcntCode, @LayerLen) = Left(A.AcntCode, @LayerLen)
					GROUP	BY B.SerialNo, Left(B.AcntCode, @LayerLen), B.DC_State 
				)
				ELSE 0 END, 
				CASE WHEN (@ShowPortion = 1) and (@PortionLayer = 8) THEN
				(
					SELECT	Sum(Credit)
					FROM	#tblAll B
					WHERE	B.SerialNo = A.SerialNo AND 
							B.DC_State = A.DC_State AND
							Left(B.AcntCode, @LayerLen) = Left(A.AcntCode, @LayerLen)
					GROUP	BY B.SerialNo, Left(B.AcntCode, @LayerLen), B.DC_State 
				) 
				ELSE 0 END, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer8), case when (@ShowPortion = 1) and (@PortionLayer = 8) then 1 else 0 end
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer9
	
	If (@FullParts <> 1) and (@Layer9 > 0)
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode,IsExtended)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer9),case when @PortionLayer=9 THEN 1 ELSE 0 END
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		if not((@ShowPortion = 1) and (@PortionLayer > 9)) 
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode,IsExtended)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen),
				CASE WHEN (@ShowPortion = 1) and (@PortionLayer = 9) THEN
				(	
					SELECT	Sum(Debit)
					FROM	#tblAll B
					WHERE	B.SerialNo = A.SerialNo AND 
							B.DC_State = A.DC_State AND
							Left(B.AcntCode, @LayerLen) = Left(A.AcntCode, @LayerLen)
					GROUP	BY B.SerialNo, Left(B.AcntCode, @LayerLen), B.DC_State 
				)
				ELSE 0 END, 
				CASE WHEN (@ShowPortion = 1) and (@PortionLayer = 9) THEN
				(
					SELECT	Sum(Credit)
					FROM	#tblAll B
					WHERE	B.SerialNo = A.SerialNo AND 
							B.DC_State = A.DC_State AND
							Left(B.AcntCode, @LayerLen) = Left(A.AcntCode, @LayerLen)
					GROUP	BY B.SerialNo, Left(B.AcntCode, @LayerLen), B.DC_State 
				) 
				ELSE 0 END, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer9), case when (@ShowPortion = 1) and (@PortionLayer = 9) then 1 else 0 end
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End
	if (@FullParts = 1) and (@LayerS > 0)
	begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode,IsExtended)
		SELECT A.*, null, case when (@ShowPortion = 1) then 1 else 0 end
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) <= @LayerLen AND IsMainCode = 1 and Len(A.AcntCode) > @PrevPart

		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode,IsExtended)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), CASE WHEN (@ShowPortion = 1)   THEN
				(	
					SELECT	Sum(Debit)
					FROM	#tblAll B
					WHERE	B.SerialNo = A.SerialNo AND 
							B.DC_State = A.DC_State AND
							Left(B.AcntCode, @LayerLen) = Left(A.AcntCode, @LayerLen)
					GROUP	BY B.SerialNo, Left(B.AcntCode, @LayerLen), B.DC_State 
				)
				ELSE 0 END, 
				CASE WHEN (@ShowPortion = 1)   THEN
				(
					SELECT	Sum(Credit)
					FROM	#tblAll B
					WHERE	B.SerialNo = A.SerialNo AND 
							B.DC_State = A.DC_State AND
							Left(B.AcntCode, @LayerLen) = Left(A.AcntCode, @LayerLen)
					GROUP	BY B.SerialNo, Left(B.AcntCode, @LayerLen), B.DC_State 
				) 
				ELSE 0 END,
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @LayerS),  case when (@ShowPortion = 1) then 1 else 0 end
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1 
	end
	
	SET @PrevPart = @LayerLen;

	--*** ------------------------------------------------------------- ***
	--*** --------------------- Second Section ------------------------ ***
	--*** ------------------------------------------------------------- ***
	SELECT	@Layer1 = Layer1, @Layer2 = Layer2, @Layer3 = Layer3, 
			@Layer4 = Layer4, @Layer5 = Layer5, @Layer6 = Layer6, 
			@Layer7 = Layer7, @Layer8 = Layer8, @Layer9 = Layer9
	FROM	pub.tblCodeLayer 
	WHERE	PartNumber = 2 AND TableName = 'acc.tblAcnt'

	SET	@LayerNumber = 2
	SET	@LayerLen = @LayerLen + 1    --/ Space /--
	SET	@LayerLen = @LayerLen + @Layer1
	SET	@LayerS = @Layer1+@Layer2+@Layer3+@Layer4+@Layer5+@Layer6+@Layer7+@Layer8+@Layer9

	If (@FullParts = 0) and (@Layer1 > 0) 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer1 - 1)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer1 - 1)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer2

	If (@FullParts = 0) and (@Layer2 > 0) 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer2)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer2)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer3

	If (@FullParts = 0) and (@Layer3 > 0) 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer3)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer3)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer4

	If (@FullParts = 0) and (@Layer4 > 0) 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer4)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer4)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer5

	If (@FullParts = 0) and (@Layer5 > 0) 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer5)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer5)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer6

	If (@FullParts = 0) and (@Layer6 > 0) 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer6)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer6)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer7

	If (@FullParts = 0) and (@Layer7 > 0) 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer7)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer7)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer8

	If (@FullParts = 0) and (@Layer8 > 0) 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer8)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer8)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer9

	If (@FullParts = 0) and (@Layer9 > 0) 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer9)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer9)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End
	
	if (@FullParts = 1) and (@LayerS > 0)
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @LayerS - 1)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) <= @LayerLen AND IsMainCode = 1  and Len(A.AcntCode) > @PrevPart

		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @LayerS - 1)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End
	
	SET @PrevPart = @LayerLen;

   --*** ------------------------------------------------------------- ***
	--*** --------------- Third Section ------------------------------- ***
   --*** ------------------------------------------------------------- ***
	SELECT	@Layer1 = Layer1, @Layer2 = Layer2, @Layer3 = Layer3, 
			@Layer4 = Layer4, @Layer5 = Layer5, @Layer6 = Layer6, 
			@Layer7 = Layer7, @Layer8 = Layer8, @Layer9 = Layer9
	FROM	pub.tblCodeLayer 
	WHERE	PartNumber = 3 AND TableName = 'acc.tblAcnt'

	SET	@LayerNumber = 3
	SET	@LayerLen = @LayerLen + 1  --/ Space /--
	SET	@LayerLen = @LayerLen + @Layer1
	SET	@LayerS = @Layer1+@Layer2+@Layer3+@Layer4+@Layer5+@Layer6+@Layer7+@Layer8+@Layer9

	If (@FullParts = 0) and (@Layer1 > 0) 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer1 - 1)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer1 - 1)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer2

	If (@FullParts = 0) and (@Layer2 > 0) 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer2)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer2)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer3

	If (@FullParts = 0) and (@Layer3 > 0) 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer3)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer3)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer4

	If (@FullParts = 0) and (@Layer4 > 0) 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer4)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer4)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer5

	If (@FullParts = 0) and (@Layer5 > 0) 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer5)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer5)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer6

	If (@FullParts = 0) and (@Layer6 > 0) 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer6)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer6)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer7

	If (@FullParts = 0) and (@Layer7 > 0) 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer7)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer7)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer8

	If (@FullParts = 0) and (@Layer8 > 0) 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer8)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer8)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer9

	If (@FullParts = 0) and (@Layer9 > 0) 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer9)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer9)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End
	
	if (@FullParts = 1) and (@LayerS > 0)
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @LayerS - 1)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) <= @LayerLen AND IsMainCode = 1 and Len(A.AcntCode) > @PrevPart

		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @LayerS - 1)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End
	
	SET @PrevPart = @LayerLen;
	
	--*** ------------------------------------------------------------- ***
	--*** --------------- Forth Section ------------------------------- ***
   --*** ------------------------------------------------------------- ***
	SELECT	@Layer1 = Layer1, @Layer2 = Layer2, @Layer3 = Layer3, 
			@Layer4 = Layer4, @Layer5 = Layer5, @Layer6 = Layer6, 
			@Layer7 = Layer7, @Layer8 = Layer8, @Layer9 = Layer9
	FROM	pub.tblCodeLayer 
	WHERE	PartNumber = 4 AND TableName = 'acc.tblAcnt'

	SET	@LayerNumber = 4
	SET	@LayerLen = @LayerLen + 1  --/ Space /--
	SET	@LayerLen = @LayerLen + @Layer1
	SET	@LayerS = @Layer1+@Layer2+@Layer3+@Layer4+@Layer5+@Layer6+@Layer7+@Layer8+@Layer9
	
	If (@FullParts = 0) and (@Layer1 > 0)
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer1 - 1)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer1 - 1)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer2
	
	If (@FullParts = 0) and (@Layer2 > 0) 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer2)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer2)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer3
	
	If (@FullParts = 0) and (@Layer3 > 0) 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer3)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer3)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer4
	
	If (@FullParts = 0) and (@Layer4 > 0) 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer4)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer4)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer5
	
	If (@FullParts = 0) and (@Layer5 > 0) 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer5)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer5)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer6
	
	If (@FullParts = 0) and (@Layer6 > 0) 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer6)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer6)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer7

	If (@FullParts = 0) and (@Layer7 > 0) 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer7)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer7)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer8

	If (@FullParts = 0) and (@Layer8 > 0) 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer8)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer8)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer9

	If (@FullParts = 0) and (@Layer9 > 0) 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer9)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) <= @LayerLen AND IsMainCode = 1

		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer9)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	if (@FullParts = 1) and (@LayerS > 0)
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,RowNo,DocRowNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @LayerS - 1)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) <= @LayerLen AND IsMainCode = 1 and Len(A.AcntCode) > @PrevPart

		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @LayerS - 1)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End
	
	update #tblResult
	set	IsExtended = 0
	where (IsExtended is null)

	update  #tblResult
	set AcntName=pub.GetCodeName(AcntCode, 1)
  
	 -----------------------------------------
	if  @ShowDesc1=1
	begin
	
		delete 
		FROM #tblResult
		where len(AcntCode) > acc.funGetAcntLayerStartandLen(1,2)
		and Debit=0 and Credit=0
		and len(AcntCode) <> acc.funGetAcntLayerStartandLen(2,1)+ acc.funGetAcntLayerStartandLen(2,2)-1
		and  len(AcntCode) <> acc.funGetAcntLayerStartandLen(3,1)+ acc.funGetAcntLayerStartandLen(3,2)-1
		and  len(AcntCode) <> acc.funGetAcntLayerStartandLen(4,1)+ acc.funGetAcntLayerStartandLen(4,2)-1
		AND AcntCode<>ParentCode
	
		update  #tblResult
		set RowNo	=0
		, DocRowNo	=0
		where RowNo	is null
	
		Declare @AcntCode VarChar(20)	 
		Declare @AcntCode2 VarChar(20)	 
		Declare @AcntName nvarchar(200)
		Declare @AcntName2 nvarchar(200)
		Declare @RowDesc1 nvarchar(200)
		Declare @SerialNo nvarchar(200)
		Declare @RowNo nvarchar(200)
		Declare @DocRowNo nvarchar(200)
	
		select * into #tblResult2 from #tblResult where 1=0
	
		DECLARE CSR_B1 CURSOR FOR			
		select AcntCode,isnull(AcntName,'') AcntName,isnull(RowDesc1 ,'') RowDesc1,SerialNo ,RowNo,DocRowNo	 FROM #tblResult
		order by SerialNo,Case when Debit=0 then 1 else 0  end ,AcntCode
		OPEN CSR_B1
		FETCH NEXT FROM CSR_B1 INTO @AcntCode,@AcntName, @RowDesc1,@SerialNo,@RowNo,@DocRowNo

		WHILE @@fetch_status = 0
		BEGIN

			insert into #tblResult2
				 select * from #tblResult
				 where AcntCode=@AcntCode and SerialNo=@SerialNo and RowNo=@RowNo	
			 
			 if @AcntName=@AcntName2 and  @AcntCode=@AcntCode2 and  @AcntName<>''
			 begin
				 update #tblResult2
					set AcntName=pub.funReverseForCrystal(@RowDesc1)
					where AcntCode=@AcntCode and SerialNo=@SerialNo and RowNo=@RowNo
					and isnull(RowDesc1 ,'')<>''
				
				 update #tblResult2
					set RowDesc1=''
					where AcntCode=@AcntCode and SerialNo=@SerialNo and RowNo=@RowNo and RowDesc1=@RowDesc1
			
			 end
			 set @AcntName2=@AcntName
			 set @AcntCode=@AcntCode2
		
				FETCH NEXT FROM CSR_B1 INTO @AcntCode,@AcntName, @RowDesc1,@SerialNo,@RowNo,@DocRowNo
		END

		CLOSE CSR_B1
		DEALLOCATE CSR_B1


		 delete from #tblResult
		 insert into #tblResult
		 select * from #tblResult2
	 
		 delete from #tblResult2
		 where RowDesc1='' or RowDesc1 is null
	 
		 update #tblResult2
		 set  RowDesc1='', Debit=0,Credit=0,RowNo=0,DocRowNo=0
	 
		 insert into #tblResult 
		  select * from #tblResult2
	 
		--select * from #tblResult
		--order by AcntCode
	 
		 update #tblResult
		 set AcntName=pub.funReverseForCrystal(RowDesc1) ,RowDesc1=''
		 where RowDesc1<>''
	 
		update #tblResult
		set AcntCode2= AcntCode
		where   rtrim(ltrim (len(AcntCode))) <= acc.funGetAcntLayerStartandLen(1,2)
	
		update #tblResult
		set AcntCode2= Space(acc.funGetAcntLayerStartandLen(1,2)+1)+ substring(AcntCode ,acc.funGetAcntLayerStartandLen(2,1), acc.funGetAcntLayerStartandLen(2,2))
		where   rtrim(ltrim (len(AcntCode))) <= acc.funGetAcntLayerStartandLen(2,1)+ acc.funGetAcntLayerStartandLen(2,2)-1
		and  rtrim(ltrim (len(AcntCode))) > acc.funGetAcntLayerStartandLen(1,2)
	
		update #tblResult
		set AcntCode2=Space(acc.funGetAcntLayerStartandLen(1,2)+acc.funGetAcntLayerStartandLen(2,2)+1)+ substring(AcntCode ,acc.funGetAcntLayerStartandLen(3,1), acc.funGetAcntLayerStartandLen(3,2))
		where   rtrim(ltrim (len(AcntCode))) <= acc.funGetAcntLayerStartandLen(3,1)+ acc.funGetAcntLayerStartandLen(3,2)-1
		and   rtrim(ltrim (len(AcntCode))) > acc.funGetAcntLayerStartandLen(2,1)+ acc.funGetAcntLayerStartandLen(2,2)-1
		

		update #tblResult
		set AcntCode2=
		Space(acc.funGetAcntLayerStartandLen(1,2)+acc.funGetAcntLayerStartandLen(2,2)+acc.funGetAcntLayerStartandLen(3,2)+1)+
		substring(AcntCode ,acc.funGetAcntLayerStartandLen(4,1), acc.funGetAcntLayerStartandLen(4,2))
		where  rtrim(ltrim (len(AcntCode))) <= acc.funGetAcntLayerStartandLen(4,1)+ acc.funGetAcntLayerStartandLen(4,2)-1
		and  rtrim(ltrim (len(AcntCode)))> acc.funGetAcntLayerStartandLen(3,1)+ acc.funGetAcntLayerStartandLen(3,2)-1
	
	end
---------------------------------------------------
	update #tblResult
		set RowDesc2 =''
		where Debit	=0 and Credit =0
	
	update #tblResult
		set DocDesc1 =b.DocDesc,DocDesc2 =b.DocDesc2
		from #tblResult a 
		inner join acc.tblVoucherHdr b
			on a.SerialNo=b.SerialNo

	Declare  @MinLen	int 
	select @MinLen= min (len(AcntCode)) from #tblResult

-- Sort By AcntCode
	Declare @Part1Start	TinyInt;
	Declare @Part2Start	TinyInt;
	Declare @Part3Start	TinyInt;
	Declare @Part4Start	TinyInt;
	Declare @Part1Len	TinyInt;
	Declare @Part2Len	TinyInt;
	Declare @Part3Len	TinyInt;
	Declare @Part4Len	TinyInt;

	select @Part1Start=acc.funGetAcntLayerStartandLen(1,1)	
	select @Part2Start=acc.funGetAcntLayerStartandLen(2,1)
	select @Part3Start=acc.funGetAcntLayerStartandLen(3,1)
	select @Part4Start=acc.funGetAcntLayerStartandLen(4,1)

	select @Part1Len=acc.funGetAcntLayerStartandLen(1,2)
	select @Part2Len=acc.funGetAcntLayerStartandLen(2,2)
	select @Part3Len=acc.funGetAcntLayerStartandLen(3,2)
	select @Part4Len=acc.funGetAcntLayerStartandLen(4,2)

	update #tblResult 
		set Acnt1=SUBSTRING(AcntCode,@Part1Start,@Part1Len)
			, Acnt2=SUBSTRING(AcntCode,@Part2Start,@Part2Len)
			, Acnt3=SUBSTRING(AcntCode,@Part3Start,@Part3Len)
			, Acnt4=SUBSTRING(AcntCode,@Part4Start,@Part4Len)
			,Acnt1Name=''	,Acnt2Name=''	,Acnt3Name=''	,Acnt4Name=''

	update #tblResult set Acnt1Name =isnull(b.AcntName,'') from #tblResult a inner join acc.tblAcntDtl b on a.Acnt1=b.AcntCode and b.PartNumber=1 
	update #tblResult set Acnt2Name =isnull(b.AcntName,'') from #tblResult a inner join acc.tblAcntDtl b on a.Acnt2=b.AcntCode and b.PartNumber=2 
	update #tblResult set Acnt3Name =isnull(b.AcntName,'') from #tblResult a inner join acc.tblAcntDtl b on a.Acnt3=b.AcntCode and b.PartNumber=3 
	update #tblResult set Acnt4Name =isnull(b.AcntName,'') from #tblResult a inner join acc.tblAcntDtl b on a.Acnt4=b.AcntCode and b.PartNumber=4 

	if (@SortByOldSrl = 0) 
		SELECT	Distinct  R.*, pub.GetUserName(H.SessionNo) UserName,
						  H.CurrencyTypeID, isnull(C.CurrencyTypeName,'') as CurrencyTypeName,H.CurrencyRate,
						  @UserFullName UserFullName, @UserName PrintUserName, pub.funFarsiDate(GETDATE()) PrintDate
						  ,isnull(D.SourceProcessID,0) SourceProcessID
						  ,isnull(D.SourceProcessNo,0) SourceProcessNo
						  ,isnull(D.SourceFiscalYear,0) SourceFiscalYear
						  ,isnull(D.SourceSerialNo,0) SourceSerialNo,@MinLen MinLen,
						  H.Tax_Type
		FROM #tblResult R
        LEFT JOIN acc.tblVoucherHdr H on H.SerialNo=R.SerialNo 
        LEFT JOIN acc.tblVoucherDtl D on D.SerialNo=R.SerialNo and  D.RowNo=R.RowNo          
        LEFT OUTER JOIN pub.tblCurrencyTypesDtl C  on C.CurrencyTypeID=H.CurrencyTypeID
		ORDER BY R.SerialNo, R.DC_State, R.AcntCode, R.IsMainCode DESC,RowNo
	else
		SELECT	Distinct R.*,  pub.GetUserName(H.SessionNo) UserName,
						 H.CurrencyTypeID, IsNull(C.CurrencyTypeName,'') as CurrencyTypeName,H.CurrencyRate,H.OldSerialNo OldSerialNo1,
						 @UserFullName UserFullName, @UserName PrintUserName, pub.funFarsiDate(GETDATE()) PrintDate
						  ,isnull(D.SourceProcessID,0) SourceProcessID
						  ,isnull(D.SourceProcessNo,0) SourceProcessNo
						  ,isnull(D.SourceFiscalYear,0) SourceFiscalYear
						  ,isnull(D.SourceSerialNo,0) SourceSerialNo,@MinLen MinLen,
						  H.Tax_Type
	FROM #tblResult R
        INNER JOIN acc.tblVoucherHdr H on H.SerialNo = R.SerialNo
        LEFT JOIN acc.tblVoucherDtl D on D.SerialNo=R.SerialNo and  D.RowNo=R.RowNo          
        LEFT OUTER JOIN pub.tblCurrencyTypesDtl C on C.CurrencyTypeID = H.CurrencyTypeID
		ORDER BY  OldSerialNo1,R.SerialNo, R.DC_State, R.AcntCode, R.IsMainCode DESC,RowNo
END
GO
