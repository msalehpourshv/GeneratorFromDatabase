USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
 -- =========== TS-QC:OK ========================
 -- Author        : Hadi Sadeghi
 -- Create date   : 99/10/09
 -- Viewed By	 : 
 -- Last Modified : 
 -- Description   : 
 -- =============================================
 Create PROCEDURE [acc].[SpVchDispatchCost]
 	@intVchNo				Int,
 	@intDocStep				TinyInt,
    @strVchDate				Char(10),
 	@intSourceProcessID		SmallInt,
 	@intSourceProcessNo		TinyInt,
 	@intSourceFiscalYear	SmallInt,
 	@intSourceSerialNo		Int,
 	@intMaxRowNo			Int,
 	@intMaxDocRowNo			Int,
 	@SessionNo				Int,
 	@LanguageID				TinyInt
 	WITH ENCRYPTION
 AS
 
 BEGIN
 	-----
 	
 	Declare @strMsgText				NVarChar(2044)
 

 	Declare @BaseSerialNo			INT
 	Declare @CostKind				Tinyint
 	Declare @DriverID				Varchar(20)
 	Declare @VehicleID				Varchar(20)
 	Declare @CostAcntCode			Varchar(20)
 	Declare @DriverCreditAcntCode	Varchar(20)
 	Declare @AcntCode1				Varchar(20)
 	Declare @DriverName				NVarChar(200)
 	Declare @DocDesc				NVarChar(1000)
 	Declare @strRecDesc				NVarChar(1000)
 	Declare @strDescDtl				NVarChar(1000)
 	Declare @strDescDtlRow			NVarChar(1000)
 	Declare @CostAmount				Float
 	Declare @SumCostAmount			Float

	SET @SumCostAmount = 0
	
 	SELECT @BaseSerialNo=CH.BaseSerialNo,@DriverID=CH.DriverID,
 		   @DocDesc = CH.DocDesc,@DriverName = [pub].[funGetDriverName](CH.DriverID,1)
 	FROM trn.tblDispatchCostHdr CH
 	WHERE CH.SerialNo = @intSourceSerialNo AND 
 		  CH.ProcessID = @intSourceProcessID 

 		  
 	SELECT @DriverCreditAcntCode=DriverCreditAcntCode FROM pub.tblDrivers where DriverID=@DriverID

    IF @DriverCreditAcntCode = ''
	BEGIN
		--
		SET @strMsgText=N'کد مساعده راننده در تعریف راننده خالی است'
		Raiserror (@strMsgText,16,1)
		Return
	END

 	SET @strRecDesc = 'سند برگه هزینه های اعزام ' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 
 	
 	
 	Declare	curDispatchCost CURSOR For 
 	SELECT	CostAcntCode,CostAmount,CostKind,DescDtl
 	FROM trn.tblDispatchCostDtl
 	WHERE SerialNo = @intSourceSerialNo AND 
 		  ProcessID = @intSourceProcessID 
 
 	Open  curDispatchCost; 
 		
 	Fetch NEXT From curDispatchCost Into @CostAcntCode,@CostAmount,@CostKind,@strDescDtl
 
 	While (@@Fetch_Status = 0)
 	
 		BEGIN
 			
 			SET @strDescDtlRow = @strRecDesc  + ' به رانندگی ' + @DriverName + ' - '  + @strDescDtl

 			SET @SumCostAmount = @SumCostAmount + @CostAmount
 			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
 			SET @intMaxRowNo = @intMaxRowNo + 1
 
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					 @CostAcntCode,ROUND(@CostAmount,0),0,@strDescDtlRow,@strDescDtl,0 )	
 							
 			Fetch NEXT From curDispatchCost Into @CostAcntCode,@CostAmount,@CostKind,@strDescDtl
 			
 		END
 
 	Close curDispatchCost;
 	Deallocate curDispatchCost; 	
  	
 	SET @strRecDesc = @strRecDesc + ' به رانندگی ' + @DriverName 
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
			 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @DriverCreditAcntCode,0,ROUND(@SumCostAmount,0),@strRecDesc,@DocDesc,0 )	

 END
 
GO
