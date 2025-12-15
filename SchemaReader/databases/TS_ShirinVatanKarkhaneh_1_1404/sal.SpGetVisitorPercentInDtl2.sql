USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
CREATE Procedure [sal].[SpGetVisitorPercentInDtl2]
	@AcntCode			Varchar(20),
	@VisitorAcntCode	Varchar(20),
	@DocDate			char(10),
	@GoodsID			varchar(20)

WITH ENCRYPTION
AS
BEGIN

	Declare @GoodsGroupID	VarChar(20);
	Declare @CustomerKindID	VarChar(20);
	Declare @Result			Float;
	Declare @AcntPartNumber tinyint;
	Declare @LayerLen AS tinyint;
	Declare @StartLayerIndex AS tinyint;

	DECLARE @VisitorPursant  Float;

	SET @LayerLen = 0
	SET @StartLayerIndex = 0
	SET @AcntPartNumber = 0
	SET @Result = 0
	SET @VisitorPursant = 0

	SELECT @LayerLen = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'LayerLen'
	
	SELECT @StartLayerIndex = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'StartLayerIndex'
	
	SELECT @AcntPartNumber = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'
	
	SELECT @CustomerKindID = CustomerKindID 
	FROM acc.tblAcnt
	WHERE PartNumber = @AcntPartNumber AND 
		  AcntCode=RTRIM(SUBSTRING(@AcntCode,@StartLayerIndex ,@LayerLen))
		
	SELECT TOP 1 @GoodsGroupID = GoodsGroupID 
	FROM inv.tblGoodsGroupsGoodsListDtl
	WHERE GoodsID = LEFT(@GoodsID,LEN(GoodsID))

	-------------------------------------------------------------------------------------------------------------------
	-----1
		SELECT TOP 1 @VisitorPursant = VisitorPursant
		FROM sal.tblVisitorsCustomersDtl D INNER JOIN sal.tblVisitorsCustomersHdr H 
		ON	 D.VisitorAcntCode = H.VisitorAcntCode 
		WHERE	(FromDate<=@DocDate AND ToDate>=@DocDate) AND D.VisitorAcntCode = SUBSTRING(@VisitorAcntCode,1,LEN(D.VisitorAcntCode)) AND
				LEN(CustomerAcntCode)>0 AND CustomerAcntCode =@AcntCode AND
				CustomerKindID = @CustomerKindID AND 
				GoodsGroupID = @GoodsGroupID  AND 
				LEN(GoodsID) > 0 AND GoodsID = LEFT(@GoodsID,LEN(GoodsID))
		ORDER BY LEN(D.VisitorAcntCode) desc
	-----2
	IF @VisitorPursant = 0 
		SELECT TOP 1 @VisitorPursant = VisitorPursant
		FROM sal.tblVisitorsCustomersDtl D INNER JOIN sal.tblVisitorsCustomersHdr H 
		ON	 D.VisitorAcntCode = H.VisitorAcntCode 
		WHERE	(FromDate<=@DocDate AND ToDate>=@DocDate) AND D.VisitorAcntCode = SUBSTRING(@VisitorAcntCode,1,LEN(D.VisitorAcntCode)) AND
				LEN(CustomerAcntCode)>0 AND CustomerAcntCode =@AcntCode AND
				CustomerKindID = @CustomerKindID AND 
				GoodsGroupID = @GoodsGroupID  AND 
				GoodsID = ''
		ORDER BY LEN(D.VisitorAcntCode) desc

	-----3
	IF @VisitorPursant = 0 
		SELECT TOP 1 @VisitorPursant = VisitorPursant
		FROM sal.tblVisitorsCustomersDtl D INNER JOIN sal.tblVisitorsCustomersHdr H 
		ON	 D.VisitorAcntCode = H.VisitorAcntCode 
		WHERE	(FromDate<=@DocDate AND ToDate>=@DocDate) AND D.VisitorAcntCode = SUBSTRING(@VisitorAcntCode,1,LEN(D.VisitorAcntCode)) AND
				LEN(CustomerAcntCode)>0 AND CustomerAcntCode =@AcntCode AND
				CustomerKindID = @CustomerKindID AND 
				GoodsGroupID = '' AND
				LEN(GoodsID) > 0 AND GoodsID = LEFT(@GoodsID,LEN(GoodsID))
		ORDER BY LEN(D.VisitorAcntCode) desc
				
	-----4
	IF @VisitorPursant = 0 
		SELECT TOP 1 @VisitorPursant = VisitorPursant
		FROM sal.tblVisitorsCustomersDtl D INNER JOIN sal.tblVisitorsCustomersHdr H 
		ON	 D.VisitorAcntCode = H.VisitorAcntCode 
		WHERE	(FromDate<=@DocDate AND ToDate>=@DocDate) AND D.VisitorAcntCode = SUBSTRING(@VisitorAcntCode,1,LEN(D.VisitorAcntCode)) AND
				LEN(CustomerAcntCode)>0 AND CustomerAcntCode =@AcntCode AND
				CustomerKindID = '' AND 
				GoodsGroupID = @GoodsGroupID  AND 
				LEN(GoodsID) > 0 AND GoodsID = LEFT(@GoodsID,LEN(GoodsID))
		ORDER BY LEN(D.VisitorAcntCode) desc
	-----5
	IF @VisitorPursant = 0 
		SELECT TOP 1 @VisitorPursant = VisitorPursant
		FROM sal.tblVisitorsCustomersDtl D INNER JOIN sal.tblVisitorsCustomersHdr H 
		ON	 D.VisitorAcntCode = H.VisitorAcntCode 
		WHERE	(FromDate<=@DocDate AND ToDate>=@DocDate) AND D.VisitorAcntCode = SUBSTRING(@VisitorAcntCode,1,LEN(D.VisitorAcntCode)) AND
				CustomerAcntCode = '' AND 
				CustomerKindID = @CustomerKindID AND 
				GoodsGroupID = @GoodsGroupID  AND 
				LEN(GoodsID) > 0 AND GoodsID = LEFT(@GoodsID,LEN(GoodsID))
		ORDER BY LEN(D.VisitorAcntCode) desc
	-----6
	IF @VisitorPursant = 0 
		SELECT TOP 1 @VisitorPursant = VisitorPursant
		FROM sal.tblVisitorsCustomersDtl D INNER JOIN sal.tblVisitorsCustomersHdr H 
		ON	 D.VisitorAcntCode = H.VisitorAcntCode 
		WHERE	(FromDate<=@DocDate AND ToDate>=@DocDate) AND D.VisitorAcntCode = SUBSTRING(@VisitorAcntCode,1,LEN(D.VisitorAcntCode)) AND
				LEN(CustomerAcntCode)>0 AND CustomerAcntCode =@AcntCode AND
				CustomerKindID = @CustomerKindID AND 
				GoodsGroupID = ''  AND 
				GoodsID = ''
		ORDER BY LEN(D.VisitorAcntCode) desc
	-----7
	IF @VisitorPursant = 0 
		SELECT TOP 1 @VisitorPursant = VisitorPursant
		FROM sal.tblVisitorsCustomersDtl D INNER JOIN sal.tblVisitorsCustomersHdr H 
		ON	 D.VisitorAcntCode = H.VisitorAcntCode 
		WHERE	(FromDate<=@DocDate AND ToDate>=@DocDate) AND D.VisitorAcntCode = SUBSTRING(@VisitorAcntCode,1,LEN(D.VisitorAcntCode)) AND
				LEN(CustomerAcntCode)>0 AND CustomerAcntCode =@AcntCode AND
				CustomerKindID = '' AND 
				GoodsGroupID = @GoodsGroupID  AND
				GoodsID = ''
		ORDER BY LEN(D.VisitorAcntCode) desc
	-----8
	IF @VisitorPursant = 0 
		SELECT TOP 1 @VisitorPursant = VisitorPursant
		FROM sal.tblVisitorsCustomersDtl D INNER JOIN sal.tblVisitorsCustomersHdr H 
		ON	 D.VisitorAcntCode = H.VisitorAcntCode 
		WHERE	(FromDate<=@DocDate AND ToDate>=@DocDate) AND D.VisitorAcntCode = SUBSTRING(@VisitorAcntCode,1,LEN(D.VisitorAcntCode)) AND
				LEN(CustomerAcntCode)>0 AND CustomerAcntCode =@AcntCode AND
				CustomerKindID = '' AND 
				GoodsGroupID = ''  AND
				LEN(GoodsID) > 0 AND GoodsID = LEFT(@GoodsID,LEN(GoodsID))
		ORDER BY LEN(D.VisitorAcntCode) desc

	-----9
	IF @VisitorPursant = 0 
		SELECT TOP 1 @VisitorPursant = VisitorPursant
		FROM sal.tblVisitorsCustomersDtl D INNER JOIN sal.tblVisitorsCustomersHdr H 
		ON	 D.VisitorAcntCode = H.VisitorAcntCode 
		WHERE	(FromDate<=@DocDate AND ToDate>=@DocDate) AND D.VisitorAcntCode = SUBSTRING(@VisitorAcntCode,1,LEN(D.VisitorAcntCode)) AND
				CustomerAcntCode ='' AND
				CustomerKindID = @CustomerKindID AND 
				GoodsGroupID = @GoodsGroupID AND  
				GoodsID = ''
		ORDER BY LEN(D.VisitorAcntCode) desc

	-----10
	IF @VisitorPursant = 0 
		SELECT TOP 1 @VisitorPursant = VisitorPursant
		FROM sal.tblVisitorsCustomersDtl D INNER JOIN sal.tblVisitorsCustomersHdr H 
		ON	 D.VisitorAcntCode = H.VisitorAcntCode 
		WHERE	(FromDate<=@DocDate AND ToDate>=@DocDate) AND D.VisitorAcntCode = SUBSTRING(@VisitorAcntCode,1,LEN(D.VisitorAcntCode)) AND
				CustomerAcntCode ='' AND
				CustomerKindID = @CustomerKindID AND 
				GoodsGroupID = '' AND  
				LEN(GoodsID) > 0 AND GoodsID = LEFT(@GoodsID,LEN(GoodsID))
		ORDER BY LEN(D.VisitorAcntCode) desc

	-----11
	IF @VisitorPursant = 0 
		SELECT TOP 1 @VisitorPursant = VisitorPursant
		FROM sal.tblVisitorsCustomersDtl D INNER JOIN sal.tblVisitorsCustomersHdr H 
		ON	 D.VisitorAcntCode = H.VisitorAcntCode 
		WHERE	(FromDate<=@DocDate AND ToDate>=@DocDate) AND D.VisitorAcntCode = SUBSTRING(@VisitorAcntCode,1,LEN(D.VisitorAcntCode)) AND
				CustomerAcntCode ='' AND
				CustomerKindID = '' AND 
				GoodsGroupID = @GoodsGroupID  AND 
				LEN(GoodsID) > 0 AND GoodsID = LEFT(@GoodsID,LEN(GoodsID))
		ORDER BY LEN(D.VisitorAcntCode) desc

	-----12
	IF @VisitorPursant = 0 
		SELECT TOP 1 @VisitorPursant = VisitorPursant
		FROM sal.tblVisitorsCustomersDtl D INNER JOIN sal.tblVisitorsCustomersHdr H 
		ON	 D.VisitorAcntCode = H.VisitorAcntCode 
		WHERE	(FromDate<=@DocDate AND ToDate>=@DocDate) AND D.VisitorAcntCode = SUBSTRING(@VisitorAcntCode,1,LEN(D.VisitorAcntCode)) AND
				LEN(CustomerAcntCode)>0 AND CustomerAcntCode =@AcntCode AND
				CustomerKindID = '' AND 
				GoodsGroupID = '' AND  
				GoodsID = ''
		ORDER BY LEN(D.VisitorAcntCode) desc

	-----13
	IF @VisitorPursant = 0 
		SELECT TOP 1 @VisitorPursant = VisitorPursant
		FROM sal.tblVisitorsCustomersDtl D INNER JOIN sal.tblVisitorsCustomersHdr H 
		ON	 D.VisitorAcntCode = H.VisitorAcntCode 
		WHERE	(FromDate<=@DocDate AND ToDate>=@DocDate) AND D.VisitorAcntCode = SUBSTRING(@VisitorAcntCode,1,LEN(D.VisitorAcntCode)) AND
				CustomerAcntCode ='' AND
				CustomerKindID = @CustomerKindID  AND 
				GoodsGroupID = '' AND  
				GoodsID = ''
		ORDER BY LEN(D.VisitorAcntCode) desc

	-----14
	IF @VisitorPursant = 0 
		SELECT TOP 1 @VisitorPursant = VisitorPursant
		FROM sal.tblVisitorsCustomersDtl D INNER JOIN sal.tblVisitorsCustomersHdr H 
		ON	 D.VisitorAcntCode = H.VisitorAcntCode 
		WHERE	(FromDate<=@DocDate AND ToDate>=@DocDate) AND D.VisitorAcntCode = SUBSTRING(@VisitorAcntCode,1,LEN(D.VisitorAcntCode)) AND
				CustomerAcntCode ='' AND
				CustomerKindID = ''  AND 
				GoodsGroupID = @GoodsGroupID  AND
				GoodsID = ''
		ORDER BY LEN(D.VisitorAcntCode) desc
	-----15
	IF @VisitorPursant = 0 
		SELECT TOP 1 @VisitorPursant = VisitorPursant
		FROM sal.tblVisitorsCustomersDtl D INNER JOIN sal.tblVisitorsCustomersHdr H 
		ON	 D.VisitorAcntCode = H.VisitorAcntCode 
		WHERE	(FromDate<=@DocDate AND ToDate>=@DocDate) AND D.VisitorAcntCode = SUBSTRING(@VisitorAcntCode,1,LEN(D.VisitorAcntCode)) AND
				CustomerAcntCode ='' AND
				CustomerKindID = ''  AND 
				GoodsGroupID = '' AND 
				LEN(GoodsID) > 0 AND GoodsID = LEFT(@GoodsID,LEN(GoodsID))
		ORDER BY LEN(D.VisitorAcntCode) desc
	-----16
	IF @VisitorPursant = 0 
		SELECT TOP 1 @VisitorPursant = VisitorPursant
		FROM sal.tblVisitorsCustomersDtl D INNER JOIN sal.tblVisitorsCustomersHdr H 
		ON	 D.VisitorAcntCode = H.VisitorAcntCode 
		WHERE	(FromDate<=@DocDate AND ToDate>=@DocDate) AND D.VisitorAcntCode = SUBSTRING(@VisitorAcntCode,1,LEN(D.VisitorAcntCode)) AND
				CustomerAcntCode ='' AND
				CustomerKindID = ''  AND 
				GoodsGroupID = ''  AND
				GoodsID = ''
		ORDER BY LEN(D.VisitorAcntCode) desc

	SELECT @VisitorPursant VisitorPercent
END
GO
