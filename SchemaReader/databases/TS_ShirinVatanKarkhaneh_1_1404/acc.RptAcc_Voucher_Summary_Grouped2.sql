USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 06-13-2007
-- Viewed By	 : 
-- Last Modified : 1392/09/16
-- Last Modifier : TakroSystem\Zia
-- Description	 : <Voucher Summary Report Grouped by Serial No>
-- =============================================
Create PROCEDURE [acc].[RptAcc_Voucher_Summary_Grouped2]
	@SelectLen		int = 20, -- not used
	@ReportType		int = 2, -- not used
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
-- DECLARE Variables ------------
DECLARE @Layer1 Tinyint
DECLARE @Layer2 Tinyint
DECLARE @Layer3 Tinyint
DECLARE @Layer4 Tinyint
DECLARE @Layer5 Tinyint
DECLARE @Layer6 Tinyint
DECLARE @Layer7 Tinyint
DECLARE @Layer8 Tinyint
DECLARE @Layer9 Tinyint
DECLARE @LayerS Tinyint
DECLARE @LayerLen Tinyint
DECLARE @PrevPart Tinyint
DECLARE @FullParts Bit
DECLARE @Source nvarchar(50)
DECLARE	@UseCurrency	Bit; -- 1 = از واحد ارزی استفاده شود
DECLARE @SourceProcessID varchar(100)
DECLARE	@SourceProcessNo	VARCHAR(30);

DECLARE @UserName		NVarChar(4000)
DECLARE @UserFullName	NVarChar(4000)

DECLARE	@UserID			Int;
DECLARE	@UserIsAdmin	bit;

SET @UserID			= pub.funSplitString(@RepInfo, '@', 4);
SET @UserIsAdmin	= pub.funSplitString(@RepInfo, '@', 5);

CREATE TABLE #tblAcntCode
		(
		AcntCode 			Varchar(20)collate arabic_cs_as null
		)	
CREATE TABLE #tblSerialRowCount
		(
		SerialNo 			int,
		SerialRowCount 			int
		)

CREATE TABLE #tblAll
(
	SerialNo	Int	Null,
	AcntCode	VarChar(20) COLLATE Arabic_CS_AS Not Null,
	Debit		float Not Null,
	Credit		float Not Null,
	DocDesc1	NVarChar(max) COLLATE Arabic_CS_AS Null,
	DocDesc2	NVarChar(max) COLLATE Arabic_CS_AS Null,
	DocDate		Char(10),
	DC_State	TinyInt, -- 0 = Debit, 1 = Credit
	IsMainCode	Bit Not Null,
	OldSerialNo	Int	Null
);

CREATE TABLE #tblResult
(
	SerialNo	Int	Null,
	AcntCode	VarChar(20) COLLATE Arabic_CS_AS Not Null,
	Debit		float Not Null,
	Credit		float Not Null,
	DocDesc1	NVarChar(max) COLLATE Arabic_CS_AS Null,
	DocDesc2	NVarChar(max) COLLATE Arabic_CS_AS Null,
	DocDate		Char(10),
	DC_State	TinyInt, -- 0 = Debit, 1 = Credit
	IsMainCode	Bit Not Null,
	OldSerialNo	Int	Null,
	ParentCode	VarChar(20) COLLATE Arabic_CS_AS Null,
	IsExtended	Bit null
);

DECLARE	@StrQuery		NVarChar(2000);
DECLARE	@StrWhere		NVarChar(1000);
DECLARE	@LayerNumber	TinyInt;

DECLARE @ShowDocDesc1	Bit -- شامل شرح اول سند باشد یا نه؟
DECLARE @ShowDocDesc2	Bit -- شامل شرح دوم سند باشد یا نه؟
DECLARE @ShowRecDesc1	Bit -- شامل شرح ردیف اول باشد یا نه؟
DECLARE @ShowRecDesc2	Bit -- شامل شرح ردیف دوم باشد یا نه؟
DECLARE @ShowPortion	Bit -- شامل ستون جزء باشد یا نه؟
DECLARE @AutoY	Bit
DECLARE @AutoN	Bit 
DECLARE @SortByOldSrl Bit
DECLARE	@LockOnly	bit;
DECLARE	@SumAmount	bit;


BEGIN ---------------------------------------------------------------------

	SET NOCOUNT ON;

	set @LockOnly = 0;
	select @LockOnly = SettingValue
	from pub.tblSettings
	where SettingKey='Acc_ReportLockedOnly'

	SET @SourceProcessID = pub.funSplitString(@ExtraParams, '#', 1);
	SET @UserFullName	 = pub.funSplitString(@ExtraParams, '#', 2);
	SET @UserName		 = pub.funSplitString(@ExtraParams, '#', 3);	

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
	set @SumAmount		= Substring(@RepOptions, 16, 1)
	---------------------------------------------------------

	if (@UseCurrency = 1) 
		set @Source = 'acc.vwVoucherDtl2'
	else
		set @Source = 'acc.tblVoucherDtl'

	--========= < W H E R E > =======================================================
	SET @LayerLen = 0;
	SET @PrevPart = 0;
		
	SET @StrWhere = '(D.VchKind <> 0)';

	if (@SourceProcessID <> '')
		SET @StrWhere = @StrWhere  + ' AND (D.SourceProcessID in (' + LTrim(@SourceProcessID) + '))'

	If (@SourceProcessNo <>'0')
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

	--============ < S E L E C T > ==================================================

	SET @StrQuery = '
		INSERT INTO	#tblAll
		SELECT	D.SerialNo, Left(LTrim(RTrim(D.AcntCode)), ' + LTrim(Str(@SelectLen)) + ') AcntCode, Sum(D.Debit) Debit, Sum(D.Credit) Credit, 
				H.DocDesc AS DocDesc1, H.DocDesc2, D.DocDate,
				CASE WHEN (Debit <> 0) Then 0 Else 1 End AS DC_State, 1 AS IsMainCode, H.OldSerialNo
		FROM	' + @Source + ' D 
					INNER JOIN acc.tblVoucherHdr H ON D.SerialNo = H.SerialNo 
		WHERE	' + @StrWhere + ' 
		GROUP BY D.SerialNo, D.AcntCode, CASE WHEN (Debit <> 0) Then 0 Else 1 End, H.DocDesc, H.DocDesc2, D.DocDate, H.OldSerialNo '
	
	print @StrQuery;
	Exec sp_executesql @StrQuery;
		
if @UserIsAdmin=0
	begin
		
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

	If	(@FullParts <> 1) and @Layer1 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Null
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		if not((@ShowPortion = 1) and (@PortionLayer > 1)) 
		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode,IsExtended)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 
				CASE WHEN @ShowPortion = 1 THEN
				(	
					SELECT	Sum(Debit)
					FROM	#tblAll B
					WHERE	B.SerialNo = A.SerialNo AND 
							B.DC_State = A.DC_State AND
							Left(B.AcntCode, @LayerLen) = Left(A.AcntCode, @LayerLen)
					GROUP	BY B.SerialNo, Left(B.AcntCode, @LayerLen), B.DC_State 
				)
				ELSE 0 END, 
				CASE WHEN @ShowPortion = 1 THEN
				(
					SELECT	Sum(Credit)
					FROM	#tblAll B
					WHERE	B.SerialNo = A.SerialNo AND 
							B.DC_State = A.DC_State AND
							Left(B.AcntCode, @LayerLen) = Left(A.AcntCode, @LayerLen)
					GROUP	BY B.SerialNo, Left(B.AcntCode, @LayerLen), B.DC_State 
				) 
				ELSE 0 END, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer1), case when (@ShowPortion = 1) and (@PortionLayer = 1) then 1 else 0 end
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1

	End
	
	SET @LayerLen = @LayerLen + @Layer2

	If  (@FullParts <> 1) and @Layer2 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer2)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		if not((@ShowPortion = 1) and (@PortionLayer > 2)) 
		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode,IsExtended)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 
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
				ELSE 0 END, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer2), case when (@ShowPortion = 1) and (@PortionLayer = 2) then 1 else 0 end
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer3

	If  (@FullParts <> 1) and @Layer3 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer3)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		if not((@ShowPortion = 1) and (@PortionLayer > 3)) 
		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode,IsExtended)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 
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
				ELSE 0 END, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer3), case when (@ShowPortion = 1) and (@PortionLayer = 3) then 1 else 0 end
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer4

	If  (@FullParts <> 1) and @Layer4 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer4)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		if not((@ShowPortion = 1) and (@PortionLayer > 4)) 
		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode,IsExtended)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 				
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
				ELSE 0 END, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer4), case when (@ShowPortion = 1) and (@PortionLayer = 4) then 1 else 0 end
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer5

	If  (@FullParts <> 1) and @Layer5 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer5)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		if not((@ShowPortion = 1) and (@PortionLayer > 5)) 
		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode,IsExtended)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 
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
				ELSE 0 END, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer5), case when (@ShowPortion = 1) and (@PortionLayer = 5) then 1 else 0 end
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer6

	If  (@FullParts <> 1) and @Layer6 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer6)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		if not((@ShowPortion = 1) and (@PortionLayer > 6)) 
		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode,IsExtended)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 
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
				ELSE 0 END, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer6), case when (@ShowPortion = 1) and (@PortionLayer = 6) then 1 else 0 end
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer7

	If  (@FullParts <> 1) and @Layer7 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer7)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		if not((@ShowPortion = 1) and (@PortionLayer > 7)) 
		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode,IsExtended)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 
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
				ELSE 0 END, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer7), case when (@ShowPortion = 1) and (@PortionLayer = 7) then 1 else 0 end
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer8

	If  (@FullParts <> 1) and @Layer8 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer8)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		if not((@ShowPortion = 1) and (@PortionLayer > 8)) 
		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode,IsExtended)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen),
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
				ELSE 0 END, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer8), case when (@ShowPortion = 1) and (@PortionLayer = 8) then 1 else 0 end
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer9
	
	If (@FullParts <> 1) and @Layer9 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer9)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		if not((@ShowPortion = 1) and (@PortionLayer > 9)) 
		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode,IsExtended)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 
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
				ELSE 0 END, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer9), case when (@ShowPortion = 1) and (@PortionLayer = 9) then 1 else 0 end
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End
	
	if (@FullParts = 1) and (@LayerS > 0)
	begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode,IsExtended)
		SELECT A.*, null,  case when (@ShowPortion = 1) then 1 else 0 end
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) <= @LayerLen AND IsMainCode = 1 and Len(A.AcntCode) > @PrevPart
	
		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode,IsExtended)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 
		CASE WHEN (@ShowPortion = 1)   THEN
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
		 '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @LayerS),  case when (@ShowPortion = 1) then 1 else 0 end
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

	If (@FullParts <> 1) and @Layer1 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer1 - 1)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 0, 0, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer1 - 1)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer2

	If (@FullParts <> 1) and @Layer2 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer2)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 0, 0, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer2)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer3

	If (@FullParts <> 1) and @Layer3 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer3)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 0, 0, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer3)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer4

	If (@FullParts <> 1) and @Layer4 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer4)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 0, 0, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer4)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer5

	If (@FullParts <> 1) and @Layer5 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer5)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 0, 0, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer5)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer6

	If (@FullParts <> 1) and @Layer6 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer6)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 0, 0, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer6)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer7

	If (@FullParts <> 1) and @Layer7 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer7)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 0, 0, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer7)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer8

	If (@FullParts <> 1) and @Layer8 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer8)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 0, 0, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer8)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer9

	If (@FullParts <> 1) and @Layer9 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer9)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 0, 0, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer9)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End
	
	if (@FullParts = 1) and (@LayerS > 0)
	begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @LayerS)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) <= @LayerLen AND IsMainCode = 1 and Len(A.AcntCode) > @PrevPart

		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 0,0,'', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @LayerS)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	end
	
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

	If (@FullParts <> 1) and @Layer1 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer1 - 1)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 0, 0, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer1 - 1)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer2

	If  (@FullParts <> 1) and @Layer2 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer2)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 0, 0, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer2)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer3

	If  (@FullParts <> 1) and @Layer3 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer3)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 0, 0, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer3)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer4

	If  (@FullParts <> 1) and @Layer4 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer4)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 0, 0, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer4)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer5

	If  (@FullParts <> 1) and @Layer5 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer5)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 0, 0, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer5)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer6

	If  (@FullParts <> 1) and @Layer6 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer6)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 0, 0, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer6)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer7

	If  (@FullParts <> 1) and @Layer7 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer7)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 0, 0, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer7)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer8

	If  (@FullParts <> 1) and @Layer8 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer8)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 0, 0, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer8)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer9

	If  (@FullParts <> 1) and @Layer9 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer9)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 0, 0, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer9)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End
	
	if (@FullParts = 1) and (@LayerS > 0)
	begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @LayerS)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) <= @LayerLen AND IsMainCode = 1 and Len(A.AcntCode) > @PrevPart

		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen),0,0,'', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @LayerS)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	end
	
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

	If	(@FullParts <> 1) and @Layer1 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer1 - 1)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 0, 0, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer1 - 1)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer2
	
	If  (@FullParts <> 1) and @Layer2 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer2)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 0, 0, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer2)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer3
	
	If  (@FullParts <> 1) and @Layer3 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer3)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 0, 0, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer3)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer4
	
	If  (@FullParts <> 1) and @Layer4 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer4)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 0, 0, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer4)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer5
	
	If  (@FullParts <> 1) and @Layer5 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer5)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 0, 0, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer5)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer6
	
	If  (@FullParts <> 1) and @Layer6 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer6)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 0, 0, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer6)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer7
	
	If  (@FullParts <> 1) and @Layer7 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer7)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 0, 0, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer7)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer8

	If  (@FullParts <> 1) and @Layer8 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer8)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 0, 0, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer8)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer9

	If  (@FullParts <> 1) and @Layer9 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer9)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 0, 0, '', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer9)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End
	
	if (@FullParts = 1) and (@LayerS > 0)
	begin
		INSERT INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @LayerS)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) <= @LayerLen AND IsMainCode = 1 and Len(A.AcntCode) > @PrevPart

		INSERT	INTO #tblResult(SerialNo,AcntCode,Debit,Credit,DocDesc1,DocDesc2,DocDate,DC_State,IsMainCode,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, Left(AcntCode, @LayerLen), 0,0,'', '', 
				DocDate, DC_State, 0, A.OldSerialNo, Left(AcntCode, @LayerLen - @LayerS)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	end
	
	SET @PrevPart = @LayerLen;

	update #tblResult
	set	IsExtended = 0
	where (IsExtended is null)
	
	----------------------------------------------------------------------------/
	if @SumAmount='True'
	begin
		if @SortByOldSrl = 0
			SELECT	R.SerialNo,R.AcntCode,Sum(R.Debit) Debit	,Sum(R.Credit) Credit	,R.DocDesc1,R.DocDesc2,	R.DocDate	,R.DC_State	,R.IsMainCode	,R.OldSerialNo	,R.ParentCode	,R.IsExtended	
				, pub.GetCodeName(AcntCode, 1) AS AcntName, pub.GetUserName(H.SessionNo) UserName,
					@UserFullName UserFullName, @UserName PrintUserName, 
					pub.funFarsiDate(GETDATE()) PrintDate,Tax_Type
			FROM	#tblResult R
			LEFT JOIN acc.tblVoucherHdr H on H.SerialNo=R.SerialNo 
			group by R.SerialNo,R.AcntCode,R.DocDesc1,R.DocDesc2,	R.DocDate	,R.DC_State	,R.IsMainCode	,R.OldSerialNo	,R.ParentCode	,R.IsExtended	, H.SessionNo,Tax_Type
			Order By R.SerialNo,R.DC_State, R.AcntCode, R.IsMainCode Desc
		else
			SELECT	R.SerialNo,R.AcntCode,Sum(R.Debit) Debit	,Sum(R.Credit) Credit	,R.DocDesc1,R.DocDesc2,	R.DocDate	,R.DC_State	,R.IsMainCode	,R.OldSerialNo	,R.ParentCode	,R.IsExtended	
				, pub.GetCodeName(AcntCode, 1) AS AcntName, pub.GetUserName(H.SessionNo) UserName,
					@UserFullName UserFullName, @UserName PrintUserName, 
					pub.funFarsiDate(GETDATE()) PrintDate,Tax_Type
			FROM	#tblResult R
			LEFT JOIN acc.tblVoucherHdr H on H.SerialNo=R.SerialNo 
			group by R.SerialNo,R.AcntCode,R.DocDesc1,R.DocDesc2,	R.DocDate	,R.DC_State	,R.IsMainCode	,R.OldSerialNo	,R.ParentCode	,R.IsExtended	, H.SessionNo,Tax_Type
			Order By R.OldSerialNo,R.DC_State, R.AcntCode, R.IsMainCode Desc
	end 
	else
	begin
		if @SortByOldSrl = 0
			SELECT	R.*, pub.GetCodeName(AcntCode, 1) AS AcntName, pub.GetUserName(H.SessionNo) UserName,
					@UserFullName UserFullName, @UserName PrintUserName, 
					pub.funFarsiDate(GETDATE()) PrintDate,Tax_Type
			FROM	#tblResult R
			LEFT JOIN acc.tblVoucherHdr H on H.SerialNo=R.SerialNo 
			Order By R.SerialNo,R.DC_State, R.AcntCode, R.IsMainCode Desc
		else
			SELECT	R.*, pub.GetCodeName(AcntCode, 1) AS AcntName, pub.GetUserName(H.SessionNo) UserName,
					@UserFullName UserFullName, @UserName PrintUserName, 
					pub.funFarsiDate(GETDATE()) PrintDate,Tax_Type
			FROM	#tblResult R
			LEFT JOIN acc.tblVoucherHdr H on H.SerialNo=R.SerialNo 
			Order By R.OldSerialNo,R.DC_State, R.AcntCode, R.IsMainCode Desc
	end
END
GO
