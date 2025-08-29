-- Create Database Homework4
IF DB_ID(N'Homework4') IS NULL
BEGIN
    CREATE DATABASE Homework4;
END
GO

-- Use DB
USE Homework4;
GO


-- students table
CREATE TABLE students (
	studentID INT PRIMARY KEY IDENTITY(1,1),
	firstName VARCHAR(50) NOT NULL,
	lastName VARCHAR(50) NOT NULL,
	gender VARCHAR(10),
	DateOfBirth DATE,
	major VARCHAR(50),
	department VARCHAR(50),
	HeightInCm DECIMAL(5, 2),
	WeightInPounds DECIMAL(5, 2)
	);

-- Task 1: Create the Database structure from class
-- classes table
CREATE TABLE classes (
	classID INT PRIMARY KEY,
	className VARCHAR(50) NOT NULL,
	description VARCHAR(300)
	);

-- enrollments table
CREATE TABLE enrollments (
	enrollmentID INT PRIMARY KEY IDENTITY(1,1),
	studentID INT NOT NULL,
	classID INT NOT NULL,
	FOREIGN KEY (studentID) REFERENCES students(studentID),
	FOREIGN KEY (classID) REFERENCES classes(classID)
	);

-- Task 2: Create a Grades Table, that maps enrollment to letter grade, i.e., A+,A, B+..
-- grades table
CREATE TABLE Grades (
	gradeID INT PRIMARY KEY IDENTITY(1,1),
	enrollmentID INT NOT NULL UNIQUE,
	letterGrade VARCHAR(2) NOT NULL,
	gradePoints DECIMAL(3, 2) NOT NULL, -- for calculate GPA
	CONSTRAINT FK_Grades_Enrollments FOREIGN KEY (enrollmentID) REFERENCES enrollments(enrollmentID)
	);

-- Task 3: Populate the student table with 1000+ records using iteration
BEGIN TRANSACTION;  -- Start a transaction

BEGIN TRY
    -- =========================================================
    -- STEP 1: Generate 1000 students
    -- =========================================================
    DECLARE @counter INT = 1;
    DECLARE @gender VARCHAR(10);
    DECLARE @firstName VARCHAR(50);
	DECLARE @lastName VARCHAR(50);
    DECLARE @dob DATE;
    DECLARE @major VARCHAR(50);
    DECLARE @department VARCHAR(50);
    DECLARE @height DECIMAL(5,2);
    DECLARE @weight DECIMAL(5,2);

    WHILE @counter <= 1000
    BEGIN
        -- Gender
        SET @gender = CASE WHEN ABS(CHECKSUM(NEWID())) % 2 = 0 THEN 'Male' ELSE 'Female' END;

        -- Names - Alternative approach using modulo with better bounds checking
        DECLARE @randomNum1 INT = ABS(CHECKSUM(NEWID()));
        DECLARE @randomNum2 INT = ABS(CHECKSUM(NEWID()));
        
        -- Ensure we get values 1-12 for firstName (12 options)
        DECLARE @firstNameIndex INT = (@randomNum1 % 12) + 1;
        -- Ensure we get values 1-10 for lastName (10 options) 
        DECLARE @lastNameIndex INT = (@randomNum2 % 10) + 1;
        
		SET @firstName = CHOOSE(@firstNameIndex,
		'Anh','Linh','Chi','Long','Dung','Ngoc','Trang','Tuan','Minh','Huyen','Ha','Son');

		SET @lastName = CHOOSE(@lastNameIndex,
		'Nguyen','Tran','Le','Pham','Hoang','Vu','Dang','Do','Bui','Mai');

        -- Safety check - if somehow NULL, set default values
        IF @firstName IS NULL SET @firstName = 'Anh';
        IF @lastName IS NULL SET @lastName = 'Nguyen';


        -- Date of Birth: Age 18-25
        SET @dob = DATEADD(DAY, -1 * (6570 + ABS(CHECKSUM(NEWID())) % 2556), GETDATE());

        -- Major & Department
        SET @major = CHOOSE((ABS(CHECKSUM(NEWID())) % 6) + 1,
            'Computer Science','Business Administration','Data Analytics','Engineering','Arts','Medicine');

        IF @major IN ('Computer Science','Data Analytics','Engineering')
            SET @department = 'School of Technology';
        ELSE IF @major = 'Business Administration'
            SET @department = 'School of Economics';
        ELSE
            SET @department = 'School of Social Sciences and Humanities';

        -- Height & Weight
        IF @gender = 'Male'
        BEGIN
            SET @height = CAST(165 + (ABS(CHECKSUM(NEWID())) % 21) AS DECIMAL(5,2)); -- 165–185 cm
            SET @weight = CAST(120 + (ABS(CHECKSUM(NEWID())) % 81) AS DECIMAL(5,2)); -- 120–200 lbs
        END
        ELSE
        BEGIN
            SET @height = CAST(155 + (ABS(CHECKSUM(NEWID())) % 16) AS DECIMAL(5,2)); -- 155–170 cm
            SET @weight = CAST(100 + (ABS(CHECKSUM(NEWID())) % 61) AS DECIMAL(5,2)); -- 100–160 lbs
        END

        -- Insert student
        INSERT INTO students(firstName,lastName,gender,DateOfBirth,major,department,HeightInCm,WeightInPounds)
        VALUES(@firstName,@lastName,@gender,@dob,@major,@department,@height,@weight);

        SET @counter = @counter + 1;
    END
COMMIT TRANSACTION;  -- Commit all inserts
    PRINT 'Transaction committed successfully. 1000 students created and enrolled into classes.';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION; -- Rollback if any error occurs
    PRINT 'Error occurred. Transaction rolled back.';
    SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage;
END CATCH
-- Print completion message
PRINT 'Successfully inserted 1000 students with diverse random data.';

SELECT TOP 20 * FROM students ORDER BY DateOfBirth ASC;
SELECT * FROM students;



-- Task 4: POPULATE 50 DETAILED CLASS RECORDS
BEGIN TRANSACTION;

BEGIN TRY
-- General & Foundational Courses
    INSERT INTO classes (classID, className, description) VALUES
    (1001, 'ENG101: English Composition I', 'Develops skills in critical reading, writing, and thinking. Focuses on argumentative and analytical essays.'),
    (1002, 'MATH110: College Algebra', 'Covers linear and quadratic equations, functions, graphing, and systems of equations.'),
    (1003, 'PHY120: General Physics I', 'An introduction to classical mechanics, including kinematics, dynamics, work, energy, and momentum.'),
    (1004, 'CHEM130: General Chemistry I', 'Fundamental principles of chemistry, including atomic structure, bonding, and chemical reactions.'),
    (1005, 'HIS101: World History to 1500', 'A survey of major world civilizations from ancient times to 1500.');

    -- Computer Science & Data Analytics
    INSERT INTO classes (classID, className, description) VALUES
    (2001, 'CS101: Introduction to Programming', 'Fundamentals of programming using Python. Covers variables, control structures, functions, and basic data structures.'),
    (2002, 'CS202: Data Structures and Algorithms', 'In-depth study of data structures like arrays, linked lists, stacks, queues, trees, and graphs.'),
    (2003, 'CS250: Database Systems', 'Introduction to database design, modeling, SQL, and relational database management systems.'),
    (2004, 'CS310: Operating Systems', 'Principles of operating system design, including process management, memory management, and file systems.'),
    (2005, 'CS360: Software Engineering', 'Covers the software development lifecycle, including requirements, design, testing, and project management.'),
    (2006, 'DA201: Introduction to Data Analytics', 'Covers the fundamentals of the data analytics lifecycle, from data extraction to visualization.'),
    (2007, 'DA310: Machine Learning', 'Introduction to machine learning concepts, algorithms, and applications.'),
    (2008, 'DA325: Data Visualization', 'Techniques and tools for creating effective and insightful data visualizations using Tableau and Python.'),
    (2009, 'CS451: Artificial Intelligence', 'Survey of artificial intelligence topics, including search, knowledge representation, and neural networks.'),
    (2010, 'CS470: Computer Networks', 'Study of network protocols, architecture, and applications, including the TCP/IP suite.');

    -- Engineering
    INSERT INTO classes (classID, className, description) VALUES
    (2501, 'ENGR100: Introduction to Engineering', 'Overview of various engineering disciplines and the engineering design process.'),
    (2502, 'ENGR210: Statics and Dynamics', 'Analysis of forces on particles and rigid bodies in static equilibrium and in motion.'),
    (2503, 'ENGR220: Thermodynamics', 'Principles of thermodynamics, including energy, heat, work, and the laws of thermodynamics.'),
    (2504, 'ENGR330: Electric Circuits', 'Analysis of DC and AC circuits, including resistors, capacitors, inductors, and operational amplifiers.'),
    (2505, 'ENGR350: Materials Science', 'Study of the properties, structure, and processing of engineering materials.');

    -- Business Administration & Economics
    INSERT INTO classes (classID, className, description) VALUES
    (3001, 'BA101: Introduction to Business', 'Survey of business functions, including management, marketing, finance, and accounting.'),
    (3002, 'ACCT201: Principles of Financial Accounting', 'Introduction to basic principles and concepts of financial accounting.'),
    (3003, 'ACCT202: Principles of Managerial Accounting', 'Focus on the use of accounting information for internal planning and control.'),
    (3004, 'FIN301: Corporate Finance', 'Principles of financial management, including financial analysis, valuation, and capital budgeting.'),
    (3005, 'MKTG301: Principles of Marketing', 'Overview of marketing concepts, including market research, consumer behavior, and marketing strategy.'),
    (3006, 'MGMT350: Organizational Behavior', 'Study of individual and group behavior within organizations.'),
    (3007, 'ECON201: Microeconomics', 'Analysis of individual economic behavior, including supply, demand, and market structures.'),
    (3008, 'ECON202: Macroeconomics', 'Analysis of the economy as a whole, including GDP, inflation, unemployment, and monetary policy.'),
    (3009, 'BA450: Business Strategy', 'Capstone course focusing on strategic management and competitive analysis.'),
    (3010, 'BA460: International Business', 'Examination of challenges and opportunities of conducting business in a global environment.');

    -- Medicine
    INSERT INTO classes (classID, className, description) VALUES
    (4001, 'MED101: Introduction to Medical Science', 'Overview of the medical field, terminology, and healthcare systems.'),
    (4002, 'BIO201: Human Anatomy and Physiology I', 'Study of the structure and function of the human body, covering the integumentary, skeletal, muscular, and nervous systems.'),
    (4003, 'BIO202: Human Anatomy and Physiology II', 'Continuation of the study of the human body, covering the endocrine, cardiovascular, respiratory, digestive, and urinary systems.'),
    (4004, 'BIO310: Microbiology', 'Study of microorganisms, including bacteria, viruses, fungi, and protozoa.'),
    (4005, 'CHEM351: Organic Chemistry I', 'Study of the structure, properties, and reactions of organic compounds.'),
    (4006, 'CHEM352: Organic Chemistry II', 'Continuation of Organic Chemistry I with a focus on more complex reaction mechanisms.'),
    (4007, 'MED410: Pharmacology', 'Introduction to principles of drug action and their effects on the human body.'),
    (4008, 'MED450: Introduction to Pathology', 'Study of the causes and effects of diseases.'),
    (4009, 'MED480: Medical Ethics', 'Examination of ethical issues and dilemmas in the practice of medicine.'),
    (4010, 'BIO490: Genetics', 'Principles of heredity and variation in living organisms.');

    -- Arts & Social Sciences
    INSERT INTO classes (classID, className, description) VALUES
    (5001, 'ART100: Art History Survey I', 'Survey of art and architecture from the prehistoric period through the Middle Ages.'),
    (5002, 'MUS101: Music Appreciation', 'Introduction to the history and elements of Western music.'),
    (5003, 'PHIL201: Introduction to Philosophy', 'Examination of fundamental philosophical questions concerning knowledge, reality, and morality.'),
    (5004, 'PSY101: General Psychology', 'Introduction to the scientific study of behavior and mental processes.'),
    (5005, 'SOC101: Introduction to Sociology', 'Study of human society, social behavior, and social structures.'),
    (5006, 'LIT210: Survey of World Literature', 'Survey of major literary works from around the world.'),
    (5007, 'PSCI201: Introduction to Political Science', 'Introduction to the study of politics, government, and public policy.'),
    (5008, 'ART250: Drawing I', 'Fundamentals of drawing, focusing on observation, composition, and technique.'),
    (5009, 'THTR101: Introduction to Theatre', 'Survey of the history, theory, and practice of theatre.'),
    (5010, 'COM201: Public Speaking', 'Development of skills in preparing and delivering effective public presentations.');
    COMMIT TRANSACTION; 
    PRINT 'Successfully inserted 50 detailed class records.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION; 
    PRINT 'Error occurred. Transaction rolled back.';
    -- Optional: show error info
    SELECT ERROR_NUMBER() AS ErrorNumber,
           ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

SELECT * FROM classes;
-- Task 5: Enroll every student in at least one class but make sure at least half the student population is enrolled in 2 or more classes
BEGIN TRANSACTION;
BEGIN TRY
    PRINT 'Starting Task 5: Enrolling students into classes.';
    
    DECLARE @classID INT;
    DECLARE @numExtraClasses INT;
    DECLARE @totalStudents INT = (SELECT COUNT(*) FROM students);
    DECLARE @halfStudents INT = CEILING(@totalStudents * 0.6); -- enroll 60% students with extra classes
    
    PRINT CONCAT('Total students: ', @totalStudents);
    PRINT CONCAT('Students to get extra classes: ', @halfStudents);
    
    -- ====================================================================
    -- STEP 1: Ensure every student has at least 1 class
    -- ====================================================================
    PRINT 'Step 1: Enrolling every student with 1 random class...';
    
    -- Insert 1 class for every student using their actual studentID
    INSERT INTO enrollments(studentID, classID)
    SELECT 
        s.studentID,
        (SELECT TOP 1 classID FROM classes ORDER BY NEWID())
    FROM students s;
    
    PRINT 'Step 1 completed. All students have at least 1 class.';
    
    -- ====================================================================
    -- STEP 2: Enroll at least 60% of students with extra classes
    -- ====================================================================
    PRINT 'Step 2: Enrolling extra classes for 60% of students...';
    
    -- Use cursor to get actual studentIDs (not assume 1,2,3...)
    DECLARE @currentStudentID INT;
    DECLARE @studentCounter INT = 0;
    
    DECLARE student_cursor CURSOR FOR 
    SELECT TOP (@halfStudents) studentID FROM students ORDER BY studentID;

    OPEN student_cursor;
    FETCH NEXT FROM student_cursor INTO @currentStudentID;

    WHILE @@FETCH_STATUS = 0 AND @studentCounter < @halfStudents
    BEGIN
        -- Randomly decide 1 or 2 extra classes
        SET @numExtraClasses = CHOOSE((ABS(CHECKSUM(NEWID())) % 2) + 1, 1, 2);
        
        DECLARE @i INT = 1;
        WHILE @i <= @numExtraClasses
        BEGIN
            -- Select a random class not already enrolled by this student
            SELECT TOP 1 @classID = classID
            FROM classes
            WHERE classID NOT IN (
                SELECT classID FROM enrollments WHERE studentID = @currentStudentID
            )
            ORDER BY NEWID();
            
            -- Only insert if we found an available class
            IF @classID IS NOT NULL
            BEGIN
                INSERT INTO enrollments(studentID, classID)
                VALUES (@currentStudentID, @classID);
            END
            
            SET @i = @i + 1;
        END
        
        SET @studentCounter = @studentCounter + 1;
        FETCH NEXT FROM student_cursor INTO @currentStudentID;
    END

    CLOSE student_cursor;
    DEALLOCATE student_cursor;
    
    -- ====================================================================
    -- VERIFICATION: Check if requirements are met
    -- ====================================================================
    DECLARE @totalEnrollments INT = (SELECT COUNT(*) FROM enrollments);
    DECLARE @studentsWithMultipleClasses INT = (
        SELECT COUNT(*) 
        FROM (
            SELECT studentID 
            FROM enrollments 
            GROUP BY studentID 
            HAVING COUNT(*) >= 2
        ) AS StudentsWithMultiple
    );
    
    PRINT CONCAT('Total enrollments created: ', @totalEnrollments);
    PRINT CONCAT('Students with 2+ classes: ', @studentsWithMultipleClasses);
    PRINT CONCAT('Percentage with multiple classes: ', 
                 CAST(@studentsWithMultipleClasses * 100.0 / @totalStudents AS DECIMAL(5,2)), '%');
    
    -- Verify requirements
    IF @studentsWithMultipleClasses >= CEILING(@totalStudents * 0.5)
        PRINT 'SUCCESS: Requirements met - at least 50% of students have 2+ classes!';
    ELSE
        PRINT 'WARNING: Less than 50% of students have 2+ classes.';
    
    COMMIT TRANSACTION;
    PRINT 'Task 5 completed successfully. All enrollments committed.';
    
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error occurred. Transaction rolled back.';
    SELECT ERROR_NUMBER() AS ErrorNumber,
           ERROR_MESSAGE() AS ErrorMessage;
END CATCH

-- ====================================================================
-- VERIFY RESULTS
-- Count number of classes per student
WITH StudentEnrollmentCounts AS (
    SELECT studentID, COUNT(classID) AS ClassCount
    FROM enrollments
    GROUP BY studentID
)
SELECT ClassCount AS [NumberOfClasses], COUNT(studentID) AS [NumberOfStudents]
FROM StudentEnrollmentCounts
GROUP BY ClassCount
ORDER BY ClassCount;

-- Show top 20 students with most classes
SELECT TOP 20
    s.studentID,
    s.firstName + ' ' + s.lastName AS FullName,
    COUNT(e.classID) AS NumberOfClasses
FROM students s
JOIN enrollments e ON s.studentID = e.studentID
GROUP BY s.studentID, s.firstName, s.lastName
ORDER BY NumberOfClasses DESC;
GO




-- Task 6: Assign grades for every class enrolled in
SELECT enrollmentID FROM enrollments;
BEGIN TRANSACTION;

BEGIN TRY
    PRINT 'Starting Assigning grades for all enrollments...';

    -- First, clear existing grades if any
    DELETE FROM Grades;

    -- Declare variables
    DECLARE @enrollmentID INT;
    DECLARE @letterGrade VARCHAR(2);
    DECLARE @gradePoints DECIMAL(3,2);

    -- Cursor to iterate over all enrollments
    DECLARE enroll_cursor CURSOR FOR
    SELECT enrollmentID FROM enrollments;

    OPEN enroll_cursor;
    FETCH NEXT FROM enroll_cursor INTO @enrollmentID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Randomly assign a grade based on weighted probability
        -- Example probabilities:
        -- A+ 10%, A 15%, B+ 25%, B 25%, C+ 15%, C 7%, D 3%, F 0%
        DECLARE @rand INT = ABS(CHECKSUM(NEWID())) % 100 + 1;

        IF @rand <= 10
        BEGIN SET @letterGrade = 'A+'; SET @gradePoints = 4.0; END
        ELSE IF @rand <= 25
        BEGIN SET @letterGrade = 'A'; SET @gradePoints = 3.7; END
        ELSE IF @rand <= 50
        BEGIN SET @letterGrade = 'B+'; SET @gradePoints = 3.3; END
        ELSE IF @rand <= 75
        BEGIN SET @letterGrade = 'B'; SET @gradePoints = 3.0; END
        ELSE IF @rand <= 90
        BEGIN SET @letterGrade = 'C+'; SET @gradePoints = 2.5; END
        ELSE IF @rand <= 97
        BEGIN SET @letterGrade = 'C'; SET @gradePoints = 2.0; END
        ELSE IF @rand <= 100
        BEGIN SET @letterGrade = 'D'; SET @gradePoints = 1.0; END

        -- Insert grade
        INSERT INTO Grades(enrollmentID, letterGrade, gradePoints)
        VALUES (@enrollmentID, @letterGrade, @gradePoints);

        -- Next enrollment
        FETCH NEXT FROM enroll_cursor INTO @enrollmentID;
    END

    CLOSE enroll_cursor;
    DEALLOCATE enroll_cursor;

    COMMIT TRANSACTION;
    PRINT 'Grades has assigned for all enrollments.';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error occurred. Transaction rolled back.';
    SELECT ERROR_NUMBER() AS ErrorNumber,
           ERROR_MESSAGE() AS ErrorMessage;
END CATCH

-- Verify grades
SELECT * FROM Grades Order by gradePoints desc;

SELECT letterGrade, COUNT(*) AS CountPerGrade
FROM Grades
GROUP BY letterGrade
ORDER BY CountPerGrade DESC;

SELECT TOP 20 e.enrollmentID, s.firstName + ' ' + s.lastName AS FullName,
       c.className, g.letterGrade, g.gradePoints
FROM Grades g
JOIN enrollments e ON g.enrollmentID = e.enrollmentID
JOIN students s ON e.studentID = s.studentID
JOIN classes c ON e.classID = c.classID
ORDER BY g.enrollmentID;



-- Task 7: Write a stored procedure to compute the GPA
CREATE PROCEDURE ComputeGPA
    @StudentID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        s.studentID,
        s.firstName + ' ' + s.lastName AS FullName,
        CAST(AVG(g.gradePoints) AS DECIMAL(3,2)) AS GPA
    FROM students s
    JOIN enrollments e ON s.studentID = e.studentID
    JOIN Grades g ON e.enrollmentID = g.enrollmentID
    WHERE (@StudentID IS NULL OR s.studentID = @StudentID)
    GROUP BY s.studentID, s.firstName, s.lastName
    ORDER BY GPA DESC;
END;
GO

EXEC ComputeGPA;
EXEC ComputeGPA @StudentID = 5035;

/*
Task 8: Write a stored procedure to compute the descriptive statistics of the student population, viz. Mean , Variance, Standard Deviation, Mode of the following Attributes
a.) G.P.A    b.) HeightInCm   c.) WeightInPounds 
Hint: G.P.A is a derived attribute of every student, it depends on their grade in enrolled classes
*/

CREATE OR ALTER PROCEDURE ComputeDescriptiveStatistics
    @Gender VARCHAR(10) = NULL -- Optional parameter to filter by gender
AS
BEGIN
    SET NOCOUNT ON;

    -- Step 1: Use a CTE to calculate GPA and store the results in a temporary table (#StudentStatsData).
    -- The temp table exists only for this session and will be dropped automatically if not dropped manually.
    IF OBJECT_ID('tempdb..#StudentStatsData') IS NOT NULL
        DROP TABLE #StudentStatsData;

    WITH StudentStats AS (
        SELECT
            s.studentID,
            s.HeightInCm,
            s.WeightInPounds,
            s.gender,
            CAST(AVG(g.gradePoints) AS DECIMAL(10, 2)) AS GPA
        FROM
            students s
        JOIN enrollments e ON s.studentID = e.studentID
        JOIN Grades g ON e.enrollmentID = g.enrollmentID
        GROUP BY
            s.studentID, s.HeightInCm, s.WeightInPounds, s.gender
    )
    -- Save the processed data into the temp table for later use.
    SELECT *
    INTO #StudentStatsData
    FROM StudentStats
    WHERE (@Gender IS NULL OR gender = @Gender);


    -- Step 2: Declare variables to store the statistical results.
    DECLARE
        @MeanGPA DECIMAL(10, 2), @StdevGPA DECIMAL(10, 2), @VarGPA DECIMAL(10, 2), @ModeGPA DECIMAL(10, 2),
        @MeanHeight DECIMAL(10, 2), @StdevHeight DECIMAL(10, 2), @VarHeight DECIMAL(10, 2), @ModeHeight DECIMAL(10, 2),
        @MeanWeight DECIMAL(10, 2), @StdevWeight DECIMAL(10, 2), @VarWeight DECIMAL(10, 2), @ModeWeight DECIMAL(10, 2);

    -- Step 3: Calculate all statistics from the temporary table.
    -- Calculations for GPA
    SELECT
        @MeanGPA = AVG(GPA),
        @StdevGPA = STDEV(GPA),
        @VarGPA = VAR(GPA)
    FROM #StudentStatsData;
    SELECT TOP 1 @ModeGPA = GPA FROM #StudentStatsData WHERE GPA IS NOT NULL GROUP BY GPA ORDER BY COUNT(*) DESC;

    -- Calculations for Height
    SELECT
        @MeanHeight = AVG(HeightInCm),
        @StdevHeight = STDEV(HeightInCm),
        @VarHeight = VAR(HeightInCm)
    FROM #StudentStatsData;
    SELECT TOP 1 @ModeHeight = HeightInCm FROM #StudentStatsData WHERE HeightInCm IS NOT NULL GROUP BY HeightInCm ORDER BY COUNT(*) DESC;

    -- Calculations for Weight
    SELECT
        @MeanWeight = AVG(WeightInPounds),
        @StdevWeight = STDEV(WeightInPounds),
        @VarWeight = VAR(WeightInPounds)
    FROM #StudentStatsData;
    SELECT TOP 1 @ModeWeight = WeightInPounds FROM #StudentStatsData WHERE WeightInPounds IS NOT NULL GROUP BY WeightInPounds ORDER BY COUNT(*) DESC;

    -- Step 4: Present the results as a clean report table.
    SELECT 'Mean' AS Statistic, @MeanGPA AS GPA_Value, @MeanHeight AS Height_Value, @MeanWeight AS Weight_Value
    UNION ALL
    SELECT 'Standard Deviation' AS Statistic, @StdevGPA, @StdevHeight, @StdevWeight
    UNION ALL
    SELECT 'Variance' AS Statistic, @VarGPA, @VarHeight, @VarWeight
    UNION ALL
    SELECT 'Mode' AS Statistic, @ModeGPA, @ModeHeight, @ModeWeight;

    -- Clean up the temp table after use.
    DROP TABLE #StudentStatsData;

END;
GO

SELECT gender from students;
EXEC ComputeDescriptiveStatistics;
EXEC ComputeDescriptiveStatistics @Gender = 'Male';

-- Task 9: Create a VIEW to show how height distributes over Gender
CREATE OR ALTER VIEW vHeightDistributionByGender
AS
-- Using TOP 100 PERCENT is a common technique to allow ORDER BY in a VIEW definition,
-- ensuring the default output is always sorted logically.
SELECT TOP 100 PERCENT
    HeightRange,
    MaleCount,
    FemaleCount,
    TotalCount
FROM (
    -- This inner query performs the aggregation (counting and grouping).
    SELECT
        HeightRange,
        SortOrder,
        COUNT(CASE WHEN gender = 'Male' THEN 1 END) AS MaleCount,
        COUNT(CASE WHEN gender = 'Female' THEN 1 END) AS FemaleCount,
        COUNT(*) AS TotalCount
    FROM (
        -- This innermost query categorizes each student's height into a specific bin.
        SELECT
            gender,
            HeightInCm,
            CASE
                WHEN HeightInCm < 160 THEN 'Below 160cm'
                WHEN HeightInCm < 165 THEN '160cm - 164.9cm'
                WHEN HeightInCm < 170 THEN '165cm - 169.9cm'
                WHEN HeightInCm < 175 THEN '170cm - 174.9cm'
                WHEN HeightInCm < 180 THEN '175cm - 179.9cm'
                ELSE                     '180cm and Above'
            END AS HeightRange,
            -- A numeric column to ensure correct sorting of the text-based ranges.
            CASE
                WHEN HeightInCm < 160 THEN 1
                WHEN HeightInCm < 165 THEN 2
                WHEN HeightInCm < 170 THEN 3
                WHEN HeightInCm < 175 THEN 4
                WHEN HeightInCm < 180 THEN 5
                ELSE                     6
            END AS SortOrder
        FROM
            students
        WHERE
            HeightInCm IS NOT NULL AND gender IS NOT NULL
    ) AS BinnedData
    GROUP BY
        HeightRange, SortOrder
) AS AggregatedData
ORDER BY
    SortOrder;
GO

SELECT * FROM vHeightDistributionByGender;

-- Task 10: Write a store procedure to compute the distribution of G.P.A over Gender
CREATE OR ALTER PROCEDURE ComputeGpaDistributionByGender
AS
BEGIN
    -- Standard optimization to prevent row count messages
    SET NOCOUNT ON;

    -- Step 1: Use a CTE to get the calculated GPA and gender for each student.
    -- This is the base data for our analysis.
    WITH StudentGpaData AS (
        SELECT
            s.gender,
            CAST(AVG(g.gradePoints) AS DECIMAL(3, 2)) AS GPA
        FROM
            students s
        JOIN enrollments e ON s.studentID = e.studentID
        JOIN Grades g ON e.enrollmentID = g.enrollmentID
        GROUP BY
            s.studentID, s.gender
    ),
    -- Step 2: Use another CTE to categorize each student's GPA into defined ranges (bins).
    -- This makes the final query cleaner and more readable.
    GpaDistributionSource AS (
        SELECT
            gender,
            -- This CASE statement creates the descriptive GPA range labels.
            CASE
                WHEN GPA >= 3.5 THEN '3.50 - 4.00 (Excellent)'
                WHEN GPA >= 3.0 THEN '3.00 - 3.49 (Good)'
                WHEN GPA >= 2.5 THEN '2.50 - 2.99 (Average)'
                WHEN GPA >= 2.0 THEN '2.00 - 2.49 (Below Average)'
                ELSE                'Below 2.00 (Poor)'
            END AS GpaRange,
            -- This CASE statement creates a numeric order for sorting the text-based ranges.
            CASE
                WHEN GPA >= 3.5 THEN 1
                WHEN GPA >= 3.0 THEN 2
                WHEN GPA >= 2.5 THEN 3
                WHEN GPA >= 2.0 THEN 4
                ELSE                5
            END AS SortOrder
        FROM
            StudentGpaData
        WHERE
            GPA IS NOT NULL -- Ensure we only consider students with a calculated GPA
    )
    -- Step 3: Pivot the data using conditional aggregation to get counts for each gender
    -- and group by the GPA ranges to create the final report.
    SELECT
        GpaRange,
        -- This is the conditional aggregation. It counts a record only if the gender matches.
        COUNT(CASE WHEN gender = 'Male' THEN 1 END) AS MaleCount,
        COUNT(CASE WHEN gender = 'Female' THEN 1 END) AS FemaleCount,
        -- Total count for the range.
        COUNT(*) AS TotalCount
    FROM
        GpaDistributionSource
    GROUP BY
        GpaRange, SortOrder
    ORDER BY
        SortOrder; -- Order by the numeric sort order to ensure a logical display (Excellent to Poor).

END;
GO

EXEC ComputeGpaDistributionByGender;

-- Task 11: Describe what you learned from this homework 


/*
SELECT * FROM classes;
TRUNCATE TABLE students;
TRUNCATE TABLE enrollments;
TRUNCATE TABLE Grades;
SELECT * FROM students;
SELECT * FROM enrollments;
DROP table Grades;
DROP table enrollments;
*/
