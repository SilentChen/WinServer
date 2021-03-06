CREATE PROCEDURE [dbo].[USP_OTHERCHARGE]
@ORDERNO	BIGINT,			--订单号
@ACCOUNT	VARCHAR(50),	--帐号ID
@QUANTITY	INT				--充值元宝数
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @RESULT CHAR(4)
	DECLARE @ACCOUNTID INT

	SELECT @ACCOUNTID = 0, @RESULT = '0000'
	IF @QUANTITY <= 0
		SET @RESULT = '0001'

	IF @RESULT = '0000' AND 
		EXISTS(SELECT 1 FROM GAME_CHARGE_HISTORY WHERE SEQUENCE = @ORDERNO)
		SET @RESULT = '0010'

	IF @RESULT = '0000'
	BEGIN
		SELECT @ACCOUNTID = ACCOUNTID FROM SXZ_ACCOUNTDB.DBO.TBL_ACCOUNT WHERE ACCOUNT = @ACCOUNT
		IF @@ROWCOUNT = 0
			SET @RESULT = '0003'
	END

	IF @RESULT = '0000'
	BEGIN
		BEGIN TRAN OTHERCHARGE

		IF NOT EXISTS(SELECT 1 FROM T_USER_PAY WHERE ACCOUNTID = @ACCOUNTID)
			INSERT T_USER_PAY SELECT @ACCOUNTID, 0, 0, 0

		UPDATE T_USER_PAY SET PAY_POINTS = PAY_POINTS + @QUANTITY
			WHERE ACCOUNTID = @ACCOUNTID
		IF @@ERROR <> 0 
			SET @RESULT = '0004'

		IF @RESULT = '0000'
		BEGIN
			INSERT INTO GAME_CHARGE_HISTORY(SEQUENCE, CREATEDATE, CHECKDATE, ACCOUNTID,
					PAY_POINTS, FREE_POINTS, HONOR, CARDTYPE, CARDNO)
				SELECT @ORDERNO, GETDATE(), GETDATE(), @ACCOUNTID, @QUANTITY, 0, 0, '0', '0'
			IF @@ERROR <> 0 
				SET @RESULT = '0004'
		END

		IF @RESULT = '0000'
			COMMIT TRAN OTHERCHARGE
		ELSE
			ROLLBACK TRAN OTHERCHARGE
	END

	SELECT @RESULT
END