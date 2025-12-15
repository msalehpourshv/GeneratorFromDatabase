USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1403/08/02
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- ----------------------------------------------
-- Description	 : < مشخصات و تنظیمات شعبات  >
-- ==============================================
Create PROCEDURE iw.SpStationInfo
	@StationID		varchar(20)	 ,
	@StationName	nvarchar(200) ,
	@StrWhare		NVarChar(MAX),
	@Skip			int,
	@Take			int
WITH ENCRYPTION
AS
BEGIN	
DECLARE @StrSelect		NVarChar(MAX);

	if isnull(@Take,0)=0
		set @Take=1

	set @StrSelect ='
	select  Count(*)over () TotalCount, H.StationID, isnull(H.BranchTransferStockAcntCode, '''') BranchTransferStockAcntCode, isnull(H.POSStoreID, '''')POSStoreID
	, isnull(H.PosSaleType, '''')PosSaleType, isnull(H.PosAcntCode, '''')PosAcntCode, isnull(H.PosVisitorAcntCode, '''') PosVisitorAcntCode
	, isnull(D.StationName, '''')	StationName, isnull(D.StationDBName, '''')StationDBName	
	from   pub.tblStation H
	inner join  pub.tblStationDtl D on H.StationID=D.StationID and D.LanguageID=1
	where H.CodeClosed=0
	and (isnull('''+@StationID+''' ,'''')='''' or  H.StationID like '''+@StationID+'%'' )
	and (isnull('''+@StationName+''' ,'''')='''' or D.StationName like N''%'+@StationName+'%'' )
	  '
	if isnull(@StrWhare,'')<>''
		set @StrSelect +=' and ' +@StrWhare
	set @StrSelect += ' Order by H.StationID,D.StationName
						OFFSET ' +str(@Skip) +' Rows 
						FETCH NEXT ' +Str(@Take) +' Rows ONLY '
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;


END

GO
