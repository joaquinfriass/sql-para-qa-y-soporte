-- Base de práctica: tienda online ficticia (PostgreSQL)
-- Los datos tienen defectos plantados a propósito para practicar validación.
--
-- Cómo cargarla (con una base vacía llamada tienda_qa):
--   pgAdmin 4: clic derecho en la base "tienda_qa" > Query Tool > abrir este archivo > F5.
--   psql:      psql -U postgres -d tienda_qa -f db/tienda_postgres.sql
--
-- NO se declaran FOREIGN KEY a propósito: con ellas el motor rechazaría las filas huérfanas
-- (por ejemplo la orden 107, que apunta al usuario 99) y no tendríamos defectos que encontrar.

DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT,
  country TEXT,
  created_at DATE,
  status TEXT
);

CREATE TABLE products (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT,
  price NUMERIC(10,2),
  stock INTEGER
);

CREATE TABLE orders (
  id INTEGER PRIMARY KEY,
  user_id INTEGER,          -- apunta a users.id
  status TEXT,
  total NUMERIC(10,2),
  created_at DATE
);

CREATE TABLE order_items (
  id INTEGER PRIMARY KEY,
  order_id INTEGER,         -- apunta a orders.id
  product_id INTEGER,       -- apunta a products.id
  quantity INTEGER,
  unit_price NUMERIC(10,2)
);

CREATE TABLE payments (
  id INTEGER PRIMARY KEY,
  order_id INTEGER,         -- apunta a orders.id
  amount NUMERIC(10,2),
  method TEXT,
  status TEXT
);

INSERT INTO users (id, name, email, country, created_at, status) VALUES
(1, 'Ana Pérez',    'ana@mail.com',    'AR', '2026-01-10', 'active'),
(2, 'Bruno Díaz',   'bruno@mail.com',  'AR', '2026-01-15', 'active'),
(3, 'Carla Gómez',  'carla@mail.com',  'CL', '2026-02-01', 'active'),
(4, 'Diego Ruiz',   'diego@mail.com',  'UY', '2026-02-10', 'inactive'),
(5, 'Elena Sosa',   'elena@mail.com',  'AR', '2026-02-20', 'active'),
(6, 'Bruno Díaz',   'bruno@mail.com',  'AR', '2026-03-05', 'active'),
(7, 'Fabián Luna',  NULL,              'BR', '2026-03-12', 'active'),
(8, 'Gisela Rojas', 'gisela@mail.com', 'CL', '2026-03-20', 'active'),
(9, 'Hugo Vega',    'hugo@mail.com',   'AR', '2026-04-01', 'inactive'),
(10,'Irene Paz',    'irene@mail.com',  'UY', '2026-04-15', 'active');

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
