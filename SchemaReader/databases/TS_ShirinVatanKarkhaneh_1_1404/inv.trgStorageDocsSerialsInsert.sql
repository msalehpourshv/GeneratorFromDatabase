USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [inv].[trgStorageDocsSerialsInsert] 
   ON  [inv].[tblStorageDocsSerials]
   WITH ENCRYPTION
   AFTER INSERT
AS 

Begin

	Declare 
	 @ProcessID		Smallint	,	
	 @ProcessNo		Tinyint		,
	 @FiscalYear	Smallint	,	
	 @SerialNo		Int	,		
	 @DocRowNo		Int	,		
	 @AtomRowNo		Int	,		
	 @ContainerID	VARCHAR(20),			
	 @ContainerID2	VARCHAR(20),			
	 @ContainerStoresID		VARCHAR(20),			
	 @ContainerStoresID2	VARCHAR(20),			
	 @StoreID2		VARCHAR(20),			
	 @ProductSerialID	int,
	 @ProductSerialID2	int,
	 @PSerialNo		VARCHAR(30),			
	 @PSerialNo2	VARCHAR(30)			
	 
	Begin TRY
	Declare curStorageInsertDocsSerials Cursor For 
	Select ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo,AtomRowNo,
		   ContainerID,ContainerID2,ContainerStoresID,ContainerStoresID2,
		   ProductSerialID,ProductSerialID2,PSerialNo,PSerialNo2
	From Inserted

	Open curStorageInsertDocsSerials

	FETCH NEXT FROM curStorageInsertDocsSerials INTO	
		@ProcessID, @ProcessNo, @FiscalYear, @SerialNo, @DocRowNo ,@AtomRowNo,
		@ContainerID,@ContainerID2,@ContainerStoresID,@ContainerStoresID2,
		@ProductSerialID,@ProductSerialID2,@PSerialNo,@PSerialNo2

	WHILE @@FETCH_STATUS = 0
		BEGIN
			
			IF @ProcessID=120  -- انتقال داخلی
				Begin
					Declare @SettingValue NVarchar(10)
								
					IF @ProcessNo = 2
						SELECT @SettingValue=SettingValue 
						FROM pub.tblSettings 
						WHERE SettingKey='IsAutoTransfer2'
					ELSE
						SELECT @SettingValue=SettingValue 
						FROM pub.tblSettings 
						WHERE SettingKey='IsAutoTransfer'


					IF UPPER(@SettingValue) = 'TRUE' OR @SettingValue = '1'
					BEGIN
						Select * Into #InvInserted From Inserted;

						select @StoreID2 = StoreID2 from inv.tblStorageDocsDtl 
						where ProcessID = @ProcessID 
						  and ProcessNo=@ProcessNo
						  and FiscalYear=@FiscalYear
						  and SerialNo=@SerialNo
						  and DocRowNo=@DocRowNo

						Update #InvInserted 
						Set ProcessID=125,ContainerID=@ContainerID2,ContainerID2=@ContainerID,ContainerStoresID = @ContainerStoresID2,ContainerStoresID2 = @ContainerStoresID, StoreID=@StoreID2, EnterKind=1;
				
						Insert Into [inv].[tblStorageDocsSerials] Select * From #InvInserted
					
						Drop table #InvInserted;
					END
				End

			ELSE IF @ProcessID=260 -- کارت به کالا
				Begin

					Select * Into #InvInserted2 From Inserted;

					select @StoreID2 = StoreID2 from inv.tblStorageDocsDtl 
					where ProcessID = @ProcessID 
					  and ProcessNo=@ProcessNo
					  and FiscalYear=@FiscalYear
					  and SerialNo=@SerialNo
					  and DocRowNo=@DocRowNo

					Update #InvInserted2 
					Set ProcessID=265, StoreID=@StoreID2, EnterKind=1,
						ProductSerialID=@ProductSerialID2,
						ProductSerialID2=@ProductSerialID,
						PSerialNo=@PSerialNo2,
						PSerialNo2=@PSerialNo,
						ContainerStoresID = @ContainerStoresID2,
						ContainerStoresID2 = @ContainerStoresID;
					
					Insert Into [inv].[tblStorageDocsSerials] Select * From #InvInserted2
					
					Drop table #InvInserted2;
					
				End

			----- Fetch next record
	FETCH NEXT FROM curStorageInsertDocsSerials INTO	
		@ProcessID, @ProcessNo, @FiscalYear, @SerialNo, @DocRowNo ,@AtomRowNo,@ContainerID,@ContainerID2,@ContainerStoresID,@ContainerStoresID2,
		@ProductSerialID,@ProductSerialID2,@PSerialNo,@PSerialNo2

	END

	Close curStorageInsertDocsSerials
	Deallocate curStorageInsertDocsSerials
	
    END TRY

	Begin Catch
		Declare @StrErrorMessage As Nvarchar(1024)
		Set @StrErrorMessage = ERROR_MESSAGE() 
		raiserror (@StrErrorMessage, 16, 1)
		
	End Catch

END
GO
