USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER ast.trgAssetsDtlDelete
   ON  ast.tblAssetsDtl
   WITH ENCRYPTION     
   AFTER DELETE
AS 

BEGIN
	Declare 
	  @DocDate			Char(10)	,
	  @AssetPlaque		VarChar(20)	,
	  @ProcessID		Smallint ,   
	  @EventNo		INT   
	  
	Begin TRY
			
		Declare curAssetsDtl Cursor For 
		Select	ProcessID,AssetPlaque, DocDate,EventNo
		From	Deleted

		Open curAssetsDtl

		FETCH NEXT FROM curAssetsDtl INTO 
			@ProcessID,@AssetPlaque, @DocDate,@EventNo

		WHILE @@FETCH_STATUS = 0
			BEGIN
				if @ProcessID=500 OR @ProcessID=505
				BEGIN
					DECLARE @StrErr NVARCHAR(4000)
					declare @TmpProcessID int ,@SerialNo int
					SET @SerialNo=0
					SELECT TOP 1 @SerialNo=SerialNo,@TmpProcessID=ProcessID 
					FROM ast.tblAssetsDtl 
					WHERE AssetPlaque=@AssetPlaque and (DocDate>@DocDate or (DocDate=@DocDate and EventNo>@EventNo)) and ProcessID in (500,505)
					ORDER BY DocDate,EventNo
					IF @SerialNo> 0
					BEGIN
						IF @TmpProcessID=505 and @ProcessID=500
						begin
							Close curAssetsDtl
							Deallocate curAssetsDtl
							SET @StrErr = '# پلاک '  + @AssetPlaque + ' در برگه ' + LTRIM(STR(@SerialNo))  + ' برگشت داده شده است'
							raiserror (@StrErr, 16, 1)
						END	
						IF @TmpProcessID=500 and @ProcessID=505
						begin
							Close curAssetsDtl
							Deallocate curAssetsDtl
							SET @StrErr = '# پلاک '  + @AssetPlaque + ' در برگه ' + LTRIM(STR(@SerialNo))  + ' خارج شده است'
							raiserror (@StrErr, 16, 1)
						END	
					END
				END
	 
				FETCH NEXT FROM curAssetsDtl INTO 
					@ProcessID,@AssetPlaque, @DocDate,@EventNo
			END

		Close curAssetsDtl
		Deallocate curAssetsDtl

	End TRY

	Begin Catch
		Declare @strErrorMessage As Nvarchar(1024)
		Set @strErrorMessage = ERROR_MESSAGE() 
		raiserror (@strErrorMessage, 16, 1)
	
	End Catch

END
GO
