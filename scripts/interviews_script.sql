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
/*Show the difference between the largest weight and smallest weight for patients with the last name 'Maroni'*/
SELECT
	MAX(weight)-MIN(weight)
FROM patients
WHERE last_name = 'Maroni'
/*Show the difference between the largest weight and smallest weight for patients with the last name 'Maroni'*/
SELECT
	MAX(weight)-MIN(weight)
FROM patients
WHERE last_name = 'Maroni'
/*Show all of the days of the month (1-31) and how many admission_dates occurred on that day. 
Sort by the day with most admissions to least admissions.*/
SELECT
	DAY(admission_date),
    COUnT(patient_id) AS number_of_admissions
FROM admissions
GROUP BY DAY(admission_date)
ORDER BY COUnT(patient_id) DESC
/*Show all columns for patient_id 542's most recent admission_date.*/
SELECT
	*
FROM admissions
WHere patient_id = 542
ORDER BY admission_date DESC
LIMIT 1
/*Show patient_id, attending_doctor_id, and diagnosis for admissions that match one of the two criteria:
1. patient_id is an odd number and attending_doctor_id is either 1, 5, or 19.
2. attending_doctor_id contains a 2 and the length of patient_id is 3 characters.*/
SELECT
	patient_id,
    attending_doctor_id,
    diagnosis
FROM admissions
WHere patient_id%2 = 1 AND attending_doctor_id IN(1, 5, 19)
OR attending_doctor_id LIKE '%2%' AND LEN(patient_id) = 3;
/*Show first_name, last_name, and the total number of admissions attended for each doctor.

Every admission has been attended by a doctor.*/
SELECT
	d.first_name,
    d.last_name,
    COUNT(a.patient_id) AS admissions_total
FROM doctors AS d
JOIN admissions AS a
ON d.doctor_id = a.attending_doctor_id
GROUP BY d.first_name, d.last_name
/*For each doctor, display their id, full name, and the first and last admission date they attended.*/
SELECT
	a.attending_doctor_id AS doctor_id,
	CONCAT(d.first_name,' ',d.last_name) AS full_name,
    MIN(a.admission_date) AS first_admission_date,
    MAX(a.admission_date) AS last_admission_date
FROM doctors AS d 
JOIN admissions AS a 
ON d.doctor_id = a.attending_doctor_id
GROUP BY attending_doctor_id;
/*Display the total amount of patients for each province. Order by descending.*/
SELECT
	p.province_name,
    COUNT(pa.patient_id) AS patient_count
FROM province_names AS p 
JOIN patients AS pa 
ON p.province_id = pa.province_id
GROUP BY p.province_name
ORDER BY COUNT(pa.patient_id) DESC;
/*For every admission, display the patient's full name, their admission diagnosis, and their doctor's full name who diagnosed their problem.*/
SELECT
	CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    a.diagnosis,
    CONCAT(d.first_name, ' ', d.last_name) AS doctor_name
FROM patients AS p 
JOIN admissions AS a 
ON p.patient_id = a.patient_id
JOIN doctors AS d 
ON a.attending_doctor_id = d.doctor_id;
/*display the first name, last name and number of duplicate patients based on their first name and last name.*/
SELECT
	first_name, 
    last_name,
    COUNT(patient_id) AS num_of_duplicate
FROM patients
GROUP BY first_name, last_name
HAVING COUNT(patient_id) > 1;
/*Display patient's full name,
height in the units feet rounded to 1 decimal,
weight in the unit pounds rounded to 0 decimals,
birth_date,
gender non abbreviated.

Convert CM to feet by dividing by 30.48.
Convert KG to pounds by multiplying by 2.205.*/
SELECT
	CONCAT(first_name, ' ',last_name) AS patient_name,
    ROUND(height/30.48, 1) AS height,
    ROUND(weight*2.205, 0) AS weight,
    birth_date,
    CASE gender
    	WHEN 'M' THEN 'MALE'
        WHEN 'F' THEN 'FEMALE'
    END AS gender
FROM patients;
/*Show patient_id, first_name, last_name from patients whose does not have any records in the admissions table. 
(Their patient_id does not exist in any admissions.patient_id rows.)*/
SELECT
	p.patient_id,
    p.first_name,
    p.last_name
FROM patients AS p
LEFT JOIN admissions AS a
ON a.patient_id = p.patient_id
WHERE a.patient_id IS NULL;
/*Display a single row with max_visits, min_visits, average_visits where the maximum, 
minimum and average number of admissions per day is calculated. Average is rounded to 2 decimal places.*/
SELECT
	MAX(total_visits) AS max_visits,
    MIN(total_visits) AS min_visits,
    ROUND(AVG(total_visits),2) AS average_visits
FROM
(
SELECT
	admission_date,
	COUNT(patient_id) total_visits
FROM admissions
GROUP BY admission_date)t
