USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [ast].[spFrmAssetPlaqueRecoed]
	@ProcessID	  Smallint ,
	@ProcessNo	  tinyint ,
	@FiscalYear	  smallint ,
	@SerialNo	  int ,
	@AssetPlaque  Varchar(20) ,
	@LanguageID   tinyint 

	WITH ENCRYPTION
AS
BEGIN
	
	DECLARE @StrSelect		NVarChar(Max);
	
	Select @StrSelect ='SELECT TOP 1 	
	 ProcessID	,ProcessNo	,FiscalYear	,SerialNo	,RowNo	,DocDate	,AstGroupID	,LocateID	,GoodsID	,AssetPlaque	,AssetTitle	,AssetManagerID	,ResponsibleID	,AssetAcntCode	
	 ,case when '+ str(@ProcessID) +'=505 then isnull(( select top 1 ObverseAcntCode From ast.tblAssetsDtl Where AssetPlaque = '''+@AssetPlaque+ ''' AND ProcessID=500 order by DocDate Desc), ObverseAcntCode) else  ObverseAcntCode	end ObverseAcntCode	
	 ,PurchaseDate	,PurchaseAmount	,SetupAmount	,OtherCosts	,UseDate	,DepreciationAcntCode	,OldValue	,TopRegisteredValue	,CostAmount	,DocRowNo	,BaseProcessID	
	 ,BaseProcessNo	,BaseFiscalYear	,BaseSerialNo	,BaseDocRowNo	,DepreciationMethod	,DepreciationRate	,DepreciationAmount	,RegisteredValue	,RenovationTypeID	,ChangeAmount	,ReturnDate	
	 ,AssetState	,EventNo	,CostAcntCode	,SourceSerialNo	,SourceProcessNo	,SetupAmountAcntCode	,OtherCostsAcntCode	,DepreciationValue	,CostInSale	,DescDtl	,DepreciationCost	
	 ,DepreciationCostAcntCode	,AssetAcntCode2	,EnterKind	,ast.funGetAssetManagerName(AssetManagerID,'+ str(@LanguageID) +' ) AS AssetManagerName,ast.funGetAstGroupName(AstGroupID,'+ str(@LanguageID) +' ) AS AstGroupName
	 ,prs.funGetPersonnelName(ResponsibleID,'+ str(@LanguageID) +' ) AS ResponsibleName,ast.funGetLocateName(LocateID,'+ str(@LanguageID) +' ) AS LocateName 
	From ast.tblAssetsDtl
	Where AssetPlaque = '''+@AssetPlaque+ ''' AND
		NOT(ProcessID='+ str(@ProcessID) +'  And ProcessNo='+ str(@ProcessNo) +' AND FiscalYear='+ str(@FiscalYear ) +'  AND SerialNo='+ str(@SerialNo ) +' )
	ORDER BY EventNo Desc '
	
	print   @StrSelect;             
	EXEC sp_executesql @StrSelect;

END
GO
