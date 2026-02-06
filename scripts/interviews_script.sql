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
