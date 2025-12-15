USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem/Hadi Sadeghi
-- Create date   : 1398/03/28
-- Viewed By	 : 
-- Last Modified : 1398/03/28
-- Last Modifier : TakroSystem/Hadi Sadeghi
-- Description   : 
-- =============================================
Create PROCEDURE [pln].[SpCreateProductSerials]
	@ProductID		 Varchar(20) = Null, 
	@SerialPrefix	 Varchar(20) = Null, 
	@ManualPrefix	 Varchar(20) = Null, 
	@FiscalYear		 Int = 93,
	@UserID	         Int = 1,
	@SessionNo		 Int = 1,
	@DocDate		 char(10) = '',
	@DocTime         char(5) = '',
	@ColorID		 Varchar(20) = Null,
	@RegEmpID		 Varchar(20) = Null,	
	@MotorTypeID	 Varchar(20) = Null,
	@SerialStatusID  Varchar(20) = Null,
	@SerialLen		 Int = 16,
	@SerialCount	 Int=1,
	@CompanyName	 varchar(200),
	@BRN			 VARCHAR(10),
	@ExtraParams	 NVarChar(Max) 	
WITH ENCRYPTION
AS 
DECLARE @LanguageID TinyInt;
DECLARE @StrSelect	NVarChar(Max);
DECLARE @StrWhere	NVarChar(Max);
DECLARE @MaxSerialNo DECIMAL(20,0)
declare @ProductSerialID int
DECLARE @Count		Int;
DECLARE @RowNo		Int;
DECLARE	@GoodsID1	Varchar(20) 
DECLARE	@GoodsID2	Varchar(20) 
DECLARE	@GoodsID3	Varchar(20) 
DECLARE	@GoodsID4	Varchar(20) 
DECLARE	@GoodsID5	Varchar(20) 
DECLARE	@GoodsID6	Varchar(20) 
DECLARE	@Property1	NVarchar(100) 
DECLARE	@Property2	NVarchar(100) 
DECLARE @FromSerial VARCHAR(100)
Declare @strMsgText	NVarChar(2044)
DECLARE @PrdSerialsReg TinyInt;
Begin --============== S T A R T  C O D E ===================================================
	--set @SerialLen = 16
	SELECT cast(0 as int) ProductSerialID INTO #ProductSerialID
	IF @ColorID = ''
		SET @ColorID = NULL
		
	IF @MotorTypeID = ''
		SET @MotorTypeID = NULL
	
	SET @PrdSerialsReg = 0
	SET @GoodsID1		= LTrim(pub.funSplitString(@ExtraParams, '@', 10)); 
	SET @GoodsID2		= LTrim(pub.funSplitString(@ExtraParams, '@', 11)); 
	SET @GoodsID3		= LTrim(pub.funSplitString(@ExtraParams, '@', 12)); 
	SET @GoodsID4		= LTrim(pub.funSplitString(@ExtraParams, '@', 13)); 
	SET @GoodsID5		= LTrim(pub.funSplitString(@ExtraParams, '@', 14)); 
	SET @GoodsID6		= LTrim(pub.funSplitString(@ExtraParams, '@', 15)); 
	SET @Property1		= LTrim(pub.funSplitString(@ExtraParams, '@', 16)); 
	SET @Property2		= LTrim(pub.funSplitString(@ExtraParams, '@', 17)); 
	SET @PrdSerialsReg	= LTrim(pub.funSplitString(@ExtraParams, '@', 18)); 

	DECLARE @MProductSerialID INT
	SET @MProductSerialID = 1
	CREATE TABLE #S (MPSID  INT)
	INSERT INTO #S
	EXEC [pln].[SpGetMaxProductSerialID] @BRN

	SELECT @MProductSerialID=MPSID FROM #S


	IF @CompanyName='LuxPen' OR @CompanyName='LuxPen2' 
	BEGIN
		declare @SerialNoLux Varchar(20)  
		declare @CTLux1 Nvarchar(100)
		declare @CTLux2 Nvarchar(100)
		declare @CTLux3 Nvarchar(100)
		declare @CTLux4 Nvarchar(100)

		SET @CTLux1				= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
		SET @CTLux2				= LTrim(pub.funSplitString(@ExtraParams, '@', 3));
		SET @CTLux3				= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
		SET @CTLux4				= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
		SET @FromSerial			= LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
		SEt @SerialNoLux = ''
		if @FromSerial ='0'
			SET @FromSerial = ''

		SET @SerialNoLux		= LTrim(pub.funSplitString(@ExtraParams, '@', 16)); 

		IF @SerialNoLux<>'' AND 
			(SELECT COUNT(*) FROM pln.tblProductSerials 	
			WHERE ProductID = @ProductID AND SerialNo=@SerialNoLux)>0
		BEGIN
			SELECT @SerialNoLux
			RETURN
		END
			
		select @SerialPrefix = @CTLux1 + @CTLux2+@CTLux3+@CTLux4 
			
		SET @SerialLen = 18
		IF (select COUNT(*) from pln.tblSerialPrefixes WHERE SerialPrefix ='') = 0
			INSERT INTO pln.tblSerialPrefixes
			select '',@FiscalYear,'',@SerialLen




		set @Count=0
		WHILE @Count< @SerialCount
		BEGIN
			SET @Count = @Count + 1

			SELECT @ProductSerialID = ISNULL(MAX(ProductSerialID),0)+1 FROM pln.tblProductSerials

			IF @MProductSerialID>@ProductSerialID
				SET @ProductSerialID = @MProductSerialID

			IF @FromSerial = ''
			BEGIN
				SELECT @MaxSerialNo=ISNULL(MAX(SUBSTRING(SerialNo,13,6)),0) 
				FROM pln.tblProductSerials 
				WHERE LEN(SerialNo)=18 --AND ProductID=@ProductID  
			
				SET @MaxSerialNo = @MaxSerialNo+1
			END
			ELSE
				SET @MaxSerialNo = @FromSerial +@Count-1
		
			IF @SerialNoLux=''
				SELECT @SerialNoLux=@SerialPrefix +SUBSTRING(@DocDate,3,2)+ SUBSTRING(@DocDate,6,2)+ [pub].[funPadLeft](LTRIM(STR(@MaxSerialNo)),'0',6)

			INSERT INTO pln.tblProductSerials
			(ProductSerialID, ProductID, SerialPrefix, SerialNo, ColorID, RegDate, RegEmpID, IsPrinted, DocDate, UserID, MotorTypeID, IsPrinted2, IsPrinted3, BaseSerialNo, BaseFiscalYear, BaseProcessID, NumberPerSerial)
			select @ProductSerialID,@ProductID,'',@SerialNoLux,@ColorID,@DocDate,@RegEmpID,'False',@DocDate,@UserID,@MotorTypeID,'False','False',0,0,0,1
				
			SELECT @RowNo = ISNULL(MAX(RowNo),0)+1 from pln.tblProductSerialStatus

			IF @MProductSerialID>@ProductSerialID
				SET @ProductSerialID = @MProductSerialID
		
			INSERT INTO pln.tblProductSerialStatus
			(RowNo, DocDate, DocTime, SessionNo, ProductSerialID, SerialStatusID, IsLocked)
			SELECT @RowNo,@DocDate,@DocTime,@SessionNo,@ProductSerialID,@SerialStatusID,'False'
			
			SET @SerialNoLux=''

			INSERT #ProductSerialID select @ProductSerialID
		END
	END
	ELSE IF @CompanyName = 'BehSoozanAzar' OR @CompanyName = 'BehSoozanAzar2'
	BEGIN
			declare @SerialNoBeh Varchar(20)  
			declare @CTBeh1 Nvarchar(100)
			declare @CTBeh2 Nvarchar(100)
			declare @CTBeh3 Nvarchar(100)
			declare @CTBeh4 Nvarchar(100)
			declare @CTBeh5 Nvarchar(100)
			declare @CTBeh6 Nvarchar(100)

			SET @CTBeh1				= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
			SET @CTBeh2				= LTrim(pub.funSplitString(@ExtraParams, '@', 3));
			SET @CTBeh3				= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
			SET @CTBeh4				= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
			SET @CTBeh5				= LTrim(pub.funSplitString(@ExtraParams, '@', 6)); 
			SET @CTBeh6				= LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 
			SET @FromSerial			= LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
			SEt @SerialNoBeh = ''
			if @FromSerial ='0'
				SET @FromSerial = ''

			SET @SerialNoBeh		= LTrim(pub.funSplitString(@ExtraParams, '@', 16)); 

			IF @SerialNoBeh<>'' AND 
			  (SELECT COUNT(*) FROM pln.tblProductSerials 	
			   WHERE ProductID = @ProductID AND SerialNo=@SerialNoBeh)>0
			BEGIN
				SELECT @SerialNoBeh
				RETURN
			END
			
			 SET @SerialPrefix = SUBSTRING(@DocDate,3,2) +@CTBeh1+@CTBeh2+@CTBeh3
		   
		   		IF @FromSerial<>''AND 
				  (SELECT COUNT(*) 
				   FROM pln.tblProductSerials 	
				   WHERE --ProductID = @ProductID AND 
						@SerialPrefix=SUBSTRING(SerialNo,1,6) AND SUBSTRING(SerialNo,7,5)= [pub].[funPadLeft](@FromSerial,'0',7))>0
				BEGIN
					SET @strMsgText=N'شروع از مقدار که وارد شده قبلا برایش سریال ایجاد شده است'
					Raiserror (@strMsgText,16,1)
					Return
				END

			SET @SerialLen = 11
			IF (select COUNT(*) from pln.tblSerialPrefixes WHERE SerialPrefix =@SerialPrefix) = 0
				INSERT INTO pln.tblSerialPrefixes
				select @SerialPrefix,@FiscalYear,@ProductID,@SerialLen

			set @Count=0
	
			WHILE @Count< @SerialCount
			BEGIN
				SET @Count = @Count + 1

				IF @FromSerial=''
				BEGIN
					SELECT @MaxSerialNo=ISNULL(MAX(SUBSTRING(SerialNo,7,@SerialLen)),0) 
					FROM pln.tblProductSerials 
					WHERE SUBSTRING(SerialNo,1,6) =@SerialPrefix AND  LEN(SerialNo)=@SerialLen-- = @SerialPrefix
					SET @MaxSerialNo = @MaxSerialNo+1
				END		
				ELSE
				BEGIN
					IF @Count>1
						SET @FromSerial = @FromSerial + 1

					SET @MaxSerialNo = @FromSerial
			
					Declare @ExistBeh bit='True'
					WHILE @ExistBeh='True'
					BEGIN
						IF (SELECT COUNT(*) 
							FROM pln.tblProductSerials 	
							WHERE ProductID = @ProductID AND SerialNo=@SerialPrefix + [pub].[funPadLeft](@FromSerial,'0',5))>0
	
							SET @FromSerial = @FromSerial + 1
						ELSE
						BEGIN
							SET @MaxSerialNo = @FromSerial
							SET @ExistBeh='False'
						END
					END

				END
		
				SELECT @ProductSerialID = ISNULL(MAX(ProductSerialID),0)+1 FROM pln.tblProductSerials

				IF @MProductSerialID>@ProductSerialID
					SET @ProductSerialID = @MProductSerialID
		
				IF @SerialNoBeh=''
					SELECT @SerialNoBeh=@SerialPrefix + [pub].[funPadLeft](@MaxSerialNo,'0',5)

				INSERT INTO pln.tblProductSerials
				(ProductSerialID, ProductID, SerialPrefix, SerialNo, ColorID, RegDate, RegEmpID, IsPrinted, DocDate, UserID, MotorTypeID, IsPrinted2, IsPrinted3, BaseSerialNo, BaseFiscalYear, BaseProcessID, NumberPerSerial)
				select @ProductSerialID,@ProductID,@SerialPrefix,@SerialNoBeh,@ColorID,@DocDate,@RegEmpID,'False',@DocDate,@UserID,@MotorTypeID,'False','False',0,0,0,1
				
				SELECT @RowNo = ISNULL(MAX(RowNo),0)+1 from pln.tblProductSerialStatus

				IF @MProductSerialID>@ProductSerialID
					SET @ProductSerialID = @MProductSerialID
		
				INSERT INTO pln.tblProductSerialStatus
				(RowNo, DocDate, DocTime, SessionNo, ProductSerialID, SerialStatusID, IsLocked)
				SELECT @RowNo,@DocDate,@DocTime,@SessionNo,@ProductSerialID,@SerialStatusID,'False'
			
				SET @SerialNoBeh=''

				INSERT #ProductSerialID select @ProductSerialID
		END
	END
	ELSE IF @CompanyName = 'DornaSahar' OR @CompanyName = 'DornaSahar2' 
	BEGIN
		SET @SerialPrefix = @SerialPrefix --+ SUBSTRING(@DocDate,9,2)
		IF (select COUNT(*) from pln.tblSerialPrefixes WHERE SerialPrefix =@ManualPrefix) = 0
			INSERT INTO pln.tblSerialPrefixes
			select @ManualPrefix,@FiscalYear,@ProductID,@SerialLen
			
		set @Count=0
	
		WHILE @Count< @SerialCount
		BEGIN
			SET @Count = @Count + 1
		
			SELECT @MaxSerialNo=ISNULL(MAX(SUBSTRING(SerialNo,LEN(@ManualPrefix)+1,@SerialLen)),0) 
			from pln.tblProductSerials
			where LEN(SerialNo)=@SerialLen AND LEFT(SerialNo,LEN(@ManualPrefix)) =@ManualPrefix
		
			SET @MaxSerialNo = @MaxSerialNo+1
		
			SELECT @ProductSerialID = ISNULL(MAX(ProductSerialID),0)+1 	FROM pln.tblProductSerials

			IF @MProductSerialID>@ProductSerialID
				SET @ProductSerialID = @MProductSerialID

			INSERT INTO pln.tblProductSerials
			(ProductSerialID, ProductID, SerialPrefix, SerialNo, ColorID, RegDate, RegEmpID, IsPrinted, DocDate, UserID, MotorTypeID, IsPrinted2, IsPrinted3, BaseSerialNo, BaseFiscalYear, BaseProcessID, NumberPerSerial,GoodsID1,GoodsID2,GoodsID3,GoodsID4,GoodsID5,GoodsID6,Property1,Property2)
			select @ProductSerialID,@ProductID,@ManualPrefix,@ManualPrefix + [pub].[funPadLeft](@MaxSerialNo,'0',@SerialLen-LEN(@ManualPrefix)),@ColorID,@DocDate,@RegEmpID,'False',@DocDate,@UserID,@MotorTypeID,'False','False',0,0,0,1,@GoodsID1,@GoodsID2,@GoodsID3,@GoodsID4,@GoodsID5,@GoodsID6,@Property1,@Property2
		
		
			SELECT @RowNo = ISNULL(MAX(RowNo),0)+1 from pln.tblProductSerialStatus
		
			INSERT INTO pln.tblProductSerialStatus
			(RowNo, DocDate, DocTime, SessionNo, ProductSerialID, SerialStatusID, IsLocked)
			SELECT @RowNo,@DocDate,@DocTime,@SessionNo,@ProductSerialID,@SerialStatusID,'False'
		
			INSERT #ProductSerialID select @ProductSerialID
		END
	
	END
	ELSE IF @CompanyName = 'AzarFarasoyeSahar' OR  @CompanyName = 'AzarFarasoyeSahand12'  OR  @CompanyName = 'AzarFarasoyeSahand21'  OR  @CompanyName = 'AzarFarasoyeSahand2' 
	BEGIN
		SET @SerialPrefix = @SerialPrefix --+ SUBSTRING(@DocDate,9,2)
		IF (select COUNT(*) from pln.tblSerialPrefixes WHERE SerialPrefix =@SerialPrefix) = 0
			INSERT INTO pln.tblSerialPrefixes
			select @SerialPrefix,@FiscalYear,@ProductID,@SerialLen
			
		set @Count=0
	
		WHILE @Count< @SerialCount
		BEGIN
			SET @Count = @Count + 1
		
			SELECT @MaxSerialNo=ISNULL(MAX(SUBSTRING(SerialNo,LEN(@SerialPrefix)+1,@SerialLen)),0) 
			from pln.tblProductSerials
			where LEN(SerialNo)=@SerialLen AND LEFT(SerialNo,LEN(@SerialPrefix)-2) =LEFT(@SerialPrefix,LEN(@SerialPrefix)-2)
		
			SET @MaxSerialNo = @MaxSerialNo+1
		
			SELECT @ProductSerialID = ISNULL(MAX(ProductSerialID),0)+1 	FROM pln.tblProductSerials

			IF @MProductSerialID>@ProductSerialID
				SET @ProductSerialID = @MProductSerialID

			INSERT INTO pln.tblProductSerials
			(ProductSerialID, ProductID, SerialPrefix, SerialNo, ColorID, RegDate, RegEmpID, IsPrinted, DocDate, UserID, MotorTypeID, IsPrinted2, IsPrinted3, BaseSerialNo, BaseFiscalYear, BaseProcessID, NumberPerSerial,GoodsID1,GoodsID2,GoodsID3,GoodsID4,GoodsID5,GoodsID6,Property1,Property2)
			select @ProductSerialID,@ProductID,@SerialPrefix,@SerialPrefix + [pub].[funPadLeft](@MaxSerialNo,'0',@SerialLen-LEN(@SerialPrefix)),@ColorID,@DocDate,@RegEmpID,'False',@DocDate,@UserID,@MotorTypeID,'False','False',0,0,0,1,@GoodsID1,@GoodsID2,@GoodsID3,@GoodsID4,@GoodsID5,@GoodsID6,@Property1,@Property2
		
			SELECT @RowNo = ISNULL(MAX(RowNo),0)+1 from pln.tblProductSerialStatus
		
			INSERT INTO pln.tblProductSerialStatus
			(RowNo, DocDate, DocTime, SessionNo, ProductSerialID, SerialStatusID, IsLocked)
			SELECT @RowNo,@DocDate,@DocTime,@SessionNo,@ProductSerialID,@SerialStatusID,'False'
		
			INSERT #ProductSerialID select @ProductSerialID
		END
	
	END
		ELSE IF @CompanyName = 'PardisKhazar'
	BEGIN
		SET @SerialPrefix = @SerialPrefix + SUBSTRING(@DocDate,9,2)
		IF (select COUNT(*) from pln.tblSerialPrefixes WHERE SerialPrefix =@SerialPrefix) = 0
			INSERT INTO pln.tblSerialPrefixes
			select @SerialPrefix,@FiscalYear,@ProductID,@SerialLen
			
		set @Count=0
	
		WHILE @Count< @SerialCount
		BEGIN
			SET @Count = @Count + 1
		
			SELECT @MaxSerialNo=ISNULL(MAX(SUBSTRING(SerialNo,LEN(@SerialPrefix)+1,@SerialLen)),0) 
			from pln.tblProductSerials
			where LEN(SerialNo)=@SerialLen AND LEFT(SerialNo,LEN(@SerialPrefix)-2) =LEFT(@SerialPrefix,LEN(@SerialPrefix)-2)
		
			SET @MaxSerialNo = @MaxSerialNo+1
		
			SELECT @ProductSerialID = ISNULL(MAX(ProductSerialID),0)+1 	FROM pln.tblProductSerials

			IF @MProductSerialID>@ProductSerialID
				SET @ProductSerialID = @MProductSerialID

			INSERT INTO pln.tblProductSerials
			(ProductSerialID, ProductID, SerialPrefix, SerialNo, ColorID, RegDate, RegEmpID, IsPrinted, DocDate, UserID, MotorTypeID, IsPrinted2, IsPrinted3, BaseSerialNo, BaseFiscalYear, BaseProcessID, NumberPerSerial,GoodsID1,GoodsID2,GoodsID3,GoodsID4,GoodsID5,GoodsID6,Property1,Property2)
			select @ProductSerialID,@ProductID,@SerialPrefix,@SerialPrefix + [pub].[funPadLeft](@MaxSerialNo,'0',@SerialLen-LEN(@SerialPrefix)),@ColorID,@DocDate,@RegEmpID,'False',@DocDate,@UserID,@MotorTypeID,'False','False',0,0,0,1,@GoodsID1,@GoodsID2,@GoodsID3,@GoodsID4,@GoodsID5,@GoodsID6,@Property1,@Property2
		
			SELECT @RowNo = ISNULL(MAX(RowNo),0)+1 from pln.tblProductSerialStatus
		
			INSERT INTO pln.tblProductSerialStatus
			(RowNo, DocDate, DocTime, SessionNo, ProductSerialID, SerialStatusID, IsLocked)
			SELECT @RowNo,@DocDate,@DocTime,@SessionNo,@ProductSerialID,@SerialStatusID,'False'
		
			INSERT #ProductSerialID select @ProductSerialID
		END
	
	END
	ELSE IF @CompanyName = 'ElectroHouse' 
	BEGIN
		SET @SerialPrefix = @SerialPrefix + SUBSTRING(@DocDate,9,2)
		IF (select COUNT(*) from pln.tblSerialPrefixes WHERE SerialPrefix =@SerialPrefix) = 0
			INSERT INTO pln.tblSerialPrefixes
			select @SerialPrefix,@FiscalYear,@ProductID,@SerialLen
			
		set @Count=0
	
		WHILE @Count< @SerialCount
		BEGIN
			SET @Count = @Count + 1
		
			SELECT @MaxSerialNo=ISNULL(MAX(SUBSTRING(SerialNo,LEN(@SerialPrefix)+1,@SerialLen)),0) 
			from pln.tblProductSerials
			where LEN(SerialNo)=@SerialLen AND SUBSTRING(SerialNo,LEN(@SerialPrefix)-6+1,6) =SUBSTRING(@SerialPrefix,LEN(@SerialPrefix)-6+1,6) 
		
			SET @MaxSerialNo = @MaxSerialNo+1
		
			SELECT @ProductSerialID = ISNULL(MAX(ProductSerialID),0)+1 	FROM pln.tblProductSerials

			IF @MProductSerialID>@ProductSerialID
				SET @ProductSerialID = @MProductSerialID
		
			INSERT INTO pln.tblProductSerials
			(ProductSerialID, ProductID, SerialPrefix, SerialNo, ColorID, RegDate, RegEmpID, IsPrinted, DocDate, UserID, MotorTypeID, IsPrinted2, IsPrinted3, BaseSerialNo, BaseFiscalYear, BaseProcessID, NumberPerSerial,GoodsID1,GoodsID2,GoodsID3,GoodsID4,GoodsID5,GoodsID6,Property1,Property2)
			select @ProductSerialID,@ProductID,@SerialPrefix,@SerialPrefix + [pub].[funPadLeft](@MaxSerialNo,'0',@SerialLen-LEN(@SerialPrefix)),@ColorID,@DocDate,@RegEmpID,'False',@DocDate,@UserID,@MotorTypeID,'False','False',0,0,0,1,@GoodsID1,@GoodsID2,@GoodsID3,@GoodsID4,@GoodsID5,@GoodsID6,@Property1,@Property2
		
		
			SELECT @RowNo = ISNULL(MAX(RowNo),0)+1 from pln.tblProductSerialStatus
		
			INSERT INTO pln.tblProductSerialStatus
			(RowNo, DocDate, DocTime, SessionNo, ProductSerialID, SerialStatusID, IsLocked)
			SELECT @RowNo,@DocDate,@DocTime,@SessionNo,@ProductSerialID,@SerialStatusID,'False'
		
			INSERT #ProductSerialID select @ProductSerialID
		END
	
	END
	ELSE IF @CompanyName = 'Mahtab' 
	BEGIN
		SET @FromSerial				= LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
		if @FromSerial ='0'
			SET @FromSerial = ''
		IF 	@FromSerial<>'' AND LEN(@FromSerial)>=LEN(@SerialPrefix)
			SET @SerialPrefix = SUBSTRING(@FromSerial,0,LEN(@SerialPrefix))
			
		IF (select COUNT(*) from pln.tblSerialPrefixes WHERE SerialPrefix =@SerialPrefix) = 0
			INSERT INTO pln.tblSerialPrefixes
			select @SerialPrefix,@FiscalYear,@ProductID,@SerialLen
			
		set @Count=0
	
		WHILE @Count< @SerialCount
		BEGIN
					
			SELECT @ProductSerialID = ISNULL(MAX(ProductSerialID),0)+1 	FROM pln.tblProductSerials

			IF @MProductSerialID>@ProductSerialID
				SET @ProductSerialID = @MProductSerialID
				
			SET @Count = @Count + 1
			
			IF @FromSerial=''
			BEGIN
				SELECT @MaxSerialNo=ISNULL(MAX(SUBSTRING(SerialNo,LEN(@SerialPrefix)+1,@SerialLen)),0) 
				from pln.tblProductSerials
				where LEN(SerialNo)=@SerialLen AND SUBSTRING(SerialNo,LEN(@SerialPrefix)-4+1,2) =SUBSTRING(@SerialPrefix,LEN(@SerialPrefix)-4+1,2) 
			
				SET @MaxSerialNo = @MaxSerialNo+1

				INSERT INTO pln.tblProductSerials
				(ProductSerialID, ProductID, SerialPrefix, SerialNo, ColorID, RegDate, RegEmpID, IsPrinted, DocDate, UserID, MotorTypeID, IsPrinted2, IsPrinted3, BaseSerialNo, BaseFiscalYear, BaseProcessID, NumberPerSerial,GoodsID1,GoodsID2,GoodsID3,GoodsID4,GoodsID5,GoodsID6,Property1,Property2)
				SELECT @ProductSerialID,@ProductID,@SerialPrefix,@SerialPrefix + [pub].[funPadLeft](@MaxSerialNo,'0',@SerialLen-LEN(@SerialPrefix)),@ColorID,@DocDate,@RegEmpID,'False',@DocDate,@UserID,@MotorTypeID,'False','False',0,0,0,1,@GoodsID1,@GoodsID2,@GoodsID3,@GoodsID4,@GoodsID5,@GoodsID6,@Property1,@Property2

			END
			ELSE
			BEGIN
				DECLARE @Flag bit='False'
				WHILE @Flag='False'
				BEGIN
					IF (SELECT COUNT(*) from pln.tblProductSerials where SerialNo=@FromSerial)=0
						SET @Flag='True'
					ELSE
						SET @FromSerial = @SerialPrefix + CAST((SUBSTRING(@FromSerial,LEN(@SerialPrefix)+1,20)+1) as VARCHAR(20))
				END

				INSERT INTO pln.tblProductSerials
				(ProductSerialID, ProductID, SerialPrefix, SerialNo, ColorID, RegDate, RegEmpID, IsPrinted, DocDate, UserID, MotorTypeID, IsPrinted2, IsPrinted3, BaseSerialNo, BaseFiscalYear, BaseProcessID, NumberPerSerial,GoodsID1,GoodsID2,GoodsID3,GoodsID4,GoodsID5,GoodsID6,Property1,Property2)
				SELECT @ProductSerialID,@ProductID,@SerialPrefix,@FromSerial,@ColorID,@DocDate,@RegEmpID,'False',@DocDate,@UserID,@MotorTypeID,'False','False',0,0,0,1,@GoodsID1,@GoodsID2,@GoodsID3,@GoodsID4,@GoodsID5,@GoodsID6,@Property1,@Property2
				
			END
		
		
			SELECT @RowNo = ISNULL(MAX(RowNo),0)+1 from pln.tblProductSerialStatus
		
			INSERT INTO pln.tblProductSerialStatus
			(RowNo, DocDate, DocTime, SessionNo, ProductSerialID, SerialStatusID, IsLocked)
			SELECT @RowNo,@DocDate,@DocTime,@SessionNo,@ProductSerialID,@SerialStatusID,'False'
		
			INSERT #ProductSerialID select @ProductSerialID
		END
	
	END
	ELSE IF @CompanyName = 'Donar'
	BEGIN
		SET @SerialPrefix = SUBSTRING(@DocDate,3,2) + SUBSTRING(@ProductID,8,5)

		IF (select COUNT(*) from pln.tblSerialPrefixes WHERE SerialPrefix =@SerialPrefix) = 0
			INSERT INTO pln.tblSerialPrefixes
			select @SerialPrefix,@FiscalYear,@ProductID,@SerialLen

		set @Count=0
	
		WHILE @Count< @SerialCount
		BEGIN
			SET @Count = @Count + 1
		
			SELECT @MaxSerialNo=ISNULL(MAX(SUBSTRING(SerialNo,LEN(@SerialPrefix)+1,@SerialLen)),0) 
			FROM pln.tblProductSerials 
			WHERE LEN(SerialNo)=@SerialLen AND SerialPrefix = @SerialPrefix
		
			SET @MaxSerialNo = @MaxSerialNo+1
		
			SELECT @ProductSerialID = ISNULL(MAX(ProductSerialID),0)+1 FROM pln.tblProductSerials

			IF @MProductSerialID>@ProductSerialID
				SET @ProductSerialID = @MProductSerialID
		
			INSERT INTO pln.tblProductSerials
			(ProductSerialID, ProductID, SerialPrefix, SerialNo, ColorID, RegDate, RegEmpID, IsPrinted, DocDate, UserID, MotorTypeID, IsPrinted2, IsPrinted3, BaseSerialNo, BaseFiscalYear, BaseProcessID, NumberPerSerial,GoodsID1,GoodsID2,GoodsID3,GoodsID4,GoodsID5,GoodsID6,Property1,Property2)
			select @ProductSerialID,@ProductID,@SerialPrefix,@SerialPrefix + [pub].[funPadLeft](@MaxSerialNo,'0',5),@ColorID,@DocDate,@RegEmpID,'False',@DocDate,@UserID,@MotorTypeID,'False','False',0,0,0,1,@GoodsID1,@GoodsID2,@GoodsID3,@GoodsID4,@GoodsID5,@GoodsID6,@Property1,@Property2
				
			SELECT @RowNo = ISNULL(MAX(RowNo),0)+1 from pln.tblProductSerialStatus
		
			INSERT INTO pln.tblProductSerialStatus
			(RowNo, DocDate, DocTime, SessionNo, ProductSerialID, SerialStatusID, IsLocked)
			SELECT @RowNo,@DocDate,@DocTime,@SessionNo,@ProductSerialID,@SerialStatusID,'False'
		
			INSERT #ProductSerialID select @ProductSerialID
		END
	END
	ELSE IF @CompanyName = 'Ghaynar'
	BEGIN
		SET @SerialPrefix = @ManualPrefix

		IF (select COUNT(*) from pln.tblSerialPrefixes WHERE SerialPrefix =@SerialPrefix) = 0
			INSERT INTO pln.tblSerialPrefixes
			select @SerialPrefix,@FiscalYear,@ProductID,@SerialLen
			
			declare @CTG11 Nvarchar(100)
			declare @LenSerial tinyint
			
			SET @CTG11				= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
			set @LenSerial= @SerialLen - LEN(@SerialPrefix) - LEN(@CTG11)
			set @Count=0

	
		WHILE @Count< @SerialCount
		BEGIN
			SET @Count = @Count + 1
		
			SELECT @MaxSerialNo=ISNULL(MAX(SUBSTRING(SerialNo,LEN(@SerialPrefix+ @CTG11)+1,@SerialLen)),0) 
			FROM pln.tblProductSerials 
			WHERE LEN(SerialNo)=@SerialLen AND SerialPrefix = @SerialPrefix AND SUBSTRING(SerialNo,1,LEN(@SerialPrefix+ @CTG11)) = @SerialPrefix+ @CTG11
		
			SET @MaxSerialNo = @MaxSerialNo+1
		
			SELECT @ProductSerialID = ISNULL(MAX(ProductSerialID),0)+1 FROM pln.tblProductSerials

			IF @MProductSerialID>@ProductSerialID
				SET @ProductSerialID = @MProductSerialID
		
			INSERT INTO pln.tblProductSerials
			(ProductSerialID, ProductID, SerialPrefix, SerialNo, ColorID, RegDate, RegEmpID, IsPrinted, DocDate, UserID, MotorTypeID, IsPrinted2, IsPrinted3, BaseSerialNo, BaseFiscalYear, BaseProcessID, NumberPerSerial,GoodsID1,GoodsID2,GoodsID3,GoodsID4,GoodsID5,GoodsID6,Property1,Property2)
			select @ProductSerialID,@ProductID,@SerialPrefix,@SerialPrefix + @CTG11 + [pub].[funPadLeft](@MaxSerialNo,'0',@LenSerial),@ColorID,@DocDate,@RegEmpID,'False',@DocDate,@UserID,@MotorTypeID,'False','False',0,0,0,1,@GoodsID1,@GoodsID2,@GoodsID3,@GoodsID4,@GoodsID5,@GoodsID6,@Property1,@Property2
				
			SELECT @RowNo = ISNULL(MAX(RowNo),0)+1 from pln.tblProductSerialStatus
		
			INSERT INTO pln.tblProductSerialStatus
			(RowNo, DocDate, DocTime, SessionNo, ProductSerialID, SerialStatusID, IsLocked)
			SELECT @RowNo,@DocDate,@DocTime,@SessionNo,@ProductSerialID,@SerialStatusID,'False'
		
			INSERT #ProductSerialID select @ProductSerialID
		END
	END
	ELSE IF @CompanyName = 'Koohsar'
	BEGIN
		SET @SerialPrefix = [pub].[funPadLeft](SUBSTRING(@ProductID,3,12),'0',12)+ SUBSTRING(@DocDate,3,2)+ SUBSTRING(@DocDate,6,2)+ SUBSTRING(@DocDate,9,2)

		SELECT @MaxSerialNo=ISNULL(MAX(SUBSTRING(SerialNo,19,2)),0) 
		FROM pln.tblProductSerials 
		WHERE LEN(SerialNo)=20  AND SUBSTRING(SerialNo,1,18) = @SerialPrefix

		IF @MaxSerialNo+@SerialCount>99
			BEGIN
				SET @strMsgText=N'این تعداد سریال برای این محصول در این تاریخ از 99 عدد بیشتر می شود و قابل تولید نیست'
				Raiserror (@strMsgText,16,1)
				Return
			END

		IF (select COUNT(*) from pln.tblSerialPrefixes WHERE SerialPrefix =@ProductID) = 0
			INSERT INTO pln.tblSerialPrefixes
			select @ProductID,@FiscalYear,@ProductID,20

		set @Count=0
	
		WHILE @Count< @SerialCount
		BEGIN
			SET @Count = @Count + 1
			SET @MaxSerialNo = @MaxSerialNo+1
		
			SELECT @ProductSerialID = ISNULL(MAX(ProductSerialID),0)+1 FROM pln.tblProductSerials

			IF @MProductSerialID>@ProductSerialID
				SET @ProductSerialID = @MProductSerialID
		
			INSERT INTO pln.tblProductSerials
			(ProductSerialID, ProductID, SerialPrefix, SerialNo, ColorID, RegDate, RegEmpID, IsPrinted, DocDate, UserID, MotorTypeID, IsPrinted2, IsPrinted3, BaseSerialNo, BaseFiscalYear, BaseProcessID, NumberPerSerial,GoodsID1,GoodsID2,GoodsID3,GoodsID4,GoodsID5,GoodsID6,Property1,Property2)
			select @ProductSerialID,@ProductID,@ProductID,@SerialPrefix + [pub].[funPadLeft](@MaxSerialNo,'0',2),@ColorID,@DocDate,@RegEmpID,'False',@DocDate,@UserID,@MotorTypeID,'False','False',0,0,0,1,@GoodsID1,@GoodsID2,@GoodsID3,@GoodsID4,@GoodsID5,@GoodsID6,@Property1,@Property2
				
			SELECT @RowNo = ISNULL(MAX(RowNo),0)+1 from pln.tblProductSerialStatus
		
			INSERT INTO pln.tblProductSerialStatus
			(RowNo, DocDate, DocTime, SessionNo, ProductSerialID, SerialStatusID, IsLocked)
			SELECT @RowNo,@DocDate,@DocTime,@SessionNo,@ProductSerialID,@SerialStatusID,'False'
		
			INSERT #ProductSerialID select @ProductSerialID
		END

	END
	ELSE IF @CompanyName = 'AzarBatri'
	BEGIN
	if @DocDate > '1444/01/00'
		BEGIN

			declare @SerialNoA Varchar(20)  
			declare @CTA1 Nvarchar(100)
			declare @CTA2 Nvarchar(100)
			declare @CTA3 Nvarchar(100)
			declare @CTA4 Nvarchar(100)

			SET @CTA1				= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
			SET @CTA2				= LTrim(pub.funSplitString(@ExtraParams, '@', 3));
			SET @CTA3				= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
			SET @CTA4				= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
			SET @FromSerial			= LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
			SEt @SerialNoA = ''
			if @FromSerial ='0'
				SET @FromSerial = ''

			SET @SerialNoA		= LTrim(pub.funSplitString(@ExtraParams, '@', 16)); 

			IF @SerialNoA<>'' AND 
			  (SELECT COUNT(*) FROM pln.tblProductSerials 	
			   WHERE ProductID = @ProductID AND SerialNo=@SerialNoA)>0
			BEGIN
				SELECT @SerialNoA
				RETURN
			END
			
			select @SerialPrefix = char(65+LEFT(@DocDate,4)-1403) + SUBSTRING(@DocDate,9,1)+ char(64+cast(SUBSTRING(@DocDate,6,2) as int))+ SUBSTRING(@DocDate,10,1)+@CTA3+@CTA1+@CTA2+@CTA4 +'-'
			
			SET @SerialLen = 19
			IF (select COUNT(*) from pln.tblSerialPrefixes WHERE SerialPrefix ='') = 0
				INSERT INTO pln.tblSerialPrefixes
				select '',@FiscalYear,@ProductID,@SerialLen

			set @Count=0
	
			WHILE @Count< @SerialCount
			BEGIN
				SET @Count = @Count + 1

				SELECT @ProductSerialID = ISNULL(MAX(ProductSerialID),0)+1 FROM pln.tblProductSerials

				IF @MProductSerialID>@ProductSerialID
					SET @ProductSerialID = @MProductSerialID
		
				IF @SerialNoA=''
					SELECT @SerialNoA=@SerialPrefix + [pub].[funPadLeft](LTRIM(STR(FLOOR(RAND()*(10000000-100000+1)+100000))),'0',7)

				INSERT INTO pln.tblProductSerials
				(ProductSerialID, ProductID, SerialPrefix, SerialNo, ColorID, RegDate, RegEmpID, IsPrinted, DocDate, UserID, MotorTypeID, IsPrinted2, IsPrinted3, BaseSerialNo, BaseFiscalYear, BaseProcessID, NumberPerSerial)
				select @ProductSerialID,@ProductID,'',@SerialNoA,@ColorID,@DocDate,@RegEmpID,'False',@DocDate,@UserID,@MotorTypeID,'False','False',0,0,0,1
				
				SELECT @RowNo = ISNULL(MAX(RowNo),0)+1 from pln.tblProductSerialStatus

				IF @MProductSerialID>@ProductSerialID
					SET @ProductSerialID = @MProductSerialID
		
				INSERT INTO pln.tblProductSerialStatus
				(RowNo, DocDate, DocTime, SessionNo, ProductSerialID, SerialStatusID, IsLocked)
				SELECT @RowNo,@DocDate,@DocTime,@SessionNo,@ProductSerialID,@SerialStatusID,'False'
			
				SET @SerialNoA=''

				INSERT #ProductSerialID select @ProductSerialID
			END
		END
	ELSE if @DocDate > '1404/05/31'
		BEGIN
			declare @BchNo Varchar(20)  
			declare @SrlNo Varchar(20)  
			declare @CTAB1 Nvarchar(100)
			declare @CTAB2 Nvarchar(100)
			declare @CTAB3 Nvarchar(100)
			declare @CTAB4 Nvarchar(100)
			declare @CTAB5 Nvarchar(100)
			declare @CTAB6 Nvarchar(100)

			--SET @BatchNo			= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
			SET @CTAB1				= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
			SET @CTAB2				= LTrim(pub.funSplitString(@ExtraParams, '@', 3));
			SET @CTAB3				= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
			SET @CTAB4				= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
			--SET @CT5				= LTrim(pub.funSplitString(@ExtraParams, '@', 6)); 
			--SET @CT6				= LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 
			SET @FromSerial			= LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
			SEt @SrlNo = ''
			if @FromSerial ='0'
				SET @FromSerial = ''

			SET @SrlNo		= LTrim(pub.funSplitString(@ExtraParams, '@', 16)); 

			IF @SrlNo<>'' AND 
			  (SELECT COUNT(*) FROM pln.tblProductSerials 	
			   WHERE ProductID = @ProductID AND SerialNo=@SrlNo)>0
			BEGIN
				SELECT @SrlNo
				RETURN
			END
			
			 SET @SerialPrefix = SUBSTRING(@DocDate,3,2) +@CTAB1+@CTAB2+@CTAB3 +[pub].[funPadLeft](pub.funFarsiDateDiff('Day',SUBSTRING(@DocDate,1,4)+'/01/01',@DocDate)+1 , '0',3) +@CTAB4
		   
		   	IF @FromSerial<>''AND 
				(SELECT COUNT(*) 
				FROM pln.tblProductSerials 	
				WHERE --ProductID = @ProductID AND 
					substring(RegDate,3,2)=SUBSTRING(@DocDate,3,2) AND SUBSTRING(SerialNo,4,2) =SUBSTRING(@DocDate,3,2) AND SUBSTRING(SerialNo,1,7)= [pub].[funPadLeft](@FromSerial,'0',7))>0
			BEGIN
				SET @strMsgText=N'شروع از مقدار که وارد شده قبلا برایش سریال ایجاد شده است'
				Raiserror (@strMsgText,16,1)
				Return
			END

			SET @SerialLen = 19
			IF (select COUNT(*) from pln.tblSerialPrefixes WHERE SerialPrefix ='') = 0
				INSERT INTO pln.tblSerialPrefixes
				select '',@FiscalYear,@ProductID,@SerialLen

			set @Count=0

			WHILE @Count< @SerialCount
			BEGIN
				SET @Count = @Count + 1

				IF @FromSerial=''
				BEGIN
					SELECT @MaxSerialNo= (floor(rand()*(((10000000)-(100000))+(1))+(100000)))
				END		
				ELSE
				BEGIN
					IF @Count>1
						SET @FromSerial = @FromSerial + 1

					SET @MaxSerialNo = @FromSerial
			
					Declare @ExistAB bit='True'
					WHILE @ExistAB='True'
					BEGIN
						IF (SELECT COUNT(*) 
							FROM pln.tblProductSerials 	
							WHERE ProductID = @ProductID AND SerialNo= [pub].[funPadLeft](@FromSerial,'0',7)+@SerialPrefix)>0
	
							SET @FromSerial =  (floor(rand()*(((10000000)-(100000))+(1))+(100000)))
						ELSE
						BEGIN
							SET @MaxSerialNo = @FromSerial
							SET @ExistAB='False'
						END
					END

				END
		
				SELECT @ProductSerialID = ISNULL(MAX(ProductSerialID),0)+1 FROM pln.tblProductSerials

				IF @MProductSerialID>@ProductSerialID
					SET @ProductSerialID = @MProductSerialID
		
				IF @SrlNo=''
					SELECT @SrlNo= [pub].[funPadLeft](@MaxSerialNo,'0',7) +@SerialPrefix 

				INSERT INTO pln.tblProductSerials
				(ProductSerialID, ProductID, SerialPrefix, SerialNo, ColorID, RegDate, RegEmpID, IsPrinted, DocDate, UserID, MotorTypeID, IsPrinted2, IsPrinted3, BaseSerialNo, BaseFiscalYear, BaseProcessID, NumberPerSerial)
				select @ProductSerialID,@ProductID,'',@SrlNo,@ColorID,@DocDate,@RegEmpID,'False',@DocDate,@UserID,@MotorTypeID,'False','False',0,0,0,1
				
				SELECT @RowNo = ISNULL(MAX(RowNo),0)+1 from pln.tblProductSerialStatus

				IF @MProductSerialID>@ProductSerialID
					SET @ProductSerialID = @MProductSerialID
		
				INSERT INTO pln.tblProductSerialStatus
				(RowNo, DocDate, DocTime, SessionNo, ProductSerialID, SerialStatusID, IsLocked)
				SELECT @RowNo,@DocDate,@DocTime,@SessionNo,@ProductSerialID,@SerialStatusID,'False'

				SET @SrlNo=''

				INSERT #ProductSerialID select @ProductSerialID
			END
		END
	ELSE
		BEGIN
			declare @BatchNo Varchar(20)  
			declare @SerialNo Varchar(20)  
			declare @CT1 Nvarchar(100)
			declare @CT2 Nvarchar(100)
			declare @CT3 Nvarchar(100)
			declare @CT4 Nvarchar(100)
			declare @CT5 Nvarchar(100)
			declare @CT6 Nvarchar(100)

			--SET @BatchNo			= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
			SET @CT1				= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
			SET @CT2				= LTrim(pub.funSplitString(@ExtraParams, '@', 3));
			SET @CT3				= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
			SET @CT4				= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
			--SET @CT5				= LTrim(pub.funSplitString(@ExtraParams, '@', 6)); 
			--SET @CT6				= LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 
			SET @FromSerial			= LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
			SEt @SerialNo = ''
			if @FromSerial ='0'
				SET @FromSerial = ''

			SET @SerialNo		= LTrim(pub.funSplitString(@ExtraParams, '@', 16)); 

			IF @SerialNo<>'' AND 
			  (SELECT COUNT(*) FROM pln.tblProductSerials 	
			   WHERE ProductID = @ProductID AND SerialNo=@SerialNo)>0
			BEGIN
				SELECT @SerialNo
				RETURN
			END
			
			select @SerialPrefix = [pub].[funPadLeft](pub.funFarsiDateDiff('Day',SUBSTRING(@DocDate,1,4)+'/01/01',@DocDate)+1 , '0',3) + SUBSTRING(@DocDate,3,2)
			 --SET @SerialPrefix = SUBSTRING(@DocDate,3,2)+ SUBSTRING(@DocDate,6,2)+ SUBSTRING(@DocDate,9,2)
			 SET @SerialPrefix = @SerialPrefix +@CT1+@CT2+@CT3+@CT4
		   
		   		IF @FromSerial<>''AND 
				  (SELECT COUNT(*) 
				   FROM pln.tblProductSerials 	
				   WHERE --ProductID = @ProductID AND 
						substring(RegDate,3,2)=SUBSTRING(@DocDate,3,2) AND SUBSTRING(SerialNo,4,2) =SUBSTRING(@DocDate,3,2) AND SUBSTRING(SerialNo,13,7)= [pub].[funPadLeft](@FromSerial,'0',7))>0
				BEGIN
					SET @strMsgText=N'شروع از مقدار که وارد شده قبلا برایش سریال ایجاد شده است'
					Raiserror (@strMsgText,16,1)
					Return
				END

			SET @SerialLen = 19
			IF (select COUNT(*) from pln.tblSerialPrefixes WHERE SerialPrefix ='') = 0
				INSERT INTO pln.tblSerialPrefixes
				select '',@FiscalYear,@ProductID,@SerialLen

			set @Count=0

			WHILE @Count< @SerialCount
			BEGIN
				SET @Count = @Count + 1

				IF @FromSerial=''
				BEGIN
					SELECT @MaxSerialNo=ISNULL(MAX(SUBSTRING(SerialNo,13,@SerialLen)),0) 
					FROM pln.tblProductSerials 
					WHERE SUBSTRING(SerialNo,4,2) =SUBSTRING(@DocDate,3,2) AND  LEN(SerialNo)=@SerialLen-- = @SerialPrefix
					SET @MaxSerialNo = @MaxSerialNo+1
				END		
				ELSE
				BEGIN
					IF @Count>1
						SET @FromSerial = @FromSerial + 1

					SET @MaxSerialNo = @FromSerial
			
					Declare @Exist bit='True'
					WHILE @Exist='True'
					BEGIN
						IF (SELECT COUNT(*) 
							FROM pln.tblProductSerials 	
							WHERE ProductID = @ProductID AND SerialNo=@SerialPrefix + [pub].[funPadLeft](@FromSerial,'0',7))>0
	
							SET @FromSerial = @FromSerial + 1
						ELSE
						BEGIN
							SET @MaxSerialNo = @FromSerial
							SET @Exist='False'
						END
					END

				END
		
				SELECT @ProductSerialID = ISNULL(MAX(ProductSerialID),0)+1 FROM pln.tblProductSerials

				IF @MProductSerialID>@ProductSerialID
					SET @ProductSerialID = @MProductSerialID
		
				IF @SerialNo=''
					SELECT @SerialNo=@SerialPrefix + [pub].[funPadLeft](@MaxSerialNo,'0',7)

				INSERT INTO pln.tblProductSerials
				(ProductSerialID, ProductID, SerialPrefix, SerialNo, ColorID, RegDate, RegEmpID, IsPrinted, DocDate, UserID, MotorTypeID, IsPrinted2, IsPrinted3, BaseSerialNo, BaseFiscalYear, BaseProcessID, NumberPerSerial)
				select @ProductSerialID,@ProductID,'',@SerialNo,@ColorID,@DocDate,@RegEmpID,'False',@DocDate,@UserID,@MotorTypeID,'False','False',0,0,0,1
				
				SELECT @RowNo = ISNULL(MAX(RowNo),0)+1 from pln.tblProductSerialStatus

				IF @MProductSerialID>@ProductSerialID
					SET @ProductSerialID = @MProductSerialID
		
				INSERT INTO pln.tblProductSerialStatus
				(RowNo, DocDate, DocTime, SessionNo, ProductSerialID, SerialStatusID, IsLocked)
				SELECT @RowNo,@DocDate,@DocTime,@SessionNo,@ProductSerialID,@SerialStatusID,'False'

				SET @SerialNo=''

				INSERT #ProductSerialID select @ProductSerialID
			END
		END
	END
	ELSE IF @CompanyName = 'ZibaAfrozHoma'
	BEGIN
		declare @BatchNoZ Varchar(20)  
		declare @SerialNoZ Varchar(20)  
		declare @CTZ1 Nvarchar(100)
		declare @CTZ2 Nvarchar(100)
		declare @CTZ3 Nvarchar(100)
		declare @CTZ4 Nvarchar(100)
		declare @CTZ5 Nvarchar(100)
		declare @CTZ6 Nvarchar(100)
		SET @CTZ1				= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
		SET @FromSerial			= LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
		SEt @SerialNoZ = ''
		if @FromSerial ='0'
			SET @FromSerial = ''

		SET @SerialNoZ		= LTrim(pub.funSplitString(@ExtraParams, '@', 16)); 

		IF @SerialNoZ<>'' AND 
		  (SELECT COUNT(*) FROM pln.tblProductSerials 	
		   WHERE ProductID = @ProductID AND SerialNo=@SerialNoZ)>0
		BEGIN
			SELECT @SerialNoZ
			RETURN
		END
		SELECT @CTZ2=RIGHT([pub].[funPadLeft](@ColorID,'0',1),1)
		SELECT @CTZ3=RIGHT([pub].[funPadLeft](@MotorTypeID,'0',1),1)
		SELECT @SerialPrefix =[pub].[funPadLeft](@CTZ1,'0',2) + SUBSTRING(@DocDate,3,2)+ SUBSTRING(@DocDate,6,2)+ SUBSTRING(@DocDate,9,2) + [pub].[funPadLeft](@ProductID,'0',7) + [pub].[funPadLeft](@CTZ2,'0',1) +[pub].[funPadLeft](@CTZ3,'0',1)
		   
		IF @FromSerial<>''AND 
			(SELECT COUNT(*) 
			FROM pln.tblProductSerials 	
			WHERE ProductID = @ProductID AND 
			        SerialNo=@SerialPrefix  + [pub].[funPadLeft](@FromSerial,'0',3))>0
		BEGIN
			SET @strMsgText=N'شروع از مقدار که وارد شده قبلا برایش سریال ایجاد شده است'
			Raiserror (@strMsgText,16,1)
			Return
		END

		SET @SerialLen = 20
		IF (select COUNT(*) from pln.tblSerialPrefixes WHERE SerialPrefix ='') = 0
			INSERT INTO pln.tblSerialPrefixes
			select '',@FiscalYear,@ProductID,@SerialLen

		set @Count=0
	
		WHILE @Count< @SerialCount
		BEGIN
			SET @Count = @Count + 1

			IF @FromSerial=''
			BEGIN
				SELECT @MaxSerialNo=ISNULL(MAX(SUBSTRING(SerialNo,18,@SerialLen)),0) 
				FROM pln.tblProductSerials 
				WHERE LEN(SerialNo)=@SerialLen AND LEFT(SerialNo,17)=@SerialPrefix -- = @SerialPrefix
				SET @MaxSerialNo = @MaxSerialNo+1
			END		
			ELSE
			BEGIN
				IF @Count>1
					SET @FromSerial = @FromSerial + 1

				SET @MaxSerialNo = @FromSerial
			
				Declare @Exist1 bit='True'
				WHILE @Exist1='True'
				BEGIN
					IF (SELECT COUNT(*) 
						FROM pln.tblProductSerials 	
						WHERE ProductID = @ProductID AND SerialNo=@SerialPrefix + [pub].[funPadLeft](@FromSerial,'0',3))>0
	
						SET @FromSerial = @FromSerial + 1
					ELSE
					BEGIN
						SET @MaxSerialNo = @FromSerial
						SET @Exist1='False'
					END
				END

			END
		
			SELECT @ProductSerialID = ISNULL(MAX(ProductSerialID),0)+1 FROM pln.tblProductSerials

			IF @MProductSerialID>@ProductSerialID
				SET @ProductSerialID = @MProductSerialID
		
			IF @SerialNoZ=''
				SELECT @SerialNoZ=@SerialPrefix + [pub].[funPadLeft](@MaxSerialNo,'0',3)

			INSERT INTO pln.tblProductSerials
			(ProductSerialID, ProductID, SerialPrefix, SerialNo, ColorID, RegDate, RegEmpID, IsPrinted, DocDate, UserID, MotorTypeID, IsPrinted2, IsPrinted3, BaseSerialNo, BaseFiscalYear, BaseProcessID, NumberPerSerial)
			select @ProductSerialID,@ProductID,'',@SerialNoZ,@ColorID,@DocDate,@RegEmpID,'False',@DocDate,@UserID,@MotorTypeID,'False','False',0,0,0,1
				
			SELECT @RowNo = ISNULL(MAX(RowNo),0)+1 from pln.tblProductSerialStatus

			IF @MProductSerialID>@ProductSerialID
				SET @ProductSerialID = @MProductSerialID
		
			INSERT INTO pln.tblProductSerialStatus
			(RowNo, DocDate, DocTime, SessionNo, ProductSerialID, SerialStatusID, IsLocked)
			SELECT @RowNo,@DocDate,@DocTime,@SessionNo,@ProductSerialID,@SerialStatusID,'False'
			
			SET @SerialNoZ=''

			INSERT #ProductSerialID select @ProductSerialID
		END
	END
	ELSE IF @CompanyName = 'PardisKhazar'
	BEGIN
		declare @SerialNoP Varchar(20)  
		declare @CTP1 Nvarchar(100)
		declare @CTP2 Nvarchar(100)
		declare @CTP3 Nvarchar(100)

		SET @CTP1				= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
		SET @FromSerial			= LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
		SEt @SerialNoP = ''
		if @FromSerial ='0'
			SET @FromSerial = ''

		SET @SerialNoP		= LTrim(pub.funSplitString(@ExtraParams, '@', 16)); 

		IF @SerialNoP<>'' AND 
		  (SELECT COUNT(*) FROM pln.tblProductSerials 	
		   WHERE ProductID = @ProductID AND SerialNo=@SerialNoP)>0
		BEGIN
			SELECT @SerialNoP
			RETURN
		END
		DECLARE @SerialPrfx varchar(20)
		SET @SerialPrfx = ''

		select TOP 1 @SerialPrfx = SerialPrefix from pln.tblSerialPrefixes where GoodsID=SUBSTRING(@ProductID,1,LEN(GoodsID))

		IF @SerialPrfx = '' OR LEN(@SerialPrfx) < 3
		BEGIN
			SET @strMsgText=N'پیشوند برای این کالا تعریف نشده است'
			Raiserror (@strMsgText,16,1)
			Return
		END

		SELECT @CTP2=RIGHT([pub].[funPadLeft](@MotorTypeID,'0',3),3)
		SELECT @CTP3=RIGHT([pub].[funPadLeft](@ColorID,'0',3),3)
		SELECT @SerialPrefix =LEFT(@SerialPrfx,3) + SUBSTRING(@DocDate,3,2)+ SUBSTRING(@DocDate,6,2)+ SUBSTRING(@DocDate,9,2) + @CTP2 +@CTP3+[pub].[funPadLeft](@CTP1,'0',1)
		   
		IF @FromSerial<>''AND 
			(SELECT COUNT(*) 
			FROM pln.tblProductSerials 	
			WHERE ProductID = @ProductID AND 
			        SerialNo=@SerialPrefix  + [pub].[funPadLeft](@FromSerial,'0',3))>0
		BEGIN
			SET @strMsgText=N'شروع از مقدار که وارد شده قبلا برایش سریال ایجاد شده است'
			Raiserror (@strMsgText,16,1)
			Return
		END

		SET @SerialLen = 19
		--IF (select COUNT(*) from pln.tblSerialPrefixes WHERE SerialPrefix ='') = 0
		--	INSERT INTO pln.tblSerialPrefixes
		--	select '',@FiscalYear,@ProductID,@SerialLen

		set @Count=0
		WHILE @Count< @SerialCount
		BEGIN
			SET @Count = @Count + 1

			IF @FromSerial=''
			BEGIN
				SELECT @MaxSerialNo=ISNULL(MAX(SUBSTRING(SerialNo,17,@SerialLen)),0) 
				FROM pln.tblProductSerials 
				WHERE LEN(SerialNo)=@SerialLen AND LEFT(SerialNo,16)=@SerialPrefix -- = @SerialPrefix
				SET @MaxSerialNo = @MaxSerialNo+1
			END		
			ELSE
			BEGIN
				IF @Count>1
					SET @FromSerial = @FromSerial + 1

				SET @MaxSerialNo = @FromSerial
			
				Declare @ExistP bit='True'
				WHILE @ExistP='True'
				BEGIN
					IF (SELECT COUNT(*) 
						FROM pln.tblProductSerials 	
						WHERE ProductID = @ProductID AND SerialNo=@SerialPrefix + [pub].[funPadLeft](@FromSerial,'0',3))>0
	
						SET @FromSerial = @FromSerial + 1
					ELSE
					BEGIN
						SET @MaxSerialNo = @FromSerial
						SET @ExistP='False'
					END
				END

			END
		
			SELECT @ProductSerialID = ISNULL(MAX(ProductSerialID),0)+1 FROM pln.tblProductSerials

			IF @MProductSerialID>@ProductSerialID
				SET @ProductSerialID = @MProductSerialID
		
			IF @SerialNoP=''
				SELECT @SerialNoP=@SerialPrefix + [pub].[funPadLeft](@MaxSerialNo,'0',3)



			INSERT INTO pln.tblProductSerials
			(ProductSerialID, ProductID, SerialPrefix, SerialNo, ColorID, RegDate, RegEmpID, IsPrinted, DocDate, UserID, MotorTypeID, IsPrinted2, IsPrinted3, BaseSerialNo, BaseFiscalYear, BaseProcessID, NumberPerSerial)
			select @ProductSerialID,@ProductID,@SerialPrfx,@SerialNoP,@ColorID,@DocDate,@RegEmpID,'False',@DocDate,@UserID,@MotorTypeID,'False','False',0,0,0,1
				
			SELECT @RowNo = ISNULL(MAX(RowNo),0)+1 from pln.tblProductSerialStatus

			IF @MProductSerialID>@ProductSerialID
				SET @ProductSerialID = @MProductSerialID
		
			INSERT INTO pln.tblProductSerialStatus
			(RowNo, DocDate, DocTime, SessionNo, ProductSerialID, SerialStatusID, IsLocked)
			SELECT @RowNo,@DocDate,@DocTime,@SessionNo,@ProductSerialID,@SerialStatusID,'False'
			
			SET @SerialNoP=''

			INSERT #ProductSerialID select @ProductSerialID
		END
	END
	ELSE IF @CompanyName = 'ParsNeginMaraghe'
	BEGIN
		SET @FromSerial			= LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
		if @FromSerial ='0'
			SET @FromSerial = ''
		SET @SerialPrefix=''
		SET @SerialLen=0

		SELECT @SerialPrefix = SerialPrefix,@SerialLen=SerialLen FROM pln.tblSerialPrefixes WHERE GoodsID=@ProductID
		
		IF @SerialPrefix=''
			BEGIN
				SET @strMsgText=N'پیشوند برای این کالا تعریف نکرده اید'
				Raiserror (@strMsgText,16,1)
				Return
			END

		IF @SerialLen=0
			BEGIN
				SET @strMsgText=N'طول سریال در تعریف پیشوند را برای این کالا تعریف نکرده اید'
				Raiserror (@strMsgText,16,1)
				Return
			END

		set @Count=0
	
		WHILE @Count< @SerialCount
		BEGIN
			SET @Count = @Count + 1
			
			IF @FromSerial=''
			BEGIN
				SELECT @MaxSerialNo=ISNULL(MAX(SUBSTRING(SerialNo,LEN(@SerialPrefix)+5,@SerialLen)),0) 
				FROM pln.tblProductSerials 
				WHERE LEN(SerialNo)=@SerialLen AND ProductID=@ProductID  AND SUBSTRING(SerialNo,1,LEN(@SerialPrefix)+2)= @SerialPrefix + SUBSTRING(@DocDate,3,2) 
				SET @MaxSerialNo = @MaxSerialNo+1
			END		
			ELSE
			BEGIN
				IF @Count>1
					SET @FromSerial = @FromSerial + 1

				SET @MaxSerialNo = @FromSerial
			END
		
			SELECT @ProductSerialID = ISNULL(MAX(ProductSerialID),0)+1 FROM pln.tblProductSerials

			IF @MProductSerialID>@ProductSerialID
				SET @ProductSerialID = @MProductSerialID
		
			INSERT INTO pln.tblProductSerials
			(ProductSerialID, ProductID, SerialPrefix, SerialNo, ColorID, RegDate, RegEmpID, IsPrinted, DocDate, UserID, MotorTypeID, IsPrinted2, IsPrinted3, BaseSerialNo, BaseFiscalYear, BaseProcessID, NumberPerSerial)
			select @ProductSerialID,@ProductID,@SerialPrefix,@SerialPrefix + SUBSTRING(@DocDate,3,2) + SUBSTRING(@DocDate,6,2) + [pub].[funPadLeft](@MaxSerialNo,'0',@SerialLen-LEN(@SerialPrefix)-4),@ColorID,@DocDate,@RegEmpID,'False',@DocDate,@UserID,@MotorTypeID,'False','False',0,0,0,1
				
			SELECT @RowNo = ISNULL(MAX(RowNo),0)+1 from pln.tblProductSerialStatus

			IF @MProductSerialID>@ProductSerialID
				SET @ProductSerialID = @MProductSerialID
		
			INSERT INTO pln.tblProductSerialStatus
			(RowNo, DocDate, DocTime, SessionNo, ProductSerialID, SerialStatusID, IsLocked)
			SELECT @RowNo,@DocDate,@DocTime,@SessionNo,@ProductSerialID,@SerialStatusID,'False'
		
			INSERT #ProductSerialID select @ProductSerialID
		END
	END
	ELSE IF @CompanyName = 'Leader' OR @CompanyName = 'AlmasAzar' OR @CompanyName = 'AlmasAzar2'
	BEGIN
		declare @CTL1 Nvarchar(100)

		SET @CTL1				= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
		SET @FromSerial			= LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 

		if @FromSerial ='0'
			SET @FromSerial = ''

		SET @SerialPrefix=@CTL1

		IF (select COUNT(*) from pln.tblSerialPrefixes WHERE SerialPrefix =@SerialPrefix) = 0
			INSERT INTO pln.tblSerialPrefixes
			select @SerialPrefix,@FiscalYear,@ProductID,@SerialLen

		set @Count=0
	
		WHILE @Count< @SerialCount
		BEGIN
			SET @Count = @Count + 1
			
			IF @FromSerial=''
			BEGIN
				SELECT @MaxSerialNo=ISNULL(MAX(SUBSTRING(SerialNo,LEN(@SerialPrefix)+5,@SerialLen)),0) 
				FROM pln.tblProductSerials 
				WHERE LEN(SerialNo)=@SerialLen AND SUBSTRING(SerialNo,5,2)=SUBSTRING(@DocDate,3,2)  AND (SerialPrefix= @SerialPrefix) AND SUBSTRING(SerialNo,1,4)= @SerialPrefix 
				SET @MaxSerialNo = @MaxSerialNo+1
			END		
			ELSE
			BEGIN
				IF @Count>1
					SET @FromSerial = @FromSerial + 1

				SET @MaxSerialNo = @FromSerial
			END
		
			SELECT @ProductSerialID = ISNULL(MAX(ProductSerialID),0)+1 FROM pln.tblProductSerials

			IF @MProductSerialID>@ProductSerialID
				SET @ProductSerialID = @MProductSerialID
		
			INSERT INTO pln.tblProductSerials
			(ProductSerialID, ProductID, SerialPrefix, SerialNo, ColorID, RegDate, RegEmpID, IsPrinted, DocDate, UserID, MotorTypeID, IsPrinted2, IsPrinted3, BaseSerialNo, BaseFiscalYear, BaseProcessID, NumberPerSerial)
			select @ProductSerialID,@ProductID,@SerialPrefix,@SerialPrefix + SUBSTRING(@DocDate,3,2) + SUBSTRING(@DocDate,6,2) + [pub].[funPadLeft](@MaxSerialNo,'0',@SerialLen-LEN(@SerialPrefix)-4),@ColorID,@DocDate,@RegEmpID,'False',@DocDate,@UserID,@MotorTypeID,'False','False',0,0,0,1
				
			SELECT @RowNo = ISNULL(MAX(RowNo),0)+1 from pln.tblProductSerialStatus

			IF @MProductSerialID>@ProductSerialID
				SET @ProductSerialID = @MProductSerialID
		
			INSERT INTO pln.tblProductSerialStatus
			(RowNo, DocDate, DocTime, SessionNo, ProductSerialID, SerialStatusID, IsLocked)
			SELECT @RowNo,@DocDate,@DocTime,@SessionNo,@ProductSerialID,@SerialStatusID,'False'
		
			INSERT #ProductSerialID select @ProductSerialID
		END
	END
ELSE IF @CompanyName = 'MahrisBaft'
	BEGIN
		SET @FromSerial			= LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 

		if @FromSerial ='0'
			SET @FromSerial = ''

		SET @SerialPrefix = SUBSTRING(@DocDate,3,2) + SUBSTRING(@DocDate,6,2)+ SUBSTRING(@DocDate,9,2)

		IF (select COUNT(*) from pln.tblSerialPrefixes WHERE SerialPrefix =@SerialPrefix) = 0
			INSERT INTO pln.tblSerialPrefixes
			select @SerialPrefix,@FiscalYear,@ProductID,@SerialLen

		set @Count=0
	
		WHILE @Count< @SerialCount
		BEGIN
			SET @Count = @Count + 1
			
			IF @FromSerial=''
			BEGIN
				SELECT @MaxSerialNo=ISNULL(MAX(SUBSTRING(SerialNo,LEN(@SerialPrefix)+1,@SerialLen)),0) 
				FROM pln.tblProductSerials 
				WHERE LEN(SerialNo)=@SerialLen AND (SerialPrefix= @SerialPrefix) AND SUBSTRING(SerialNo,1,6)= @SerialPrefix 
				SET @MaxSerialNo = @MaxSerialNo+1
			END		
			ELSE
			BEGIN
				IF @Count>1
					SET @FromSerial = @FromSerial + 1

				SET @MaxSerialNo = @FromSerial
			END
		
			SELECT @ProductSerialID = ISNULL(MAX(ProductSerialID),0)+1 FROM pln.tblProductSerials

			IF @MProductSerialID>@ProductSerialID
				SET @ProductSerialID = @MProductSerialID
		
			INSERT INTO pln.tblProductSerials
			(ProductSerialID, ProductID, SerialPrefix, SerialNo, ColorID, RegDate, RegEmpID, IsPrinted, DocDate, UserID, MotorTypeID, IsPrinted2, IsPrinted3, BaseSerialNo, BaseFiscalYear, BaseProcessID, NumberPerSerial)
			select @ProductSerialID,@ProductID,@SerialPrefix,@SerialPrefix  + [pub].[funPadLeft](@MaxSerialNo,'0',@SerialLen-LEN(@SerialPrefix)),@ColorID,@DocDate,@RegEmpID,'False',@DocDate,@UserID,@MotorTypeID,'False','False',0,0,0,1
				
			SELECT @RowNo = ISNULL(MAX(RowNo),0)+1 from pln.tblProductSerialStatus

			IF @MProductSerialID>@ProductSerialID
				SET @ProductSerialID = @MProductSerialID
		
			INSERT INTO pln.tblProductSerialStatus
			(RowNo, DocDate, DocTime, SessionNo, ProductSerialID, SerialStatusID, IsLocked)
			SELECT @RowNo,@DocDate,@DocTime,@SessionNo,@ProductSerialID,@SerialStatusID,'False'
		
			INSERT #ProductSerialID select @ProductSerialID
		END
	END
	ELSE IF @CompanyName = 'NikanTejaratAvesta'
	BEGIN
		IF LEn(@ColorID)<>2 
		BEGIN
			SET @strMsgText=N'کد رنگ باید به طول 2 وارد شده باشد'
			Raiserror (@strMsgText,16,1)
			Return
		END

		IF LEn(@MotorTypeID)<>2 
		BEGIN
			SET @strMsgText=N'کد موتور باید به طول 2 وارد شده باشد'
			Raiserror (@strMsgText,16,1)
			Return
		END

		declare @SerialNoN Varchar(20)  
		declare @CTN1 Nvarchar(100)
		declare @CTN2 Nvarchar(100)
		--declare @CTN3 Nvarchar(100)
		--declare @CTN4 Nvarchar(100)
		--declare @CTN5 Nvarchar(100)
		--declare @CTN6 Nvarchar(100)

		SET @CTN1				= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
		SET @CTN2				= LTrim(pub.funSplitString(@ExtraParams, '@', 3));
		--SET @CTN3				= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
		--SET @CTN4				= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
		SET @FromSerial			= LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
		SEt @SerialNoN = ''
		if @FromSerial ='0'
			SET @FromSerial = ''

		SET @SerialNoN		= LTrim(pub.funSplitString(@ExtraParams, '@', 16)); 

		IF @SerialNoN<>'' AND 
		  (SELECT COUNT(*) FROM pln.tblProductSerials 	
		   WHERE ProductID = @ProductID AND SerialNo=@SerialNoN)>0
		BEGIN
			SELECT @SerialNoN
			RETURN
		END
			
		select @SerialPrefix =  SUBSTRING(@DocDate,3,2) + SUBSTRING(@DocDate,6,2) + SUBSTRING(@DocDate,9,2)
		 SET @SerialPrefix = @SerialPrefix +@CTN1+@ColorID+@MotorTypeID+@CTN2
		   
		   	IF @FromSerial<>''AND 
			  (SELECT COUNT(*) 
			   FROM pln.tblProductSerials 	
			   WHERE SUBSTRING(SerialNo,1,2) =SUBSTRING(@DocDate,3,2) AND SUBSTRING(SerialNo,16,5)= [pub].[funPadLeft](@FromSerial,'0',5))>0
			BEGIN
				SET @strMsgText=N'شروع از مقدار که وارد شده قبلا برایش سریال ایجاد شده است'
				Raiserror (@strMsgText,16,1)
				Return
			END

		SET @SerialLen = 20
		IF (select COUNT(*) from pln.tblSerialPrefixes WHERE SerialPrefix ='') = 0
			INSERT INTO pln.tblSerialPrefixes
			select '',@FiscalYear,@ProductID,@SerialLen

		set @Count=0
	
		WHILE @Count< @SerialCount
		BEGIN
			SET @Count = @Count + 1

			IF @FromSerial=''
			BEGIN
				SELECT @MaxSerialNo=ISNULL(MAX(SUBSTRING(SerialNo,16,@SerialLen)),0) 
				FROM pln.tblProductSerials 
				WHERE SUBSTRING(SerialNo,1,2) =SUBSTRING(@DocDate,3,2) AND  LEN(SerialNo)=@SerialLen-- = @SerialPrefix
				SET @MaxSerialNo = @MaxSerialNo+1
			END		
			ELSE
			BEGIN
				IF @Count>1
					SET @FromSerial = @FromSerial + 1

				SET @MaxSerialNo = @FromSerial
			
				Declare @ExistN bit='True'
				WHILE @ExistN='True'
				BEGIN
					IF (SELECT COUNT(*) 
						FROM pln.tblProductSerials 	
						WHERE ProductID = @ProductID AND SerialNo=@SerialPrefix + [pub].[funPadLeft](@FromSerial,'0',5))>0
	
						SET @FromSerial = @FromSerial + 1
					ELSE
					BEGIN
						SET @MaxSerialNo = @FromSerial
						SET @ExistN='False'
					END
				END

			END
		
			SELECT @ProductSerialID = ISNULL(MAX(ProductSerialID),0)+1 FROM pln.tblProductSerials

			IF @MProductSerialID>@ProductSerialID
				SET @ProductSerialID = @MProductSerialID
		
			IF @SerialNoN=''
				SELECT @SerialNoN=@SerialPrefix + [pub].[funPadLeft](@MaxSerialNo,'0',5)

			INSERT INTO pln.tblProductSerials
			(ProductSerialID, ProductID, SerialPrefix, SerialNo, ColorID, RegDate, RegEmpID, IsPrinted, DocDate, UserID, MotorTypeID, IsPrinted2, IsPrinted3, BaseSerialNo, BaseFiscalYear, BaseProcessID, NumberPerSerial)
			select @ProductSerialID,@ProductID,'',@SerialNoN,@ColorID,@DocDate,@RegEmpID,'False',@DocDate,@UserID,@MotorTypeID,'False','False',0,0,0,1
				
			SELECT @RowNo = ISNULL(MAX(RowNo),0)+1 from pln.tblProductSerialStatus

			IF @MProductSerialID>@ProductSerialID
				SET @ProductSerialID = @MProductSerialID
		
			INSERT INTO pln.tblProductSerialStatus
			(RowNo, DocDate, DocTime, SessionNo, ProductSerialID, SerialStatusID, IsLocked)
			SELECT @RowNo,@DocDate,@DocTime,@SessionNo,@ProductSerialID,@SerialStatusID,'False'
			
			SET @SerialNoN=''

			INSERT #ProductSerialID select @ProductSerialID
		END
	END
	--ELSE IF @CompanyName = 'Ghaya'
	--BEGIN
	--	declare @BatchNo Varchar(20)  
	--	declare @CT1 Nvarchar(100)
	--	declare @CT2 Nvarchar(100)
	--	declare @CT3 Nvarchar(100)
	--	declare @CT4 Nvarchar(100)
	--	declare @CT5 Nvarchar(100)
	--	declare @CT6 Nvarchar(100)
	--	SET @BatchNo			= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	--	SET @CT1				= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
	--	SET @CT2				= LTrim(pub.funSplitString(@ExtraParams, '@', 3));
	--	SET @CT3				= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
	--	SET @CT4				= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
	--	SET @CT5				= LTrim(pub.funSplitString(@ExtraParams, '@', 6)); 
	--	SET @CT6				= LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 



	--	SET @SerialPrefix = SUBSTRING(@DocDate,3,2) --+ SUBSTRING(@ProductID,8,5)
	--	SET @SerialPrefix = @SerialPrefix + SUBSTRING(@ProductID,1,3) 
	--	SET @SerialPrefix = @SerialPrefix + SUBSTRING(@BatchNo,1,6) +SUBSTRING('000000',1,6-len(@BatchNo)) 
	--	SET @SerialPrefix = @SerialPrefix + SUBSTRING(@CT1,1,2) +SUBSTRING('00',1,2-len(@CT1))
	--	SET @SerialPrefix = @SerialPrefix + SUBSTRING(@CT2,1,2) +SUBSTRING('00',1,2-len(@CT2))
		
	--	IF (select COUNT(*) from pln.tblSerialPrefixes WHERE SerialPrefix =@SerialPrefix) = 0
	--		INSERT INTO pln.tblSerialPrefixes
	--		select @SerialPrefix,@FiscalYear,@ProductID,@SerialLen

	--	set @Count=0
	
	--	WHILE @Count< @SerialCount
	--	BEGIN
	--		SET @Count = @Count + 1
		
	--		SELECT @MaxSerialNo=ISNULL(MAX(SUBSTRING(SerialNo,LEN(@SerialPrefix)+1,@SerialLen)),0) 
	--		FROM pln.tblProductSerials 
	--		WHERE SerialPrefix = @SerialPrefix
		
	--		SET @MaxSerialNo = @MaxSerialNo+1
		
	--		SELECT @ProductSerialID = ISNULL(MAX(ProductSerialID),0)+1 		from pln.tblProductSerials
		
	--		INSERT INTO pln.tblProductSerials
	--		(ProductSerialID, ProductID, SerialPrefix, SerialNo, ColorID, RegDate, RegEmpID, IsPrinted, DocDate, UserID, MotorTypeID, IsPrinted2, IsPrinted3, BaseSerialNo, BaseFiscalYear, BaseProcessID, NumberPerSerial,GoodsID1,GoodsID2,GoodsID3,GoodsID4,GoodsID5,GoodsID6,Property1,Property2)
	--		select @ProductSerialID,@ProductID,@SerialPrefix,@SerialPrefix + [pub].[funPadLeft](@MaxSerialNo,'0',5),@ColorID,@DocDate,@RegEmpID,'False',@DocDate,@UserID,@MotorTypeID,'False','False',0,0,0,1,@GoodsID1,@GoodsID2,@GoodsID3,@GoodsID4,@GoodsID5,@GoodsID6,@Property1,@Property2
				
	--		SELECT @RowNo = ISNULL(MAX(RowNo),0)+1 from pln.tblProductSerialStatus
		
	--		INSERT INTO pln.tblProductSerialStatus
	--		(RowNo, DocDate, DocTime, SessionNo, ProductSerialID, SerialStatusID, IsLocked)
	--		SELECT @RowNo,@DocDate,@DocTime,@SessionNo,@ProductSerialID,@SerialStatusID,'False'
		
	--		INSERT #ProductSerialID select @ProductSerialID
	--	END
	--END
	ELSE IF @CompanyName = 'FarshbafMotor'
	BEGIN
		DECLARE @ExtraField5 varchar(2)
		SELECT @ExtraField5 = [pub].[funPadLeft](a.ExtraField5,'0',2)
		FROM inv.tblGoods a
		WHERE GoodsID = @ProductID

		SET @SerialLen = 12
		SET @SerialPrefix = SUBSTRING(@DocDate,1,4)+SUBSTRING(@DocDate,6,2)
		IF (select COUNT(*) from pln.tblSerialPrefixes WHERE SerialPrefix =@SerialPrefix) = 0
			INSERT INTO pln.tblSerialPrefixes
			select SUBSTRING(@DocDate,1,4)+SUBSTRING(@DocDate,6,2),@FiscalYear,'',12
			
		set @Count=0
	
		WHILE @Count< @SerialCount
		BEGIN
			SET @Count = @Count + 1
		
			SELECT @MaxSerialNo=ISNULL(MAX(SUBSTRING(SerialNo,9,@SerialLen)),'1000' ) 
			from pln.tblProductSerials
			where LEN(SerialNo)=@SerialLen AND SUBSTRING(SerialNo,1,4) =SUBSTRING(@DocDate,1,4)
		
			SET @MaxSerialNo = @MaxSerialNo+1
		
			SELECT @ProductSerialID = ISNULL(MAX(ProductSerialID),0)+1 		
			FROM pln.tblProductSerials

			IF @MProductSerialID>@ProductSerialID
				SET @ProductSerialID = @MProductSerialID
		
			INSERT INTO pln.tblProductSerials
			(ProductSerialID, ProductID, SerialPrefix, SerialNo, ColorID, RegDate, RegEmpID, IsPrinted, DocDate, UserID, MotorTypeID, IsPrinted2, IsPrinted3, BaseSerialNo, BaseFiscalYear, BaseProcessID, NumberPerSerial,GoodsID1,GoodsID2,GoodsID3,GoodsID4,GoodsID5,GoodsID6,Property1,Property2)
			select @ProductSerialID,@ProductID,@SerialPrefix,@SerialPrefix + @ExtraField5 + [pub].[funPadLeft](@MaxSerialNo,'0',4),@ColorID,@DocDate,@RegEmpID,'False',@DocDate,@UserID,@MotorTypeID,'False','False',0,0,0,1,@GoodsID1,@GoodsID2,@GoodsID3,@GoodsID4,@GoodsID5,@GoodsID6,@Property1,@Property2
		
		
			SELECT @RowNo = ISNULL(MAX(RowNo),0)+1 from pln.tblProductSerialStatus
		
			INSERT INTO pln.tblProductSerialStatus
			(RowNo, DocDate, DocTime, SessionNo, ProductSerialID, SerialStatusID, IsLocked)
			SELECT @RowNo,@DocDate,@DocTime,@SessionNo,@ProductSerialID,@SerialStatusID,'False'
		
			INSERT #ProductSerialID select @ProductSerialID
		END
		--IF LEFT(@DocDate,4)<1402
		--BEGIN
		--	declare @CTF1 Nvarchar(100)
		--	SET @FromSerial			= LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
		--	SET @CTF1				= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 

		--	if @FromSerial ='0'
		--		SET @FromSerial = ''

		--	IF (select COUNT(*) from pln.tblSerialPrefixes WHERE SerialPrefix ='') = 0
		--		INSERT INTO pln.tblSerialPrefixes
		--		select '',@FiscalYear,@ProductID,8

		--	set @Count=0
	
		--	WHILE @Count< @SerialCount
		--	BEGIN
		--		SET @Count = @Count + 1
			
		--		IF @FromSerial=''
		--		BEGIN
		--			SELECT @MaxSerialNo=ISNULL(MAX(SUBSTRING(SerialNo,1,6)),0) 
		--			FROM pln.tblProductSerials 
		--			WHERE LEN(SerialNo)=8 
		--			SET @MaxSerialNo = @MaxSerialNo+1
		--		END		
		--		ELSE
		--		BEGIN
		--			DECLARE @FlagF bit='False'
		--			WHILE @FlagF='False'
		--			BEGIN
		--				IF (SELECT COUNT(*) from pln.tblProductSerials where LEFT(SerialNo,6)=@FromSerial)=0
		--					SET @FlagF='True'
		--				ELSE
		--					SET @FromSerial = @FromSerial + 1
		--			END

		--			SET @MaxSerialNo = @FromSerial
		--		END
		
		--		SELECT @ProductSerialID = ISNULL(MAX(ProductSerialID),0)+1 FROM pln.tblProductSerials

		--		IF @MProductSerialID>@ProductSerialID
		--			SET @ProductSerialID = @MProductSerialID
		
		--		INSERT INTO pln.tblProductSerials
		--		(ProductSerialID, ProductID, SerialPrefix, SerialNo, ColorID, RegDate, RegEmpID, IsPrinted, DocDate, UserID, MotorTypeID, IsPrinted2, IsPrinted3, BaseSerialNo, BaseFiscalYear, BaseProcessID, NumberPerSerial)
		--		select @ProductSerialID,@ProductID,'',[pub].[funPadLeft](@MaxSerialNo,'0',6)+ @CTF1,@ColorID,@DocDate,@RegEmpID,'False',@DocDate,@UserID,@MotorTypeID,'False','False',0,0,0,1
				
		--		SELECT @RowNo = ISNULL(MAX(RowNo),0)+1 from pln.tblProductSerialStatus

		--		IF @MProductSerialID>@ProductSerialID
		--			SET @ProductSerialID = @MProductSerialID
		
		--		INSERT INTO pln.tblProductSerialStatus
		--		(RowNo, DocDate, DocTime, SessionNo, ProductSerialID, SerialStatusID, IsLocked)
		--		SELECT @RowNo,@DocDate,@DocTime,@SessionNo,@ProductSerialID,@SerialStatusID,'False'
		
		--		INSERT #ProductSerialID select @ProductSerialID
		--	END
		--END
		--ELSE
		--BEGIN
		--	SELECT @SerialPrefix = [pub].[funPadLeft](a.ExtraField6,'0',1)+[pub].[funPadLeft](a.ExtraField7,'0',1)+[pub].[funPadLeft](a.ExtraField8,'0',1)+
		--		   [pub].[funPadLeft](a.ExtraField9,'0',1)+[pub].[funPadLeft](a.ExtraField10,'0',1)+[pub].[funPadLeft](a.ExtraField11,'0',1) 
		--	FROM inv.tblGoods a
		--	WHERE GoodsID = @ProductID

		--	set @Count=0
	
		--	WHILE @Count< @SerialCount
		--	BEGIN
		--		SET @Count = @Count + 1

		--		SELECT @MaxSerialNo=ISNULL(MAX(SUBSTRING(SerialNo,7,4)),0) 
		--		FROM pln.tblProductSerials 
		--		WHERE LEN(SerialNo)=14 AND ProductID = @ProductID

		--		SET @MaxSerialNo = @MaxSerialNo+1

		--		SELECT @ProductSerialID = ISNULL(MAX(ProductSerialID),0)+1 FROM pln.tblProductSerials

		--		IF @MProductSerialID>@ProductSerialID
		--			SET @ProductSerialID = @MProductSerialID
		
		--		INSERT INTO pln.tblProductSerials
		--		(ProductSerialID, ProductID, SerialPrefix, SerialNo, ColorID, RegDate, RegEmpID, IsPrinted, DocDate, UserID, MotorTypeID, IsPrinted2, IsPrinted3, BaseSerialNo, BaseFiscalYear, BaseProcessID, NumberPerSerial)
		--		select @ProductSerialID,@ProductID,'',@SerialPrefix + [pub].[funPadLeft](@MaxSerialNo,'0',4)+ SUBSTRING(@DocDate,3,2) + SUBSTRING(@DocDate,6,2),@ColorID,@DocDate,@RegEmpID,'False',@DocDate,@UserID,@MotorTypeID,'False','False',0,0,0,1
				
		--		SELECT @RowNo = ISNULL(MAX(RowNo),0)+1 from pln.tblProductSerialStatus

		--		IF @MProductSerialID>@ProductSerialID
		--			SET @ProductSerialID = @MProductSerialID
		
		--		INSERT INTO pln.tblProductSerialStatus
		--		(RowNo, DocDate, DocTime, SessionNo, ProductSerialID, SerialStatusID, IsLocked)
		--		SELECT @RowNo,@DocDate,@DocTime,@SessionNo,@ProductSerialID,@SerialStatusID,'False'
		
		--		INSERT #ProductSerialID select @ProductSerialID
		--	END

		--END

	END
	ELSE
	BEGIN
			
		IF (select COUNT(*) from pln.tblSerialPrefixes WHERE SerialPrefix =@SerialPrefix) = 0
			INSERT INTO pln.tblSerialPrefixes
			select @SerialPrefix,@FiscalYear,@ProductID,@SerialLen
			
		set @Count=0
	
		WHILE @Count< @SerialCount
		BEGIN
			SET @Count = @Count + 1
		
			SELECT @MaxSerialNo=ISNULL(MAX(SUBSTRING(SerialNo,LEN(@SerialPrefix)+1,@SerialLen)),0) 
			from pln.tblProductSerials
			where LEN(SerialNo)=@SerialLen AND SUBSTRING(SerialNo,LEN(@SerialPrefix)-4+1,2) =SUBSTRING(@SerialPrefix,LEN(@SerialPrefix)-4+1,2) 
		
			SET @MaxSerialNo = @MaxSerialNo+1
		
			SELECT @ProductSerialID = ISNULL(MAX(ProductSerialID),0)+1 		
			FROM pln.tblProductSerials

			IF @MProductSerialID>@ProductSerialID
				SET @ProductSerialID = @MProductSerialID
		
			INSERT INTO pln.tblProductSerials
			(ProductSerialID, ProductID, SerialPrefix, SerialNo, ColorID, RegDate, RegEmpID, IsPrinted, DocDate, UserID, MotorTypeID, IsPrinted2, IsPrinted3, BaseSerialNo, BaseFiscalYear, BaseProcessID, NumberPerSerial,GoodsID1,GoodsID2,GoodsID3,GoodsID4,GoodsID5,GoodsID6,Property1,Property2)
			select @ProductSerialID,@ProductID,@SerialPrefix,@SerialPrefix + [pub].[funPadLeft](@MaxSerialNo,'0',@SerialLen-LEN(@SerialPrefix)),@ColorID,@DocDate,@RegEmpID,'False',@DocDate,@UserID,@MotorTypeID,'False','False',0,0,0,1,@GoodsID1,@GoodsID2,@GoodsID3,@GoodsID4,@GoodsID5,@GoodsID6,@Property1,@Property2
		
		
			SELECT @RowNo = ISNULL(MAX(RowNo),0)+1 from pln.tblProductSerialStatus
		
			INSERT INTO pln.tblProductSerialStatus
			(RowNo, DocDate, DocTime, SessionNo, ProductSerialID, SerialStatusID, IsLocked)
			SELECT @RowNo,@DocDate,@DocTime,@SessionNo,@ProductSerialID,@SerialStatusID,'False'

			INSERT #ProductSerialID select @ProductSerialID
		END
	END

	if @PrdSerialsReg=1
	Begin
		declare @MaxSN int
		SELECT @MaxSN = ISNULL(MAX(SerialNo),0)+1 FROM pln.tblProducesSerialsRegHdr

		INSERT INTO [pln].[tblProducesSerialsRegHdr] ([SerialNo], [DocDate], [RecID], [SessionNo]) 
		select @MaxSN,@DocDate,0,@SessionNo

		INSERT INTO [pln].[tblProducesSerialsRegDtl] 
				([SerialNo], [RowNo], [DocRowNo], [DocDate], [ProductSerialID], [PSerialNo]) 
		select @MaxSN,ROW_NUMBER()over(order by ProductSerialID),ROW_NUMBER()over(order by ProductSerialID),@DocDate,ProductSerialID, SerialNo
	    from pln.tblProductSerials where ProductSerialID in (select * from #ProductSerialID)
		
	END
	select SerialNo,ProductSerialID 
	from pln.tblProductSerials where ProductSerialID in (select * from #ProductSerialID)
END
GO
