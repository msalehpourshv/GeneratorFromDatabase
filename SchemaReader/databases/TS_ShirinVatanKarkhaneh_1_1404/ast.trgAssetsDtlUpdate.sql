USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER ast.trgAssetsDtlUpdate
   ON  ast.tblAssetsDtl
   WITH ENCRYPTION     
   AFTER Update
AS 

BEGIN


			DECLARE 
			 @OldDate			Char(10)		,	@NewDate			Char(10)	,
			 @PreDate			Char(10)		,	@NextDate			Char(10)	,
			 @OldAssetPlaque	VARCHAR(20)		,	@NewAssetPlaque	VARCHAR(20)	,
			 @ProcessID			Smallint		,	@SerialNo			Int			,
			 @OldEventNo		Int				,	@NewEventNo			Int,
			 @StrErr			NVARCHAR(4000)	,	@TmpProcessID int 
			
			BEGIN TRY
				
				
				DECLARE curAssetsDtlInserted Cursor  For 
				SELECT ProcessID,AssetPlaque, DocDate,EventNo
				FROM	Inserted

				DECLARE curAssetsDtlDeleted Cursor  For 
				SELECT	ProcessID,AssetPlaque, DocDate,EventNo
				FROM	Deleted

				OPEN curAssetsDtlInserted
				OPEN curAssetsDtlDeleted
				
				FETCH NEXT FROM curAssetsDtlInserted INTO	@ProcessID,@NewAssetPlaque, @NewDate,@NewEventNo

				WHILE @@FETCH_STATUS = 0
					BEGIN
						
					----- داده هاي سطر قديمي 
							FETCH NEXT FROM curAssetsDtlDeleted INTO	@ProcessID,@OldAssetPlaque, @OldDate,@OldEventNo

							IF	@NewDate <> @OldDate and @NewAssetPlaque = @NewAssetPlaque 
							begin 
								Declare @Date1	Char(10)	
								Declare @Date2	Char(10)	
								declare @ENV1	int 
								declare @ENV2	int 
								
								set @Date1=@OldDate
								set @Date2=@NewDate
								
								set @ENV1=@OldEventNo
								set @ENV2=@NewEventNo

								if @Date1>@Date2
								begin
									set @Date1=@NewDate
									set @Date2=@OldDate
							 		
									set @ENV1=@NewEventNo
									set @ENV2=@OldEventNo
								end

								SET @TmpProcessID=0
								SET @SerialNo=0
								SELECT TOP 1 @SerialNo=SerialNo,@TmpProcessID=ProcessID 
								FROM ast.tblAssetsDtl 
								WHERE AssetPlaque=@NewAssetPlaque    and ProcessID in (500,505)
									and (DocDate>@Date1 or (DocDate=@Date1 and EventNo>@ENV1))
									and (DocDate<@Date2 or (DocDate=@Date2 and EventNo<@ENV2))
									ORDER BY DocDate,EventNo


									
										IF @SerialNo> 0 and ( @ProcessID=500 OR @ProcessID=505)
										BEGIN
											IF @TmpProcessID=505
											begin
												Close curAssetsDtlDeleted
												Deallocate curAssetsDtlDeleted
												Close curAssetsDtlInserted
												Deallocate curAssetsDtlInserted
												SET @StrErr = '# پلاک '  + @NewAssetPlaque + ' در برگه ' + LTRIM(STR(@SerialNo))  + ' برگشت داده شده است'
												raiserror (@StrErr, 16, 1)
											END	
											IF @TmpProcessID=500 
											begin
												Close curAssetsDtlDeleted
												Deallocate curAssetsDtlDeleted
												Close curAssetsDtlInserted
												Deallocate curAssetsDtlInserted
												SET @StrErr = '# پلاک '  + @NewAssetPlaque + ' در برگه ' + LTRIM(STR(@SerialNo))  + ' خارج شده است'
												raiserror (@StrErr, 16, 1)
											END	
										END

							end

							
							--==================== When AssetPlaque Or Others are changed ============================================
							IF	@NewAssetPlaque <> @NewAssetPlaque
								-- حذف سطر قديمي و افزودن سطر جديد
								BEGIN
									if @ProcessID=500 OR @ProcessID=505
									BEGIN
										
										------جدید										
										SET @TmpProcessID=0
										SET @SerialNo=0
										SELECT TOP 1 @SerialNo=SerialNo,@TmpProcessID=ProcessID 
										FROM ast.tblAssetsDtl 
										WHERE AssetPlaque=@NewAssetPlaque  and (DocDate>@NewDate or (DocDate=@NewDate and EventNo>@NewEventNo))  and ProcessID in (500,505)
										ORDER BY DocDate,EventNo
										IF @SerialNo> 0
										BEGIN
											IF @TmpProcessID=505 and @ProcessID=505
											begin
												Close curAssetsDtlDeleted
												Deallocate curAssetsDtlDeleted
												Close curAssetsDtlInserted
												Deallocate curAssetsDtlInserted
												SET @StrErr = '# پلاک '  + @NewAssetPlaque + ' در برگه ' + LTRIM(STR(@SerialNo))  + ' برگشت داده شده است'
												raiserror (@StrErr, 16, 1)
											END	
											IF @TmpProcessID=500 and @ProcessID=500
											begin
												Close curAssetsDtlDeleted
												Deallocate curAssetsDtlDeleted
												Close curAssetsDtlInserted
												Deallocate curAssetsDtlInserted
												SET @StrErr = '# پلاک '  + @NewAssetPlaque + ' در برگه ' + LTRIM(STR(@SerialNo))  + ' خارج شده است'
												raiserror (@StrErr, 16, 1)
											END	
										END
											SET @SerialNo=0
											SET @TmpProcessID = 0
											SELECT TOP 1 @SerialNo=SerialNo,@TmpProcessID=ProcessID 
											FROM ast.tblAssetsDtl 
											WHERE AssetPlaque=@OldAssetPlaque and (DocDate>@OldDate or (DocDate=@OldDate and EventNo>@OldEventNo)) and ProcessID in (500,505)
											ORDER BY DocDate,EventNo
											IF @SerialNo> 0
											BEGIN
												IF @TmpProcessID=505 and @ProcessID=500
												begin
													Close curAssetsDtlDeleted
													Deallocate curAssetsDtlDeleted
													Close curAssetsDtlInserted
													Deallocate curAssetsDtlInserted
													SET @StrErr = '# پلاک '  + @OldAssetPlaque + ' در برگه ' + LTRIM(STR(@SerialNo))  + ' برگشت داده شده است'
													raiserror (@StrErr, 16, 1)
												END	
												IF @TmpProcessID=500 and @ProcessID=505
												begin
													Close curAssetsDtlDeleted
													Deallocate curAssetsDtlDeleted
													Close curAssetsDtlInserted
													Deallocate curAssetsDtlInserted
													SET @StrErr = '# پلاک '  + @OldAssetPlaque + ' در برگه ' + LTRIM(STR(@SerialNo))  + ' خارج شده است'
													raiserror (@StrErr, 16, 1)
												END	
											END

									END
								END
												
						--========================================================================================================================
					FETCH NEXT FROM curAssetsDtlInserted INTO	@ProcessID,@NewAssetPlaque, @NewDate,@NewEventNo

					END -- WHILE 

				CLOSE curAssetsDtlInserted
				Deallocate curAssetsDtlInserted

				CLOSE curAssetsDtlDeleted
				Deallocate curAssetsDtlDeleted
			
			END TRY

			BEGIN Catch
				DECLARE @StrErrorMessage As NVARCHAR(1024)
				SET @StrErrorMessage = ERROR_MESSAGE() 
				RAISERROR (@StrErrorMessage, 16, 1)
			END Catch

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
