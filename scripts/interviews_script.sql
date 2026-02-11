/*Show patient_id and first_name from patients 
where their first_name start and ends with 's' 
and is at least 6 characters long.*/

SELECT
	patient_id,
    first_name
FROM patients
WHERE first_name LIKE ('s%s')
AND LEN(first_name) >= 6
/*Show patient_id, first_name, last_name from patients whos diagnosis is 'Dementia'.*/

SELECT
	p.patient_id,
    p.first_name,
    p.last_name
FROM patients AS p
JOIN admissions AS a
ON p.patient_id = a.patient_id
WHERE a.diagnosis = 'Dementia'
/*Show the total amount of male patients and the total amount of female patients in the patients table.
Display the two results in the same row.*/
SELECT
	(SELECT COUNT(patient_id) FROM patients WHERE gender = 'M') AS male_count,
    COUNT(patient_id) AS female_count
FROM patients
WHERE gender = 'F'
/*Show first and last name, allergies from patients which have allergies to either 
'Penicillin' or 'Morphine'. Show results ordered ascending 
by allergies then by first_name then by last_name.*/
SELECT
	first_name,
    last_name,
    allergies
FROM patients
WHERE allergies IN ('Penicillin', 'Morphine')
ORDER BY allergies, first_name, last_name
/*Show patient_id, diagnosis from admissions. 
Find patients admitted multiple times for the same diagnosis.*/
SELECT
	DISTINCT patient_id,
    diagnosis
FROM
(
SELECT
	patient_id,
    diagnosis,
    COUNT(diagnosis) OVER(PARTITION BY patient_id, diagnosis) AS diagnosis_count
FROM admissions)t 
WHERE diagnosis_count > 1
/*Show the city and the total number of patients in the city.
Order from most to least patients and then by city name ascending.*/
SELECT
	city,
    COUNT(patient_id) AS num_patients
FROM patients
GROUP BY city
ORDER BY COUNT(patient_id) dESC, city
/*Show first name, last name and role of every person that is either patient or doctor.
The roles are either "Patient" or "Doctor"*/
SELECT
	first_name,
    last_name,
    'Patient' AS role
FROM patients
UNION ALL 
SELECT
	first_name,
    last_name,
    'Doctor'
FROM doctors
/*Show all allergies ordered by popularity. Remove NULL values from query.*/
SELECT
	p.allergies,
  	COUNT(a.diagnosis) AS total_diagnosis
FROM patients AS p 
JOIN admissions AS a 
ON p.patient_id = a.patient_id
WHERE p.allergies IS NOT NULL
GROUP BY p.allergies
ORDER BY COUNT(diagnosis) DESC
/*Show all patient's first_name, last_name, and birth_date who were born in the 1970s decade. 
Sort the list starting from the earliest birth_date.*/
SELECT
	first_name,
    last_name,
    birth_date
FROM patients
WHERE birth_date BETWEEN '1970-01-01' AND '1979-12-31'
ORDER BY birth_date
/*Show all patient's first_name, last_name, and birth_date who were born in the 1970s decade. 
Sort the list starting from the earliest birth_date.*/
SELECT
	first_name,
    last_name,
    birth_date
FROM patients
WHERE birth_date BETWEEN '1970-01-01' AND '1979-12-31'
ORDER BY birth_date
/*We want to display each patient's full name in a single column. 
Their last_name in all upper letters must appear first, then first_name in all lower case letters. 
Separate the last_name and first_name with a comma. Order the list by the first_name in decending order
EX: SMITH,jane*/
SELECT
	CONCAT(UPPER(last_name), ',' , LOWER(first_name))  AS new_name_format
FROM patients
ORDER BY first_name DESC
/*Show the province_id(s), sum of height; 
where the total sum of its patient's height is greater than or equal to 7,000.*/
SELECT
	province_id,
    SUM(height) AS sum_height
FROM patients
GROUP BY province_id
HAVING SUM(height) >= 7000
