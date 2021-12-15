GO

DECLARE
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

EXEC	dbo.USP_Example
		@TimeStamped			= '2020-01-11 15:28:54.979',
		@Uid	                = 'E0 12 23 45 67 89 78 12',
        @DataOk				    = 0,
		@VisionOk		        = 1,
		@VisionCause		    = 1,
		@VisionScore		    = 99,
        @GetCycles              = 0,
        @GetAge                 = 0,
        @GetRecord              = 1,
        @Expired                = 0