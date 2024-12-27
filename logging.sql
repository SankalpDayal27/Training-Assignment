

#FOR MY PROJECT ,I HAD FIVE TABLES:-USER,DOCTOR,DOCTORTYPE,SYMPTOM,APPOINTMENT.THE APPLICATION IS A APPOINTMENT BASED SYSTEM FOR A USER TO ADD,REMOVE,RESCHEDULE APPOINTMENTS
#BY SELECTING A DOCTOR CLOSEST TO THEIR CURRENT LOCATION



#APPOINTMENT TABLE CREATION

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";  
START TRANSACTION;                              
SET time_zone = "+00:00";                            #SET TIMEZONE



CREATE TABLE `appointment` (                          #TABLE SCHEMA CREATION WITH USE OF CONSTRAINTS LIKE NOT NULL,DEFAULT
  `id` int NOT NULL,
  `healthproblem` varchar(50) NOT NULL,
  `dateandtime` timestamp NOT NULL,
  `reminder` timestamp NOT NULL,
  `remindercheck` tinyint(1) NOT NULL DEFAULT '0',
  `user_id` int NOT NULL,
  `doctor_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;              #SPECIFY THE ENGINE THE TABLE WILL USE THAT SUPPORTS TRANSACTIONS,FOREIGN KEY CONTRAINTS ETC ALONG WITH SETTING THE CHARACTER ENCODING 




INSERT INTO `appointment` (`id`, `healthproblem`, `dateandtime`, `reminder`, `remindercheck`, `user_id`, `doctor_id`) VALUES   #INSERT A ROW 
(1, 'diabetes', '2024-08-01 10:15:00', '2024-07-29 10:15:00', 0, 1, 2);


ALTER TABLE `appointment`                         #ALTER TABLE 
  ADD PRIMARY KEY (`id`),                         #ADD PRIMARY KEY USING THE 'id' column
  ADD KEY `fk_appointment2user` (`user_id`),      #ADD INDEX FOR 'user_id' and 'doctor_id' FOR FILTERING
  ADD KEY `fk_appointment2doctor` (`doctor_id`);


ALTER TABLE `appointment`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;    #MODIFY THE 'id' COLUMN TO MAKE IT AUTO INCREAMENTING AND SET NEXT VALUE AS 2


ALTER TABLE `appointment`                         #ADD FOREIGN KEY CONSTRAINT USING DOCTOR AND USER TABLE,ALSO SPECIFY CASCADING OPTIONS ON DELETION AND UPDATION
  ADD CONSTRAINT `fk_appointment2doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctor` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_appointment2user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;                                           #COMMIT THE CHANGES



#Operations(Answers present in log file generated:-log.txt):-

SELECT * FROM User;
SELECT DISTINCT CITY FROM USER;    #find distinct cities
SELECT * FROM USER WHERE GENDER="m" AND CITY="Mumbai";      #Users that are male and live in mumbai
INSERT INTO DOCTOR (`place_id`, `name`, `address`)          #insert 2 doctors
    -> VALUES 
    -> ('KANDIVALI', 'DR.Parker', 'Mahavir Nagar,Kandivali'),
    -> ('Chembur', 'Dr.Mithani', 'Shell Colony,Sahakar Nagar,Chembur');
SELECT ID,USERNAME FROM USER WHERE (GENDER='M' AND CITY='MUMBAI') OR (GENDER='F' AND CITY='jeroom beckstraat'); #find user which are male and live in Mumbai or female and live in jeroom beckstratt
SELECT ID,USERNAME FROM USER WHERE (GENDER='M' AND CITY='MUMBAI') OR (GENDER='F' AND CITY='Antwerpen, Belgien');
SELECT ID,USERNAME,DATEOFBIRTH FROM USER ORDER BY DATEOFBIRTH;  #Arrange users on basis of birthdate in ascending order
SELECT ID FROM APPOINTMENT ORDER BY DATEANDTIME DESC ;      #arrange appointments in terms of which is scheduled earliest
UPDATE APPOINTMENT SET remindercheck=0 WHERE id=3;    #update a row 

SELECT ID,USERNAME FROM USER LIMIT 3;          #find top 3 users
SELECT * FROM SYMPTOMS WHERE SYMPTOM like '% pain';  #find symptoms that end with pain word
SELECT * FROM APPOINTMENT WHERE HEALTHPROBLEM IN ('anxiety' ,'diabetes');   #find appointments where health problem is either anxiety or diabetes
SELECT * FROM APPOINTMENT WHERE DATEANDTIME BETWEEN '2022-01-01 01:01:00' AND '2023-12-31 11:59:59'; #find appointment between the specified time

#Deletion operation
START TRANSACTION;                            #start transaction for deletion purposes
DELETE FROM USER WHERE INSURANCETYPE='private';     #delete user with private insurance type
SELECT * FROM USER WHERE INSURANCETYPE='private';
ROLLBACK;                                            #rollback the changes 


#JOINS
SELECT                          #all users who have an appointment, along with the doctor they are assigned to
    u.id AS user_id,  
    u.username,
    a.id AS appointment_id,
    a.healthproblem,
    d.name AS doctor_name
FROM 
    user u
INNER JOIN 
    appointment a ON u.id = a.user_id
INNER JOIN 
    doctor d ON a.doctor_id = d.id;


    
SELECT                        #all records from the left table (user), and the matched records from the right table (ppointment and doctor). If there is no match, NULL values are returned for columns from the right table.
    u.id AS user_id,
    u.username,
    a.id AS appointment_id,
    a.healthproblem,
    d.name AS doctor_name
FROM 
    user u
LEFT JOIN 
    appointment a ON u.id = a.user_id
LEFT JOIN 
    doctor d ON a.doctor_id = d.id;


SELECT                        #all records from the right table (appointment and doctor), and the matched records from the left table (user). If there is no match, NULL values are returned for columns from the left table.
    u.id AS user_id,
    u.username,
    a.id AS appointment_id,
    a.healthproblem,
    d.name AS doctor_name
FROM 
    user u
RIGHT JOIN 
    appointment a ON u.id = a.user_id
RIGHT JOIN 
    doctor d ON a.doctor_id = d.id;


SELECT                    #very possible combination of user and doctor, creating a Cartesian product. 
    u.username,
    d.name AS doctor_name
FROM 
    user u
CROSS JOIN 
    doctor d;


SELECT                   #finds pairs of users who live in the same city (u1.city = u2.city) and excludes matching the user with themselves (u1.id != u2.id).
    u1.username AS user1,
    u2.username AS user2
FROM 
    user u1
INNER JOIN 
    user u2 ON u1.city = u2.city AND u1.id != u2.id;




#GROUP BY AND HAVING OPERATIONS ON TABLES

SELECT d.name AS doctor_name, COUNT(a.id) AS total_appointments   #Doctors with More Than 2 Appointments
FROM appointment a
JOIN doctor d ON a.doctor_id = d.id
GROUP BY d.name
HAVING COUNT(a.id) > 2;


SELECT insurancetype, COUNT(*) AS user_count                     #Insurance Type with Fewer than 3 Users
FROM user
GROUP BY insurancetype
HAVING user_count < 3;



SELECT                                                           #GROUP APPOINTMENTS BY DOCTORS,HANDLE CASES WHERE ADDRESS IS NULL AND THEN FILTER DOCTORS WITH ATLEAST 1 APPOINTMENT
    d.name AS doctor_name, 
    COUNT(a.id) AS total_appointments, 
    COALESCE(d.address, 'No Address Provided') AS doctor_address
FROM appointment a
LEFT JOIN doctor d ON a.doctor_id = d.id
GROUP BY d.name
HAVING total_appointments > 0;


SELECT insurancetype,                                            #Average age of users for each insurance type, but only show insurance types where the average age is over 15 years
     AVG(TIMESTAMPDIFF(YEAR, dateofbirth, CURDATE())) AS avg_age 
FROM user 
GROUP BY insurancetype 
HAVING avg_age > 15;




#Stored procedure to insert an appointment 
CREATE PROCEDURE InsertAppointment (
   IN p_healthproblem VARCHAR(50),
   IN p_dateandtime TIMESTAMP,
   IN p_reminder TIMESTAMP,
   IN p_user_id INT,
   IN p_doctor_id INT
BEGIN
    INSERT INTO appointment (healthproblem, dateandtime, reminder, user_id, doctor_id)
    VALUES (p_healthproblem, p_dateandtime, p_reminder, p_user_id, p_doctor_id);

DELIMETER;
