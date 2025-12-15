USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        :
-- Create date   :
-- Viewed By	 : 
-- Last Modified : 
-- Description   :
-- =============================================
Create FUNCTION [pub].[funLockStatusWithGoods]
(
	-- Add the parameters for the function here
	@ProcessID		Smallint,
	@ProcessNo		Tinyint	,
	@FiscalYear		Smallint ,
	@SerialNo		Int	,
	@DocRowNo		Int	,
	@DocStep		Tinyint,
	@GoodsID		varchar(20)
)
RETURNS VARCHAR(30)
WITH ENCRYPTION

AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result VARCHAR(30)
	DECLARE @LockProcessNo VARCHAR(2)

	SET @Result = ''

	IF @ProcessID = 41
		BEGIN
			Select TOP 1 @Result = SerialNo , @LockProcessNo = ProcessNo
			From trs.tblPayHdr 
			Where	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo
			
			IF @Result = 0
				Return ''
			ELSE
				Return 'SerialNo-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo)) 
	
		END
	IF @ProcessID = 55 OR @ProcessID = 90 OR @ProcessID = 110 OR @ProcessID = 70
		BEGIN
			DECLARE @prd_ChangeQtyAfterRecive as bit
			SET @prd_ChangeQtyAfterRecive='False'
			IF @ProcessID = 70
			BEGIN
				SELECT @prd_ChangeQtyAfterRecive = SettingValue from pub.tblSettings where SettingKey='prd_ChangeQtyAfterRecive'
			END


			IF @prd_ChangeQtyAfterRecive = 'True'
				RETURN ''

			IF @DocStep <= 1	
				BEGIN
								
					Select TOP 1 @Result = DocStep ,@LockProcessNo = ProcessNo
					From [inv].[tblStorageDocsDtl] 
					Where	ProcessID = @ProcessID AND ProcessNo = @ProcessNo AND FiscalYear = @FiscalYear AND 
							SerialNo = @SerialNo AND DocRowNo = @DocRowNo AND DocStep >1
					ORDER BY DocStep Desc
							
					IF @Result < '2'
						BEGIN
							Select TOP 1 @Result = ProcessID , @LockProcessNo = ProcessNo
							From [inv].[tblStorageDocsDtl] 
							Where	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
									BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo AND BaseDocRowNo = @DocRowNo
							ORDER By DocDate Desc,VolumeRowNo Desc
				
							IF @Result = 0
								Return ''
							ELSE
								Return 'ProcessID-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo)) 
						END	
					ELSE
						Return 'DocStep-' +LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo))  
				END
			ELSE			-- Confirm 
				BEGIN
					Select TOP 1 @Result = DocStep ,@LockProcessNo = ProcessNo
					From [inv].[tblStorageDocsDtl] 
					Where	ProcessID = @ProcessID AND ProcessNo = @ProcessNo AND FiscalYear = @FiscalYear AND 
							SerialNo = @SerialNo AND DocRowNo = @DocRowNo AND DocStep >@DocStep
					ORDER BY DocStep Desc
							
					IF @Result > 0
						Return 'DocStep-' +LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo))	

					Select TOP 1 @Result = ProcessID , @LockProcessNo = ProcessNo
					From [inv].[tblStorageDocsDtl] 
					Where	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
							BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo AND BaseDocRowNo = @DocRowNo
					ORDER By DocDate Desc,VolumeRowNo Desc
				
					IF @Result = 0
						Return ''
					ELSE
						Return 'ProcessID-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo)) 
					
				END
		END
		
	ELSE IF @ProcessID = 56	or @ProcessID = 91
	BEGIN
		
		Select TOP 1 @Result = ProcessID , @LockProcessNo = ProcessNo
		From inv.tblStorageDocsDtl
		Where	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
				 BaseSerialNo = @SerialNo AND BaseDocRowNo = @DocRowNo
		ORDER By DocDate Desc,VolumeRowNo Desc
		IF @Result = 0
			begin
				Select TOP 1 @Result = ProcessID , @LockProcessNo = ProcessNo
				From inv.tblStorageDocsHdr
				Where	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
						    BaseSerialNo = @SerialNo 
				ORDER By DocDate Desc
			IF @Result = 0
				begin
					Select TOP 1 @Result = ProcessID , @LockProcessNo = ProcessNo
					From inv.tblStorageDocsHdr
					Where	BaskulSerialNo = @SerialNo 
					and ( (@ProcessID=56 and ProcessID=55)or (@ProcessID=91 and ProcessID=90)) 
					and DocStep>1
					ORDER By DocDate Desc
					IF @Result = 0
						Return ''	
					else
						Return 'ProcessID-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo)) 
			
				end 
			else
				Return 'ProcessID-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo)) 
			
			end 
		ELSE
			Return 'ProcessID-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo)) 
	END	
	ELSE IF @ProcessID = 194
		BEGIN		
			Select TOP 1 @Result = ProcessID , @LockProcessNo = ProcessNo
			From  inv.tblStorageDocsHdr
			Where	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
					 BaseSerialNo = @SerialNo 
			ORDER By DocDate Desc
			IF @Result = 0
				Return ''	
			else
				Return 'ProcessID-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo)) 				
		END		
	ELSE IF @ProcessID = 75	-- Product_Send_Ret
		BEGIN
			Select TOP 1 @Result = ProcessID , @LockProcessNo = ProcessNo
			From inv.tblStorageDocsDtl
			Where	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
					BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo AND BaseDocRowNo = @DocRowNo
			ORDER By DocDate Desc,VolumeRowNo Desc

			IF @Result = 0
				Return ''
			ELSE
				Return 'ProcessID-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo)) 
		END
		
	ELSE IF @ProcessID = 80
	BEGIN
		IF @DocStep = 1	
		BEGIN
			Select TOP 1 @Result = DocStep ,@LockProcessNo = ProcessNo
			From [inv].[tblStorageDocsDtl] 
			Where	ProcessID = @ProcessID AND ProcessNo = @ProcessNo AND FiscalYear = @FiscalYear AND 
					SerialNo = @SerialNo AND DocStep > 1
			ORDER BY DocStep Desc
				
			IF @Result < 2
				Return ''
			ELSE
				Return 'DocStep-' +LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo))  
		END

	END
	ELSE IF @ProcessID = 100	-- Sale Return
		BEGIN
			IF @DocStep = 1	
			BEGIN
				Select TOP 1 @Result = DocStep ,@LockProcessNo = ProcessNo
				From [inv].[tblStorageDocsDtl] 
				Where	ProcessID = @ProcessID AND ProcessNo = @ProcessNo AND FiscalYear = @FiscalYear AND 
						SerialNo = @SerialNo AND DocRowNo = @DocRowNo AND DocStep > 1
				ORDER BY DocStep Desc
				
				IF @Result < 2
					Return ''
				ELSE
					Return 'DocStep-' +LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo))  
			END
		END
		
	ELSE IF @ProcessID = 150	-- Buy Request
		BEGIN
			IF @DocStep = 1	-- Save Request
				BEGIN
					Select TOP 1 @Result = DocStep ,@LockProcessNo = ProcessNo
					From cmr.tblCMRDtl
					Where	ProcessID = @ProcessID AND ProcessNo = @ProcessNo AND FiscalYear = @FiscalYear AND 
							SerialNo = @SerialNo AND DocRowNo = @DocRowNo AND DocStep > 1
					ORDER BY DocStep Desc
			
					IF @Result < 2
						Return ''
					ELSE
						Return 'DocStep-' +LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo))  
				END
			ELSE			-- Confirm Request
				BEGIN
					Select TOP 1 @Result = ProcessID , @LockProcessNo = ProcessNo
					From cmr.tblCMRDtl
					Where	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
							BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo AND BaseDocRowNo = @DocRowNo
					ORDER By DocDate Desc 

					IF @Result > 0
						Return 'ProcessID-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo)) 

					Select TOP 1 @Result = ProcessID , @LockProcessNo = ProcessNo 
					From cmr.tblOrderDtl
					Where	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
							BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo AND BaseDocRowNo = @DocRowNo
					ORDER By DocDate Desc

					IF @Result > 0
						Return 'ProcessID-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo)) 

					Select TOP 1 @Result = ProcessID , @LockProcessNo = ProcessNo 
					From inv.tblInvTempReceiptDtl
					Where	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
							BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo AND BaseDocRowNo = @DocRowNo
					ORDER By DocDate Desc

					IF @Result > 0
						Return 'ProcessID-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo)) 

					Select TOP 1 @Result = ProcessID , @LockProcessNo = ProcessNo 
					From inv.tblStorageDocsDtl
					Where	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
							BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo AND BaseDocRowNo = @DocRowNo
					ORDER By DocDate Desc

					IF @Result = 0
						Return ''
					ELSE
						Return 'ProcessID-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo)) 
					
				END
		END

	ELSE IF @ProcessID = 155	-- BuyRequestCancel
		BEGIN
			Select TOP 1 @Result = ProcessID , @LockProcessNo = ProcessNo  
			From cmr.tblOrderDtl
			Where	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
					BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo AND BaseDocRowNo = @DocRowNo
			ORDER By DocDate Desc

			IF @Result > 0
				Return 'ProcessID-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo)) 

			Select TOP 1 @Result=ProcessID  
			From inv.tblInvTempReceiptDtl
			Where	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
					BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo AND BaseDocRowNo = @DocRowNo
			ORDER By DocDate Desc

			IF @Result = 0
				Return ''
			ELSE
				Return 'ProcessID-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo)) 
		END

	ELSE IF @ProcessID = 160	-- Buy Order
		BEGIN
			IF @DocStep = 1	-- Save Order
				BEGIN
					Select TOP 1 @Result = DocStep ,@LockProcessNo = ProcessNo
					From cmr.tblOrderDtl
					Where	ProcessID = @ProcessID AND ProcessNo = @ProcessNo AND FiscalYear = @FiscalYear AND 
							SerialNo = @SerialNo AND DocRowNo = @DocRowNo AND DocStep > 1
					ORDER BY DocStep Desc
			
				declare  @BuyOrderOneStep BIT
				SET @BuyOrderOneStep = 'False'

			 	SELECT @BuyOrderOneStep = SettingValue
				FROM pub.tblSettings
				WHERE SettingKey = 'BuyOrderOneStep' 

					IF @BuyOrderOneStep = 'True'
						RETURN ''

					IF @Result < 2
						Return ''
					ELSE
						Return 'DocStep-' +LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo))  
				END
			ELSE			-- Confirm Order
				BEGIN

					Select TOP 1 @Result = ProcessID , @LockProcessNo = ProcessNo  
					From cmr.tblOrderDtl
					Where	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
							BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo AND BaseDocRowNo = @DocRowNo
					ORDER By DocDate Desc
		
					IF @Result > 0
						Return 'ProcessID-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo)) 

					Select TOP 1 @Result = ProcessID , @LockProcessNo = ProcessNo
					From inv.tblInvTempReceiptDtl
					Where	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
							BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo AND BaseDocRowNo = @DocRowNo
					ORDER By DocDate Desc

					IF @Result > 0
						Return 'ProcessID-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo)) 
						
					Select TOP 1 @Result = ProcessID , @LockProcessNo = ProcessNo
					From inv.tblStorageDocsDtl
					Where	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
							BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo AND BaseDocRowNo = @DocRowNo
					ORDER By DocDate Desc,VolumeRowNo Desc

					IF @Result = 0
						Return ''
					ELSE
						Return 'ProcessID-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo)) 
				END
		END

	ELSE IF @ProcessID = 165	-- Buy Cancel Order
		BEGIN
			Select TOP 1 @Result = ProcessID , @LockProcessNo = ProcessNo 
			From inv.tblInvTempReceiptDtl
			Where	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
					BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo AND BaseDocRowNo = @DocRowNo
			ORDER By DocDate Desc

			IF @Result > 0
				Return 'ProcessID-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo)) 

			Select TOP 1 @Result = ProcessID , @LockProcessNo = ProcessNo
			From inv.tblStorageDocsDtl
			Where	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
					BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo AND BaseDocRowNo = @DocRowNo
			ORDER By DocDate Desc,VolumeRowNo Desc

			IF @Result = 0
				Return ''
			ELSE
				Return 'ProcessID-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo)) 
		END

	ELSE IF @ProcessID = 170		-- TempReceipt
		BEGIN
			IF @DocStep = 1	-- Save TempReceipt
				BEGIN
					Select TOP 1 @Result = DocStep ,@LockProcessNo = ProcessNo
					From inv.tblInvTempReceiptDtl
					Where	ProcessID = @ProcessID AND ProcessNo = @ProcessNo AND FiscalYear = @FiscalYear AND 
							SerialNo = @SerialNo AND DocRowNo = @DocRowNo AND DocStep > 1
					ORDER BY DocStep Desc
			
					IF @Result < 2
						Return ''
					ELSE
						Return 'DocStep-' +LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo))  
						
				END
			ELSE			-- Confirm TempReceipt
				BEGIN
					Select TOP 1 @Result = ProcessID , @LockProcessNo = ProcessNo
					From inv.tblInvTempReceiptDtl
					Where	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
							BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo AND BaseDocRowNo = @DocRowNo
					ORDER By DocDate Desc

					IF @Result > 0
						Return 'ProcessID-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo)) 

					Select TOP 1 @Result = ProcessID , @LockProcessNo = ProcessNo 
					From inv.tblStorageDocsDtl
					Where	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
							BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo AND BaseDocRowNo = @DocRowNo
					ORDER By DocDate Desc,VolumeRowNo Desc

					IF @Result = 0
						Return ''
					ELSE
						Return 'ProcessID-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo)) 
				END
		END
	ELSE IF @ProcessID = 171		-- TempReceipt
		BEGIN
			IF @DocStep = 1	-- Save TempReceipt
				BEGIN
					Select TOP 1 @Result = DocStep ,@LockProcessNo = ProcessNo
					From inv.tblInvTempReceiptDtl
					Where	ProcessID = @ProcessID AND ProcessNo = @ProcessNo AND FiscalYear = @FiscalYear AND 
							SerialNo = @SerialNo AND DocRowNo = @DocRowNo AND DocStep > 1
					ORDER BY DocStep Desc
			
					IF @Result < 2
						Return ''
					ELSE
						Return 'DocStep-' +LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo))  
						
				END
			ELSE			-- Confirm TempReceipt
				BEGIN
					declare @Qty  float 
					set @Qty=0
					Select TOP 1 @Result = ProcessID , @LockProcessNo = ProcessNo ,@Qty  =SUM(GoodsQuantity)
					From inv.tblInvTempReceiptDtl
					Where	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
							BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo AND BaseDocRowNo = @DocRowNo
					group by ProcessID,ProcessNo
					--ORDER By DocDate Desc

					IF @Result > 0
						Return 'ProcessID-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo)) + '-' + LTRIM(STR(@Qty)) 

					Select TOP 1 @Result = ProcessID , @LockProcessNo = ProcessNo ,@Qty  =SUM(GoodsQuantity)
					From inv.tblStorageDocsDtl
					Where	SourceProcessID = @ProcessID AND SourceProcessNo = @ProcessNo AND 
							SourceFiscalYear = @FiscalYear AND SourceSerialNo = @SerialNo AND SourceDocRowNo = @DocRowNo
					group by ProcessID,ProcessNo							
					--ORDER By DocDate Desc,VolumeRowNo Desc
							

					IF @Result = 0
						Return ''
					ELSE
						Return 'ProcessID-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo)) + '-' + LTRIM(STR(@Qty))
				END
		END

	ELSE IF @ProcessID = 175	-- Cancel TempReceipt
		BEGIN
			Select TOP 1 @Result = ProcessID , @LockProcessNo = ProcessNo 
			From inv.tblStorageDocsDtl
			Where	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
					BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo AND BaseDocRowNo = @DocRowNo
			ORDER By DocDate Desc,VolumeRowNo Desc

			IF @Result = 0
				Return ''
			ELSE
				Return 'ProcessID-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo)) 
		END

	
	ELSE IF @ProcessID = 180	--sale Order
		BEGIN
		DECLARE @GoodsQuantitySO FLOAT
		DECLARE @GoodsQuantityS FLOAT
		DECLARE @GoodsQuantityST FLOAT
		SET @GoodsQuantitySO = 0
		SET @GoodsQuantityST = 0
		SET @GoodsQuantityS = 0
	---Return ----------------------------------------	
		Select  top 1 @GoodsQuantitySO =SerialNo-- Sum(ISNULL(GoodsQuantity,0)) 
		From sal.tblSaleOrderDtl
		Where	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
		BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo AND BaseDocRowNo = @DocRowNo AND GoodsID=@GoodsID
		order by SerialNo Desc 
		IF ISNULL(@GoodsQuantitySO,0)   > 0
			Return 'BaseProcess-180-'  + LTRIM(STR(ISNULL(@GoodsQuantitySO,0)))
	---Return ----------------------------------------	
	---Produce Program ----------------------------------------					
		select @GoodsQuantitySO =isnull(t.SerialNo,0) 
		from pln.tblTaskOrderHdr  t
		inner join  pln.tblProduceOrderDtl p
			on t.BaseProcessID=p.ProcessID and t.BaseProcessNo=p.ProcessNo and t.BaseFiscalYear=p.FiscalYear and t.BaseSerialNo=p.SerialNo and t.ProdDocRowNo =p.DocRowNo 
		inner join sal.tblSaleOrderDtl o
			on p.BaseProcessID=o.ProcessID and p.BaseProcessNo=o.ProcessNo and p.BaseFiscalYear=o.FiscalYear and p.BaseSerialNo=o.SerialNo and p.BaseDocRowNo =o.DocRowNo 
		where o.ProcessID=@ProcessID
			and o.ProcessNo=@ProcessNo
			and o.FiscalYear=@FiscalYear
			and o.SerialNo=@SerialNo
			and o.DocRowNo=@DocRowNo
		IF ISNULL(@GoodsQuantitySO,0)   > 0
			Return 'BaseProcess-610-'  + LTRIM(STR(ISNULL(@GoodsQuantitySO,0)))	
	---Produce Program ----------------------------------------	
	---Transfer ----------------------------------------	
		Select @GoodsQuantityST = Sum(ISNULL(GoodsQuantity,0)) 
		From inv.tblStorageDocsDtl
		Where	ProcessID =120 AND BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
				BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo AND BaseDocRowNo = @DocRowNo AND GoodsID=@GoodsID			
		IF  ISNULL(@GoodsQuantityST,0) > 0
			Return 'BaseProcess-120-'  + LTRIM(STR(ISNULL(@GoodsQuantityST,0)))
	---Transfer ----------------------------------------	
	---Sale ----------------------------------------	
		Select top 1  @GoodsQuantityS = SerialNo--Sum(ISNULL(GoodsQuantity,0)) 
		From inv.tblStorageDocsDtl
		Where	ProcessID =90 AND BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
				BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo AND BaseDocRowNo = @DocRowNo AND GoodsID=@GoodsID	
				order by SerialNo Desc 
		IF  ISNULL(@GoodsQuantityS,0) > 0
			Return 'BaseProcess-90-'  + LTRIM(STR(ISNULL(@GoodsQuantityS,0)))
		ELSE
			Return ''		
		END		
	---Sale ----------------------------------------			
	ELSE IF @ProcessID = 185	-- sale Order Cancel
			BEGIN

				Select TOP 1 @Result = ProcessID , @LockProcessNo = ProcessNo 
				From inv.tblStorageDocsDtl
				Where	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
						BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo AND BaseDocRowNo = @DocRowNo
				ORDER By DocDate Desc,VolumeRowNo Desc

				IF @Result = 0
					Return ''
				ELSE
					Return 'ProcessID-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo)) 
			END

	ELSE IF @ProcessID = 230	--Use Request
		BEGIN
			Select TOP 1 @Result = ProcessID , @LockProcessNo = ProcessNo  
			from 
			(
			 Select ProcessID , ProcessNo  
			From inv.tblStorageDocsDtl
			Where	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
					BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo AND BaseDocRowNo = @DocRowNo
			union all 
			Select ProcessID , ProcessNo  
			From cmr.tblCMRDtl
			Where	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
					BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo AND BaseDocRowNo = @DocRowNo
			
			)aa
			
			IF @Result = 0
				Return ''
			ELSE
				Return 'ProcessID-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo)) 
		END

	ELSE IF @ProcessID = 240	
		BEGIN
			Select TOP 1 @Result = ProcessID , @LockProcessNo = ProcessNo  
			From sal.tblSaleOrderDtl
			Where	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
					BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo AND BaseDocRowNo = @DocRowNo
			ORDER By DocDate Desc
			
			IF @Result <> 0
				Return 'ProcessID-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo)) 

			IF @Result= 0 
			BEGIN
				Select TOP 1 @Result = ProcessID , @LockProcessNo = ProcessNo
				From inv.tblStorageDocsDtl
				Where	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
						BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo AND BaseDocRowNo = @DocRowNo
				ORDER By DocDate Desc,VolumeRowNo Desc

				IF @Result = 0
					Return ''
				ELSE
					Return 'ProcessID-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo)) 	
			END	
		END
	ELSE IF @ProcessID = 250	--Asset Delivery
		BEGIN
			IF @DocStep = 1	
				BEGIN
					-- ==========								
					Select TOP 1 @Result = DocStep ,@LockProcessNo = ProcessNo
					From [inv].[tblStorageDocsDtl] 
					Where	ProcessID = @ProcessID AND ProcessNo = @ProcessNo AND FiscalYear = @FiscalYear AND 
							SerialNo = @SerialNo AND DocRowNo = @DocRowNo AND DocStep > 1
					ORDER BY DocStep Desc
							
					IF @Result < '2'
						Return ''
					ELSE
						Return 'DocStep-' +LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo))  
				END
			ELSE IF @DocStep = 2	
				BEGIN
					-- ==========								
					Select TOP 1 @Result = DocStep ,@LockProcessNo = ProcessNo
					From [inv].[tblStorageDocsDtl] 
					Where	ProcessID = @ProcessID AND ProcessNo = @ProcessNo AND FiscalYear = @FiscalYear AND 
							SerialNo = @SerialNo AND DocRowNo = @DocRowNo AND DocStep > 2
					ORDER BY DocStep Desc
							
					IF @Result < '3'
						Return ''
					ELSE
						Return 'DocStep-' +LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo))  
				END
			ELSE			-- Confirm 
				BEGIN
					-- ==========								
					Select TOP 1 @Result = ProcessID , @LockProcessNo = ProcessNo
					From inv.tblStorageDocsDtl 
					Where	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
							BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo AND BaseDocRowNo = @DocRowNo
					ORDER By DocDate Desc
				
					IF @Result > 0
						Return 'ProcessID-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo)) 
										
					-- ==========								
					Select TOP 1 @Result = ProcessID , @LockProcessNo = ProcessNo
					From ast.tblAssetsDtl 
					Where	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
							BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo AND BaseDocRowNo = @DocRowNo
					ORDER By DocDate Desc
				
					IF @Result = 0
						Return ''
					ELSE
						Return 'ProcessID-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo)) 
				END
		END
		
	ELSE IF @ProcessID = 127	-- درخواست انتقال کالا بین انبارها
		BEGIN
			-- ==========								
			Select TOP 1 @Result = ProcessID , @LockProcessNo = ProcessNo
			From inv.tblStorageDocsDtl
			Where	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
					BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo AND BaseDocRowNo = @DocRowNo
			ORDER By DocDate Desc
		
			IF @Result = 0
				Return ''
			ELSE
				Return 'ProcessID-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo))   
		END
		
	ELSE IF @ProcessID = 255	--Asset Delivery Return
		BEGIN
		IF @DocStep = 1	
			BEGIN
				Select TOP 1 @Result = DocStep ,@LockProcessNo = ProcessNo
				From [inv].[tblStorageDocsDtl] 
				Where	ProcessID = @ProcessID AND ProcessNo = @ProcessNo AND FiscalYear = @FiscalYear AND 
						SerialNo = @SerialNo AND DocRowNo = @DocRowNo AND DocStep > 1
				ORDER BY DocStep Desc
				
				IF @Result < 2
					Return ''
				ELSE
					Return 'DocStep-' +LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo))  
			END
		END
	ELSE IF @ProcessID = 136 OR @ProcessID = 130 OR @ProcessID = 135 OR @ProcessID = 131 	
		BEGIN
			IF @DocStep = 1	
			BEGIN
							
				Select TOP 1 @Result = DocStep ,@LockProcessNo = ProcessNo
				From [inv].[tblStorageDocsDtl] 
				Where	ProcessID = @ProcessID AND ProcessNo = @ProcessNo AND FiscalYear = @FiscalYear AND 
						SerialNo = @SerialNo AND DocRowNo = @DocRowNo AND DocStep > 1
				ORDER BY DocStep Desc
						
				IF @Result < '2'
					Return ''
				ELSE
					Return 'DocStep-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo))  
			END
			ELSE IF Not (@ProcessID <> 130 OR @DocStep = 3) -- Confirm 
			BEGIN
				Select TOP 1 @Result = ProcessID , @LockProcessNo = ProcessNo  
				From inv.tblStorageDocsDtl
				Where	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
						BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo AND BaseDocRowNo = @DocRowNo
				ORDER By DocDate Desc,VolumeRowNo Desc
			
				IF @Result = 0
					Return ''
				ELSE
					Return 'ProcessID-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo)) 
			END
	END
	RETURN @Result

END
GO
