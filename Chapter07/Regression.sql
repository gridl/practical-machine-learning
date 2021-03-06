USE ML
GO
--TRUNCATE TABLE [PredictiveMaintenance].[Models] 
--TRUNCATE TABLE [PredictiveMaintenance].[Regression_metrics]
GO

WITH ranking AS 
	(SELECT *, ROW_NUMBER() OVER (ORDER BY [Root Mean Squared Error]) as Rn
	FROM [PredictiveMaintenance].[Regression_metrics])
SELECT [Name], [Variables], [Root Mean Squared Error], Rn
FROM ranking
WHERE Rn <=5 OR Rn >31
ORDER BY [Root Mean Squared Error];
GO

SELECT *
FROM [PredictiveMaintenance].[Regression_metrics]
--WHERE Name like 'rxNeural%'
ORDER BY [Root Mean Squared Error]; 
GO

EXEC sp_helptext'[PredictiveMaintenance].[TrainRegressionModel]'
GO

SELECT *
FROM [PredictiveMaintenance].[Models]; 

DECLARE @model VARBINARY(MAX);
DECLARE @name VARCHAR(255) = 'rxFastTrees regression on enchanced data';
EXEC [PredictiveMaintenance].[TrainRegressionModel] 'rxFastTrees','[PredictiveMaintenance].[train_Features]', 20,
	 @model OUTPUT;
IF EXISTS(SELECT * FROM [PredictiveMaintenance].[Models]  where model_name=@name)
  UPDATE [PredictiveMaintenance].[Models] 
  SET [model] = @model
  WHERE [model_name] = @name
ELSE
	INSERT INTO [PredictiveMaintenance].[Models] (model_name, model) 
	VALUES(@name, @model);
GO

DECLARE @model VARBINARY(MAX);
DECLARE @name VARCHAR(255) = 'rxFastForest regression on normalized data';
EXEC [PredictiveMaintenance].[TrainRegressionModel] 'rxFastForest','[PredictiveMaintenance].[Train_Features_Normalized]', 10, @model OUTPUT;
IF EXISTS(SELECT * FROM [PredictiveMaintenance].[Models]  where model_name=@name)
  UPDATE [PredictiveMaintenance].[Models] 
  SET [model] = @model
  WHERE [model_name] = @name
ELSE
	INSERT INTO [PredictiveMaintenance].[Models] (model_name, model) 
	VALUES(@name, @model);
GO

DECLARE @model VARBINARY(MAX);
DECLARE @name VARCHAR(255) = 'rxEnsemble regression on enchanced data';
EXEC [PredictiveMaintenance].[TrainRegressionModel] 'rxEnsemble','[PredictiveMaintenance].[train_Features]', 20, @model OUTPUT;
IF EXISTS(SELECT * FROM [PredictiveMaintenance].[Models]  where model_name=@name)
  UPDATE [PredictiveMaintenance].[Models] 
  SET [model] = @model
  WHERE [model_name] = @name
ELSE
	INSERT INTO [PredictiveMaintenance].[Models] (model_name, model) 
	VALUES(@name, @model);
GO

SELECT *
FROM [PredictiveMaintenance].[Models];

DECLARE @model VARBINARY(MAX);
EXEC [PredictiveMaintenance].[TrainRegressionModel] 'rxGlm','[PredictiveMaintenance].[Train_Features_Normalized]', 10,
	 @model OUTPUT;
GO

--Real-time scoring
sp_configure 'clr enabled', 1  
GO  
RECONFIGURE  
GO  

--C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\R_SERVICES\library\RevoScaleR\rxLibs\x64>RegisterRExt.exe /installRts /database:ML


DECLARE @model varbinary(max) = (SELECT model 
	FROM [PredictiveMaintenance].[Models] 
	WHERE model_name = 'rxFastTrees regression on enchanced data');
EXEC sp_rxPredict
	@model = @model,
	@inputData = N'SELECT RUL ,  s11 , s4 , s12 , s7 , s15 , s21 , s20 , s2 , 
	s17 , s3 , s8 , s13 , s9 , s6 , a3 , a15 , a2 , a20 , a21 , a12 
	FROM [PredictiveMaintenance].[test_Features]';
GO


DECLARE @model varbinary(max) = (SELECT model 
	FROM [PredictiveMaintenance].[Models] 
	WHERE model_name = 'rxEnsemble regression on enchanced data');
EXEC sp_rxPredict
	@model = @model,
	@inputData = N'SELECT RUL ,  s11 , s4 , s12 , s7 , s15 , s21 , s20 , s2 , 
	s17 , s3 , s8 , s13 , s9 , s6 , a3 , a15 , a2 , a20 , a21 , a12 
	FROM [PredictiveMaintenance].[test_Features]';
GO
