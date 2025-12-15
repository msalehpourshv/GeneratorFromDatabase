USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Reza Nogrepasand
-- Create date   : 91/03/20
-- Viewed By	 : 
-- Last Modified : 91/07/05
-- Description   : 
-- =============================================
CREATE PROCEDURE [srv].[SpTransferToTelLog]
	@CurrentDate CHAR(10)
	
	WITH ENCRYPTION
AS

BEGIN
	
	BEGIN TRY
		DROP TABLE #tblTempTelLog
	END TRY
	BEGIN CATCH
	END CATCH
	
	DECLARE @AcntPart TinyInt
	DECLARE @LanguageID TINYINT
	
	SET @LanguageID = pub.funGetCurrentLanguageID();
	
	--------------------------------------------------------------------
	SELECT @AcntPart = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation' 
	
	--------------------------------------------------------------------
    SELECT EventID INTO #tblTempTelLog 
    FROM (
		SELECT EventID,
			substring(pub.funFarsiDate(substring(EventDesc,1,8)),1,10) AS CallDate,
			substring(EventDesc,10,1) as Internal,	
			
			CASE WHEN (substring(EventDesc,11,7) LIKE '%AM%' and substring(EventDesc,11,2) <> '12' ) OR ((substring(EventDesc,11,2)= '12' AND substring(EventDesc,11,7) LIKE '%PM%')) 
			THEN substring(EventDesc,11,5) 
			ELSE 
				CASE WHEN ((substring(EventDesc,11,7) LIKE '%AM%')AND (substring(EventDesc,11,2) LIKE '12')) 
				THEN LTRIM(str(substring(EventDesc,11,2) - 12)) + substring(EventDesc,13,3) 
				ELSE LTRIM(str(substring(EventDesc,11,2) + 12)) + substring(EventDesc,13,3) 
				END
			END AS CallTime,
		   
			substring(EventDesc,18,4) AS Ext,
			substring(EventDesc,22,4) AS CO,
			CASE WHEN (EventDesc like '%incom%') THEN 1 ELSE 0 END AS Incoming,
			CASE WHEN (EventDesc like '%incom%') 
				 THEN substring(EventDesc,47,18) 
				 ELSE substring(EventDesc,27,38) END AS DialNumber,
			replace (substring(EventDesc,65,8), '''', ':')  AS Duration
		FROM [TS].[pub].[tblPortEvents]
		WHERE len(EventDesc)=81 and substring(EventDesc,3,1) = '/' 
		) a 
    WHERE CallDate >= @CurrentDate AND(( a.Ext = ' ' AND Incoming=1)OR (Incoming=0 AND a.Ext <> ' ')OR (Incoming=1 AND a.Ext <> ' '))--AND Internal<>' ' AND Incoming=1

    EXCEPT

    SELECT EventID 
    FROM pub.tblTelLog
    WHERE DocDate >= @CurrentDate 
	
	--------------------------------------------------------------------
	IF (SELECT COUNT(*) from #tblTempTelLog)>0
		BEGIN
		
			DECLARE @MaxID INT
			SELECT @MaxID=ISNULL(MAX(ID),0) FROM pub.tblTelLog 
			
			INSERT INTO pub.tblTelLog
			SELECT ROW_NUMBER() OVER(ORDER BY EventID) + @MaxID ,CallDate,CallTime,
			ISNULL((SELECT TOP 1 CompanyID                        
			FROM   pub.tblTelLog
			WHERE DialNumber = a.DialNumber AND CompanyID <> ''
			ORDER BY EventID DESC),'')
			,
			ISNULL((SELECT TOP 1 PhonerName                        
			FROM   pub.tblTelLog
			WHERE  DialNumber= a.DialNumber AND PhonerName <> '' AND DialNumber LIKE '09%'
			ORDER BY EventID DESC),'')
			
			,'','','',0,1,EventID,DialNumber,a.Incoming,a.Ext,a.Duration,0,0,''
			FROM (
			SELECT EventID,
			   substring(pub.funFarsiDate(substring(EventDesc,1,8)),1,10) AS CallDate,
			   substring(EventDesc,10,1) as Internal,	
			 
			   CASE WHEN (substring(EventDesc,11,7) LIKE '%AM%'  and substring(EventDesc,11,2) <> '12' )OR ((substring(EventDesc,11,2)= '12' AND substring(EventDesc,11,7) LIKE '%PM%')) 
				    THEN substring(EventDesc,11,5) 
				    ELSE 
			   CASE WHEN ((substring(EventDesc,11,7) LIKE '%AM%')AND (substring(EventDesc,11,2) LIKE '12')) 
				    THEN LTRIM(str(substring(EventDesc,11,2) - 12)) + substring(EventDesc,13,3) 
				     ELSE LTRIM(str(substring(EventDesc,11,2) + 12)) + substring(EventDesc,13,3) 
			   END
			   END AS CallTime,
				
		       substring(EventDesc,18,4) AS Ext,
			   substring(EventDesc,22,4) AS CO,
			   CASE WHEN (EventDesc like '%incom%') THEN 1 ELSE 0 END AS Incoming,
			   
			   RTRIM(CASE WHEN (EventDesc like '%incom%') 
		    		 THEN substring(EventDesc,47,18) 
					 ELSE substring(EventDesc,27,38) END) AS DialNumber,
					 
			   REPLACE (substring(EventDesc,65,8), '''', ':')  AS Duration
					  
			   FROM [TS].[pub].[tblPortEvents]
			   WHERE len(EventDesc)=81 and substring(EventDesc,3,1) = '/' 
				) a 
			WHERE EventID IN (SELECT EventID FROM #tblTempTelLog ) -- AND Ext<>' ' --AND Internal<>' ' AND EventID >  & funMaxOfColumn() & _
			ORDER BY EventID

		END
	
	--------------------------------------------------------------------
	SELECT *,ISNULL([acc].[funGetAcntName](CompanyID,@AcntPart,@LanguageID),'') CompanyName2 FROM pub.tblTelLog
	WHERE EventID IN (SELECT EventID FROM #tblTempTelLog )

END
GO
