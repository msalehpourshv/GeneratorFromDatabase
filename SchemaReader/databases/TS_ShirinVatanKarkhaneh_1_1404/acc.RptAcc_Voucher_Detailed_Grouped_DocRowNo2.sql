USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 06-13-2007
-- Viewed By	 : 
-- Last Modified : 1390/10/10
-- Last Modifier : TakroSystem\Zia
-- Description	 : <Voucher> -- چاپ اسناد حسابداری
-- ===============================================
Create PROCEDURE [acc].[RptAcc_Voucher_Detailed_Grouped_DocRowNo2]
	@SelectLen		int = 20, -- not used in this report (just for sync with common report)
	@ReportType		int = 2, -- (use 2 for this report)
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
	@RepOptions		varchar(20) = '0000011000',
	@RepInfo		nvarchar(100) = '1@1@1',
	@ExtraParams	nvarChar(200) = ''
WITH ENCRYPTION
AS

DECLARE @Layer1Len TinyInt
DECLARE @Layer2Len TinyInt
DECLARE @Layer3Len TinyInt
DECLARE @Layer4Len TinyInt

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
DECLARE @Source nvarchar(50)
DECLARE	@SourceProcessNo	VARCHAR(30);

DECLARE @ShowDocDesc1	Bit -- شامل شرح اول سند باشد یا نه؟
DECLARE @ShowDocDesc2	Bit -- شامل شرح دوم سند باشد یا نه؟
DECLARE @ShowRecDesc1	Bit -- شامل شرح ردیف اول باشد یا نه؟
DECLARE @ShowRecDesc2	Bit -- شامل شرح ردیف دوم باشد یا نه؟
DECLARE @ShowPortion	Bit -- شامل ستون جزء باشد یا نه؟
DECLARE @AutoY	Bit
DECLARE @AutoN	Bit 
DECLARE @SortByOldSrl Bit
DECLARE @FullParts Bit
DECLARE	@UseCurrency	Bit; -- 1 = از واحد ارزی استفاده شود

DECLARE @SourceProcessID varchar(100)
DECLARE @UserName		NVarChar(4000)
DECLARE @UserFullName	NVarChar(4000)

DECLARE	@UserID			Int;
DECLARE	@UserIsAdmin	bit;

SET @UserID			= pub.funSplitString(@RepInfo, '@', 4);
SET @UserIsAdmin	= pub.funSplitString(@RepInfo, '@', 5);

IF @SelectLen = 0
	SET @SelectLen = 20

CREATE TABLE #tblAcntCode
		(
		AcntCode 			Varchar(20)collate arabic_cs_as null
		)	
CREATE TABLE #tblSerialRowCount
		(
		SerialNo 			int,
		SerialRowCount 			int
		)

Create Table #tblAll
(
	SerialNo		Int	Null,
	DocDate			Char(10) COLLATE Arabic_CS_AS,
	AcntCode		VarChar(20) COLLATE Arabic_CS_AS Not Null,
	Debit			float Not Null,
	Credit			float Not Null,
	DC_State		TinyInt, -- 0 = Debit, 1 = Credit
	DocDesc1		NVarChar(4000) COLLATE Arabic_CS_AS Null,
	DocDesc2		NVarChar(4000) COLLATE Arabic_CS_AS Null,
	RecDesc1		NVarChar(4000) COLLATE Arabic_CS_AS Null,
	RecDesc2		NVarChar(4000) COLLATE Arabic_CS_AS Null,
	IsMainCode		Bit Not Null,
	RowNo			Int,
	SourceProcessID Int,
	SourceProcessNo Int,
	SourceSerialNo  Int,
	OldSerialNo		Int	Null
);

Create Table #tblResult
(
	SerialNo		Int	Null,
	DocDate			Char(10) COLLATE Arabic_CS_AS,
	AcntCode		VarChar(20) COLLATE Arabic_CS_AS Not Null,
	Debit			float Not Null,
	Credit			float Not Null,
	DC_State		TinyInt, -- 0 = Debit, 1 = Credit
	DocDesc1		NVarChar(4000) COLLATE Arabic_CS_AS Null,
	DocDesc2		NVarChar(4000) COLLATE Arabic_CS_AS Null,
	RowDesc1		NVarChar(4000) COLLATE Arabic_CS_AS Null,
	RowDesc2		NVarChar(4000) COLLATE Arabic_CS_AS Null,
	IsMainCode		Bit Not Null,
	RowNo			Int,
	SourceProcessID Int,
	SourceProcessNo Int,
	SourceSerialNo  Int,
	OldSerialNo		Int	Null,
	ParentCode		VarChar(20) COLLATE Arabic_CS_AS Null,
	IsExtended		Bit null
);

DECLARE	@StrQuery	NVarChar(4000);
DECLARE	@StrWhere	NVarChar(2000);
DECLARE	@LayerNumber	TinyInt;
DECLARE	@LockOnly	bit;
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
	IF (@RepOptions Is Null)	SET @RepOptions = '0000011000';

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
	---------------------------------------------------------

	if (@UseCurrency = 1) 
		set @Source = 'acc.vwVoucherDtl2'
	else
		set @Source = 'acc.tblVoucherDtl'

	SET @LayerLen = 0;
	SET @PrevPart = 0;

	If (@ReportType = 1) 
		-- Continous State (Common)
		SET @StrWhere = '(D.VchKind > -1)';
	Else -- Discrete State (Detailed)
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
		
		declare @AcntName1  bit;
		declare @AcntName2  bit;
		declare @AcntName3  bit;
		declare @AcntName4  bit;
		SELECT     @AcntName1  =SettingValue FROM         pub.tblSettings WHERE     (SettingKey = N'AcntNameFromPart1') 
		SELECT     @AcntName2  =SettingValue FROM         pub.tblSettings WHERE     (SettingKey = N'AcntNameFromPart2') 
		SELECT     @AcntName3  =SettingValue FROM         pub.tblSettings WHERE     (SettingKey = N'AcntNameFromPart3') 
		SELECT     @AcntName4  =SettingValue FROM         pub.tblSettings WHERE     (SettingKey = N'AcntNameFromPart4') 

	/* =================== Continous (Common) State ============== */
	If (@ReportType = 1)   -- حالت عادی بدون تفکیک و به ترتیب ثبت --
	Begin	
		
Create Table #tblAll2
(
	SerialNo		Int	Null,
	DocDate			Char(10) COLLATE Arabic_CS_AS,
	DocRowNo		Int,
	AcntCode		VarChar(20) COLLATE Arabic_CS_AS Not Null,
	Debit			float Not Null,
	Credit			float Not Null,
	DC_State		TinyInt, -- 0 = Debit, 1 = Credit
	DocDesc1		NVarChar(4000) COLLATE Arabic_CS_AS Null,
	DocDesc2		NVarChar(4000) COLLATE Arabic_CS_AS Null,
	RowDesc1		NVarChar(4000) COLLATE Arabic_CS_AS Null,
	RowDesc2		NVarChar(4000) COLLATE Arabic_CS_AS Null,
	IsMainCode		Bit Not Null,
	ParentCode		VarChar(20) COLLATE Arabic_CS_AS Not Null,
	SourceProcessID Int,
	SourceProcessNo Int,
	SourceSerialNo  Int,
	OldSerialNo		Int	Null,
	IsExtended		bit,
	AcntName1		NVarChar(4000) COLLATE Arabic_CS_AS Null,
	AcntName2		NVarChar(4000) COLLATE Arabic_CS_AS Null,
	AcntName3		NVarChar(4000) COLLATE Arabic_CS_AS Null,
	AcntName4		NVarChar(4000) COLLATE Arabic_CS_AS Null,
	UserName		NVarChar(4000) COLLATE Arabic_CS_AS Null,
	AcntName		NVarChar(4000) COLLATE Arabic_CS_AS Null,
	Tax_Type		Int	
);

		SET @StrQuery	= ' INSERT	into #tblAll2(SerialNo,DocDate,DocRowNo,AcntCode, Debit, Credit, DC_State, DocDesc1, DocDesc2, RowDesc1, RowDesc2,IsMainCode, ParentCode
							,SourceProcessID,SourceProcessNo,SourceSerialNo, OldSerialNo,IsExtended,AcntName1,AcntName2,AcntName3,AcntName4,UserName,AcntName,Tax_Type)
		SELECT	SerialNo, DocDate,DocRowNo,Left(LTrim(RTrim(AcntCode)), ' + LTrim(Str(@SelectLen)) + '), Debit, Credit, DC_State, DocDesc1, DocDesc2, RowDesc1, RowDesc2,IsMainCode, ParentCode,SourceProcessID,SourceProcessNo,SourceSerialNo, OldSerialNo
		, IsExtended,AcntName1,AcntName2,AcntName3,AcntName4,UserName
		,case when AcntNameCust='' '' then  AcntName else AcntNameCust end AcntName,Tax_Type
		  From (
		SELECT	D.SerialNo, D.DocDate,D.DocRowNo,
				LTrim(RTrim(D.AcntCode)) AS AcntCode, D.Debit, D.Credit, 
				CASE WHEN (D.Debit <> 0) THEN 0 ELSE 1 END AS DC_State, ' +
				CASE WHEN(@ShowDocDesc1 = 1) THEN 'H.DocDesc ' ELSE 'Cast('''' As NVarChar(4000))' END + ' AS DocDesc1, ' + 
				CASE WHEN(@ShowDocDesc2 = 1) THEN 'H.DocDesc2' ELSE 'Cast('''' As NVarChar(4000))' END + ' AS DocDesc2, ' + 
				CASE WHEN(@ShowRecDesc1 = 1) THEN 'D.RecDesc ' ELSE 'Cast('''' As NVarChar(4000))' END + ' AS RowDesc1, ' + 
				CASE WHEN(@ShowRecDesc2 = 1) THEN 'D.RecDesc2' ELSE 'Cast('''' As NVarChar(4000))' END + ' AS RowDesc2, 
				Cast(1 As Bit) As IsMainCode, '''' AS ParentCode, pub.GetCodeName(LTrim(RTrim(D.AcntCode)), 1) AS AcntName,'
				if @AcntName1=1  SET @StrQuery	=@StrQuery+ ' acc.funPartAcntName(D.AcntCode, 1) +  '' ''+'
				if @AcntName2=1  SET @StrQuery	=@StrQuery+ ' acc.funPartAcntName(D.AcntCode, 2) +  '' ''+'
				if @AcntName3=1  SET @StrQuery	=@StrQuery+ ' acc.funPartAcntName(D.AcntCode, 3) +  '' ''+'
				if @AcntName4=1  SET @StrQuery	=@StrQuery+ ' acc.funPartAcntName(D.AcntCode, 4) + '' '' +'
		SET @StrQuery	=@StrQuery+ ' '' ''  AcntNameCust,SourceProcessID,SourceProcessNo,SourceSerialNo, H.OldSerialNo, cast(0 as bit) as IsExtended,
				acc.funPartAcntName(D.AcntCode, 1) AcntName1,
				acc.funPartAcntName(D.AcntCode, 2) AcntName2,
				acc.funPartAcntName(D.AcntCode, 3) AcntName3,
				acc.funPartAcntName(D.AcntCode, 4) AcntName4,
				 pub.GetUserName(H.SessionNo) UserName,H.Tax_Type
 		FROM	' + @Source + ' D 
 					INNER JOIN acc.tblVoucherHdr H On H.SerialNo = D.SerialNo 
		WHERE ' + @StrWhere + ') DD
		ORDER BY SerialNo,DocRowNo,SourceProcessID,SourceProcessNo,SourceSerialNo '
	
		print @StrQuery;
		EXEC sp_executesql @StrQuery;
	 
	if @UserIsAdmin=0
	begin
		
		Insert into  #tblAcntCode (AcntCode)	SELECT Distinct AcntCode	FROM  #tblAll2
		Insert into  #tblSerialRowCount (SerialNo,SerialRowCount)	SELECT SerialNo, Count(*)	FROM  #tblAll2 group by SerialNo
		
		exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID;
	
		--حذف ردیف های سند که کاربر دسترسی ندارد

		delete  from #tblAll2 where AcntCode not in ( select AcntCode from #tblAcntCode )

		----حذف اسنادی که کاربری به تعدادی از ردیف های سند دسترسی ندارد
		delete  from #tblAll2 
		from #tblAll2 a 
		inner join (SELECT SerialNo, Count(*)	 SerialRowCount FROM  #tblAll2 group by SerialNo )b 
		on a.SerialNo=b.SerialNo
		inner join #tblSerialRowCount c
		on b.SerialNo=c.SerialNo and b.SerialRowCount<c.SerialRowCount

	end

	if @ShowPortion='true' and @PortionLayer>0
		begin		
			SELECT	@Layer1 = Layer1, @Layer2 = Layer2, @Layer3 = Layer3, 
				@Layer4 = Layer4, @Layer5 = Layer5, @Layer6 = Layer6, 
				@Layer7 = Layer7, @Layer8 = Layer8, @Layer9 = Layer9
			FROM	pub.tblCodeLayer 
			WHERE	PartNumber = 1 AND TableName = 'acc.tblAcnt'

			if @PortionLayer=2
					set @Layer1=@Layer1+@Layer2
			if @PortionLayer=3
					set @Layer1=@Layer1+@Layer2+@Layer3
			if @PortionLayer=4
					set @Layer1=@Layer1+@Layer2+@Layer3+@Layer4
			if @PortionLayer=5
					set @Layer1=@Layer1+@Layer2+@Layer3+@Layer4+@Layer5
	
		insert into 	 #tblAll2
			select * from (
				SELECT SerialNo,DocDate,0 DocRowNo, SUBSTRING(AcntCode,1, @Layer1) AcntCode , Sum(Debit) Debit,0 Credit 
					,0 DC_State,'' DocDesc1,'' DocDesc2,'' RowDesc1,'' RowDesc2,0 IsMainCode,'' ParentCode,0 SourceProcessID,0 SourceProcessNo
					,0 SourceSerialNo,	OldSerialNo	, 1 IsExtended	,''  AcntName1
					,''	AcntName2	,'' AcntName3	,'' AcntName4	, UserName	,pub.GetCodeName(SUBSTRING(AcntCode,1, @Layer1), 1) AS AcntName	,Tax_Type	
				 FROM  #tblAll2
				 where Debit>0
				group by SerialNo,DocDate ,OldSerialNo, SUBSTRING(AcntCode,1, @Layer1),UserName,Tax_Type
			 ) a
			 order by SerialNo,  AcntCode

		insert into 	 #tblAll2
			select * from (
				SELECT SerialNo,DocDate,0 DocRowNo, SUBSTRING(AcntCode,1, @Layer1) AcntCode , 0 Debit, Sum(Credit) Credit  
					,0 DC_State,'' DocDesc1,'' DocDesc2,'' RowDesc1,'' RowDesc2,0 IsMainCode,'' ParentCode,0 SourceProcessID,0 SourceProcessNo
					,0 SourceSerialNo,	OldSerialNo	, 1 IsExtended	,''  AcntName1
					,''	AcntName2	,'' AcntName3	,'' AcntName4	, UserName	,pub.GetCodeName(SUBSTRING(AcntCode,1, @Layer1), 1) AS AcntName	,Tax_Type	
				 FROM  #tblAll2
				 where Credit>0
				group by SerialNo,DocDate ,OldSerialNo, SUBSTRING(AcntCode,1, @Layer1),UserName,Tax_Type
			 ) a
			 order by SerialNo,  AcntCode
 
	end
	 
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

	
	select 	AcntCode ,AcntCode Acnt1 ,AcntCode Acnt11 ,AcntCode Acnt2 ,AcntCode Acnt3 ,AcntCode Acnt4
		,AcntName Acnt1Name,AcntName Acnt11Name,AcntName Acnt2Name,AcntName Acnt3Name,AcntName Acnt4Name
	  into  #tblAcntCodeName from #tblAll2
	  where 1=0

	  insert into #tblAcntCodeName
	  select  Distinct	AcntCode
				,SUBSTRING(AcntCode,@Part1Start,@Part1Len)
				,SUBSTRING(AcntCode,@Part1Start,@Part1Len)
				,SUBSTRING(AcntCode,@Part2Start,@Part2Len)
				,SUBSTRING(AcntCode,@Part3Start,@Part3Len)
				,SUBSTRING(AcntCode,@Part4Start,@Part4Len)
				,Acnt1Name='',Acnt11Name=''	,Acnt2Name=''	,Acnt3Name=''	,Acnt4Name=''
		from #tblAll2
	
	update #tblAcntCodeName set Acnt1Name =isnull(b.AcntName,'') from #tblAcntCodeName a inner join acc.tblAcntDtl b on a.Acnt1=b.AcntCode and b.PartNumber=1 
	update #tblAcntCodeName set Acnt11Name =isnull(b.AcntName,'') from #tblAcntCodeName a inner join acc.tblAcntDtl b on a.Acnt11=b.AcntCode and b.PartNumber=1 
	update #tblAcntCodeName set Acnt2Name =isnull(b.AcntName,'') from #tblAcntCodeName a inner join acc.tblAcntDtl b on a.Acnt2=b.AcntCode and b.PartNumber=2 
	update #tblAcntCodeName set Acnt3Name =isnull(b.AcntName,'') from #tblAcntCodeName a inner join acc.tblAcntDtl b on a.Acnt3=b.AcntCode and b.PartNumber=3 
	update #tblAcntCodeName set Acnt4Name =isnull(b.AcntName,'') from #tblAcntCodeName a inner join acc.tblAcntDtl b on a.Acnt4=b.AcntCode and b.PartNumber=4 

 	if @ShowPortion='true' and @PortionLayer>0
	begin
		update #tblAcntCodeName
		set Acnt1=SUBSTRING(Acnt1,1, @Layer1)

		update #tblAcntCodeName
		set Acnt11=SUBSTRING(Acnt11,len(Acnt1)+1,len(Acnt11)-len(Acnt1))
				
		update #tblAll2 
		set DocRowNo =  (select  top 1 DocRowNo  from #tblAll2  b 
						where Debit>0 and #tblAll2.AcntCode=SUBSTRING(b.AcntCode,1,len( #tblAll2.AcntCode)))
		where Debit>0  and DocRowNo=0

		update #tblAll2 
		set DocRowNo =  (select  top 1 DocRowNo  from #tblAll2  b 
						where Credit>0 and #tblAll2.AcntCode=SUBSTRING(b.AcntCode,1,len( #tblAll2.AcntCode)))
		where Credit>0  and DocRowNo=0
		
		select * from 
		( SELECT a.*,Acnt1 , Acnt11 , Acnt2 , Acnt3 , Acnt4
		 , Acnt1Name, Acnt11Name, Acnt2Name, Acnt3Name, Acnt4Name 	
		 ,case when Credit>0 then 1 else 0 end OrderType
		 FROM  #tblAll2 a
		 inner join #tblAcntCodeName b
		 on a.AcntCode=b.AcntCode) a 
		 order by  a.SerialNo, OrderType ,a.AcntCode ,IsMainCode,a.SourceProcessID,a.SourceProcessNo,a.SourceSerialNo

		return 
	end
	
	 SELECT a.*,Acnt1 , Acnt11 , Acnt2 , Acnt3 , Acnt4
	 , Acnt1Name, Acnt11Name, Acnt2Name, Acnt3Name, Acnt4Name 	
	 FROM  #tblAll2 a
	 inner join #tblAcntCodeName b
	 on a.AcntCode=b.AcntCode
	 order by a.SerialNo,a.DocRowNo,a.SourceProcessID,a.SourceProcessNo,a.SourceSerialNo


	RETURN
End
	/* ================================================ */
	
	SET @StrQuery = '
	INSERT	INTO #tblAll
	SELECT	D.SerialNo, D.DocDate,
			Left(LTrim(RTrim(D.AcntCode)), ' + LTrim(Str(@SelectLen)) + ') AS AcntCode, D.Debit, D.Credit, 
			CASE WHEN (D.Debit <> 0) THEN 0 ELSE 1 END AS DC_State, ' +
			CASE WHEN(@ShowDocDesc1 = 1) THEN 'H.DocDesc ' ELSE 'Cast('''' As NVarChar(4000))' END + ' AS DocDesc1, ' + 
			CASE WHEN(@ShowDocDesc2 = 1) THEN 'H.DocDesc2' ELSE 'Cast('''' As NVarChar(4000))' END + ' AS DocDesc2, ' + 
			CASE WHEN(@ShowRecDesc1 = 1) THEN 'D.RecDesc ' ELSE 'Cast('''' As NVarChar(4000))' END + ' AS RowDesc1, ' + 
			CASE WHEN(@ShowRecDesc2 = 1) THEN 'D.RecDesc2' ELSE 'Cast('''' As NVarChar(4000))' END + ' AS RowDesc2, Cast(1 As Bit), 
			D.DocRowNo,D.SourceProcessID,D.SourceProcessNo,D.SourceSerialNo,H.OldSerialNo
	FROM	' + @Source + ' D 
				INNER JOIN acc.tblVoucherHdr H On H.SerialNo = D.SerialNo 
	WHERE ' + @StrWhere

	print @StrQuery;
	EXEC sp_executesql @StrQuery;


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

	If (@FullParts <> 1) and (@Layer1 > 0)
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Null
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		if not((@ShowPortion = 1) and (@PortionLayer > 1)) 
		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode,IsExtended)
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
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer1), case when (@ShowPortion = 1) and (@PortionLayer = 1) then 1 else 0 end
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End
	
	SET @LayerLen = @LayerLen + @Layer2

	If  (@FullParts <> 1) and @Layer2 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer2)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		if not((@ShowPortion = 1) and (@PortionLayer > 2)) 
		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode,IsExtended)
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
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer2), case when (@ShowPortion = 1) and (@PortionLayer = 2) then 1 else 0 end
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer3

	If  (@FullParts <> 1) and @Layer3 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer3)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		if not((@ShowPortion = 1) and (@PortionLayer > 3)) 
		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode,IsExtended)
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
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer3), case when (@ShowPortion = 1) and (@PortionLayer = 3) then 1 else 0 end
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer4

	If  (@FullParts <> 1) and @Layer4 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer4)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		if not((@ShowPortion = 1) and (@PortionLayer > 4)) 
		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode,IsExtended)
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
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer4), case when (@ShowPortion = 1) and (@PortionLayer = 4) then 1 else 0 end
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer5

	If  (@FullParts <> 1) and @Layer5 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer5)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		if not((@ShowPortion = 1) and (@PortionLayer > 5)) 
		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode,IsExtended)
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
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer5), case when (@ShowPortion = 1) and (@PortionLayer = 5) then 1 else 0 end
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer6

	If  (@FullParts <> 1) and @Layer6 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer6)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		if not((@ShowPortion = 1) and (@PortionLayer > 6)) 
		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode,IsExtended)
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
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer6), case when (@ShowPortion = 1) and (@PortionLayer = 6) then 1 else 0 end
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer7

	If  (@FullParts <> 1) and @Layer7 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer7)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		if not((@ShowPortion = 1) and (@PortionLayer > 7)) 
		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode,IsExtended)
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
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer7), case when (@ShowPortion = 1) and (@PortionLayer = 7) then 1 else 0 end
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer8

	If  (@FullParts <> 1) and @Layer8 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer8)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		if not((@ShowPortion = 1) and (@PortionLayer > 8)) 
		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode,IsExtended)
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
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer8), case when (@ShowPortion = 1) and (@PortionLayer = 8) then 1 else 0 end
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	If (@FullParts <> 1) and @Layer9 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer9)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		if not((@ShowPortion = 1) and (@PortionLayer > 9)) 
		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode,IsExtended)
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
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer9), case when (@ShowPortion = 1) and (@PortionLayer = 9) then 1 else 0 end
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End
	
	if (@FullParts = 1) and (@LayerS > 0)
	begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode,IsExtended)
		SELECT A.*, null, case when (@ShowPortion = 1) then 1 else 0 end
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) <= @LayerLen AND IsMainCode = 1 and Len(A.AcntCode) > @PrevPart

		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode,IsExtended)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen),CASE WHEN (@ShowPortion = 1)   THEN
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
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @LayerS), case when (@ShowPortion = 1) then 1 else 0 end
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
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer1 - 1)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer1 - 1)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer2

	If (@FullParts <> 1) and @Layer2 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer2)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer2)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer3

	If (@FullParts <> 1) and @Layer3 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer3)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer3)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer4

	If (@FullParts <> 1) and @Layer4 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer4)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer4)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer5

	If (@FullParts <> 1) and @Layer5 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer5)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer5)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer6

	If (@FullParts <> 1) and @Layer6 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer6)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer6)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer7

	If (@FullParts <> 1) and @Layer7 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer7)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer7)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer8

	If (@FullParts <> 1) and @Layer8 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer8)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer8)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer9

	If (@FullParts <> 1) and @Layer9 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer9)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer9)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End
	
	if (@FullParts = 1) and (@LayerS > 0)
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @LayerS - 1)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) <= @LayerLen AND IsMainCode = 1 and Len(A.AcntCode) > @PrevPart

		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @LayerS - 1)
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

	If (@FullParts <> 1) and @Layer1 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer1 - 1)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer1 - 1)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer2

	If (@FullParts <> 1) and @Layer2 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer2)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer2)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer3

	If (@FullParts <> 1) and @Layer3 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer3)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer3)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer4

	If (@FullParts <> 1) and @Layer4 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer4)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer4)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer5

	If (@FullParts <> 1) and @Layer5 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer5)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer5)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer6

	If (@FullParts <> 1) and @Layer6 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer6)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer6)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer7

	If (@FullParts <> 1) and @Layer7 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer7)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer7)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer8

	If (@FullParts <> 1) and @Layer8 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer8)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer8)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer9

	If (@FullParts <> 1) and @Layer9 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer9)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer9)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End
	
	if (@FullParts = 1) and (@LayerS > 0)
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @LayerS - 1)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) <= @LayerLen AND IsMainCode = 1 and Len(A.AcntCode) > @PrevPart

		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @LayerS - 1)
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
	
	If (@FullParts <> 1) and @Layer1 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer1 - 1)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer1 - 1)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer2
	
	If (@FullParts <> 1) and @Layer2 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer2)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer2)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer3
	
	If (@FullParts <> 1) and @Layer3 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer3)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer3)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer4
	
	If (@FullParts <> 1) and @Layer4 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer4)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer4)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer5
	
	If (@FullParts <> 1) and @Layer5 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer5)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer5)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer6
	
	If (@FullParts <> 1) and @Layer6 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer6)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer6)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer7
	
	If (@FullParts <> 1) and @Layer7 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer7)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer7)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer8

	If (@FullParts <> 1) and @Layer8 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer8)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer8)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer9

	If (@FullParts <> 1) and @Layer9 > 0 
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer9)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @Layer9)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	if (@FullParts = 1) and (@LayerS > 0)
	Begin
		INSERT INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT A.*, Left(AcntCode, @LayerLen - @LayerS - 1)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) <= @LayerLen AND IsMainCode = 1 and Len(A.AcntCode) > @PrevPart

		INSERT	INTO #tblResult(SerialNo,DocDate,AcntCode,Debit,Credit,DC_State,DocDesc1,DocDesc2,RowDesc1,RowDesc2,IsMainCode,RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,OldSerialNo,ParentCode)
		SELECT	DISTINCT SerialNo, DocDate, Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', '', '', 0, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo, A.OldSerialNo, Left(AcntCode, @LayerLen - @LayerS - 1)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	update #tblResult
	set	IsExtended = 0
	where (IsExtended is null)

		SELECT	R.*, pub.GetCodeName(R.AcntCode, 1) AS AcntName,
			acc.funPartAcntName(R.AcntCode, 1) AcntName1,
			acc.funPartAcntName(R.AcntCode, 2) AcntName2,
			acc.funPartAcntName(R.AcntCode, 3) AcntName3, 
			pub.GetUserName(H.SessionNo) UserName,
			@UserFullName UserFullName, @UserName PrintUserName, 
			pub.funFarsiDate(GETDATE()) PrintDate,H.Tax_Type    into #tblResult2
		FROM	#tblResult R
					left join acc.tblVoucherHdr H on H.SerialNo=R.SerialNo
		where 1=0
	-- Sort By DocRowNo
	if (@SortByOldSrl = 0) 
		SELECT	R.*, pub.GetCodeName(R.AcntCode, 1) AS AcntName,
			acc.funPartAcntName(R.AcntCode, 1) AcntName1,
			acc.funPartAcntName(R.AcntCode, 2) AcntName2,
			acc.funPartAcntName(R.AcntCode, 3) AcntName3, 
			pub.GetUserName(H.SessionNo) UserName,
			@UserFullName UserFullName, @UserName PrintUserName, 
			pub.funFarsiDate(GETDATE()) PrintDate,H.Tax_Type   
		FROM	#tblResult R
					left join acc.tblVoucherHdr H on H.SerialNo=R.SerialNo
		ORDER BY R.SerialNo, R.RowNo, R.DC_State, R.SourceProcessID, R.SourceProcessNo, R.SourceSerialNo, R.AcntCode, R.IsMainCode DESC
	
	else
		SELECT	R.*, pub.GetCodeName(R.AcntCode, 1) AS AcntName,
			acc.funPartAcntName(R.AcntCode, 1) AcntName1,
			acc.funPartAcntName(R.AcntCode, 2) AcntName2,
			acc.funPartAcntName(R.AcntCode, 3) AcntName3, 
			pub.GetUserName(H.SessionNo) UserName,
			@UserFullName UserFullName, @UserName PrintUserName, 
			pub.funFarsiDate(GETDATE()) PrintDate,H.Tax_Type  
		FROM	#tblResult R
					inner join acc.tblVoucherHdr H on H.SerialNo = R.SerialNo
		ORDER BY H.OldSerialNo, R.SerialNo, R.RowNo, R.DC_State, R.SourceProcessID, R.SourceProcessNo, R.SourceSerialNo, R.AcntCode, R.IsMainCode DESC
END
GO
