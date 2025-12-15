USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/12/07
-- Viewed By	 : 
-- Last Modified : 1390/01/21
-- Last Modifier : TakroSystem\Zia
-- Description   : 
-- =================================================================
Create PROCEDURE [sal].[RptSal_SorMatrix_Dyna]
	@FromDate		varchar(10) = '0000/00/00',
	@ToDate			varchar(10) = '9999/99/99',
	@SorStore		Nvarchar(20) = '',
	@RemainStore	Nvarchar(20) = '',
	@ProcessNo		varchar(2) = '0',
	@RepOptions		nvarchar(200) = '111',
	@RepInfo		nvarchar(100) = '1@1@1', -- bit array options
	@ExtraParams	nvarchar(1000) = '' 
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(max)
DECLARE @StrFrom	NVarChar(max)
DECLARE @StrWhere	NVarChar(max)
DECLARE @GoodsID	nVarChar(50);
DECLARE @GoodsName	nVarChar(50);

DECLARE @Accepted	Bit;
DECLARE @NoAccept	Bit;
DECLARE @ShowSubUnit	Bit;

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی

BEGIN

	SET NOCOUNT ON;

	-- I N I T ------------------------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1';
	IF (@RepOptions		Is Null)	SET @RepOptions = '111'

	SET @Accepted	= Substring(@RepOptions, 1, 1);
	SET @NoAccept	= Substring(@RepOptions, 2, 1);

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	---------------------------------------------------------------------------
	-- WHERE SECTION --------------------------------
	SET @ShowSubUnit	= pub.funSplitString(@ExtraParams, '@', 1);
	SET @StrWhere		= pub.funSplitString(@ExtraParams, '@', 2);

	If (@ProcessNo > '0')
		SET @StrWhere = @StrWhere + ' AND D.ProcessNo=' + @ProcessNo 
	
	If (@FromDate <> '')
		SET @StrWhere = @StrWhere + ' AND D.DocDate>=''' + @FromDate + ''''

	If (@ToDate <> '')
		SET @StrWhere = @StrWhere + ' AND D.DocDate<=''' + @ToDate + ''''

	If (@SorStore <> '')
		SET @StrWhere = @StrWhere + ' AND D.StoreID=''' + @SorStore + ''''
		
		
	create table #tbl_Result
	(
		DocDate		char(10) not null,
		SerialNo	int not null ,
		AcntCode	varchar(20) collate arabic_cs_as not null,
		GoodsID		varchar(20) collate arabic_cs_as not null,
		GoodsName	nvarchar(100) not null,
		GoodsQuantity	float not null
	);
	if @ShowSubUnit=0
	SET @StrSelect = '
		insert into #tbl_Result
		SELECT DocDate,SerialNo,AcntCode ,GoodsID,[pub].[funGetGoodsName](GoodsID, ' + @LangID + ') As GoodsName,GoodsQuantity 
		FROM sal.tblSaleOrderDtl D where ProcessID = 180  ' +  @StrWhere + '
		UNION
		SELECT DocDate,SerialNo,AcntCode ,GoodsID,GoodsName, [inv].[funGetGoodsRemain](NULL,NULL,NULL,NULL,NULL,''' + @RemainStore + ''',GoodsID,'''',''' + @ToDate + ''',0) GoodsQuantity  
		FROM (
			SELECT distinct ''9999/99/99'' DocDate ,99999999 SerialNo,''9999999999'' AcntCode,GoodsID,[pub].[funGetGoodsName](GoodsID,  ' + @LangID + ') As GoodsName
			FROM sal.tblSaleOrderDtl D where ProcessID = 180 ' +  @StrWhere + '
			) a'
	if @ShowSubUnit=1

	SET @StrSelect = '
		insert into #tbl_Result
		select DocDate,SerialNo,AcntCode ,GoodsID,GoodsName,  [inv].[funGetSubUnitFromGoodsQuantity](a.GoodsID,b.SubUnitID,GoodsQuantity) GoodsQuantity from (	
		SELECT DocDate,SerialNo,AcntCode ,GoodsID,[pub].[funGetGoodsName](GoodsID, ' + @LangID + ') As GoodsName,GoodsQuantity
		FROM sal.tblSaleOrderDtl D where ProcessID = 180  ' +  @StrWhere + '
		UNION
		SELECT DocDate,SerialNo,AcntCode ,GoodsID,GoodsName, [inv].[funGetGoodsRemain](NULL,NULL,NULL,NULL,NULL,''' + @RemainStore + ''',GoodsID,'''',''' + @ToDate + ''',0) GoodsQuantity  
		FROM (
			SELECT distinct ''9999/99/99'' DocDate ,99999999 SerialNo,''9999999999'' AcntCode,GoodsID,[pub].[funGetGoodsName](GoodsID,  ' + @LangID + ') As GoodsName
			FROM sal.tblSaleOrderDtl D where ProcessID = 180 ' +  @StrWhere + '
			) a
			) a inner join inv.tblSubUnitsDtl b on a.GoodsID=b.GoodsID  and b.ShowInInvoice=1 '
			
	print @StrSelect;
	exec sp_executesql @StrSelect;
	-------------------------------------------------
	declare @colsD nvarchar(max);
	declare @colsSD nvarchar(max);
	set @colsD = '[جمع]';
	set @colsSD = 'SUM([جمع]) [جمع]';

	declare csr_Codes cursor for 
		select distinct GoodsName,GoodsID
		from #tbl_Result
		order by GoodsID
	open csr_Codes;

	fetch next from csr_Codes into @GoodsID,@GoodsName;

	while (@@FETCH_STATUS = 0) 
	begin
		if (@colsD <> '') 
		begin
			set @colsD = @colsD + ',';
			set @colsSD = @colsSD + ',';
		END	
		set @colsD = @colsD + '[' + @GoodsID + ']';
		set @colsSD = @colsSD + 'SUM([' + @GoodsID + ']) [' + @GoodsID + ']';
		fetch next from csr_Codes into @GoodsID,@GoodsName;
	end

	close csr_Codes;
	deallocate csr_Codes;

	-- SELECT SECTION -------------------------------
	SET @StrSelect = '
	select ' + @colsSD + ',AcntCode,LocationName,AcntName,SerialNo,DocDate
	from (
	select X.*
	from
	(
		select ' + @colsD + ',AcntCode, [acc].[funPartAcntName](AcntCode, 2) As AcntName,[acc].[funPartLayerNameFromAcnt](AcntCode, 2) LocationName,SerialNo,DocDate 
		from #tbl_Result P
		PIVOT 
		(
			Sum(P.GoodsQuantity)
			for P.GoodsName In (' + @colsD + ')
		) AS PVT 
	) X 
	) a
	group by AcntCode,LocationName,AcntName,SerialNo,DocDate
	order by a.SerialNo'
	-------------------------------------------------

	print @StrSelect;
	exec sp_executesql @StrSelect;
END
GO
