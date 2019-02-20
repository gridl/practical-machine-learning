USE ML
GO
SELECT [id]
      ,[cycle]
      ,[RUL]
      ,[label1]
FROM [PredictiveMaintenance].[train_Labels]
WHERE [RUL] BETWEEN 20 AND 35;
GO

SELECT [label1], COUNT(*) AS nr
FROM [PredictiveMaintenance].[train_Labels]
GROUP BY [label1]

SELECT [label1], COUNT(*) AS nr
FROM [PredictiveMaintenance].[Test_Features]
GROUP BY [label1];
GO

--TRUNCATE TABLE [PredictiveMaintenance].[Binary_metrics]

 SELECT *
 FROM [PredictiveMaintenance].[Binary_metrics]
 ORDER BY [F-Score]	DESC
 GO

EXEC sp_helptext'[PredictiveMaintenance].[TrainBinaryClassificationModel]'
GO

DELETE FROM [PredictiveMaintenance].[PM_Models]	
WHERE model_name IN('rxFastLinear binary classification','rxNeuralNet binary classification') 
GO

DECLARE @model VARBINARY(MAX);
EXEC [PredictiveMaintenance].[TrainBinaryClassificationModel] 'rxFastLinear','[PredictiveMaintenance].[train_Features_Normalized]', 35,
	 @model OUTPUT;
INSERT INTO [PredictiveMaintenance].[PM_Models] (model_name, model) 
VALUES('rxFastLinear binary classification', @model);
GO

DECLARE @model VARBINARY(MAX);
EXEC [PredictiveMaintenance].[TrainBinaryClassificationModel] 'rxNeuralNet','[PredictiveMaintenance].[train_Features_Normalized]', 35,
	 @model OUTPUT;
INSERT INTO [PredictiveMaintenance].[PM_Models] (model_name, model) 
VALUES('rxNeuralNet binary classification', @model);
GO

DECLARE @model varbinary(max) = ( SELECT model FROM [PredictiveMaintenance].[PM_Models] WHERE model_name = 'rxFastLinear binary classification');
EXEC sp_rxPredict
	@model = @model,
	@inputData = N'SELECT label1 , a11 , a4 , a15 , a21 , a17 , a3 , a20 , a2 , a12 , a7 , 
    s11 , s4 , s12 , s7 , s15 , s21 , s20 , s17 , s2 , a8 , a13 , 
    s3 , s8 , s13 , a9 , s9 , a14 , s14 , sd6 , a6 , sd9 , sd14 , 
    s6 , sd13 , sd11 FROM [PredictiveMaintenance].[test_Features_Normalized]'
GO

DECLARE @model varbinary(max) = ( SELECT model FROM [PredictiveMaintenance].[PM_Models] WHERE model_name = 'rxNeuralNet binary classification');
EXEC sp_rxPredict
	@model = @model,
	@inputData = N'SELECT label1 , a11 , a4 , a15 , a21 , a17 , a3 , a20 , a2 , a12 , a7 , 
    s11 , s4 , s12 , s7 , s15 , s21 , s20 , s17 , s2 , a8 , a13 , 
    s3 , s8 , s13 , a9 , s9 , a14 , s14 , sd6 , a6 , sd9 , sd14 , 
    s6 , sd13 , sd11 FROM [PredictiveMaintenance].[test_Features_Normalized]'
GO