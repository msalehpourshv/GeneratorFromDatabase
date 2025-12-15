USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER ast.trgAssetsDtlInsert
   ON  ast.tblAssetsDtl
   WITH ENCRYPTION     
   AFTER Insert
AS 

BEGIN
	Declare 
	  @DocDate			Char(10)	,
	  @AssetPlaque		VarChar(20)	,
	  @ProcessID		Smallint ,   
	  @ProcessNo		Smallint ,   
	  @FiscalYear		int ,   
	  @SerialNo			int ,   
	  @RowNo			int ,   
	  @SetEventNo		Bit ,   
	  @EventNo			INT   
	  
	Begin TRY
			
		Declare curAssetsDtl Cursor For 
		Select	ProcessID,ProcessNo,FiscalYear,SerialNo,RowNo,AssetPlaque, DocDate,EventNo
		From	inserted

		Open curAssetsDtl

		FETCH NEXT FROM curAssetsDtl INTO 
			@ProcessID,@ProcessNo,@FiscalYear,@SerialNo,@RowNo,@AssetPlaque, @DocDate,@EventNo

		WHILE @@FETCH_STATUS = 0
			BEGIN
				SET @SetEventNo = 'False'
				if @ProcessID=500 OR @ProcessID=505
				BEGIN
					IF @EventNo = 0
					BEGIN
						SET @SetEventNo = 'True'

						SELECT @EventNo=MAX(EventNo) + 1
						FROM ast.tblAssetsDtl 
						WHERE AssetPlaque=@AssetPlaque
						Update ast.tblAssetsDtl
						SET EventNo = @EventNo 
						WHERE ProcessID=@ProcessID
						 AND  ProcessNo=@ProcessNo	
						 AND  FiscalYear=@FiscalYear	
						 AND  SerialNo=@SerialNo	
						 AND  RowNo=@RowNo							 
					END
					DECLARE @StrErr NVARCHAR(4000)
					declare @TmpProcessID int ,@SerialNo1 int
					SET @SerialNo1=0
					SELECT TOP 1 @SerialNo1=SerialNo,@TmpProcessID=ProcessID 
					FROM ast.tblAssetsDtl 
					WHERE AssetPlaque=@AssetPlaque  and  (DocDate>@DocDate or (DocDate=@DocDate and EventNo>@EventNo))  and ProcessID in (500,505)
					ORDER BY DocDate,EventNo
					IF @SerialNo1> 0
					BEGIN
						IF @TmpProcessID=505 and @ProcessID=505
						begin
							Close curAssetsDtl
							Deallocate curAssetsDtl
							SET @StrErr = '# پلاک '  + @AssetPlaque + ' در برگه ' + LTRIM(STR(@SerialNo1))  + ' برگشت داده شده است'
							raiserror (@StrErr, 16, 1)
						END	
						IF @TmpProcessID=500 and @ProcessID=500
						begin
							Close curAssetsDtl
							Deallocate curAssetsDtl
							SET @StrErr = '# پلاک '  + @AssetPlaque + ' در برگه ' + LTRIM(STR(@SerialNo1))  + ' خارج شده است'
							raiserror (@StrErr, 16, 1)
						END	
					END

					SELECT TOP 1 @SerialNo1=SerialNo,@TmpProcessID=ProcessID 
					FROM ast.tblAssetsDtl 
					WHERE AssetPlaque=@AssetPlaque  and (DocDate<@DocDate or (DocDate=@DocDate and EventNo<@EventNo))  and ProcessID in (500,505)
					ORDER BY DocDate Desc,EventNo Desc
					IF @SerialNo1> 0
					BEGIN
						IF @TmpProcessID=505 and @ProcessID=505
						begin
							Close curAssetsDtl
							Deallocate curAssetsDtl
							SET @StrErr = '# پلاک '  + @AssetPlaque + ' در برگه ' + LTRIM(STR(@SerialNo1))  + ' برگشت داده شده است'
							raiserror (@StrErr, 16, 1)
						END	
						IF @TmpProcessID=500 and @ProcessID=500
						begin
							Close curAssetsDtl
							Deallocate curAssetsDtl
							SET @StrErr = '# پلاک '  + @AssetPlaque + ' در برگه ' + LTRIM(STR(@SerialNo1))  + ' خارج شده است'
							raiserror (@StrErr, 16, 1)
						END	
					END

					IF @SetEventNo = 'True'
					BEGIN
						Update ast.tblAssetsDtl
						SET EventNo = 0
						WHERE ProcessID=@ProcessID
						 AND  ProcessNo=@ProcessNo	
						 AND  FiscalYear=@FiscalYear	
						 AND  SerialNo=@SerialNo	
						 AND  RowNo=@RowNo	
					END
				END			
					
				FETCH NEXT FROM curAssetsDtl INTO 
					@ProcessID,@ProcessNo,@FiscalYear,@SerialNo,@RowNo,@AssetPlaque, @DocDate,@EventNo
			END

		Close curAssetsDtl
		Deallocate curAssetsDtl

	End TRY

	Begin Catch
		Declare @strErrorMessage As Nvarchar(1024)
		Set @strErrorMessage = ERROR_MESSAGE() 
		raiserror (@strErrorMessage, 16, 1)
	
	End Catch	
		
--Update ast.tblAssetsDtl	
--	set EventNo=	replace(SubString( Case when a.ProcessID in (450,455,460)  then a.PurchaseDate else a.DocDate end,2,9),'/','') 
--	+ pub.funPadLeft(  SubString (ltrim(MaxEventNo),8,2),'0',2)
--	from  ast.tblAssetsDtl a
--	inner join (Select  isnull(Max(EventNo),0)+1 MaxEventNo, AssetPlaque from  ast.tblAssetsDtl a Group by  AssetPlaque)b 
--	on a.AssetPlaque=b.AssetPlaque
--	where replace(SubString( Case when a.ProcessID in (450,455,460)  then a.PurchaseDate else a.DocDate end,2,9),'/','')<>SubString(ltrim(a.EventNo),1,7)
--	or len(a.EventNo)<=8  or len(a.EventNo)>9

END
GO
