﻿ALTER TABLE [dbo].[Tbl_Pet]
    ADD CONSTRAINT [DF_Tbl_Pet_Happiness] DEFAULT ((0)) FOR [Happiness];

