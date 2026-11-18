USE Academy;
GO

-- 1. Назви аудиторій, де читає лекції викладач «Edward Hopper»
SELECT DISTINCT lr.Name
FROM LectureRooms lr
JOIN Schedules s ON lr.Id = s.LectureRoomId
JOIN Lectures l ON s.LectureId = l.Id
JOIN Teachers t ON l.TeacherId = t.Id
WHERE t.Name = N'Edward' AND t.Surname = N'Hopper';

-- 2. Прізвища асистентів, які читають лекції у групі «F505»
SELECT DISTINCT t.Surname
FROM Teachers t
JOIN Assistants a ON t.Id = a.TeacherId
JOIN Lectures l ON t.Id = l.TeacherId
JOIN GroupsLectures gl ON l.Id = gl.LectureId
JOIN Groups g ON gl.GroupId = g.Id
WHERE g.Name = N'F505';

-- 3. Дисципліни, які читає викладач «Alex Carmack» для груп 5 курсу
SELECT DISTINCT sub.Name
FROM Subjects sub
JOIN Lectures l ON sub.Id = l.SubjectId
JOIN Teachers t ON l.TeacherId = t.Id
JOIN GroupsLectures gl ON l.Id = gl.LectureId
JOIN Groups g ON gl.GroupId = g.Id
WHERE t.Name = N'Alex'
  AND t.Surname = N'Carmack'
  AND g.Year = 5;

-- 4. Прізвища викладачів, які не читають лекції у понеділок
SELECT DISTINCT t.Surname
FROM Teachers t
WHERE t.Id NOT IN (
    SELECT l.TeacherId
    FROM Lectures l
    JOIN Schedules s ON l.Id = s.LectureId
    WHERE s.DayOfWeek = 1
);

-- 5. Назви аудиторій із зазначенням корпусів, де немає лекцій у середу 2-го тижня на 3-й парі
SELECT lr.Name, lr.Building
FROM LectureRooms lr
WHERE lr.Id NOT IN (
    SELECT s.LectureRoomId
    FROM Schedules s
    WHERE s.DayOfWeek = 3
      AND s.Week = 2
      AND s.Class = 3
);

-- 6. Повні імена викладачів факультету «Computer Science», які не курирують групи кафедри «Software Development»
SELECT DISTINCT t.Name + N' ' + t.Surname AS FullName
FROM Teachers t
JOIN Lectures l ON t.Id = l.TeacherId
JOIN GroupsLectures gl ON l.Id = gl.LectureId
JOIN Groups g ON gl.GroupId = g.Id
JOIN Departments d ON g.DepartmentId = d.Id
JOIN Faculties f ON d.FacultyId = f.Id
WHERE f.Name = N'Computer Science'
  AND t.Id NOT IN (
      SELECT c.TeacherId
      FROM Curators c
      JOIN GroupsCurators gc ON c.Id = gc.CuratorId
      JOIN Groups g2 ON gc.GroupId = g2.Id
      JOIN Departments d2 ON g2.DepartmentId = d2.Id
      WHERE d2.Name = N'Software Development'
  );

-- 7. Список номерів усіх корпусів із таблиць факультетів, кафедр та аудиторій
SELECT Building FROM Faculties
UNION
SELECT Building FROM Departments
UNION
SELECT Building FROM LectureRooms;

-- 8. Повні імена викладачів у порядку: декани, завідувачі, викладачі, куратори, асистенти
SELECT FullName
FROM (
    SELECT t.Name + N' ' + t.Surname AS FullName, 1 AS RoleOrder
    FROM Teachers t
    JOIN Deans d ON t.Id = d.TeacherId

    UNION

    SELECT t.Name + N' ' + t.Surname AS FullName, 2 AS RoleOrder
    FROM Teachers t
    JOIN Heads h ON t.Id = h.TeacherId

    UNION

    SELECT t.Name + N' ' + t.Surname AS FullName, 3 AS RoleOrder
    FROM Teachers t

    UNION

    SELECT t.Name + N' ' + t.Surname AS FullName, 4 AS RoleOrder
    FROM Teachers t
    JOIN Curators c ON t.Id = c.TeacherId

    UNION

    SELECT t.Name + N' ' + t.Surname AS FullName, 5 AS RoleOrder
    FROM Teachers t
    JOIN Assistants a ON t.Id = a.TeacherId
) AS OrderedTeachers
ORDER BY RoleOrder;

-- 9. Дні тижня (без повторень), коли є заняття в аудиторіях «A311» та «A104» корпусу 6
SELECT DISTINCT s.DayOfWeek
FROM Schedules s
JOIN LectureRooms lr ON s.LectureRoomId = lr.Id
WHERE lr.Building = 6
  AND lr.Name IN (N'A311', N'A104');