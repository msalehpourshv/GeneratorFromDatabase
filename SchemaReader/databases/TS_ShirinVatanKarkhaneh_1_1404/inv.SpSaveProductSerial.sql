USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [inv].[SpSaveProductSerial]
	@ProductID				Varchar(20),
	@SerialNo				Varchar(30),
	@EnterKind				smallint,
	@BRN					VARCHAR(10)=''
WITH ENCRYPTION
AS
BEGIN

if (SELECT HasSerial FROM inv.tblGoods WHERE GoodsID= @ProductID) ='False'
	SELECT 0
eLSE

	IF @EnterKind = 1
	BEGIN
		IF (SELECT COUNT(*) FROM pln.tblProductSerials WHERE SerialNo = @SerialNo AND ProductID = @ProductID )=0
		BEGIN

			DECLARE @ProductSerialID INT
			SET @ProductSerialID =1
			CREATE TABLE #S ( MPSID  int)
			insert INTO #S
			exec [pln].[SpGetMaxProductSerialID] @BRN

			select @ProductSerialID=MPSID from #S

			INSERT INTO pln.tblProductSerials
			(ProductSerialID,ProductID,SerialNo,SerialPrefix,ColorID) values (@ProductSerialID,@ProductID,@SerialNo,NULL,NULL)
		
			SELECT @ProductSerialID ProductSerialID
		END
		ELSE
			 SELECT TOP 1 ProductSerialID FROM pln.tblProductSerials WITH (NOLOCK) WHERE SerialNo = @SerialNo AND ProductID = @ProductID 

	END
	ELSE 
			 SELECT TOP 1 ProductSerialID FROM pln.tblProductSerials WITH (NOLOCK) WHERE SerialNo = @SerialNo AND ProductID = @ProductID 

END
GO
