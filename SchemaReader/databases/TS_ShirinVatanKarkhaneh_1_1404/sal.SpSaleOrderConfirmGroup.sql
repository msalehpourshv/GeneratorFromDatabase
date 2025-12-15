USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : jafari
-- Create date   : 95/08/05
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- ================================================
Create PROCEDURE [sal].[SpSaleOrderConfirmGroup]
	@StrWhere	NVarChar(4000),
	@DocDate	Char(10),
	@RepInfo	NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
BEGIN

	-- ==============
	DECLARE @SalRet_RetToSalOdr AS BIT
	SET @SalRet_RetToSalOdr = 'False'
	SELECT @SalRet_RetToSalOdr = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'SalRet_RetToSalOdr' 
	
	-- ==============
	DECLARE @StrSelect NVarChar(4000);
	DECLARE	@LangID		Char(1);
	DECLARE	@SessionNo	Int; 
	DECLARE	@ReportID	Int;
	DECLARE	@UserID		Int;
	DECLARE	@CustomerPartStart		Int;
	DECLARE	@CustomerPartLayerLen	Int;
	DECLARE	@CustomerPartNo		Int;
	DECLARE	@UserIsAdmin bit;
	DECLARE	@GoodsFilter bit;
	DECLARE	@GoodsFilter2 bit;
	DECLARE	@VisitPath1 bit;
	DECLARE	@VisitPath2 bit;
	DECLARE	@VisitPath3 bit;
	DECLARE	@VisitPath4 bit;
	DECLARE	@Campaign bit;
	DECLARE	@SalesRoomClass bit;
		
	DECLARE @StrWhereAcnt AS NVarChar(4000)
	DECLARE @StrAcntWhere	NVarChar(4000);
	
	SET @LangID				 = pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo			 = pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID			 = pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID				 = pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin		 = pub.funSplitString(@RepInfo, '@', 5);
	SET @GoodsFilter		 = pub.funSplitString(@RepInfo, '@', 6);
	SET @GoodsFilter2		 = pub.funSplitString(@RepInfo, '@', 7);
	SET @VisitPath1			 = pub.funSplitString(@RepInfo, '@', 8);
	SET @VisitPath2			 = pub.funSplitString(@RepInfo, '@', 9);
	SET @VisitPath3			 = pub.funSplitString(@RepInfo, '@', 10);
	SET @VisitPath4			 = pub.funSplitString(@RepInfo, '@', 11);
	SET @Campaign			 = pub.funSplitString(@RepInfo, '@', 12);
	SET @SalesRoomClass		 = pub.funSplitString(@RepInfo, '@', 13);
	SET @SalesRoomClass		 = pub.funSplitString(@RepInfo, '@', 13);
	SET @CustomerPartStart	 = pub.funSplitString(@RepInfo, '@', 14);
	SET @CustomerPartLayerLen = pub.funSplitString(@RepInfo, '@', 15);
	SET @CustomerPartNo		 = pub.funSplitString(@RepInfo, '@', 16);
	SET @StrWhereAcnt = ''

	IF @GoodsFilter = '1'
	BEGIN
		SET @StrWhere = @StrWhere + ' AND (SELECT COUNT(*) 
		                                   FROM sal.tblSaleOrderDtl D 
										   WHERE H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo AND 
										   ' + pub.funGetFilterString(@SessionNo, @ReportID, 1, 'D.GoodsID') +  ' ) > 0 '
	END

	IF @GoodsFilter2 = '1'
	BEGIN
		SET @StrWhere = @StrWhere + ' AND (SELECT COUNT(*) 
		                                   FROM sal.tblSaleOrderDtl D 
										   WHERE H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo AND 
										   ' + pub.funGetFilterString(@SessionNo, @ReportID, 2, 'D.GoodsID') +  ' ) = 0 '
	END


	set @StrAcntWhere=''

	If  @VisitPath1 > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, 3, 'VisitPathID1') 
		
	If  @VisitPath2 > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, 4, 'VisitPathID2') 
		
	If  @VisitPath3 > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, 5, 'VisitPathID3') 
		
	If  @VisitPath4 > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, 6, 'VisitPathID4') 
		
	If  @Campaign > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, 7, 'CampaignID') 

	If @SalesRoomClass > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, 8, 'SalesRoomClass') 

If  @StrAcntWhere <> ''
		SET @StrAcntWhere = '
		 WHERE Substring(AcntCode , ' + Str(@CustomerPartStart) + ', ' + Str(@CustomerPartLayerLen) + ') 
		       IN (Select AcntCode From acc.tblAcnt Where PartNumber = ' + LTrim(RTrim(Str(@CustomerPartNo))) + ' 
				  '+  @StrAcntWhere +') '
	
	BEGIN TRY
			DROP TABLE #tblAcntCode
			DROP TABLE #tblStoreID
		END TRY
		BEGIN CATCH
		END CATCH
		
	 CREATE TABLE #tblAcntCode
	(
		AcntCode	Varchar(20)	collate arabic_cs_as null
	)
	
	INSERT INTO  #tblAcntCode (AcntCode) SELECT  Distinct AcntCode	FROM sal.tblSaleOrderDtl WHERE  ProcessID = 180 And ProcessNo = 1

	--Insert into  #tblStoreID (StoreID) SELECT  Distinct StoreID	FROM         inv.tblStorageDocsHdr
	If @UserIsAdmin = 0
	Begin
		exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID;
	End
	
	SET @StrWhereAcnt =  '  HH.AcntCode in (SELECT   AcntCode	FROM  #tblAcntCode ' + @StrAcntWhere + ' ) '

	-- Select * From #tblAcntCode
	-- ==============
	SET @StrSelect = '
	SELECT   HH.*,isnull(p.PayOffTypeName,'''') PayOffTypeName, pub.GetCodeName(AcntCode,1) AS AcntCodeName, NationalIdentity, NationalIDNumber, EconomicalCode, pub.GetCodeName(VisitorAcntCode,1) AS VisitorAcntName,
			(
				SELECT	IsNull(Sum(Debit-Credit), 0) 
				FROM acc.tblVoucherDtl 
				WHERE VchKind <> 0 AND AcntCode = HH.AcntCode
			 ) DebitCredit,		 
					 IsNull((
								Select SUM(D.GoodsQuantity * D.GoodsPrice-D.DiscountDtl) - H.Discount - H.Discount2 AS EXPR2
								From sal.tblSaleOrderHdr AS H 
								Inner Join sal.tblSaleOrderDtl AS D ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
								Where (H.SerialNo = HH.SerialNo)  AND (H.FiscalYear = HH.FiscalYear) AND  (H.ProcessID = HH.ProcessID) AND (H.ProcessNo = HH.ProcessNo)
								Group By H.Discount, H.Discount2),0
			 ) Price, DocDesc
	FROM
	(
		SELECT DISTINCT A.ProcessID, A.ProcessNo, A.FiscalYear, A.SerialNo, A.DocDate, A.AcntCode, A.VisitorAcntCode,  F.NationalIdentity, F.NationalIDNumber, F.EconomicalCode,
			A.SgnSN1, A.SgnSN2, A.SgnSN3, A.SgnSN4, A.SgnSN5, A.DocDesc,A.SessionNo,A.PayOffTypeID,isnull(Address1,'''') Address1,ISnull(CodeClosed, 0)CodeClosed
		FROM 
		(
			SELECT D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.DocRowNo, H.DocDate, D.AcntCode, 
				   H.VisitorAcntCode, H.SgnSN1, H.SgnSN2, H.SgnSN3, H.SgnSN4, H.SgnSN5, H.DocDesc, H.SessionNo,
				   IsNull(D.GoodsQuantity, 0) - IsNull(C.GoodsQuantity, 0) Quantity,H.PayOffTypeID				  
			FROM (Select * From sal.tblSaleOrderHdr H Where ' + @StrWhere + ') H
			Inner Join sal.tblSaleOrderDtl D ON H.ProcessID = D.ProcessID And H.ProcessNo = D.ProcessNo And
												H.FiscalYear = D.FiscalYear And H.SerialNo = D.SerialNo
			Left Join (SELECT BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo,SUM(GoodsQuantity) GoodsQuantity 
					   FROM sal.tblSaleOrderDtl 
					   group by BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo 
					  ) C ON D.ProcessID = C.BaseProcessID And D.ProcessNo = C.BaseProcessNo And
			D.FiscalYear = C.BaseFiscalYear And D.SerialNo = C.BaseSerialNo And
			D.DocRowNo = C.BaseDocRowNo												
			WHERE  D.ProcessID = 180 And D.ProcessNo = 1 AND  (IsNull(D.GoodsQuantity, 0) - IsNull(C.GoodsQuantity, 0)) > 0
		) A
		OUTER APPLY acc.funGetCodeInfo(A.AcntCode) AS F
	) HH
	left join sal.tblPayOffTypesDtl p on p.PayOffTypeID=HH.PayOffTypeID and p.LanguageID='+@LangID+'
	WHERE ' + @StrWhereAcnt + '
	ORDER BY SerialNo'
 
	Print @StrSelect;
	Exec sp_executesql @StrSelect;

END
GO
