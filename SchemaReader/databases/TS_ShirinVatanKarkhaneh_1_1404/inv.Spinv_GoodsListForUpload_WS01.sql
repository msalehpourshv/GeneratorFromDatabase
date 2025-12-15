USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Reza NP
-- Create date   : 1392/09/13
-- Viewed By	 : 
-- Last Modified : 1403/11/08
-- Description   : 
-- =============================================

Create PROCEDURE  [inv].[Spinv_GoodsListForUpload_WS01] 
	
	@UserID as int=0,
	@StoreID as varchar(20)='',
	@UserAcntCode as varchar(20)='',
	@IsSayman as bit='False'
	
WITH ENCRYPTION
AS

BEGIN
	DECLARE @OnlyExistGoodsInTablet BIT = 'False'
	SELECT @OnlyExistGoodsInTablet = SettingValue from pub.tblSettings where SettingKey = 'OnlyExistGoodsInTablet'

	declare @Layer1Len int =0
	declare @Layer2Len int =0
	declare @Layer3Len int =0
	declare @Layer4Len int =0
	declare @Layer5Len int =0
	declare @Layer6Len int =0
	declare @Layer7Len int =0
	declare @Layer8Len int =0
	declare @Layer9Len int =0

	SELECT 
	@Layer1Len = Layer1,	
	@Layer2Len = Layer1+ Layer2,	
	@Layer3Len = Layer1+ Layer2+ Layer3,	
	@Layer4Len = Layer1+ Layer2+ Layer3+ Layer4,	
	@Layer5Len = Layer1+ Layer2+ Layer3+ Layer4+ Layer5,	
	@Layer6Len = Layer1+ Layer2+ Layer3+ Layer4+ Layer5+ Layer6,	
	@Layer7Len = Layer1+ Layer2+ Layer3+ Layer4+ Layer5+ Layer6+ Layer7,	
	@Layer8Len = Layer1+ Layer2+ Layer3+ Layer4+ Layer5+ Layer6+ Layer7+ Layer8,	
	@Layer9Len = Layer1+ Layer2+ Layer3+ Layer4+ Layer5+ Layer6+ Layer7+ Layer8+ Layer9 	
	from pub.tblCodeLayer WHERE TableName='inv.tblGoods' AND PartNumber=1

 if @IsSayman='False'
 	begin
		SELECT * INTO #G_WS01 FROM 
			(SELECT  distinct G.GoodsID,G.UnitID,G.GoodsPrice,D.GoodsName,
				G.SaleTypeID,isnull(ST.DaysNo,0)DaysNo,
				ISNULL((SELECT SUM(GoodsQuantity*EnterKind)  Quantity 
						FROM inv.tblStorageDocsDtl SD 
						WHERE SD.GoodsID=D.GoodsID AND( @StoreID='' OR StoreID=@StoreID)),0) Quantity,
				 ISNULL(S.SubUnitID,0) UnitID2,G.HasSerial,G.HasExpireDate,G.HasBatchNo,G.HasContainer,G.HasProductionDate,
				 0 GoodsPrice1, 
				 0 GoodsPrice2, 
				 --[sal].[funGetGoodsPriceInCustomerKind](G.GoodsID,G.UnitID) GoodsPrice1, 
				 --[sal].[funGetGoodsPriceInCustomerKind](G.GoodsID,S.SubUnitID) GoodsPrice2, 
				 ISNULL(S.MainUnitValue,1) UnitValue1,ISNULL(S.UnitValue,1) UnitValue2 ,BarCode,
				 SalePrice,BuyPrice,NotShowInTablet,UserPrice,ActiveUserPrice,G.ContainTax
			FROM inv.tblGoods G 
			INNER JOIN inv.tblGoodsDtl D 
			ON D.GoodsID = G.GoodsID   and LanguageID = 1
			LEFT JOIN  (select * from inv.tblSubUnitsDtl where ShowInInvoice=1) S 
			ON G.GoodsID=S.GoodsID 
			LEFT JOIN sal.tblSaleTypes ST 
			ON G.SaleTypeID=ST.SaleTypeID
		
			WHERE  NotShowInTablet='False' AND  D.LanguageID = 1  and (S.ShowInInvoice=1 or S.ShowInInvoice is null) AND G.CodeClosed=0 AND
		 
		 
			 ( -- حیطه
					(Select COUNT(*) from inv.tblGoodsRng
						where  UserID=@UserID AND AllowCodeView=1 AND 
							  LEFT(G.GoodsID,LEN(inv.tblGoodsRng.ToCode))>=LEFT(inv.tblGoodsRng.FromCode,LEN(G.GoodsID))
						  and LEFT(G.GoodsID,LEN(inv.tblGoodsRng.ToCode))<=LEFT(inv.tblGoodsRng.ToCode,LEN(G.GoodsID)))>0  
						  and G.CodeClosed=0 
					OR 
						(Select COUNT(*) from inv.tblGoodsRng
						where UserID=@UserID and AccessAllCode=1)>0
			 )
			 OR 
			LEFT(G.GoodsID,LEN(G.GoodsID)) in (select LEFT(g.GoodsID,LEN(G.GoodsID))
						  FROM inv.tblVisitorCoddingRangDtl a 
						  INNER JOIN inv.tblGoodsGroupsGoodsListDtl g 
						  ON a.GoodsGroupID=g.GoodsGroupID 
						  WHERE a.VisitorID = @UserAcntCode AND 
						  FromGoodsID = '' AND ToGoodsID = ''
						  and G.CodeClosed=0)	  
		  
			 OR
		 
			 ( 
				(Select COUNT(*) from inv.tblVisitorCoddingRangDtl
				where VisitorID = @UserAcntCode AND LEFT(G.GoodsID,LEN(G.GoodsID))>=LEFT(inv.tblVisitorCoddingRangDtl.FromGoodsID,LEN(G.GoodsID))
				and LEFT(G.GoodsID,LEN(G.GoodsID))<=LEFT(inv.tblVisitorCoddingRangDtl.ToGoodsID,LEN(G.GoodsID)))>0
				and G.CodeClosed=0 
			 
			 )) a
		 WHERE Quantity >0 OR @OnlyExistGoodsInTablet = 'False'

	IF @Layer2Len>0 AND @Layer1Len<>@Layer2Len
		insert into #G_WS01
		SELECT DISTINCT SUBSTRING(G.GoodsID,1,@Layer1Len) ,'' UnitID, 0 GoodsPrice,D.GoodsName,
			 '' SaleTypeID, 0 DaysNo,0 Quantity,'' UnitID2,'False' HasSerial,'False' HasExpireDate, 'False' HasBatchNo,'False' HasContainer,G.HasProductionDate,
			 0 GoodsPrice1,0 GoodsPrice2,0 UnitValue1,0 UnitValue2 ,'' BarCode,
			  0 SalePrice,0 BuyPrice,'True' NotShowInTablet,0 UserPrice,0 ActiveUserPrice,'False' ContainTax
		FROM #G_WS01 G
		INNER JOIN inv.tblGoodsDtl D 
		ON D.GoodsID = SUBSTRING(G.GoodsID,1,@Layer1Len)   and LanguageID = 1 AND LEN(D.GoodsID) =@Layer1Len

	IF @Layer3Len>0 AND @Layer2Len<>@Layer3Len
		insert into #G_WS01
		SELECT DISTINCT SUBSTRING(G.GoodsID,1,@Layer2Len) ,'' UnitID, 0 GoodsPrice,D.GoodsName,
			 '' SaleTypeID, 0 DaysNo,0 Quantity,'' UnitID2,'False' HasSerial,'False' HasExpireDate, 'False' HasBatchNo,'False' HasContainer,G.HasProductionDate,
			 0 GoodsPrice1,0 GoodsPrice2,0 UnitValue1,0 UnitValue2 ,'' BarCode,
			  0 SalePrice,0 BuyPrice,'True' NotShowInTablet,0 UserPrice,0 ActiveUserPrice,'False' ContainTax
		FROM #G_WS01 G
		INNER JOIN inv.tblGoodsDtl D 
		ON D.GoodsID = SUBSTRING(G.GoodsID,1,@Layer2Len)   and LanguageID = 1 AND LEN(D.GoodsID) =@Layer2Len

	IF @Layer4Len>0 AND @Layer3Len<>@Layer4Len
		insert into #G_WS01
		SELECT DISTINCT SUBSTRING(G.GoodsID,1,@Layer3Len) ,'' UnitID, 0 GoodsPrice,D.GoodsName,
			 '' SaleTypeID, 0 DaysNo,0 Quantity,'' UnitID2,'False' HasSerial,'False' HasExpireDate, 'False' HasBatchNo,'False' HasContainer,G.HasProductionDate,
			 0 GoodsPrice1,0 GoodsPrice2,0 UnitValue1,0 UnitValue2 ,'' BarCode,
			  0 SalePrice,0 BuyPrice,'True' NotShowInTablet,0 UserPrice,0 ActiveUserPrice,'False' ContainTax
		FROM #G_WS01 G
		INNER JOIN inv.tblGoodsDtl D 
		ON D.GoodsID = SUBSTRING(G.GoodsID,1,@Layer3Len)   and LanguageID = 1 AND LEN(D.GoodsID) =@Layer3Len

	IF @Layer5Len>0 AND @Layer4Len<>@Layer5Len
		insert into #G_WS01
		SELECT DISTINCT SUBSTRING(G.GoodsID,1,@Layer4Len) ,'' UnitID, 0 GoodsPrice,D.GoodsName,
			 '' SaleTypeID, 0 DaysNo,0 Quantity,'' UnitID2,'False' HasSerial,'False' HasExpireDate, 'False' HasBatchNo,'False' HasContainer,G.HasProductionDate,
			 0 GoodsPrice1,0 GoodsPrice2,0 UnitValue1,0 UnitValue2 ,'' BarCode,
			  0 SalePrice,0 BuyPrice,'True' NotShowInTablet,0 UserPrice,0 ActiveUserPrice,'False' ContainTax
		FROM #G_WS01 G
		INNER JOIN inv.tblGoodsDtl D 
		ON D.GoodsID = SUBSTRING(G.GoodsID,1,@Layer4Len)   and LanguageID = 1 AND LEN(D.GoodsID) =@Layer4Len
		
	IF @Layer6Len>0 AND @Layer5Len<>@Layer6Len
		insert into #G_WS01
		SELECT DISTINCT SUBSTRING(G.GoodsID,1,@Layer5Len) ,'' UnitID, 0 GoodsPrice,D.GoodsName,
			 '' SaleTypeID, 0 DaysNo,0 Quantity,'' UnitID2,'False' HasSerial,'False' HasExpireDate, 'False' HasBatchNo,'False' HasContainer,G.HasProductionDate,
			 0 GoodsPrice1,0 GoodsPrice2,0 UnitValue1,0 UnitValue2 ,'' BarCode,
			  0 SalePrice,0 BuyPrice,'True' NotShowInTablet,0 UserPrice,0 ActiveUserPrice,'False' ContainTax
		FROM #G_WS01 G
		INNER JOIN inv.tblGoodsDtl D 
		ON D.GoodsID = SUBSTRING(G.GoodsID,1,@Layer5Len)   and LanguageID = 1 AND LEN(D.GoodsID) =@Layer5Len
	
	IF @Layer7Len>0 AND @Layer6Len<>@Layer7Len
		insert into #G_WS01
		SELECT DISTINCT SUBSTRING(G.GoodsID,1,@Layer6Len) ,'' UnitID, 0 GoodsPrice,D.GoodsName,
			 '' SaleTypeID, 0 DaysNo,0 Quantity,'' UnitID2,'False' HasSerial,'False' HasExpireDate, 'False' HasBatchNo,'False' HasContainer,G.HasProductionDate,
			 0 GoodsPrice1,0 GoodsPrice2,0 UnitValue1,0 UnitValue2 ,'' BarCode,
			  0 SalePrice,0 BuyPrice,'True' NotShowInTablet,0 UserPrice,0 ActiveUserPrice,'False' ContainTax
		FROM #G_WS01 G
		INNER JOIN inv.tblGoodsDtl D 
		ON D.GoodsID = SUBSTRING(G.GoodsID,1,@Layer6Len)   and LanguageID = 1 AND LEN(D.GoodsID) =@Layer6Len
	
	IF @Layer8Len>0 AND @Layer7Len<>@Layer8Len
		insert into #G_WS01
		SELECT DISTINCT SUBSTRING(G.GoodsID,1,@Layer7Len) ,'' UnitID, 0 GoodsPrice,D.GoodsName,
			 '' SaleTypeID, 0 DaysNo,0 Quantity,'' UnitID2,'False' HasSerial,'False' HasExpireDate, 'False' HasBatchNo,'False' HasContainer,G.HasProductionDate,
			 0 GoodsPrice1,0 GoodsPrice2,0 UnitValue1,0 UnitValue2 ,'' BarCode,
			  0 SalePrice,0 BuyPrice,'True' NotShowInTablet,0 UserPrice,0 ActiveUserPrice,'False' ContainTax
		FROM #G_WS01 G
		INNER JOIN inv.tblGoodsDtl D 
		ON D.GoodsID = SUBSTRING(G.GoodsID,1,@Layer7Len)   and LanguageID = 1 AND LEN(D.GoodsID) =@Layer7Len

	IF @Layer9Len>0 AND @Layer8Len<>@Layer9Len
		insert into #G_WS01
		SELECT DISTINCT SUBSTRING(G.GoodsID,1,@Layer8Len) ,'' UnitID, 0 GoodsPrice,D.GoodsName,
			 '' SaleTypeID, 0 DaysNo,0 Quantity,'' UnitID2,'False' HasSerial,'False' HasExpireDate, 'False' HasBatchNo,'False' HasContainer,G.HasProductionDate,
			 0 GoodsPrice1,0 GoodsPrice2,0 UnitValue1,0 UnitValue2 ,'' BarCode,
			  0 SalePrice,0 BuyPrice,'True' NotShowInTablet,0 UserPrice,0 ActiveUserPrice,'False' ContainTax
		FROM #G_WS01 G
		INNER JOIN inv.tblGoodsDtl D 
		ON D.GoodsID = SUBSTRING(G.GoodsID,1,@Layer8Len)   and LanguageID = 1 AND LEN(D.GoodsID) =@Layer8Len

	SELECT * from #G_WS01
	order  by GoodsID
	
	end -- end if
	
 ELSE if @IsSayman='True'
	BEGIN
		SELECT *  INTO #G_WS011 FROM
			(SELECT  distinct G.GoodsID,G.UnitID,G.GoodsPrice,D.GoodsName,
			 G.SaleTypeID,isnull(ST.DaysNo,0)DaysNo,
			 ISNULL((SELECT SUM(GoodsQuantity*EnterKind)  Quantity 
					FROM inv.tblStorageDocsDtl SD 
					WHERE SD.GoodsID=D.GoodsID  AND( @StoreID='' OR StoreID=@StoreID)),0) Quantity,
			 ISNULL(S.SubUnitID,0) UnitID2,G.HasSerial,G.HasExpireDate,G.HasBatchNo,G.HasContainer,G.HasProductionDate,
			 [sal].[funGetGoodsPriceInCustomerKind](G.GoodsID,G.UnitID) GoodsPrice1, 
			 [sal].[funGetGoodsPriceInCustomerKind](G.GoodsID,S.SubUnitID) GoodsPrice2, 
			 ISNULL(S.MainUnitValue,1) UnitValue1,ISNULL(S.UnitValue,1) UnitValue2 ,BarCode,
			  SalePrice,BuyPrice,NotShowInTablet,UserPrice,ActiveUserPrice,G.ContainTax
			FROM inv.tblGoods G 
			INNER JOIN inv.tblGoodsDtl D 
			ON D.GoodsID = G.GoodsID  and LanguageID = 1
			LEFT JOIN inv.tblSubUnitsDtl S 
			ON G.GoodsID=S.GoodsID 
			LEFT JOIN sal.tblSaleTypes ST 
			ON G.SaleTypeID=ST.SaleTypeID
		
		    WHERE  NotShowInTablet='False' AND D.LanguageID = 1  and (S.ShowInInvoice=1 or S.ShowInInvoice is null) AND  G.CodeClosed=0 
		 ) a
		 WHERE Quantity >0 OR @OnlyExistGoodsInTablet = 'False'

	IF @Layer2Len>0 AND @Layer1Len<>@Layer2Len
		insert into #G_WS011
		SELECT DISTINCT SUBSTRING(G.GoodsID,1,@Layer1Len) ,'' UnitID, 0 GoodsPrice,D.GoodsName,
			 '' SaleTypeID, 0 DaysNo,0 Quantity,'' UnitID2,'False' HasSerial,'False' HasExpireDate, 'False' HasBatchNo,'False' HasContainer,G.HasProductionDate,
			 0 GoodsPrice1,0 GoodsPrice2,0 UnitValue1,0 UnitValue2 ,'' BarCode,
			  0 SalePrice,0 BuyPrice,'True' NotShowInTablet,0 UserPrice,0 ActiveUserPrice,'False' ContainTax
		FROM #G_WS011 G
		INNER JOIN inv.tblGoodsDtl D 
		ON D.GoodsID = SUBSTRING(G.GoodsID,1,@Layer1Len)   and LanguageID = 1 AND LEN(D.GoodsID) =@Layer1Len

	IF @Layer3Len>0 AND @Layer2Len<>@Layer3Len
		insert into #G_WS011
		SELECT DISTINCT SUBSTRING(G.GoodsID,1,@Layer2Len) ,'' UnitID, 0 GoodsPrice,D.GoodsName,
			 '' SaleTypeID, 0 DaysNo,0 Quantity,'' UnitID2,'False' HasSerial,'False' HasExpireDate, 'False' HasBatchNo,'False' HasContainer,G.HasProductionDate,
			 0 GoodsPrice1,0 GoodsPrice2,0 UnitValue1,0 UnitValue2 ,'' BarCode,
			  0 SalePrice,0 BuyPrice,'True' NotShowInTablet,0 UserPrice,0 ActiveUserPrice,'False' ContainTax
		FROM #G_WS011 G
		INNER JOIN inv.tblGoodsDtl D 
		ON D.GoodsID = SUBSTRING(G.GoodsID,1,@Layer2Len)   and LanguageID = 1 AND LEN(D.GoodsID) =@Layer2Len

	IF @Layer4Len>0 AND @Layer3Len<>@Layer4Len
		insert into #G_WS011
		SELECT DISTINCT SUBSTRING(G.GoodsID,1,@Layer3Len) ,'' UnitID, 0 GoodsPrice,D.GoodsName,
			 '' SaleTypeID, 0 DaysNo,0 Quantity,'' UnitID2,'False' HasSerial,'False' HasExpireDate, 'False' HasBatchNo,'False' HasContainer,G.HasProductionDate,
			 0 GoodsPrice1,0 GoodsPrice2,0 UnitValue1,0 UnitValue2 ,'' BarCode,
			  0 SalePrice,0 BuyPrice,'True' NotShowInTablet,0 UserPrice,0 ActiveUserPrice,'False' ContainTax
		FROM #G_WS011 G
		INNER JOIN inv.tblGoodsDtl D 
		ON D.GoodsID = SUBSTRING(G.GoodsID,1,@Layer3Len)   and LanguageID = 1 AND LEN(D.GoodsID) =@Layer3Len

	IF @Layer5Len>0 AND @Layer4Len<>@Layer5Len
		insert into #G_WS011
		SELECT DISTINCT SUBSTRING(G.GoodsID,1,@Layer4Len) ,'' UnitID, 0 GoodsPrice,D.GoodsName,
			 '' SaleTypeID, 0 DaysNo,0 Quantity,'' UnitID2,'False' HasSerial,'False' HasExpireDate, 'False' HasBatchNo,'False' HasContainer,G.HasProductionDate,
			 0 GoodsPrice1,0 GoodsPrice2,0 UnitValue1,0 UnitValue2 ,'' BarCode,
			  0 SalePrice,0 BuyPrice,'True' NotShowInTablet,0 UserPrice,0 ActiveUserPrice,'False' ContainTax
		FROM #G_WS011 G
		INNER JOIN inv.tblGoodsDtl D 
		ON D.GoodsID = SUBSTRING(G.GoodsID,1,@Layer4Len)   and LanguageID = 1 AND LEN(D.GoodsID) =@Layer4Len
		
	IF @Layer6Len>0 AND @Layer5Len<>@Layer6Len
		insert into #G_WS011
		SELECT DISTINCT SUBSTRING(G.GoodsID,1,@Layer5Len) ,'' UnitID, 0 GoodsPrice,D.GoodsName,
			 '' SaleTypeID, 0 DaysNo,0 Quantity,'' UnitID2,'False' HasSerial,'False' HasExpireDate, 'False' HasBatchNo,'False' HasContainer,G.HasProductionDate,
			 0 GoodsPrice1,0 GoodsPrice2,0 UnitValue1,0 UnitValue2 ,'' BarCode,
			  0 SalePrice,0 BuyPrice,'True' NotShowInTablet,0 UserPrice,0 ActiveUserPrice,'False' ContainTax
		FROM #G_WS011 G
		INNER JOIN inv.tblGoodsDtl D 
		ON D.GoodsID = SUBSTRING(G.GoodsID,1,@Layer5Len)   and LanguageID = 1 AND LEN(D.GoodsID) =@Layer5Len
	
	IF @Layer7Len>0 AND @Layer6Len<>@Layer7Len
		insert into #G_WS011
		SELECT DISTINCT SUBSTRING(G.GoodsID,1,@Layer6Len) ,'' UnitID, 0 GoodsPrice,D.GoodsName,
			 '' SaleTypeID, 0 DaysNo,0 Quantity,'' UnitID2,'False' HasSerial,'False' HasExpireDate, 'False' HasBatchNo,'False' HasContainer,G.HasProductionDate,
			 0 GoodsPrice1,0 GoodsPrice2,0 UnitValue1,0 UnitValue2 ,'' BarCode,
			  0 SalePrice,0 BuyPrice,'True' NotShowInTablet,0 UserPrice,0 ActiveUserPrice,'False' ContainTax
		FROM #G_WS011 G
		INNER JOIN inv.tblGoodsDtl D 
		ON D.GoodsID = SUBSTRING(G.GoodsID,1,@Layer6Len)   and LanguageID = 1 AND LEN(D.GoodsID) =@Layer6Len
	
	IF @Layer8Len>0 AND @Layer7Len<>@Layer8Len
		insert into #G_WS011
		SELECT DISTINCT SUBSTRING(G.GoodsID,1,@Layer7Len) ,'' UnitID, 0 GoodsPrice,D.GoodsName,
			 '' SaleTypeID, 0 DaysNo,0 Quantity,'' UnitID2,'False' HasSerial,'False' HasExpireDate, 'False' HasBatchNo,'False' HasContainer,G.HasProductionDate,
			 0 GoodsPrice1,0 GoodsPrice2,0 UnitValue1,0 UnitValue2 ,'' BarCode,
			  0 SalePrice,0 BuyPrice,'True' NotShowInTablet,0 UserPrice,0 ActiveUserPrice,'False' ContainTax
		FROM #G_WS011 G
		INNER JOIN inv.tblGoodsDtl D 
		ON D.GoodsID = SUBSTRING(G.GoodsID,1,@Layer7Len)   and LanguageID = 1 AND LEN(D.GoodsID) =@Layer7Len

	IF @Layer9Len>0 AND @Layer8Len<>@Layer9Len
		insert into #G_WS011
		SELECT DISTINCT SUBSTRING(G.GoodsID,1,@Layer8Len) ,'' UnitID, 0 GoodsPrice,D.GoodsName,
			 '' SaleTypeID, 0 DaysNo,0 Quantity,'' UnitID2,'False' HasSerial,'False' HasExpireDate, 'False' HasBatchNo,'False' HasContainer,G.HasProductionDate,
			 0 GoodsPrice1,0 GoodsPrice2,0 UnitValue1,0 UnitValue2 ,'' BarCode,
			  0 SalePrice,0 BuyPrice,'True' NotShowInTablet,0 UserPrice,0 ActiveUserPrice,'False' ContainTax
		FROM #G_WS011 G
		INNER JOIN inv.tblGoodsDtl D 
		ON D.GoodsID = SUBSTRING(G.GoodsID,1,@Layer8Len)   and LanguageID = 1 AND LEN(D.GoodsID) =@Layer8Len

	SELECT * from #G_WS011
	order  by GoodsID

	end -- end if 
	

END
GO
