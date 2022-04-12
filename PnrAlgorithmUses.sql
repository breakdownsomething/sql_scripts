
 
 CREATE TABLE Groups (
        GROP_ID              tinyint NOT NULL,
        GROUP_DESCRIPTION    VARCHAR(80) NOT NULL
 )
go
 
 
 ALTER TABLE Groups
        ADD PRIMARY KEY (GROP_ID)
go
 
 
 CREATE TABLE ReportAlgorithmArc (
        DATE_ID              smalldatetime NOT NULL,
        RSF_ID               INTEGER NOT NULL,
        RCF_ID               INTEGER NOT NULL,
        VERSION_NUMBER       CHAR(4) NOT NULL,
        DATA_SET_SIGN        bit NOT NULL,
        COMMENTS             VARCHAR(80) NOT NULL,
        PROGRAMMERS_ID       INTEGER NOT NULL,
        FORM_ID              smallint NOT NULL,
        GROP_ID              tinyint NOT NULL
 )
go
 
 
 ALTER TABLE ReportAlgorithmArc
        ADD PRIMARY KEY (DATE_ID, RSF_ID, RCF_ID, FORM_ID, GROP_ID)
go
 
 
 CREATE TABLE ReportForms (
        FORM_ID              smallint NOT NULL,
        FORM_NAME            VARCHAR(30) NOT NULL,
        FORM_DESCRIPTION     VARCHAR(80) NOT NULL
 )
go
 
 
 ALTER TABLE ReportForms
        ADD PRIMARY KEY (FORM_ID)
go
 
 
 ALTER TABLE ReportAlgorithmArc
        ADD FOREIGN KEY (GROP_ID)
                              REFERENCES Groups
go
 
 
 ALTER TABLE ReportAlgorithmArc
        ADD FOREIGN KEY (FORM_ID)
                              REFERENCES ReportForms
go
 
 