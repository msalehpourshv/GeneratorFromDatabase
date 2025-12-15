USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hamid
-- Create date   : 1393/08/26 - Hamid
-- Viewed By	 : 
-- Last Modified : 1393/08/26 - Hamid
-- Description   : 
-- =============================================
-- EXEC [pub].[ChangeCoding] 'inv.tblGoods','GoodsID'
CREATE PROCEDURE [pub].[ChangeCoding]
	@TableName	 VarChar(100),
	@IDFieldName VarChar(100)
WITH ENCRYPTION
 AS
BEGIN
SET NOCOUNT ON;

DECLARE @StrSelect1	NVarChar(Max);
	
	-- ================================================
	SET @StrSelect1 = '
	
	-- CREATE TABLE pub.tblChangeCoding (OldID VarChar(20), NewID VarChar(20))

	ALTER TABLE inv.tblStorageDocsDtl DISABLE TRIGGER trgStorageDocsDtlUpdate
	ALTER TABLE prd.tblFormulasDtl DISABLE TRIGGER trgCheckLoop
	DECLARE @RelatedTableNameWithSchema VarChar(50)
	DECLARE @RelatedFieldName VarChar(200)
	DECLARE @StrSelect	 NVarChar(max);
	DECLARE @NewGoodsID	 VarChar(20);
	DECLARE @OldGoodsID	 VarChar(20);
	DECLARE @TableName	 VarChar(100);
	DECLARE @IDFieldName VarChar(100);

	BEGIN TRY
		-- ========================================================================
		-- ========================== UPDATE GOODS LIST
		--DECLARE	curGoods CURSOR For 
	
		---- ========================= Select OldID And NewID
		--Select OldID, NewID From pub.tblChangeCoding
		--Where OldID <> NewID
		-- ================================================
			
			
		Update ' + @TableName + '
		Set ' + Case When @TableName = 'inv.tblGoods' Then 'MiscSpecifications = ' + @IDFieldName + ', ' Else '' End + 
		          @IDFieldName + ' = b.NewID
		from ' + @TableName + ' a
		inner join  pub.tblChangeCoding b
		on a.' +@IDFieldName + ' = b.OldID'
		
		--Open curGoods
		--Fetch NEXT From curGoods Into @OldGoodsID, @NewGoodsID
		--While (@@Fetch_Status = 0)
		--BEGIN
		--	if (Select COUNT(*) From ' + @TableName + ' Where ' + @IDFieldName + ' = @NewGoodsID) = 0
		--		Update ' + @TableName + '
		--		Set ' + Case When @TableName = 'inv.tblGoods' Then 'MiscSpecifications = ' + @IDFieldName + ', ' Else '' End + 
		--		          @IDFieldName + ' = @NewGoodsID
		--		Where ' + @IDFieldName + ' = @OldGoodsID 
		--	Else
		--		Delete From ' + @TableName + '
		--		Where ' + @IDFieldName + ' = @OldGoodsID 
			
		--	Fetch NEXT From curGoods Into @OldGoodsID, @NewGoodsID
		--END 

		--Close curGoods
		--Deallocate curGoods
		--PRINT ''Step 1 Done.''
		-- ========================================================================
		-- ========================== UPDATE RELATED TABLES'
	--============================================================================================
	--============================================================================================
	SET @StrSelect1 = @StrSelect1 + ' 
		DECLARE	curTablesRelation CURSOR For 
			SELECT RelatedTableNameWithSchema, RelatedFieldName
			FROM pub.tblTablesRelations
			WHERE SourceTableNameWithSchema = ''' + @TableName + ''' AND SourceFieldName = ''' + @IDFieldName + '''
		Open curTablesRelation;
		Fetch NEXT From curTablesRelation Into @RelatedTableNameWithSchema, @RelatedFieldName

		While (@@Fetch_Status = 0)
		
		BEGIN
			--DECLARE	curGoods CURSOR For 
			
			---- ========================= Select OldID And NewID
			--Select OldID, NewID From pub.tblChangeCoding
			--Where OldID <> NewID
			---- ================================================
			SET @StrSelect = ''
			UPDATE '' + @RelatedTableNameWithSchema + '' 
			SET    '' + @RelatedFieldName + '' = b.NewID
			from '' + @RelatedTableNameWithSchema + '' a inner join
			pub.tblChangeCoding b 
			on b.OldID=a.'' + @RelatedFieldName + ''''
			
				Print @StrSelect;
				Exec sp_executesql @StrSelect;
			
			--Open curGoods
			--Fetch NEXT From curGoods Into @OldGoodsID, @NewGoodsID
			--While (@@Fetch_Status = 0)
			--BEGIN
			--	SET @StrSelect = ''
			--	BEGIN TRY
			--		UPDATE '' + @RelatedTableNameWithSchema + '' 
			--		SET    '' + @RelatedFieldName + '' = '''''' + @NewGoodsID + ''''''
			--		WHERE  '' + @RelatedFieldName + '' = '''''' + @OldGoodsID + ''''''
			--	END TRY
			--	BEGIN CATCH
			--		PRINT ERROR_MESSAGE() 
			--		DELETE FROM '' + @RelatedTableNameWithSchema + '' WHERE ('' + @RelatedFieldName + '' = '''''' + @OldGoodsID + '''''')
			--	END CATCH ''
			--	Print @StrSelect;
			--	Exec sp_executesql @StrSelect;
			--	Fetch NEXT From curGoods Into @OldGoodsID, @NewGoodsID
			--END 
			
			--Close curGoods
			--Deallocate curGoods
			Fetch NEXT From curTablesRelation Into @RelatedTableNameWithSchema,@RelatedFieldName
		END
		Close curTablesRelation;
		Deallocate curTablesRelation; 	
		--Commit Tran
		PRINT ''Step 2 Done.''
	END TRY
	BEGIN CATCH
		-- Rollback Tran
		BEGIN TRY	
			CLOSE curGoods
			DEALLOCATE curGoods
		END TRY
		BEGIN CATCH
		END CATCH
		BEGIN TRY	
			CLOSE curTablesRelation;
			DEALLOCATE curTablesRelation; 	
		END TRY
		BEGIN CATCH
		END CATCH
		SELECT ERROR_MESSAGE() 
	END CATCH
	ALTER TABLE inv.tblStorageDocsDtl ENABLE TRIGGER trgStorageDocsDtlUpdate
	ALTER TABLE prd.tblFormulasDtl ENABLE TRIGGER trgCheckLoop

	-- DROP TABLE pub.tblChangeCoding'	
		
	-- ============================
	PRINT @StrSelect1
	Exec sp_executesql @StrSelect1; 	
	-- ============================
END
GO
