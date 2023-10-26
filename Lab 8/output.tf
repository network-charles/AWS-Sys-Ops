output "RDS_Oracle" {
  value = "sqlplus ${var.username}/${var.password}@${aws_db_instance.Oracle.endpoint}/oracle"
}

/*
CREATE TABLE employees (
    employee_id NUMBER(5) PRIMARY KEY,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    email VARCHAR2(100) UNIQUE,
    hire_date DATE,
    salary NUMBER(10, 2)
);

INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, salary)
VALUES (1, 'John', 'Doe', 'john.doe@example.com', TO_DATE('2023-10-25', 'YYYY-MM-DD'), 55000.00);

SELECT * FROM employees;

SELECT first_name, last_name FROM employees;
*/
