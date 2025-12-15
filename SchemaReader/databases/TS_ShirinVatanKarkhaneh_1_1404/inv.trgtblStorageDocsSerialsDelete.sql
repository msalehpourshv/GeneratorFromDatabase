USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER inv.trgtblStorageDocsSerialsDelete
   ON  inv.tblStorageDocsSerials 
   WITH ENCRYPTION
   AFTER Delete
AS 

BEGIN

	DECLARE 	
     @PSerialNo				VarChar(20) ,
     @StoreID				VarChar(20) ,
	 @GoodsID				VarChar(20) ,
	 @ContainerID			VarChar(20) ,
	 @ProductionDate		VarChar(10) ,
	 @ExpireDate			VarChar(10) ,
	 @NumberPerContainer	FLOAT,
	 @StrErr		NVARCHAR(4000)
	 
	BEGIN TRY
		
		DECLARE curStorageDeleteDocsPSerialNo CURSOR FOR 
		SELECT PSerialNo FROM Deleted a WHERE PSerialNo <> ''
		OPEN curStorageDeleteDocsPSerialNo

		FETCH NEXT FROM curStorageDeleteDocsPSerialNo INTO	@PSerialNo

		WHILE @@FETCH_STATUS = 0
			BEGIN

			IF (SELECT COUNT(*) 
				FROM (SELECT PSerialNo, 
							 SUM(EnterKind) EnterKind, 
							 StoreID 
					  FROM inv.tblStorageDocsSerials 
					  WHERE PSerialNo <> '' 
					    AND PSerialNo <> '0' 
						AND PSerialNo = @PSerialNo
					  GROUP BY PSerialNo, StoreID
					  HAVING SUM(EnterKind)>1 OR SUM(EnterKind)<0
				)a)>0

				BEGIN
					
					CLOSE curStorageDeleteDocsPSerialNo
					DEALLOCATE curStorageDeleteDocsPSerialNo
					
					SET @StrErr = N'#$ موجودی سریال های زیر منفی و یا بیش از 1  می شود  '+Char(13)+  ' سریال ' + @PSerialNo +Char(13) + '   #$'
					RAISERROR (@StrErr, 16, 1)

				END 

				----- Fetch next record
				FETCH NEXT FROM curStorageDeleteDocsPSerialNo INTO	@PSerialNo	
			END

		CLOSE curStorageDeleteDocsPSerialNo
		DEALLOCATE curStorageDeleteDocsPSerialNo


		DECLARE curStorageDeleteDocsSerials CURSOR FOR 
		SELECT a.StoreID,
			   a.ContainerID,
			   GoodsID,
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

		OPEN curStorageDeleteDocsSerials

		FETCH NEXT FROM curStorageDeleteDocsSerials INTO @StoreID, @ContainerID, @GoodsID, @ProductionDate, @ExpireDate

		WHILE @@FETCH_STATUS = 0
			BEGIN

				IF (SELECT  count(*) --d.GoodsID,a.ContainerID,a.StoreID,isnull(SUM((NumberPerContainer*case When a.ProcessID in (188,189) then a.EnterKind else  d.EnterKind end )),0) NumberPerContainer
                    FROM inv.tblStorageDocsSerials a 
                    INNER JOIN inv.tblStorageDocsDtl d ON a.ProcessID = d.ProcessID 
													  AND a.ProcessNo = d.ProcessNo 
													  AND a.FiscalYear = d.FiscalYear 
													  AND a.SerialNo = d.SerialNo 
													  AND a.DocRowNo = d.DocRowNo                     
					WHERE GoodsID = @GoodsID 
					  AND ContainerID = @ContainerID 
					  AND a.StoreID = @StoreID
					  AND a.ProductionDate = @ProductionDate
					  AND a.ExpireDate = @ExpireDate
                    GROUP BY d.GoodsID, a.ContainerID, a.StoreID, a.ProductionDate, a.ExpireDate
                    HAVING ISNULL(SUM(ROUND((NumberPerContainer * CASE WHEN a.ProcessID in (188,189) THEN a.EnterKind ELSE d.EnterKind END ),5)),0)<0) >0
				BEGIN
					--ROlLBACK
					SELECT @NumberPerContainer = ISNULL(SUM((NumberPerContainer * CASE WHEN a.ProcessID in (188,189) THEN a.EnterKind ELSE d.EnterKind END )),0)  
                    FROM inv.tblStorageDocsSerials a 
                    INNER JOIN inv.tblStorageDocsDtl d ON a.ProcessID = d.ProcessID 
													  AND a.ProcessNo = d.ProcessNo 
													  AND a.FiscalYear = d.FiscalYear 
													  AND a.SerialNo = d.SerialNo 
													  AND a.DocRowNo = d.DocRowNo                     
					WHERE GoodsID = @GoodsID 
					  AND ContainerID = @ContainerID 
					  AND a.StoreID = @StoreID
					  AND a.ProductionDate = @ProductionDate
					  AND a.ExpireDate = @ExpireDate
                    GROUP BY d.GoodsID, a.ContainerID, a.StoreID, a.ProductionDate, a.ExpireDate
                    HAVING ISNULL(SUM(ROUND((NumberPerContainer * CASE WHEN a.ProcessID in (188,189) THEN a.EnterKind ELSE d.EnterKind END ),5)),0)<0

					CLOSE curStorageDeleteDocsSerials
					DEALLOCATE curStorageDeleteDocsSerials
					
					SET @StrErr = N'#$ موجودی ظرف های زیر منفی می شود  '+Char(13)+ ' انبار ' +@StoreID+Char(13)+ ' کالای ' +@GoodsID+Char(13)+ ' ظرف ' + @ContainerID +Char(13) + ' تعداد ' + str(@NumberPerContainer) + '   #$'
					RAISERROR (@StrErr, 16, 1)

				END 

				----- Fetch next record
				FETCH NEXT FROM curStorageDeleteDocsSerials INTO @StoreID, @ContainerID, @GoodsID, @ProductionDate, @ExpireDate	
			END

		CLOSE curStorageDeleteDocsSerials
		DEALLOCATE curStorageDeleteDocsSerials

	END TRY

	BEGIN CATCH
		DECLARE @StrErrorMessage As Nvarchar(1024)
		SET @StrErrorMessage = ERROR_MESSAGE() 
		RAISERROR (@StrErrorMessage, 16, 1)
		
	END CATCH
END

GO
