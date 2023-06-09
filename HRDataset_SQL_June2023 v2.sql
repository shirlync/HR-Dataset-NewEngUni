SELECT *
FROM HRDataset_NewEngUni_June2023..HRDataset

-- Cleaning of data

/* Marital Status */
-- Looks okay
SELECT DISTINCT
	MarriedID
	,MaritalStatusID
	,MaritalDesc
FROM HRDataset_NewEngUni_June2023..HRDataset

/* Employee Status */
SELECT DISTINCT
	EmpStatusID
	,TermReason
	,EmploymentStatus
FROM HRDataset_NewEngUni_June2023..HRDataset

UPDATE HRDataset
SET EmpStatusID = '4'
WHERE EmploymentStatus = 'Terminated for Cause'

UPDATE HRDataset
SET EmpStatusID = '1'
WHERE EmploymentStatus = 'Active'

/* Performance Score */
SELECT DISTINCT
	PerfScoreID
	,PerformanceScore
FROM HRDataset_NewEngUni_June2023..HRDataset

UPDATE HRDataset
SET PerfScoreID = '1'
WHERE PerformanceScore = 'Exceeds'

UPDATE HRDataset
SET PerfScoreID = '2'
WHERE PerformanceScore = 'Fully Meets'

UPDATE HRDataset
SET PerfScoreID = '3'
WHERE PerformanceScore = 'Needs Improvement'

UPDATE HRDataset
SET PerfScoreID = '4'
WHERE PerformanceScore = 'PIP'

/* Gender */
-- Looks okay
SELECT DISTINCT
	GenderID
	,Sex
FROM HRDataset_NewEngUni_June2023..HRDataset

/* Department */
SELECT DISTINCT
	DeptID
	,Department
FROM HRDataset_NewEngUni_June2023..HRDataset

UPDATE HRDataset
SET DeptID = '4'
WHERE Department = 'Software Engineering'

UPDATE HRDataset
SET DeptID = '5'
WHERE Department = 'Production'

/* Manager */
SELECT DISTINCT
	ManagerID
	,ManagerName
FROM HRDataset_NewEngUni_June2023..HRDataset
ORDER BY 2

UPDATE HRDataset
SET ManagerID = '39'
WHERE ManagerName = 'Webster Butler'

UPDATE HRDataset
SET ManagerID = '1'
WHERE ManagerName = 'Brandon R. LeBlanc'

UPDATE HRDataset
SET ManagerID = '22'
WHERE ManagerName = 'Michael Albert'

/* Position */
SELECT DISTINCT
	PositionID
	,Position
FROM HRDataset_NewEngUni_June2023..HRDataset
ORDER BY 2

/*** Questions & Analysis ***/
-- Is there any relationship between who a person works for and their performance score?
SELECT *
FROM HRDataset_NewEngUni_June2023..HRDataset

SELECT
	ManagerName
	,AVG(PerfScoreID) AS avg_score
FROM HRDataset_NewEngUni_June2023..HRDataset
GROUP BY ManagerName
ORDER BY 2

-- What is the overall diversity profile of the organization?
SELECT DISTINCT
	Department
	,RaceDesc
	,HispanicLatino
	--,COUNT(RaceDesc) as num_emp
FROM HRDataset_NewEngUni_June2023..HRDataset
--GROUP BY RaceDesc, Department

SELECT DISTINCT
    Department,
    SUM(CASE WHEN RaceDesc = 'Black or African American' THEN COUNT(RaceDesc) ELSE 0 END) OVER (PARTITION BY Department) AS [Black or African American],
    SUM(CASE WHEN RaceDesc = 'White' THEN COUNT(RaceDesc) ELSE 0 END) OVER (PARTITION BY Department) AS [White],
    SUM(CASE WHEN RaceDesc = 'Asian' THEN COUNT(RaceDesc) ELSE 0 END) OVER (PARTITION BY Department) AS [Asian],
    SUM(CASE WHEN RaceDesc = 'American Indian or Alaska Native' THEN COUNT(RaceDesc) ELSE 0 END) OVER (PARTITION BY Department) AS [American Indian or Alaska Native],
    SUM(CASE WHEN RaceDesc = 'Hispanic' THEN COUNT(RaceDesc) ELSE 0 END) OVER (PARTITION BY Department) AS [Hispanic],
    SUM(CASE WHEN RaceDesc = 'Two or more races' THEN COUNT(RaceDesc) ELSE 0 END) OVER (PARTITION BY Department) AS [Two or more races]
FROM HRDataset_NewEngUni_June2023..HRDataset
GROUP BY Department, RaceDesc

-- What are our best recruiting sources if we want to ensure a diverse organization?
SELECT DISTINCT
    RecruitmentSource,
    SUM(CASE WHEN RaceDesc = 'Black or African American' THEN COUNT(RaceDesc) ELSE 0 END) OVER (PARTITION BY RecruitmentSource) AS [Black or African American],
    SUM(CASE WHEN RaceDesc = 'White' THEN COUNT(RaceDesc) ELSE 0 END) OVER (PARTITION BY RecruitmentSource) AS [White],
    SUM(CASE WHEN RaceDesc = 'Asian' THEN COUNT(RaceDesc) ELSE 0 END) OVER (PARTITION BY RecruitmentSource) AS [Asian],
    SUM(CASE WHEN RaceDesc = 'American Indian or Alaska Native' THEN COUNT(RaceDesc) ELSE 0 END) OVER (PARTITION BY RecruitmentSource) AS [American Indian or Alaska Native],
    SUM(CASE WHEN RaceDesc = 'Hispanic' THEN COUNT(RaceDesc) ELSE 0 END) OVER (PARTITION BY RecruitmentSource) AS [Hispanic],
    SUM(CASE WHEN RaceDesc = 'Two or more races' THEN COUNT(RaceDesc) ELSE 0 END) OVER (PARTITION BY RecruitmentSource) AS [Two or more races]
FROM HRDataset_NewEngUni_June2023..HRDataset
GROUP BY RecruitmentSource, RaceDesc

-- Can we predict who is going to terminate and who isn't? What level of accuracy can we achieve on this?
SELECT *
FROM HRDataset_NewEngUni_June2023..HRDataset

-- Are there areas of the company where pay is not equitable?
SELECT 
	Position
	,State
	,Position
	,RaceDesc
	,Department
	,Sex
	,Salary
FROM HRDataset_NewEngUni_June2023..HRDataset

SELECT
	Sex
	,AVG(Salary)
FROM HRDataset_NewEngUni_June2023..HRDataset
GROUP BY Sex

SELECT
	Position
	,AVG(Salary)
FROM HRDataset_NewEngUni_June2023..HRDataset
GROUP BY Position
ORDER BY 2

SELECT
    Department,
    RaceDesc,
    FORMAT(AVG(Salary), 'C', 'en-US') AS AverageSalary,
    COUNT(Employee_Name) AS EmployeeCount
FROM HRDataset_NewEngUni_June2023..HRDataset
GROUP BY RaceDesc, Department
ORDER BY Department

SELECT
    Department,
    RaceDesc,
    FORMAT(AVG(Salary) OVER (PARTITION BY RaceDesc, Department), 'C', 'en-US') AS AverageSalary,
    COUNT(Employee_Name) OVER (PARTITION BY RaceDesc, Department) AS EmployeeCount
FROM HRDataset_NewEngUni_June2023..HRDataset
ORDER BY Department;

SELECT
    Department,
    [Black or African American],
    [White],
    [Asian],
    [American Indian or Alaska Native],
    [Hispanic],
    [Two or more races]
FROM (
    SELECT
        Department,
        RaceDesc,
        FORMAT(AVG(Salary), 'C', 'en-US') AS AverageSalary
    FROM HRDataset_NewEngUni_June2023..HRDataset
    GROUP BY Department, RaceDesc
) AS SourceTable
PIVOT (
    MAX(AverageSalary)
    FOR RaceDesc IN ([Black or African American], [White], [Asian], [American Indian or Alaska Native], [Hispanic], [Two or more races])
) AS PivotTable
ORDER BY Department;


