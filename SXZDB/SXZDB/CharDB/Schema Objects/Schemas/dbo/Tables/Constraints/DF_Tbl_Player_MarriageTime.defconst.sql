﻿ALTER TABLE [dbo].[Tbl_Player]
    ADD CONSTRAINT [DF_Tbl_Player_MarriageTime] DEFAULT ((0)) FOR [MarriageTime];
