USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Taha Esmaeili
-- Creation Date : 1400/11/10
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
Create PROCEDURE trn.RptTransportationOffer
	@ProcessID			Int = 0,
	@ProcessNo	    	Int = 0,
	@FiscalYearFr		Int = 0,
	@SerialNoFr	    	Int = 0,
    @FiscalYearTo	    Int = 0,	
	@SerialNoTo			Int = 0,
    @RepOptions			VarChar(10) = '', 
	@RepInfo			NVarChar(100) = '',
	@ExtraParams	    NVarChar(400) = ''

WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect			NVarChar(max);
Declare @StrWhere			NVarChar(2048);
Declare @PrpLanguageID      varchar(3);

Begin --============== S T A R T  C O D E ===================================================
    set @PrpLanguageID= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	set @StrWhere=''
	-- Acnt Filter 
	IF (@SerialNoFr <>0)
		SET @StrWhere = @StrWhere + ' AND (H.SerialNo >=' + LTrim(Str(@SerialNoFr)) + ')'	
	IF (@SerialNoTo  <>0)
		SET @StrWhere = @StrWhere + ' AND (H.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')'		
	
 	
	Set @StrSelect = '
		SELECT H.*,pub.funGetLocationName(H.SourceLocationID,' + @PrpLanguageID +') SourceLocationName, pub.funGetLocationName(H.DestinationLocationID,' + @PrpLanguageID +') DestinationLocationName,isnull(G.GoodsName,'''') as GoodsName, isnull(D.FirstName,'''') + '' '' + isnull(D.LastName,'''')   as DriverName
                FROM trn.tblTransportationOfferHdr H 
				left join inv.tblGoodsDtl G on G.GoodsID=H.GoodsID
				left join pub.tblDriversDtl D on D.DriverID=H.DriverID
                WHERE H.ProcessID =' +  LTrim(Str(@ProcessID))  + @StrWhere +' ORDER BY H.SerialNo'
         


               
	-- RUN -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	
End
GO
