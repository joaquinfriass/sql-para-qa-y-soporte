-- Base de práctica: tienda online ficticia (SQL Server / T-SQL, 2016 o superior)
-- Los datos tienen defectos plantados a propósito para practicar validación.
-- Son las mismas tablas y los mismos datos que db/tienda_postgres.sql.
--
-- Cómo cargarla:
--   1) Crear una base vacía:  CREATE DATABASE tienda_qa;
--   2) SSMS: seleccionar la base tienda_qa, abrir este archivo y ejecutar (F5).
--
-- Diferencias con la versión de PostgreSQL: TEXT pasa a NVARCHAR, NUMERIC pasa a DECIMAL
-- y los textos con acentos llevan el prefijo N'...' para conservar los caracteres.
--
-- NO se declaran FOREIGN KEY a propósito: con ellas el motor rechazaría las filas huérfanas
-- (por ejemplo la orden 107, que apunta al usuario 99) y no tendríamos defectos que encontrar.

DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INT PRIMARY KEY,
  name NVARCHAR(100) NOT NULL,
  email NVARCHAR(100),
  country NVARCHAR(10),
  created_at DATE,
  status NVARCHAR(20)
);

CREATE TABLE products (
  id INT PRIMARY KEY,
  name NVARCHAR(100) NOT NULL,
  category NVARCHAR(50),
  price DECIMAL(10,2),
  stock INT
);

CREATE TABLE orders (
  id INT PRIMARY KEY,
  user_id INT,              -- apunta a users.id
  status NVARCHAR(20),
  total DECIMAL(10,2),
  created_at DATE
);

CREATE TABLE order_items (
  id INT PRIMARY KEY,
  order_id INT,             -- apunta a orders.id
  product_id INT,           -- apunta a products.id
  quantity INT,
  unit_price DECIMAL(10,2)
);

CREATE TABLE payments (
  id INT PRIMARY KEY,
  order_id INT,             -- apunta a orders.id
  amount DECIMAL(10,2),
  method NVARCHAR(20),
  status NVARCHAR(20)
);

INSERT INTO users (id, name, email, country, created_at, status) VALUES
(1, N'Ana Pérez',    'ana@mail.com',    'AR', '2026-01-10', 'active'),
(2, N'Bruno Díaz',   'bruno@mail.com',  'AR', '2026-01-15', 'active'),
(3, N'Carla Gómez',  'carla@mail.com',  'CL', '2026-02-01', 'active'),
(4, N'Diego Ruiz',   'diego@mail.com',  'UY', '2026-02-10', 'inactive'),
(5, N'Elena Sosa',   'elena@mail.com',  'AR', '2026-02-20', 'active'),
(6, N'Bruno Díaz',   'bruno@mail.com',  'AR', '2026-03-05', 'active'),
(7, N'Fabián Luna',  NULL,              'BR', '2026-03-12', 'active'),
(8, N'Gisela Rojas', 'gisela@mail.com', 'CL', '2026-03-20', 'active'),
(9, N'Hugo Vega',    'hugo@mail.com',   'AR', '2026-04-01', 'inactive'),
(10,N'Irene Paz',    'irene@mail.com',  'UY', '2026-04-15', 'active');

INSERT INTO products (id, name, category, price, stock) VALUES
(1, 'Remera Basic',    'Ropa',       1500.00, 40),
(2, 'Jean Slim',       'Ropa',       4200.00, 15),
(3, 'Vestido Floral',  'Ropa',       3800.00, 0),
(4, 'Zapatillas Run',  'Calzado',    9500.00, 8),
(5, 'Botas Cuero',     'Calzado',   12000.00, 5),
(6, 'Mochila Urban',   'Accesorios', 5200.00, 20),
(7, 'Gorra Sport',     'Accesorios',    0.00, 30),
(8, 'Campera Winter',  'Ropa',       8900.00, -3);

INSERT INTO orders (id, user_id, status, total, created_at) VALUES
(101, 1,  'paid',      7200.00, '2026-05-01'),
(102, 2,  'paid',      9500.00, '2026-05-03'),
(103, 3,  'shipped',   5200.00, '2026-05-07'),
(104, 1,  'paid',     12000.00, '2026-05-10'),
(105, 5,  'delivered', 8300.00, '2026-05-12'),
(106, 8,  'paid',      8000.00, '2026-05-15'),
(107, 99, 'paid',      1500.00, '2026-05-18'),
(108, 4,  'cancelled', 5200.00, '2026-05-20'),
(109, 2,  'pending',   8900.00, '2026-05-22'),
(110, 10, 'pending',      0.00, '2026-05-25'),
(111, 3,  'paid',     11000.00, '2026-05-28'),
(112, 6,  'paid',     10400.00, '2026-06-01');

INSERT INTO order_items (id, order_id, product_id, quantity, unit_price) VALUES
(1,  101, 1,  2, 1500.00),
(2,  101, 2,  1, 4200.00),
(3,  102, 4,  1, 9500.00),
(4,  103, 6,  1, 5200.00),
(5,  103, 7,  2,    0.00),
(6,  104, 5,  1, 12000.00),
(7,  105, 1,  3, 1500.00),
(8,  105, 3,  1, 3800.00),
(9,  106, 2,  2, 4200.00),
(10, 107, 1,  1, 1500.00),
(11, 108, 6,  1, 5200.00),
(12, 109, 8,  1, 8900.00),
(13, 111, 4,  1, 9500.00),
(14, 111, 1,  1, 1500.00),
(15, 112, 6,  2, 5200.00),
(16, 112, 99, 1,    0.00),
(17, 104, 6,  0, 5200.00);

INSERT INTO payments (id, order_id, amount, method, status) VALUES
(1,  101,  7200.00, 'card',     'approved'),
(2,  102,  9500.00, 'card',     'approved'),
(3,  103,  5200.00, 'transfer', 'approved'),
(4,  104, 12000.00, 'card',     'approved'),
(5,  105,  8300.00, 'card',     'approved'),
(6,  106,  8000.00, 'card',     'approved'),
(7,  107,  1500.00, 'card',     'approved'),
(8,  108,  5200.00, 'card',     'refunded'),
(9,  111, 11000.00, 'card',     'approved'),
(10, 111, 11000.00, 'card',     'approved'),
(11, 112, 10000.00, 'card',     'approved');
