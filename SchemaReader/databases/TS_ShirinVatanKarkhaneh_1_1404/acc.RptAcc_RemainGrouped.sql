USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/10/22
-- Viewed By	 : 
-- Last Modified : 1389/12/07
-- Last Modifier : TakroSystem\Zia
-- Description	 : 
-- ==============================================
Create PROCEDURE [acc].[RptAcc_RemainGrouped]
	@SelectedAcnt1	int = 0,
	@SelectedAcnt2	int = 0,
	@SelectedAcnt3	int = 0,
	@SelectedAcnt4	int = 0,
	@SortFields		NVarChar(100) = Null,
	@ExtraParams	NVarChar(100) = '0',
	@RepOptions		VarChar(10) = '1',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
declare @UserIsAdmin bit;
declare @UserID		 int;

declare @StrSelect	nvarchar(4000);
declare @StrWhere	nvarchar(4000);
declare @StrFrom	nvarchar(4000);

declare @LangID		char(1);
declare @SessionNo	int; 
declare @ReportID	int; 

declare @Part1Start	int;
declare @Part1Len	int;
declare @Part2Start	int;
declare @Part2Len	int;
declare @Part3Start	int;
declare @Part3Len	int;
declare @Part4Start	int;
declare @Part4Len	int;

declare @PartNumber	int;
declare @PartLayer	int;

declare @LimitState1	SmallInt;
declare @LimitState2	SmallInt;
declare @LimitState3	SmallInt;
declare @LimitState4	SmallInt;
declare @ShowPrimary	Bit; 
declare @ShowFinish		Bit; 
declare @ShowClosed     Bit;
Begin

	SET NOCOUNT ON;

	-- I N I T -----------------------------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1';
	IF (@RepOptions		Is Null)	SET @RepOptions	= '1';
	IF (@ExtraParams	Is Null)	SET @ExtraParams= '0';
	IF (@ExtraParams	= '')		SET @ExtraParams= '0';

	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0;

	SET @PartLayer = pub.funSplitString(@ExtraParams, '@', 1);
	SET @SortFields = pub.funSplitString(@ExtraParams, '@', 2);
	SET @ShowPrimary = pub.funSplitString(@ExtraParams, '@', 6);
	SET @ShowFinish = pub.funSplitString(@ExtraParams, '@', 7);
	SET @ShowClosed = pub.funSplitString(@ExtraParams, '@', 8);
	set @PartNumber =@PartLayer/10 

	IF (@SortFields		Is Null)	SET @SortFields = 'AcntCode';

	SET @LangID			= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo		= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID		= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID			= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin	= pub.funSplitString(@RepInfo, '@', 5);

	-------- set layers len -----------------------------------------------------------------------
select @Part1Start=[acc].[funGetAcntLayerStartandLen](1,1),@Part1Len=[acc].[funGetAcntLayerStartandLen](1,2)
select @Part2Start=[acc].[funGetAcntLayerStartandLen](2,1),@Part2Len=[acc].[funGetAcntLayerStartandLen](2,2)
select @Part3Start=[acc].[funGetAcntLayerStartandLen](3,1),@Part3Len=[acc].[funGetAcntLayerStartandLen](3,2)
select @Part4Start=[acc].[funGetAcntLayerStartandLen](4,1),@Part4Len=[acc].[funGetAcntLayerStartandLen](4,2)


print @UserIsAdmin
	If (@UserIsAdmin = 1)
	Begin
		SET	@LimitState1 = 1;
		SET	@LimitState2 = 1;
		SET	@LimitState3 = 1;
		SET	@LimitState4 = 1;
	End
	Else
	Begin
		SELECT	TOP 1 @LimitState1 = AccessAllCode
		FROM	acc.tblAcntRng
		WHERE	(UserID = @UserID) AND (PartNumber = 1)

		SET @LimitState1 = IsNull(@LimitState1, -1);

		SELECT	TOP 1 @LimitState2 = AccessAllCode
		FROM	acc.tblAcntRng
		WHERE	(UserID = @UserID) AND (PartNumber = 2)

		SET @LimitState2 = IsNull(@LimitState2, -1);

		SELECT	TOP 1 @LimitState3 = AccessAllCode
		FROM	acc.tblAcntRng
		WHERE	(UserID = @UserID) AND (PartNumber = 3)

		SET @LimitState3 = IsNull(@LimitState3, -1);

		SELECT	TOP 1 @LimitState4 = AccessAllCode
		FROM	acc.tblAcntRng
		WHERE	(UserID = @UserID) AND (PartNumber = 4)

		SET @LimitState4 = IsNull(@LimitState4, -1);
	End
	---------------------------------------------------------------------------------------------
	-- W H E R E --------------------------------------------------------------
	Set @StrWhere = '(D.VchKind <> 0)'

	IF (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')
	If (@ShowPrimary = 0)
	    SET @StrWhere = @StrWhere  + ' AND VchKind <> 2 '
	If (@ShowFinish = 0)
	    SET @StrWhere = @StrWhere  + ' AND VchKind <> 3 '
	If (@ShowClosed = 0)
	    SET @StrWhere = @StrWhere  + ' AND VchKind <> 4 '
	-- permission --
	If (@LimitState1 = -1)
		SET @StrWhere = @StrWhere + ' AND LTrim(Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(@Part1Len)) + ')) = '''' '
	Else If (@LimitState1 = 0)
		SET @StrWhere = @StrWhere + ' AND acc.funPermitted(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(@Part1Len)) + '), 1)= 1 '

	If (@LimitState2 = -1)
		SET @StrWhere = @StrWhere + ' AND LTrim(Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@Part2Len)) + ')) = '''' '
	If (@LimitState2 = 0) 
		SET @StrWhere = @StrWhere + ' AND acc.funPermitted(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@Part2Len)) + '), 2)= 1 '

	If (@LimitState3 = -1)
		SET @StrWhere = @StrWhere + ' AND LTrim(Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@Part3Len)) + ')) = '''' '
	If (@LimitState3 = 0) 
		SET @StrWhere = @StrWhere + ' AND acc.funPermitted(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@Part3Len)) + '), 3)= 1 '

 	If (@LimitState4 = -1)
		SET @StrWhere = @StrWhere + ' AND LTrim(Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@Part4Len)) + ')) = '''' '
	If (@LimitState4 = 0) 
		SET @StrWhere = @StrWhere + ' AND acc.funPermitted(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@Part4Len)) + '), 4)= 1 '

	If (@UserIsAdmin <> 1)
	begin
		Set @StrWhere = @StrWhere + '
			AND acc.funPermitted2(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(@Part1Len)) + '), 1)= 1 '
		Set @StrWhere = @StrWhere + '
			AND acc.funPermitted2(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@Part2Len)) + '), 2)= 1 '
		Set @StrWhere = @StrWhere + '
			AND acc.funPermitted2(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@Part3Len)) + '), 3)= 1 '
		Set @StrWhere = @StrWhere + '
			AND acc.funPermitted2(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@Part4Len)) + '), 4)= 1 '
	end;

select AcntCode, MonthCode, Remain, Remain1, Remain2 into #R
			from
			(
				select	AcntCode, case when(VchKind = 2) then '00' else Substring(DocDate, 6, 2) end as MonthCode, sum(Debit-Credit) as Remain, sum(Debit) as Remain1, sum(Credit) as Remain2
				from	acc.tblVoucherDtl D
				where	(D.VchKind <> 0)
				group by AcntCode, case when(VchKind = 2) then '00' else Substring(DocDate, 6, 2) end 
			) T 
			where 1=0
			
select Distinct AcntCode into #A from #R
	---------------------------------------------------------------------------
	Declare @Acnt  varchar(100);

SELECT	top 0  PartNumber,Layer1 as LayerLen ,Layer2 	as SumLayer,0 as Layer into  #Layers FROM	pub.tblCodeLayer 	
insert into #Layers SELECT	PartNumber,Layer1  ,(Layer1 ),PartNumber*10+1  FROM	pub.tblCodeLayer 	WHERE	(TableName = 'acc.tblAcnt')
insert into #Layers SELECT	PartNumber,Layer2  ,(Layer1 )+(Layer2 ),PartNumber*10+2  FROM	pub.tblCodeLayer 	WHERE	(TableName = 'acc.tblAcnt')
insert into #Layers SELECT	PartNumber,Layer3  ,(Layer1 )+(Layer2 )+(Layer3 ),PartNumber*10+3  FROM	pub.tblCodeLayer 	WHERE	(TableName = 'acc.tblAcnt')
insert into #Layers SELECT	PartNumber,Layer4  ,(Layer1 )+(Layer2 )+(Layer3 )+(Layer4 ),PartNumber*10+4  FROM	pub.tblCodeLayer 	WHERE	(TableName = 'acc.tblAcnt')
insert into #Layers SELECT	PartNumber,Layer5   ,(Layer1 )+(Layer2 )+(Layer3 )+(Layer4 )+(Layer5 ),PartNumber*10+5  FROM	pub.tblCodeLayer 	WHERE	(TableName = 'acc.tblAcnt')
insert into #Layers SELECT	PartNumber,Layer6   ,(Layer1 )+(Layer2 )+(Layer3 )+(Layer4 )+(Layer5 )+(Layer6 ),PartNumber*10+6  FROM	pub.tblCodeLayer 	WHERE	(TableName = 'acc.tblAcnt')
insert into #Layers SELECT	PartNumber,Layer7   ,(Layer1 )+(Layer2 )+(Layer3 )+(Layer4 )+(Layer5 )+(Layer6 )+(Layer7 ),PartNumber*10+7  FROM	pub.tblCodeLayer 	WHERE	(TableName = 'acc.tblAcnt')
insert into #Layers SELECT	PartNumber,Layer8  ,(Layer1 )+(Layer2 )+(Layer3 )+(Layer4 )+(Layer5 )+(Layer6 )+(Layer7 )+(Layer8 ),PartNumber*10+8  FROM	pub.tblCodeLayer 	WHERE	(TableName = 'acc.tblAcnt')
insert into #Layers SELECT	PartNumber,Layer9  ,(Layer1 )+(Layer2 )+(Layer3 )+(Layer4 )+(Layer5 )+(Layer6 )+(Layer7 )+(Layer8 )+(Layer9 ),PartNumber*10+9  FROM	pub.tblCodeLayer 	WHERE	(TableName = 'acc.tblAcnt')

select @PartLayer= SumLayer from #Layers where Layer=@PartLayer
	if @PartNumber=1
		set @Acnt  =' SubString (AcntCode,1,'+ str(@Part1Start+@PartLayer-1)+' )'
	if @PartNumber=2
		set @Acnt  =' SubString (AcntCode,1,'+ str(@Part2Start+@PartLayer-1)+' )'
	if @PartNumber=3
		set @Acnt  =' SubString (AcntCode,1,'+ str(@Part3Start+@PartLayer-1)+'  )'
	if @PartNumber=4
		set @Acnt  =' SubString (AcntCode,1,'+ str(@Part4Start+@PartLayer-1)+'  )'
 
 	-- S E L E C T ------------------------------------------------------------
	SET @StrSelect = '
	select AcntCode, MonthCode, Remain, Remain1, Remain2 into #R
			from
			(
				select	'+ @Acnt +' AcntCode, case when(VchKind = 2) then ''00'' else Substring(DocDate, 6, 2) end as MonthCode, sum(Debit-Credit) as Remain, sum(Debit) as Remain1, sum(Credit) as Remain2
				from	acc.tblVoucherDtl D
				where	' + @StrWhere + '
				group by '+ @Acnt +' , case when(VchKind = 2) then ''00'' else Substring(DocDate, 6, 2) end 
			) T 
		
select Distinct AcntCode into #A from #R

select a.*, pub.GetCodeName(a.AcntCode, 1) AcntName,[acc].[funGetAcntFullName_LastLayers](a.AcntCode)AcntName2
,isnull(m00.Remain ,0) m00Remain ,isnull(m00.Remain1 ,0) m00Remain1 ,isnull(m00.Remain2 ,0) m00Remain2 
,isnull(m01.Remain ,0) m01Remain ,isnull(m01.Remain1 ,0) m01Remain1 ,isnull(m01.Remain2 ,0) m01Remain2 
,isnull(m02.Remain ,0) m02Remain ,isnull(m02.Remain1 ,0) m02Remain1 ,isnull(m02.Remain2 ,0) m02Remain2
,isnull(m03.Remain ,0) m03Remain ,isnull(m03.Remain1 ,0) m03Remain1 ,isnull(m03.Remain2 ,0) m03Remain2 
,isnull(m04.Remain ,0) m04Remain ,isnull(m04.Remain1 ,0) m04Remain1 ,isnull(m04.Remain2 ,0) m04Remain2 
,isnull(m05.Remain ,0) m05Remain ,isnull(m05.Remain1 ,0) m05Remain1 ,isnull(m05.Remain2 ,0) m05Remain2 
,isnull(m06.Remain ,0) m06Remain ,isnull(m06.Remain1 ,0) m06Remain1 ,isnull(m06.Remain2 ,0) m06Remain2 
,isnull(m07.Remain ,0) m07Remain ,isnull(m07.Remain1 ,0) m07Remain1 ,isnull(m07.Remain2 ,0) m07Remain2 
,isnull(m08.Remain ,0) m08Remain ,isnull(m08.Remain1 ,0) m08Remain1 ,isnull(m08.Remain2 ,0) m08Remain2 
,isnull(m09.Remain ,0) m09Remain ,isnull(m09.Remain1 ,0) m09Remain1 ,isnull(m09.Remain2 ,0) m09Remain2 
,isnull(m10.Remain ,0) m10Remain ,isnull(m10.Remain1 ,0) m10Remain1 ,isnull(m10.Remain2 ,0) m10Remain2 
,isnull(m11.Remain ,0) m11Remain ,isnull(m11.Remain1 ,0) m11Remain1 ,isnull(m11.Remain2 ,0) m11Remain2 
,isnull(m12.Remain ,0) m12Remain ,isnull(m12.Remain1 ,0) m12Remain1 ,isnull(m12.Remain2 ,0) m12Remain2 
from #A a
Left join (select * from #R where MonthCode=''00'') m00 on a.AcntCode=m00.AcntCode
Left join (select * from #R where MonthCode=''01'') m01 on a.AcntCode=m01.AcntCode
Left join (select * from #R where MonthCode=''02'') m02 on a.AcntCode=m02.AcntCode
Left join (select * from #R where MonthCode=''03'') m03 on a.AcntCode=m03.AcntCode
Left join (select * from #R where MonthCode=''04'') m04 on a.AcntCode=m04.AcntCode
Left join (select * from #R where MonthCode=''05'') m05 on a.AcntCode=m05.AcntCode
Left join (select * from #R where MonthCode=''06'') m06 on a.AcntCode=m06.AcntCode
Left join (select * from #R where MonthCode=''07'') m07 on a.AcntCode=m07.AcntCode
Left join (select * from #R where MonthCode=''08'') m08 on a.AcntCode=m08.AcntCode
Left join (select * from #R where MonthCode=''09'') m09 on a.AcntCode=m09.AcntCode
Left join (select * from #R where MonthCode=''10'') m10 on a.AcntCode=m10.AcntCode
Left join (select * from #R where MonthCode=''11'') m11 on a.AcntCode=m11.AcntCode
Left join (select * from #R where MonthCode=''12'') m12 on a.AcntCode=m12.AcntCode
		
ORDER BY ' + @SortFields
	---------------------------------------------------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
