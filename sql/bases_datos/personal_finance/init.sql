USE personal_finance;

CREATE TABLE users(
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE,
    register_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE accounts(
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    account_name VARCHAR(200) NOT NULL,
    account_type ENUM('Efectivo', 'Credito', 'Inversion', 'Debito') NOT NULL,
    current_balance DECIMAL(12,2) DEFAULT 0.00,
    FOREIGN KEY (user_id)
        REFERENCES users(user_id) 
        ON DELETE CASCADE
);

CREATE TABLE categories(
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name varchar(200) NOT NULL,
    type_movement ENUM('Ingreso', 'Gasto') NOT NULL
);

CREATE TABLE transactions(
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    category_id INT NOT NULL,
    aount DECIMAL(12,2) NOT NULL,
    description TEXT,
    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) 
        REFERENCES accounts(account_id)
        ON DELETE CASCADE,
    FOREIGN KEY (category_id) 
        REFERENCES categories(category_id)
);