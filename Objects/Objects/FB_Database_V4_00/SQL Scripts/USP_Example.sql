GO
IF OBJECT_ID('dbo.USP_Example', 'P') IS NOT NULL
    DROP PROCEDURE dbo.USP_Example;
GO

CREATE PROCEDURE dbo.USP_Example
@TimeStamped		       datetime,
@Uid                 	varchar(31),
@DataOk				        tinyint,
@VisionOk			      	tinyint,	  
@VisionCause			    tinyint,
@VisionScore			    tinyint,
@GetCycles					bit,
@GetAge						bit,
@GetRecord					bit,
@Expired					bit  

AS
BEGIN
  BEGIN TRY
    BEGIN TRANSACTION;

	    IF (@TimeStamped = '' OR @TimeStamped is NULL) 
	    BEGIN
		    SET @TimeStamped = '';
	    END
        IF (@Uid = '' OR @Uid is NULL) 
	    BEGIN
		    SET @Uid = 'Unobtainable';
	    END
        IF (@DataOk	 is NULL) 
	    BEGIN
		    SET @DataOk	 = 0;
	    END
		IF (@VisionOk is NULL) 
	    BEGIN
		    SET @VisionOk = 0;
	    END
		IF (@VisionCause is NULL) 
	    BEGIN
		    SET @VisionCause = 0;
	    END
		IF (@VisionScore is NULL) 
	    BEGIN
		    SET @VisionScore = 0;
	    END
		IF (@GetCycles is NULL) 
	    BEGIN
		    SET @GetCycles = 0;
	    END
		IF (@GetAge is NULL) 
	    BEGIN
		    SET @GetAge = 0;
	    END
		IF (@GetRecord is NULL) 
	    BEGIN
		    SET @GetRecord = 0;
	    END
		IF (@Expired is NULL) 
	    BEGIN
		    SET @Expired = 0;
	    END

		IF ((@GetCycles = 1 OR @GetAge = 1) AND @GetRecord = 1 AND @Uid <> '00 00 00 00 00 00 00 00')
		BEGIN
		DECLARE
    		@Cycles	            tinyint,
    		@Age                varchar(31),
			@dateofbirth		datetime,
			@years				varchar(31),
			@months				varchar(31),
			@days				varchar(31)

		SELECT @Cycles = COUNT(*) FROM [dbo].[RfidTagRecord] Where [dbo].[RfidTagRecord].Uid = @Uid
		END

		IF (@Cycles > 0 AND @GetAge = 1 AND @GetRecord = 1 AND @Expired = 0 AND @Uid <> '00 00 00 00 00 00 00 00')
		BEGIN
			SELECT @dateofbirth = MIN(TimeStamped) From [dbo].[RfidTagRecord] Where [dbo].[RfidTagRecord].Uid = @Uid 
			SELECT @years=datediff(year,@dateofbirth,@TimeStamped)-- To find Years  
			SELECT @months=datediff(month,@dateofbirth,@TimeStamped)-(datediff(year,@dateofbirth,@TimeStamped)*12)  -- To Find Months  
			SELECT @days=datepart(d,@TimeStamped)-datepart(d,@dateofbirth)-- To Find Days  
			SET @Age = @years  +'y ' +@months +'m '+@days   +'d'
		END
		ELSE IF(@Expired = 1) 
		BEGIN
			SET @Age = 'Expired';
		END
		ELSE
		BEGIN
			SET @Age = '0y 0m 0d'
		END

		INSERT INTO [dbo].[RfidTagRecord]
		(
        TimeStamped,
        Uid,
        DataOk,
		VisionOk,
		VisionCause,
		VisionScore,
		Cycles,
		Age			 
		)
		VALUES
		(
        @TimeStamped,
        @Uid,
        @DataOk,
		@VisionOk,
        @VisionCause,
		@VisionScore,
		@Cycles,
		@Age	
		)

	IF (@GetRecord = 1)
	BEGIN
    SELECT TOP 30
      CONVERT(VARCHAR(31), TimeStamped ,121),
      Uid = IsNull(Uid,''),
	  (SELECT TOP 1 [dbo].[RfidTagResult].Result FROM [dbo].[RfidTagResult] WHERE [dbo].[RfidTagRecord].DataOk = [dbo].[RfidTagResult].Id),
      (SELECT TOP 1 [dbo].[RfidTagResult].Result FROM [dbo].[RfidTagResult] WHERE [dbo].[RfidTagRecord].VisionOk = [dbo].[RfidTagResult].Id),
      (SELECT TOP 1 [dbo].[VisionCause].Cause FROM [dbo].[VisionCause] WHERE [dbo].[RfidTagRecord].VisionCause = [dbo].[VisionCause].Id),      
	  VisionScore = IsNull(VisionScore,0),
	  Cycles = IsNull(Cycles,0),
	  Age = IsNull(Age,'')
	  FROM [dbo].[RfidTagRecord]
      WHERE TimeStamped >= DATEADD(mi, -1, GETDATE())
      ORDER BY TimeStamped Desc
	END

    COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;
 
    DECLARE @ErrorNumber INT = ERROR_NUMBER();
    DECLARE @ErrorLine INT = ERROR_LINE();
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
 
    PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
    PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
  END CATCH
END;
GO