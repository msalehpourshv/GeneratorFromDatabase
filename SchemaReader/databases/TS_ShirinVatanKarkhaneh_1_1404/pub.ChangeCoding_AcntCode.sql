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
-- EXEC [pub].[ChangeCoding_AcntCode] 'acc.tblAcnt', 'AcntCode', 2
Create PROCEDURE [pub].[ChangeCoding_AcntCode]
	@TableName	 VarChar(100) = 'acc.tblAcnt',
	@IDFieldName VarChar(100) = 'AcntCode',
	@PartNumber	 Int = 1
WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON;

DECLARE @StrSelect	NVarChar(Max);
DECLARE @StrSelect1	NVarChar(Max);
DECLARE @StrSelect2	NVarChar(Max);
	
	-- ================================================
	SET @StrSelect1 = '
	
	-- CREATE TABLE pub.tblChangeCoding_AcntCode (OldID VarChar(20), NewID VarChar(20))

	ALTER TABLE inv.tblStorageDocsDtl DISABLE TRIGGER trgStorageDocsDtlUpdate

	DECLARE @SourceTableNameWithSchema Varchar(50)
	DECLARE @SourceFieldName Varchar(200)

	DECLARE @RelatedTableNameWithSchema varchar(50)
	DECLARE @RelatedFieldNamee varchar(200)
	DECLARE @StrSelect	NVarChar(4000);
	DECLARE @OldID	NVarChar(4000);
	DECLARE @NewID	NVarChar(4000);

	DECLARE @PartNo	TinyInt;
	DECLARE @PartNumber	TinyInt;
	DECLARE @PartNoLen1	TinyInt;
	DECLARE @PrePartsLen TinyInt;
	DECLARE @StartLen	TinyInt;

	SET @SourceTableNameWithSchema = ''' + @TableName + '''
	SET @SourceFieldName = ''' + @IDFieldName + '''
	SET @PartNumber = ' + LTrim(RTrim(Str(@PartNumber))) + '
	SET @StartLen = 1
	SET @PrePartsLen = 0

	-- ================= Select PartNumber
	Select @PartNoLen1 = Layer1 + Layer2 + Layer3 + Layer4 + Layer5+ Layer6 + Layer7 + Layer8 + Layer9
	From pub.tblCodeLayer
	Where TableName = @SourceTableNameWithSchema And PartNumber = @PartNumber

	SET @StrSelect = ''UPDATE '' + @SourceTableNameWithSchema +
				     '' SET '' + @SourceFieldName + '' = b.NewID 
				        FROM  '' + @SourceTableNameWithSchema + '' a INNER JOIN  pub.tblChangeCoding_AcntCode b ON a.PartNumber = '' + LTrim(RTrim(Str(@PartNumber))) + '' And a.'' + @SourceFieldName + '' = b.OldID ''
			 
						 
	Print @StrSelect;
	Exec sp_executesql @StrSelect;

	PRINT ''Step 1 Done.''
	-- ========================================================================
	-- ========================== UPDATE RELATED TABLES'
	Print @StrSelect1
	--============================================================================================
	--============================================================================================
	SET @StrSelect2 = ' 
	Declare	curTablesRelation CURSOR For 
	SELECT	RelatedTableNameWithSchema,RelatedFieldName,PartNo
	FROM pub.tblTablesRelations
	WHERE SourceTableNameWithSchema = @SourceTableNameWithSchema AND
		  SourceFieldName = @SourceFieldName AND (PartNo=0 OR PartNo=' + LTrim(RTrim(Str(@PartNumber))) + ')

	Open curTablesRelation;
		
	Fetch NEXT From curTablesRelation Into @RelatedTableNameWithSchema,@RelatedFieldNamee,@PartNo

		While (@@Fetch_Status = 0)
		BEGIN
		
			---- ================= Select StartLen
			Select @PrePartsLen = Sum(Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9) + @PartNumber - 1
			From pub.tblCodeLayer
			Where TableName = @SourceTableNameWithSchema And PartNumber < @PartNumber		
			
			If @PrePartsLen Is Null
				Set @PrePartsLen = 0
			IF @PartNo = 0
				SET @StrSelect = ''UPDATE '' + @RelatedTableNameWithSchema +
						 '' SET '' + @RelatedFieldNamee + '' = SubString(a.'' + @RelatedFieldNamee + '','' + LTrim(RTrim(Str(@StartLen))) +
						 '','' + LTrim(RTrim(Str(@PrePartsLen))) + '') + b.NewID + SubString(a.'' + @RelatedFieldNamee + '','' + 
						 LTrim(RTrim(Str(@PrePartsLen + @PartNoLen1 + 1))) + '',20)'' +
						 '' FROM  '' + @RelatedTableNameWithSchema + '' a INNER JOIN  pub.tblChangeCoding_AcntCode  b '' + 
						 '' ON LEN(a.'' + @RelatedFieldNamee + '') > '' + LTrim(RTrim(Str(@PrePartsLen))) + 
						 '' AND SubString(a.'' + @RelatedFieldNamee + '','' + LTrim(RTrim(Str(@PrePartsLen + 1))) + '','' + 
										  LTrim(RTrim(Str(@PartNoLen1))) + '') = b.OldID ''
			ELSE 
				SET @StrSelect = ''UPDATE '' + @RelatedTableNameWithSchema +
						 '' SET '' + @RelatedFieldNamee + '' =  b.NewID 
						    FROM  '' + @RelatedTableNameWithSchema + '' a INNER JOIN  pub.tblChangeCoding_AcntCode  b '' + 
						 '' ON  a.'' + @RelatedFieldNamee + '' = b.OldID ''


				Print @StrSelect;
				Exec sp_executesql @StrSelect;
		
			Fetch NEXT From curTablesRelation Into @RelatedTableNameWithSchema,@RelatedFieldNamee,@PartNo
		END

	Close curTablesRelation;
	Deallocate curTablesRelation; 	

	ALTER TABLE inv.tblStorageDocsDtl ENABLE TRIGGER trgStorageDocsDtlUpdate
	PRINT ''Step 2 Done.''

	-- DROP TABLE pub.tblChangeCoding_AcntCode'	
	Print @StrSelect2
	
	SET @StrSelect = @StrSelect1 + @StrSelect2
	-- ============================
	PRINT @StrSelect1
	EXEC sp_executesql @StrSelect; 	
	-- ============================
END
GO
