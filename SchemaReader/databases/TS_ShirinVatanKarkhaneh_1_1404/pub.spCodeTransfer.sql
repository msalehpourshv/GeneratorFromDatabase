USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Javad Bayani
-- Create date: 2008/02/07
-- Description:	Update an Old AcntCode to a New One
-- =============================================
Create PROCEDURE [pub].[spCodeTransfer]
	@TableNameWithSchema VarChar(100),
	@OldCode   VarChar(30),
	@NewCode   VarChar(30),
	@StartIndex TINYINT,
	@ComplateCode TINYINT
	
WITH ENCRYPTION
AS
BEGIN
	Declare @RelatedTable Varchar(50)	, @RelatedField  Varchar(50)
	Declare @strExecute	Varchar(500)
	Declare @StrErrorMessage As Nvarchar(1024)
	Declare @StrExtraUpdateFiledName As Nvarchar(1024)
	Declare @StrExtrafilter As Nvarchar(1024)

	SET NOCOUNT ON;
	
   BEGIN TRY
	
	BEGIN TRAN

	ALTER table inv.tblStorageDocsDtl disable trigger trgStorageDocsDtlUpdate
	-- Search Related Tables That Can be Delete Their Records
	Declare	curTables CURSOR FOR
	Select	RelatedTableNameWithSchema ,RelatedFieldName 
	From	pub.tblTablesRelations
	Where	SourceTableNameWithSchema = @TableNameWithSchema
	Order By RelatedTableNameWithSchema Desc ,RelatedFieldName

	OPEN curTables

	FETCH NEXT FROM curTables INTO @RelatedTable ,@RelatedField 
	WHILE @@FETCH_STATUS = 0
		BEGIN 
			SET @StrExtrafilter = ''
			SET @StrExtraUpdateFiledName = ''
			IF @TableNameWithSchema = 'acc.tblAcnt'
			if @ComplateCode=1
					SET @strExecute	= 'UPDATE ' + @RelatedTable + ' SET ' + @RelatedField + ' = 
					SUBSTRING(' + @RelatedField + ',1,' + LTRIM(STR(@StartIndex - 1)) + ') + ''' + @NewCode + ''' + SUBSTRING(' + @RelatedField + ',' + LTRIM(STR(@StartIndex + LEN(@NewCode) )) + ',30) 
					Where SUBSTRING(' + @RelatedField + ',' + LTRIM(STR(@StartIndex)) + ',' + LTRIM(STR(LEN(@OldCode))) + ') = ''' + @OldCode + ''''
						
			else
			
				SET @strExecute	= 'UPDATE ' + @RelatedTable + ' SET ' + @RelatedField + ' = 
					SUBSTRING(' + @RelatedField + ',1,' + LTRIM(STR(@StartIndex - 1)) + ') + ''' + @NewCode + ''' 
					Where SUBSTRING(' + @RelatedField + ',' + LTRIM(STR(@StartIndex)) + ',' + LTRIM(STR(LEN(@OldCode))) + ') = ''' + @OldCode + ''''
			ELSE
			BEGIN

				IF @TableNameWithSchema = 'inv.tblGoods'
				BEGIN
					DELETE FROM sal.tblGoodsPricesDtl WHERE GoodsID = @OldCode
					DELETE FROM inv.tblGoodsImages WHERE GoodsID = @OldCode
					
					IF( SELECT COUNT(*) FROM prd.tblFormulasHdr WHERE ProductID  = @NewCode)>0
						DELETE FROM prd.tblFormulasHdr WHERE ProductID  = @OldCode
						
					IF( SELECT COUNT(*) FROM prd.tblFormulasOverLoadHdr WHERE ProductID  = @NewCode)>0
						DELETE FROM prd.tblFormulasOverLoadHdr WHERE ProductID = @OldCode
					

					IF @RelatedTable = 'inv.tblSubUnitsHdr'
					BEGIN
						SET @StrExtrafilter = ' AND (select COUNT(*) from inv.tblSubUnitsHdr where GoodsID = ''' + @NewCode + ''' )=0 '
					END

					IF @RelatedTable = 'inv.tblSubUnitsHdr'
					BEGIN
						SET @StrExtrafilter = ' AND (select COUNT(*) from inv.tblSubUnitsHdr where GoodsID = ''' + @NewCode + ''' )=0 '
					END

					IF @RelatedTable = 'inv.tblSubUnitsDtl'
					BEGIN
						SET @StrExtrafilter = ' AND (select COUNT(*) from inv.tblSubUnitsDtl a where GoodsID = ''' + @NewCode + ''' AND inv.tblSubUnitsDtl.SubUnitID=a.SubUnitID AND inv.tblSubUnitsDtl.UnitValue=a.UnitValue AND  inv.tblSubUnitsDtl.MainUnitValue=a.MainUnitValue  )=0 '
						SET @StrExtraUpdateFiledName = ',ShowInInvoice=0,RowNo = RowNo+10 '
					END
				END
				
				IF @TableNameWithSchema = 'inv.tblStores' and @RelatedTable = 'inv.tblGoodsStatusDtl'					
					SET @StrExtrafilter = ' AND (select COUNT(*) from inv.tblGoodsStatusDtl where StoreID = ''' + @NewCode + ''' )=0 '

				SET @strExecute	= 'UPDATE ' + @RelatedTable + ' SET ' + @RelatedField + ' = ''' + 
					@NewCode  +  ''' ' + + @StrExtraUpdateFiledName + ' Where ' + @RelatedField + ' = ''' + @OldCode + '''' + @StrExtrafilter
					
			END
				
			BEGIN TRY
				PRINT @strExecute
				EXECUTE (@strExecute);
			END TRY
			BEGIN CATCH
				Set @StrErrorMessage = ERROR_MESSAGE() 
				raiserrOR(@StrErrorMessage, 16, 1)
			END CATCH

			FETCH NEXT FROM curTables INTO @RelatedTable ,@RelatedField 
		END

	CLOSE curTables
	DEALLOCATE curTables
	COMMIT TRAN
	
	ALTER table inv.tblStorageDocsDtl enable trigger trgStorageDocsDtlUpdate

	END TRY -- ===========
	BEGIN CATCH
			ROLLBACK TRAN
			Set @StrErrorMessage = ERROR_MESSAGE() 
			raiserror (@StrErrorMessage, 16, 1)
			CLOSE curTables  
			DEALLOCATE curTables
	END CATCH
END
GO
