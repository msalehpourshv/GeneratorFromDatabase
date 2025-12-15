USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [pub].[spDeleteInvalidCode]
@TableName as VARCHAR(200)
WITH ENCRYPTION
as
BEGIN
	delete from pub.tblCodingRelation  
	from pub.tblCodingRelation  a
	inner join 
	(select  * from pub.tblCodingRelation where TableName= @TableName
	except 
	select a.* from pub.tblCodingRelation a
	inner join  inv.tblGoods b
	on a.Code = b.GoodsID AND a.LinkedPartNo = b.PartNumber
	where a.TableName= @TableName
	)b
	on a.TableName = b.TableName and  a.Code=b.Code AND  a.LinkedPartNo=b.LinkedPartNo AND  a.AcntXCode= b.AcntXCode AND a.PartNo=b.PartNo


	delete from pub.tblCodingRelation  
	from pub.tblCodingRelation  a
	inner join 
	(select  * from pub.tblCodingRelation where TableName= @TableName
	except 
	select a.* from pub.tblCodingRelation a
	inner join  inv.tblGoods b
	on a.AcntXCode = b.GoodsID AND a.PartNo = b.PartNumber
	where a.TableName= @TableName
	)b
	on a.TableName = b.TableName and  a.Code=b.Code AND  a.LinkedPartNo=b.LinkedPartNo AND  a.AcntXCode= b.AcntXCode AND a.PartNo=b.PartNo

END
GO
