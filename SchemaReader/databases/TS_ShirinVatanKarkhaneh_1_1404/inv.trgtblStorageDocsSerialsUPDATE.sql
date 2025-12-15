USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER inv.trgtblStorageDocsSerialsUPDATE 
   ON  inv.tblStorageDocsSerials 
   WITH ENCRYPTION
   AFTER UPDATE
AS 

BEGIN

	DECLARE 
     @PSerialNo				VarChar(20) ,
     @NewStoreID			VarChar(20) ,
	 @NewGoodsID			VarChar(20) ,
	 @NewContainerID		VarChar(20) ,	 
	 @NewContainerID2		VarChar(20) ,
	 @NewProductionDate		VarChar(10) ,
	 @NewExpireDate			VarChar(10) ,
     @OldStoreID			VarChar(20) ,
	 @OldGoodsID			VarChar(20) ,
	 @OldContainerID		VarChar(20) ,	 
	 @OldContainerID2		VarChar(20) ,
	 @OldProductionDate		VarChar(10) ,
	 @OldExpireDate			VarChar(10) ,
	 @NumberPerContainer	FLOAT,
	 @StrErr		NVARCHAR(4000) 

	BEGIN TRY
		
		DECLARE curStorageUpdateDocsPSerialNo CURSOR FOR 
		SELECT PSerialNo FROM Inserted a WHERE PSerialNo <>''
		UNION 
		SELECT PSerialNo FROM Deleted a WHERE PSerialNo <>''
		
		OPEN curStorageUpdateDocsPSerialNo
		FETCH NEXT FROM curStorageUpdateDocsPSerialNo INTO @PSerialNo

		WHILE @@FETCH_STATUS = 0
			BEGIN

			IF (SELECT COUNT(*) 
				FROM (SELECT PSerialNo, 
							 Sum(EnterKind) EnterKind, 
							 StoreID 
					  FROM inv.tblStorageDocsSerials 
					  WHERE PSerialNo <> '' 
					    AND PSerialNo <> '0' 
						AND PSerialNo = @PSerialNo
					  GROUP BY PSerialNo, StoreID
					  HAVING SUM(EnterKind) > 1 OR SUM(EnterKind) < 0
				)a)>0

				BEGIN
					
					CLOSE curStorageUpdateDocsPSerialNo
					DEALLOCATE curStorageUpdateDocsPSerialNo
					
					SET @StrErr = N'#$ موجودی سریال های زیر منفی و یا بیش از 1  می شود  '+Char(13)+  ' سریال ' + @PSerialNo +Char(13) + '   #$'
					RAISERROR (@StrErr, 16, 1)
				END 

				----- Fetch next record
				FETCH NEXT FROM curStorageUpdateDocsPSerialNo INTO @PSerialNo	
			END

		CLOSE curStorageUpdateDocsPSerialNo
		DEALLOCATE curStorageUpdateDocsPSerialNo

		
			DECLARE curStorageSerialsInserted CURSOR  FOR 
			SELECT a.StoreID,
				   a.ContainerID,
				   GoodsID,
				   a.ContainerID2,
				   a.ProductionDate,
				   a.ExpireDate
			FROM Inserted a 
			INNER JOIN inv.tblStorageDocsDtl d ON a.ProcessID = d.ProcessID 
											  AND a.ProcessNo = d.ProcessNo 
											  AND a.FiscalYear = d.FiscalYear 
											  AND a.SerialNo = d.SerialNo 
											  AND a.DocRowNo = d.DocRowNo 
			WHERE ContainerID <> '' 
			  AND NumberPerContainer <> 0

			DECLARE curStorageSerialsDeleted Cursor  For 
			SELECT a.StoreID,
				   a.ContainerID,
				   GoodsID, 
				   a.ContainerID2,
				   a.ProductionDate,
				   a.ExpireDate
			FROM Deleted a 
			INNER JOIN inv.tblStorageDocsDtl d ON a.ProcessID = d.ProcessID 
											  AND a.ProcessNo = d.ProcessNo 
											  AND a.FiscalYear = d.FiscalYear 
											  AND a.SerialNo = d.SerialNo 
											  AND a.DocRowNo = d.DocRowNo 
			WHERE ContainerID <> '' 
			  AND NumberPerContainer <> 0

				OPEN curStorageSerialsInserted
				OPEN curStorageSerialsDeleted
				
				FETCH NEXT FROM curStorageSerialsInserted INTO @NewStoreID, @NewContainerID, @NewGoodsID, @NewContainerID2, @NewProductionDate, @NewExpireDate

				WHILE @@FETCH_STATUS = 0
					BEGIN

					FETCH NEXT FROM curStorageSerialsDeleted INTO @OldStoreID, @OldContainerID, @OldGoodsID, @OldContainerID2, @OldProductionDate, @OldExpireDate
			
						IF (@OldStoreID <> @NewStoreID OR @OldContainerID <> @NewContainerID OR @OldContainerID2 <> @NewContainerID2 OR @OldProductionDate <> @NewProductionDate OR @OldExpireDate <> @NewExpireDate)
						BEGIN
						IF (
							SELECT COUNT(*) --d.GoodsID,a.ContainerID,a.StoreID,isnull(SUM((NumberPerContainer*case When a.ProcessID in (188,189) then a.EnterKind else  d.EnterKind end )),0) NumberPerContainer
							FROM inv.tblStorageDocsSerials a 
							INNER JOIN inv.tblStorageDocsDtl d ON a.ProcessID = d.ProcessID 
															  AND a.ProcessNo = d.ProcessNo 
															  AND a.FiscalYear = d.FiscalYear 
															  AND a.SerialNo = d.SerialNo 
															  AND a.DocRowNo = d.DocRowNo                     
							--	Left JOIN Inserted AD ON AD.ProcessID=d.ProcessID and AD.ProcessNo=d.ProcessNo and AD.FiscalYear=d.FiscalYear and AD.SerialNo=d.SerialNo and AD.DocRowNo=d.DocRowNo                     
							--	Left JOIN Deleted  DE ON DE.ProcessID=d.ProcessID and DE.ProcessNo=d.ProcessNo and DE.FiscalYear=d.FiscalYear and DE.SerialNo=d.SerialNo and DE.DocRowNo=d.DocRowNo                     
							WHERE GoodsID = @NewGoodsID 
							  AND a.ContainerID = @NewContainerID 
							  AND a.StoreID = @NewStoreID 
							  AND a.ContainerID2 = @NewContainerID2
							  AND a.ProductionDate = @NewProductionDate
							  AND a.ExpireDate = @NewExpireDate
							GROUP BY d.GoodsID, a.ContainerID, a.StoreID, a.ProductionDate, a.ExpireDate
							HAVING ISNULL(SUM(ROUND((a.NumberPerContainer * CASE WHEN a.ProcessID in (188,189) THEN a.EnterKind ELSE d.EnterKind END ),5)),0) < 0
							) >0
						BEGIN
							--ROlLBACK
							SET @NumberPerContainer = 0
							SELECT @NumberPerContainer = ISNULL(SUM(ROUND((a.NumberPerContainer * CASE WHEN a.ProcessID in (188,189) THEN a.EnterKind ELSE d.EnterKind END ),5)),0) --+ isnull(SUM(round(AD.(NumberPerContainer*case When a.ProcessID in (188,189) then a.EnterKind else  d.EnterKind end ),5)),0) 
							FROM inv.tblStorageDocsSerials a 
							INNER JOIN inv.tblStorageDocsDtl d ON a.ProcessID = d.ProcessID 
															  AND a.ProcessNo = d.ProcessNo 
															  AND a.FiscalYear = d.FiscalYear 
															  AND a.SerialNo = d.SerialNo 
															  AND a.DocRowNo = d.DocRowNo                     
							--	Left JOIN Inserted AD ON AD.ProcessID=d.ProcessID and AD.ProcessNo=d.ProcessNo and AD.FiscalYear=d.FiscalYear and AD.SerialNo=d.SerialNo and AD.DocRowNo=d.DocRowNo                     
							--	Left JOIN Deleted  DE ON DE.ProcessID=d.ProcessID and DE.ProcessNo=d.ProcessNo and DE.FiscalYear=d.FiscalYear and DE.SerialNo=d.SerialNo and DE.DocRowNo=d.DocRowNo                     
							WHERE GoodsID = @NewGoodsID 
							  AND a.ContainerID = @NewContainerID 
							  AND a.StoreID = @NewStoreID 
							  AND a.ContainerID2 = @NewContainerID
							  AND a.ProductionDate = @NewProductionDate
							  AND a.ExpireDate = @NewExpireDate
							GROUP BY d.GoodsID, a.ContainerID, a.StoreID, a.ProductionDate, a.ExpireDate
							HAVING ISNULL(SUM(ROUND((a.NumberPerContainer * CASE WHEN a.ProcessID in (188,189) THEN a.EnterKind ELSE d.EnterKind END ),5)),0) < 0

							SET @StrErr = N'#$ موجودی ظرف های زیر منفی می شود  '+Char(13)+ ' انبار ' +@NewStoreID+Char(13)+ ' کالای ' +@NewGoodsID+Char(13)  + ' ظرف ' +@NewContainerID   +Char(13)  + ' تعداد ' + Ltrim(Rtrim(str(@NumberPerContainer))) + '   #$'

							CLOSE curStorageSerialsInserted
							DEALLOCATE curStorageSerialsInserted
							
							CLOSE curStorageSerialsDeleted
							DEALLOCATE curStorageSerialsDeleted
							
							RAISERROR (@StrErr, 16, 1)
						END 

							IF (SELECT COUNT(*) --d.GoodsID,a.ContainerID,a.StoreID,isnull(SUM((NumberPerContainer*case When a.ProcessID in (188,189) then a.EnterKind else  d.EnterKind end )),0) NumberPerContainer
								FROM inv.tblStorageDocsSerials a 
								INNER JOIN inv.tblStorageDocsDtl d ON a.ProcessID = d.ProcessID 
																  AND a.ProcessNo = d.ProcessNo 
																  AND a.FiscalYear = d.FiscalYear 
																  AND a.SerialNo = d.SerialNo 
																  AND a.DocRowNo = d.DocRowNo                     
								WHERE GoodsID = @OldGoodsID 
								  AND ContainerID = @OldContainerID 
								  AND a.StoreID = @OldStoreID
								  AND a.ProductionDate = @OldProductionDate
								  AND a.ExpireDate = @OldExpireDate
								GROUP BY d.GoodsID, a.ContainerID, a.StoreID, a.ProductionDate, a.ExpireDate
								HAVING ISNULL(SUM(ROUND((NumberPerContainer * CASE WHEN a.ProcessID in (188,189) THEN a.EnterKind ELSE d.EnterKind END ),5)),0)<0) > 0
							BEGIN
								--ROlLBACK
								SET @NumberPerContainer = 0
								SELECT @NumberPerContainer = ISNULL(SUM((NumberPerContainer * CASE WHEN a.ProcessID in (188,189) THEN a.EnterKind ELSE d.EnterKind END )),0)  
								FROM inv.tblStorageDocsSerials a 
								INNER JOIN inv.tblStorageDocsDtl d ON a.ProcessID = d.ProcessID 
																  AND a.ProcessNo = d.ProcessNo 
																  AND a.FiscalYear = d.FiscalYear 
																  AND a.SerialNo = d.SerialNo 
																  AND a.DocRowNo = d.DocRowNo                     
								WHERE GoodsID = @OldGoodsID 
								  AND ContainerID = @OldContainerID 
								  AND a.StoreID = @OldStoreID
								  AND a.ProductionDate = @OldProductionDate
								  AND a.ExpireDate = @OldExpireDate
								GROUP BY d.GoodsID, a.ContainerID, a.StoreID, a.ProductionDate, a.ExpireDate
								HAVING ISNULL(SUM(ROUND((NumberPerContainer * CASE WHEN a.ProcessID in (188,189) THEN a.EnterKind ELSE d.EnterKind end ),5)),0) < 0

								CLOSE curStorageSerialsDeleted
								DEALLOCATE curStorageSerialsDeleted
								
								CLOSE curStorageSerialsInserted
								DEALLOCATE curStorageSerialsInserted
								
								SET @StrErr = N'#$ موجودی ظرف های زیر منفی می شود  ' +Char(13)+ ' انبار ' +@OldStoreID +Char(13)+   ' کالای '  +@OldGoodsID+Char(13) + ' ظرف ' +@OldContainerID +Char(13) + ' تعداد '  + str(@NumberPerContainer)    + '   #$'
							RAISERROR (@StrErr, 16, 1)
							END 		
						END 		

				----- Fetch next record
					FETCH NEXT FROM curStorageSerialsInserted INTO @NewStoreID, @NewContainerID, @NewGoodsID, @NewContainerID2, @NewProductionDate, @NewExpireDate	
					END -- WHILE 

				CLOSE curStorageSerialsInserted
				DEALLOCATE curStorageSerialsInserted

				CLOSE curStorageSerialsDeleted
				DEALLOCATE curStorageSerialsDeleted
			
			END TRY

			BEGIN Catch
				DECLARE @StrErrorMessage As NVARCHAR(1024)
				SET @StrErrorMessage = ERROR_MESSAGE() 
				RAISERROR (@StrErrorMessage, 16, 1)
			END Catch
END

GO
