USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation date : 1388/03/09
-- Viewed By	 : 
-- Last Modified : 1393/06/10
-- Last Modifier : TakroSystem\Zia
-- Description	 : Returns filter string accourding to the params in filter table
-- =======================================
Create FUNCTION [pub].[funGetFilterString]
(
	@SessionNo	Int,	
	@ReportID	Int,	
	@ObjectID	Int,
	@MainField	VarChar(50)
)
RETURNS NVarChar(MAX)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @StrResult	NVarChar(MAX);
	DECLARE @FilterType	TinyInt;
	DECLARE @CodeFr		VarChar(20);
	DECLARE @CodeTo		VarChar(20);
	DECLARE @CodeStart	VarChar(3);
	DECLARE @NameMask	NVarChar(100);
	DECLARE @CodeFrLen	VarChar(3);
	DECLARE @CodeToLen	VarChar(3);
	DECLARE @AppendTyp	VarChar(3);

	DECLARE @CodeTable	VarChar(100); -- Coding table Hdr
	DECLARE @NameTable	VarChar(50); -- Coding table Dtl 
	DECLARE @CodeField	VarChar(50); -- Code field in Coding Table (Hdr & Dtl)
	DECLARE @NameField	VarChar(50); -- Name field in Coding Table (Dtl only)
	DECLARE @GroupTable VarChar(100);
	DECLARE @GroupField VarChar(50);
	DECLARE @PartNo		Int;		 -- PartNo for Acnt Codings
	DECLARE @PartLen	Int;		 -- Part len for Acnt Codings
	DECLARE @StrPartSection AS NVarChar(200);

	SET @StrResult = '';

	DECLARE csr_funGetFilterString_01 CURSOR FOR 
		SELECT FilterType, CodeFrom, CodeTo, CodeStart, NameMask, CodingTable, CodeField, NameField , PartNo, GroupTable, GroupField, AppendType
		FROM rpt.tblFilters
		WHERE (SessionNo = @SessionNo) AND (ReportID = @ReportID) AND (ObjectID = @ObjectID)

	OPEN  csr_funGetFilterString_01
	FETCH NEXT FROM csr_funGetFilterString_01 INTO @FilterType, @CodeFr, @CodeTo, @CodeStart, @NameMask, @CodeTable, @CodeField, @NameField, @PartNo, @GroupTable, @GroupField, @AppendTyp

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		SET @CodeFr		= LTrim(@CodeFr)
		SET @CodeTo		= LTrim(@CodeTo)
		SET @CodeStart	= LTrim(@CodeStart)
		SET @NameMask	= LTrim(@NameMask)
		SET @CodeFrLen	= LTrim(Str(Len(@CodeFr)))
		SET @CodeToLen	= LTrim(Str(Len(@CodeTo)))
		SET @NameTable  = @CodeTable + 'Dtl'

		IF (@FilterType = 1) -- >> FromCode ToCode
		BEGIN
			IF (@StrResult <> '') SET @StrResult = @StrResult + ' AND ';
			IF (@AppendTyp = 'NOT') SET @StrResult = @StrResult + 'NOT ';

			IF (@CodeFr = @CodeTo)
			BEGIN
				IF (@PartNo = 0)
					SET @StrResult = @StrResult + '(SUBSTRING(' + @MainField + ',1,LEN(''' + @CodeFr + ''')) = ''' + @CodeFr + ''')'
				ELSE
					SET @StrResult = @StrResult + '(Substring(' + @MainField + ', ' + @CodeStart + ', ' + @CodeFrLen + ') = ''' + @CodeFr + ''') '
			END
			ELSE
			BEGIN
				IF (@PartNo = 0)
					SET @StrResult = @StrResult + '(SUBSTRING(' + @MainField + ',1,LEN(''' + @CodeFr + ''')) >= ''' + @CodeFr + ''' AND SUBSTRING(' + @MainField + ',1,LEN(''' + @CodeFr + ''')) <= ''' + @CodeTo + ''') '
				ELSE
					SET @StrResult = @StrResult + '(Substring(' + @MainField + ', ' + @CodeStart + ', ' + @CodeFrLen + ') >= ''' + @CodeFr + ''' AND Substring(' + @MainField + ', ' + @CodeStart + ', ' + @CodeToLen + ') <= ''' + @CodeTo + ''') '
			END
		END

		IF (@FilterType = 2) -- >> Mask End of code
		BEGIN
			IF (@StrResult <> '') SET @StrResult = @StrResult + ' AND ';
			IF (@AppendTyp = 'NOT') SET @StrResult = @StrResult + 'NOT ';
			SET @StrResult = @StrResult + '(' + @MainField + ' LIKE ''%' + @CodeFr + ''') '
		END

		IF (@FilterType = 3) -- >> Code Mask
		BEGIN
			IF (@StrResult <> '') SET @StrResult = @StrResult + ' AND ';
			IF (@AppendTyp = 'NOT') SET @StrResult = @StrResult + 'NOT ';
			SET @StrResult = @StrResult + '(Substring(' + @MainField + ', ' + @CodeStart + ', ' + @CodeFrLen + ') LIKE ''' + @CodeFr + '%'') '
		END

		IF (@FilterType = 4) -- >> Part of code
		BEGIN
			If (@PartNo > 0) 
				SELECT @PartLen = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9
				FROM pub.tblCodeLayer
				WHERE TableName = @CodeTable AND PartNumber = @PartNo
			Else
				SELECT TOP 1 @PartLen = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9
				FROM pub.tblCodeLayer
				WHERE TableName = @CodeTable

			IF (@StrResult <> '') SET @StrResult = @StrResult + ' AND ';
			IF (@AppendTyp = 'NOT') SET @StrResult = @StrResult + 'NOT ';
			SET @StrResult = @StrResult + '(Substring(' + @MainField + ', ' + @CodeStart + ', ' + LTrim(Str(@PartLen)) + ') LIKE ''%' + @CodeFr + '%'') '
		END

		IF (@FilterType = 5) -- >> Part of name
		BEGIN
			If (@PartNo > 0) 
				SELECT @PartLen = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9
				FROM pub.tblCodeLayer
				WHERE TableName = @CodeTable AND PartNumber = @PartNo
			Else
				SELECT TOP 1 @PartLen = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9
				FROM pub.tblCodeLayer
				WHERE TableName = @CodeTable

			IF (@StrResult <> '') SET @StrResult = @StrResult + ' AND ';
			IF (@AppendTyp = 'NOT') SET @StrResult = @StrResult + 'NOT ';

			if (@PartNo > 0)
				SET @StrResult = @StrResult + '(Substring(' + @MainField + ', ' + @CodeStart + ', ' + LTrim(Str(@PartLen)) + ') IN (SELECT ' + @CodeField + ' FROM ' + @NameTable + ' WHERE ' + replace(@NameField,' ','') + ' LIKE N''%' +REPLACE(@NameMask ,' ','') + '%'' ))'
			else
				SET @StrResult = @StrResult + '(' + @MainField + ' IN (SELECT ' + @CodeField + ' FROM ' + @NameTable + ' WHERE ' + replace(@NameField,' ','') + ' LIKE N''%' +REPLACE(@NameMask,' ','')  + '%'') )'
		END

		IF (@FilterType = 6)
		BEGIN
			IF (@StrResult <> '') 
			begin
				IF (@AppendTyp <> 'NOT') 
					SET @StrResult = @StrResult + ' or ';
				else 
					SET @StrResult = @StrResult + ' and NOT ';
			END
			IF (@StrResult = '') and (@AppendTyp = 'NOT') 
					SET @StrResult = @StrResult + ' NOT ';
			
			IF (@PartNo = 0)
				SET @StrResult = @StrResult + '(SUBSTRING(' + @MainField + ',1,LEN(''' + @CodeFr + ''')) = ''' + @CodeFr + ''')'
			ELSE
				SET @StrResult = @StrResult + '(Substring(' + @MainField + ', ' + @CodeStart + ', ' + @CodeFrLen + ') = ''' + @CodeFr + ''') '			
		END

		IF (@FilterType = 7) -- >> Group
		BEGIN
			If (@PartNo > 0) 
				SELECT @PartLen = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9
				FROM pub.tblCodeLayer
				WHERE TableName = @CodeTable AND PartNumber = @PartNo
			Else
				SELECT TOP 1 @PartLen = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9
				FROM pub.tblCodeLayer
				WHERE TableName = @CodeTable

			IF (@StrResult <> '') SET @StrResult = @StrResult + ' AND ';
			IF (@AppendTyp = 'NOT') SET @StrResult = @StrResult + 'NOT ';
			IF @CodeTable = 'inv.tblGoods'
				SET @StrResult = @StrResult + '(RTrim(' + @MainField + ') IN 
				(
					SELECT	DISTINCT G.' + @CodeField + '
					FROM	 ' + @GroupTable + ' G
					WHERE	' + @GroupField + ' = ''' + @CodeFr + ''' 
				))'
			ELSE
				SET @StrResult = @StrResult + '(RTrim(Substring(' + @MainField + ', ' + @CodeStart + ', ' + LTrim(Str(@PartLen)) + ')) IN 
				(
					SELECT	DISTINCT C.' + @CodeField + '
					FROM	' + @CodeTable + ' C, ' + @GroupTable + ' G
					WHERE	' + @GroupField + ' = ''' + @CodeFr + ''' AND LEFT(C.' + @CodeField + ', LEN(G.' + @CodeField + ')) = G.' + @CodeField + ' 
				))'
		END

		IF (@FilterType = 8) -- >> Code start with
		BEGIN
			IF (@StrResult <> '') SET @StrResult = @StrResult + ' AND ';
			IF (@AppendTyp = 'NOT') SET @StrResult = @StrResult + 'NOT ';
			SET @StrResult = @StrResult + '(Substring(' + @MainField + ', ' + @CodeStart + ', ' + @CodeFrLen + ') = ''' + @CodeFr + ''')'
		END
		
		IF (@FilterType = 11) -- >> Mask End of code
		BEGIN
		
			if (@CodeTable = 'inv.tblGoods')
			begin
				IF (@StrResult <> '') SET @StrResult = @StrResult + ' AND ';
				IF (@AppendTyp = 'NOT') SET @StrResult = @StrResult + 'NOT ';
				SET @StrResult = @StrResult + '(' + @MainField + ' IN (SELECT C.' + @CodeField + ' FROM ' + @CodeTable + ' C WHERE (UPPER(C.TechnicalNo) = UPPER(''' + @CodeFr + '''))))' 
			end;
		END

		IF (@FilterType = 12) -- >> Mask End of code
		BEGIN
		
			if (@CodeTable = 'inv.tblGoods')
			begin
				IF (@StrResult <> '') SET @StrResult = @StrResult + ' AND ';
				IF (@AppendTyp = 'NOT') SET @StrResult = @StrResult + 'NOT ';
				SET @StrResult = @StrResult + '(' + @MainField + ' IN (SELECT C.' + @CodeField + ' FROM ' + @CodeTable + ' C WHERE (C.TechnicalSpecifications like ''%' + replace(@CodeFr,' ','') + '%'')))' 
			end;
		END

		FETCH NEXT FROM csr_funGetFilterString_01 INTO @FilterType, @CodeFr, @CodeTo, @CodeStart, @NameMask, @CodeTable, @CodeField, @NameField, @PartNo, @GroupTable, @GroupField, @AppendTyp
	END

	CLOSE      csr_funGetFilterString_01
	DEALLOCATE csr_funGetFilterString_01

	-- Append Selected Codes 
	SET @CodeStart = Null
	SET @PartNo = 0

	SELECT	TOP 1 @CodeStart = CodeStart, @PartNo = PartNo
	FROM	rpt.tblFilters
	WHERE	(SessionNo = @SessionNo) AND 
			(ReportID = @ReportID) AND 
			(ObjectID = @ObjectID) AND 
			(FilterType = 16) and (AppendType <> 'NOT')

	Declare @Layer2Len as tinyint 
	SET @Layer2Len = 0
	declare @strType6Filter as NVARCHAR(500)
	SET @strType6Filter = 'Substring(' + @MainField + ',' + @CodeStart + ', LEN(F.CodeFrom))'
	IF (@CodeStart Is Not Null) 
	Begin
		If (@PartNo > 0) 
			SELECT @Layer2Len = Layer2 ,@PartLen = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9
			FROM pub.tblCodeLayer
			WHERE TableName = @CodeTable AND PartNumber = @PartNo
		Else
			SELECT TOP 1 @Layer2Len = Layer2 ,@PartLen = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9
			FROM pub.tblCodeLayer
			WHERE TableName = @CodeTable

		IF @PartNo = 1 
		Begin
			IF @Layer2Len = 0
			Begin
				SET @strType6Filter = @MainField
			End
		End

		IF (@StrResult <> '') SET @StrResult = @StrResult + ' AND ';

		If (@PartNo > 0) 
			SET @StrPartSection = ' AND (C.PartNumber = ' + LTrim(Str(@PartNo)) + ') '
		Else
			SET @StrPartSection = ''

		If (@PartNo > 0) 
		SET @StrResult = @StrResult + '
		(
			SELECT COUNT(*)
			FROM ' + @CodeTable + ' C,rpt.tblFilters F
			WHERE LEFT(C.' + @CodeField + ',LEN(F.CodeFrom))=F.CodeFrom AND
				(' + @strType6Filter + '=RTrim(LTrim(F.CodeFrom))) AND
				(F.SessionNo=' + LTrim(Str(@SessionNo)) + ') AND
				(F.ReportID='  + LTrim(Str(@ReportID))  + ') AND
				(F.ObjectID='  + LTrim(Str(@ObjectID))  + ') AND
				(F.FilterType=16)AND(F.AppendType<>''NOT'')' + @StrPartSection + '
		)>0'
		else
		SET @StrResult = @StrResult + '(' + @MainField + ' in 
		(
			select F.CodeFrom 
			from rpt.tblFilters F
			where (F.SessionNo=' + LTrim(Str(@SessionNo)) + ') AND
				(F.ReportID='  + LTrim(Str(@ReportID))  + ') AND
				(F.ObjectID='  + LTrim(Str(@ObjectID))  + ') AND
				(F.FilterType=16) AND 
				(F.AppendType<>''NOT'')' + @StrPartSection + '
		) )'
	End

	-- Append Selected Codes <not mode>
	SET @CodeStart = Null;
	SET @PartNo = 0;

	SELECT	TOP 1 @CodeStart = CodeStart, @PartNo = PartNo
	FROM	rpt.tblFilters
	WHERE	(SessionNo = @SessionNo) AND 
			(ReportID = @ReportID) AND 
			(ObjectID = @ObjectID) AND 
			(FilterType = 16) and (AppendType = 'NOT')

	IF (@CodeStart Is Not Null) 
	Begin
		If (@PartNo > 0) 
			SELECT @PartLen = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9
			FROM pub.tblCodeLayer
			WHERE TableName = @CodeTable AND PartNumber = @PartNo
		Else
			SELECT TOP 1 @PartLen = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9
			FROM pub.tblCodeLayer
			WHERE TableName = @CodeTable

		IF (@StrResult <> '')
			SET @StrResult = @StrResult + ' AND Substring(' + @MainField + ', ' + @CodeStart + ', ' + @CodeFrLen + ') NOT in ';
		 ELSE
		 SET @StrResult = @StrResult + '  Substring(' + @MainField + ', ' + @CodeStart + ', ' + @CodeFrLen + ') NOT in  ';

		If (@PartNo > 0) 
			SET @StrPartSection = ' AND (C.PartNumber = ' + LTrim(Str(@PartNo)) + ') '
		Else
			SET @StrPartSection = ''	 

		If (@PartNo > 0) 
		SET @StrResult = @StrResult + '
		(
			SELECT C.' + @CodeField + '
			FROM ' + @CodeTable + ' C,rpt.tblFilters F
			WHERE LEFT(C.' + @CodeField + ',LEN(C.' + @CodeField + '))=F.CodeFrom AND
				(Substring(C.' + @CodeField + ',1, LEN(F.CodeFrom))=RTrim(LTrim(F.CodeFrom))) AND
				(F.SessionNo=' + LTrim(Str(@SessionNo)) + ') AND
				(F.ReportID='  + LTrim(Str(@ReportID))  + ') AND
				(F.ObjectID='  + LTrim(Str(@ObjectID))  + ') AND
				(F.FilterType=16) AND (F.AppendType = ''NOT'')' + @StrPartSection + '
		) '
		else
		SET @StrResult = @StrResult + '
		(  (
			select F.CodeFrom 
			from rpt.tblFilters F
			where (F.SessionNo=' + LTrim(Str(@SessionNo)) + ') AND (F.ReportID='  + LTrim(Str(@ReportID))  + ') AND (F.ObjectID='  + LTrim(Str(@ObjectID))  + ') AND (F.FilterType=16) AND (F.AppendType=''NOT'')' + @StrPartSection + '
		))'
		
	End

	if LTrim(@StrResult) = '' set @StrResult = '1=1'

	RETURN '(' + @StrResult + ')'
END
GO
