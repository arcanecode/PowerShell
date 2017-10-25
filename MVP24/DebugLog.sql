/*
  These tables / procs are only used for debugging, shouldn't wind up in
  the final code. However we're including it should you wish to use it 
  to do debugging or trace progress in your own code.
*/

-- Create the logging table for assisting in debugging ------------------------
IF OBJECT_ID(N'dbo.DebugLog') IS NOT NULL
BEGIN
  DROP TABLE dbo.DebugLog
END
GO

CREATE TABLE dbo.DebugLog
( [LogKey] Int Identity NOT NULL
, [Message] NVARCHAR(2000)
, [Log Time] DateTime2 NOT NULL
)


-- This procedure just makes it quick and easy to display the log -------------
IF OBJECT_ID(N'dbo.ShowDebugLog') IS NOT NULL
BEGIN
  DROP PROCEDURE dbo.ShowDebugLog
END
GO

CREATE PROCEDURE dbo.ShowDebugLog
AS
BEGIN
  SELECT [LogKey] 
       , [Message] 
       , [Log Time] 
    FROM dbo.DebugLog
   ORDER BY [Log Time] DESC;
END
GO

-- Create a procedure to make logging easy ------------------------------------
IF OBJECT_ID(N'dbo.LogMessage') IS NOT NULL
BEGIN
  DROP PROCEDURE dbo.LogMessage
END
GO

CREATE PROCEDURE dbo.LogMessage
  @Message NVARCHAR(2000)
AS
BEGIN

  DECLARE @LogTime DATETIME2(7)
  SET @LogTime = GETDATE()
  
  INSERT INTO dbo.DebugLog
    ([Message], [Log Time])
  VALUES
    (@Message, @LogTime)
  
END

/* Test Harness ---------------------------------------------------------------

EXEC dbo.LogMessage 'A test message for the log'

EXEC ShowDebugLog

SELECT * 
  FROM dbo.DebugLog
 ORDER BY [Log Time] DESC

-----------------------------------------------------------------------------*/



