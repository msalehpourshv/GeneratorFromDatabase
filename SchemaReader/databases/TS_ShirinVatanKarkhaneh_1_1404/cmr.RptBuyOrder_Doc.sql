USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem/Ahmadnejad
-- Create date   : 1387/01/08
-- Viewed By	 : 
-- Last Modified : 1393/08/03
-- Last Modifier : TakroSystem/Hamid
-- Description   : برگ سفارش خرید کالا
-- =============================================
Create PROCEDURE [cmr].[RptBuyOrder_Doc]
	@ProcessID		Int = 160, -- Buy Order Process ID
	@ProcessNo		Int = 1, 
	@FiscalYear		Int = Null,
	@SerialNo		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null
WITH ENCRYPTION
AS 
DECLARE @LanguageID TinyInt;
Begin --============== S T A R T  C O D E ===================================================

	SET @LanguageID = pub.funGetCurrentLanguageID();

	Set NoCount On;
	DECLARE @db_0000				NVarchar(50)

	DECLARE @StrSelect	NVarChar(4000);
	DECLARE @StrWhere	NVarChar(4000);

	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	SET @db_0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'

	SET @StrWhere = 'H.ProcessID = ' + LTrim(RTrim(Str(@ProcessID))) + ' AND H.ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo)))

	-- Where ----------------------------------------
	IF (@FiscalYear Is Not Null)
		SET @StrWhere = @StrWhere + ' AND ((H.FiscalYear >' + LTrim(Str(@FiscalYear)) + ') OR (H.FiscalYear = ' + LTrim(Str(@FiscalYear)) + ' AND H.SerialNo >= ' + LTrim(Str(@SerialNo)) + ')) '
	IF (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND ((H.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ') OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND H.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '		
	

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart
	
	--=======================
	CREATE TABLE #tbl_Session1
	(
		SerialNo	Int,
		UserID		Int
	);
	select * into #tbl_Session2 from #tbl_Session1
	select * into #tbl_Session3 from #tbl_Session1
	select * into #tbl_Session4 from #tbl_Session1
	select * into #tbl_Session5 from #tbl_Session1
	select * into #tbl_Session6 from #tbl_Session1
	select * into #tbl_Session7 from #tbl_Session1
	select * into #tbl_Session8 from #tbl_Session1
	SET @StrSelect = '
	INSERT INTO #tbl_Session1(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SessionNo)
	FROM cmr.tblOrderHdr H 
	Where ' + @StrWhere
	EXEC sp_executesql @StrSelect;
	--=======================
	SET @StrSelect = '
	INSERT INTO #tbl_Session2(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SessionNo2)
	FROM cmr.tblOrderHdr H 
	Where ' + @StrWhere
	EXEC sp_executesql @StrSelect;
	--=======================
	SET @StrSelect = '
	INSERT INTO #tbl_Session3(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SessionNo3)
	FROM cmr.tblOrderHdr H 
	Where ' + @StrWhere
	EXEC sp_executesql @StrSelect;
	--=======================
	SET @StrSelect = '
	INSERT INTO #tbl_Session4(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SgnSN1)
	FROM cmr.tblOrderHdr H 
	Where ' + @StrWhere
	EXEC sp_executesql @StrSelect;
	--=======================
	SET @StrSelect = '
	INSERT INTO #tbl_Session5(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SgnSN2)
	FROM cmr.tblOrderHdr H 
	Where ' + @StrWhere
	EXEC sp_executesql @StrSelect;
	--=======================
	SET @StrSelect = '
	INSERT INTO #tbl_Session6(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SgnSN3)
	FROM cmr.tblOrderHdr H 
	Where ' + @StrWhere
	EXEC sp_executesql @StrSelect;
	--=======================
	SET @StrSelect = '
	INSERT INTO #tbl_Session7(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SgnSN4)
	FROM cmr.tblOrderHdr H 
	Where ' + @StrWhere
	EXEC sp_executesql @StrSelect;
	--=======================
	SET @StrSelect = '
	INSERT INTO #tbl_Session8(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SgnSN5)
	FROM cmr.tblOrderHdr H 
	Where ' + @StrWhere
	EXEC sp_executesql @StrSelect;	

	--=======================
	CREATE TABLE #tbl_Signatures
	(
		UserID   Int,
		UserSign Image
	);

	SET @StrSelect = '
	INSERT INTO #tbl_Signatures(UserID, UserSign)
	SELECT UserID, UserSignature
	FROM ' + LTrim(RTrim(@db_0000)) + '.usr.tblUsers U '
		
	--PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	-- I N I T ----------------------------------------------------------------
	If (@ProcessNo  Is Null)	SET @ProcessNo  = 1;
	If (@LanguageID Is Null)	SET @LanguageID = 1
	If (@FiscalYearTo Is Null)	SET @FiscalYearTo = @FiscalYear;
	If (@SerialNoTo Is Null)	SET @SerialNoTo = @SerialNo;

	-- S E L E C T ------------------------------------------------------------
	SELECT	D.*, H.DocDesc, H.AgreeNo As HdrAgreeNo, [pub].[funGetGoodsName](D.GoodsID,@LanguageID) GoodsName, 
			IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '') BarCode, U.UnitName, 
			pub.GetCodeName(D.AcntCode, @LanguageID) AcntName,
			pub.GetUserName(H.SessionNo) AS UserName,
			inv.funSubUnit2(D.GoodsID) UnitScale,
			inv.funSubUnit2Name(D.GoodsID) UnitNameX,
			GH.TechnicalNo, GH.TechnicalSpecifications, GH.MiscSpecifications,
		    S1.UserSign As UserSignature1,
		    S2.UserSign As UserSignature2,
		    S3.UserSign As UserSignature3,
		    S4.UserSign As Signature1,
		    S5.UserSign As Signature2,
		    S6.UserSign As Signature3,
		    S7.UserSign As Signature4,
		    S8.UserSign As Signature5,
			ISNULL(C.DescDtl,'') CmrDescDtl ,ISNULL(C.DescDtl2,'') CmrDescDtl2,
			inv.funGetLastBuyGoodsPrice(D.GoodsID,'',D.DocDate,0,1) AS LastBuyPrice
	FROM    cmr.tblOrderDtl AS D 
	INNER JOIN cmr.tblOrderHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
	LEFT  JOIN cmr.tblCMRDtl C ON C.ProcessID = D.BaseProcessID AND C.ProcessNo = D.BaseProcessNo AND C.FiscalYear = D.BaseFiscalYear AND C.SerialNo = D.BaseSerialNo  AND C.DocRowNo = D.BaseDocRowNo AND C.GoodsID = D.GoodsID
	LEFT  JOIN inv.tblGoods GH ON GH.GoodsID = SUBSTRING(D.GoodsID,@str_Goods+1, @str_GoodsSum) AND GH.PartNumber= @UnitPart
	LEFT  JOIN inv.tblGoodsDtl G ON G.GoodsID = SUBSTRING(D.GoodsID,@str_Goods+1, @str_GoodsSum) AND G.PartNumber= @UnitPart AND G.LanguageID = @LanguageID
	LEFT  JOIN inv.tblUnitsDtl U ON U.UnitID = D.SubUnitID AND U.LanguageID = @LanguageID
	LEFT  JOIN #tbl_Signatures S1 on S1.UserID = ISNULL((SELECT top 1 UserID FROM #tbl_Session1 Where SerialNo = H.SerialNo),-1)
	LEFT  JOIN #tbl_Signatures S2 on S2.UserID = ISNULL((SELECT top 1 UserID FROM #tbl_Session2 Where SerialNo = H.SerialNo),-1)
	LEFT  JOIN #tbl_Signatures S3 on S3.UserID = ISNULL((SELECT top 1 UserID FROM #tbl_Session3 Where SerialNo = H.SerialNo),-1)
	LEFT  JOIN #tbl_Signatures S4 on S4.UserID = ISNULL((SELECT top 1 UserID FROM #tbl_Session4 Where SerialNo = H.SerialNo),-1)
	LEFT  JOIN #tbl_Signatures S5 on S5.UserID = ISNULL((SELECT top 1 UserID FROM #tbl_Session5 Where SerialNo = H.SerialNo),-1)
	LEFT  JOIN #tbl_Signatures S6 on S6.UserID = ISNULL((SELECT top 1 UserID FROM #tbl_Session6 Where SerialNo = H.SerialNo),-1)
	LEFT  JOIN #tbl_Signatures S7 on S7.UserID = ISNULL((SELECT top 1 UserID FROM #tbl_Session7 Where SerialNo = H.SerialNo),-1)
	LEFT  JOIN #tbl_Signatures S8 on S8.UserID = ISNULL((SELECT top 1 UserID FROM #tbl_Session8 Where SerialNo = H.SerialNo),-1)
	WHERE   H.ProcessID  = @ProcessID  AND H.ProcessNo = @ProcessNo AND
			H.FiscalYear >= @FiscalYear AND H.SerialNo >= @SerialNo AND
			H.FiscalYear <= @FiscalYearTo AND H.SerialNo <= @SerialNoTo
End
GO
