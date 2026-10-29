# 03 · Ordenar y limitar

`ORDER BY` ordena el resultado. `TOP` (SQL Server) o `LIMIT` (PostgreSQL, SQLite) recortan cuántas filas se devuelven. Se usan juntos para preguntas del tipo «los últimos» o «los más caros».

---

### Ordenar de mayor a menor

**QA:** ver el producto más caro y el más barato de un vistazo (el precio 0 queda al final y salta a la vista).

```sql
SELECT name, price
FROM products
ORDER BY price DESC;
```

**Resultado:** 8 filas, de Botas Cuero (12000.00) a Gorra Sport (0.00).

**Ojo:** sin `DESC` el orden es ascendente (`ASC`). Es el valor por defecto.

---

### Ordenar por dos columnas

**Soporte:** listar clientes agrupados por país y, dentro de cada país, por nombre.

```sql
SELECT name, country
FROM users
ORDER BY country, name;
```

**Resultado:** 10 filas: primero los de `AR`, luego `BR`, `CL` y `UY`.

---

### Los N primeros (top N)

**Soporte / QA:** los tres productos más caros.

SQL Server:

```sql
SELECT TOP 3 name, price
FROM products
ORDER BY price DESC;
```

PostgreSQL y SQLite:

```sql
SELECT name, price
FROM products
ORDER BY price DESC
LIMIT 3;
```

**Resultado:** 3 filas: Botas Cuero 12000.00, Zapatillas Run 9500.00, Campera Winter 8900.00.

En SQL Server también se puede escribir con el estándar:

```sql
SELECT name, price
FROM products
ORDER BY price DESC
OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY;
```

**Ojo:** `TOP` / `LIMIT` **sin `ORDER BY`** devuelven filas «cualquiera» y el resultado puede cambiar entre ejecuciones. El orden es lo que le da sentido al recorte.

---

### El último registro

**Soporte:** «¿cuál fue el último pedido que entró?»

SQL Server:

```sql
SELECT TOP 1 id, user_id, created_at
FROM orders
ORDER BY created_at DESC;
```

PostgreSQL y SQLite:

```sql
SELECT id, user_id, created_at
FROM orders
ORDER BY created_at DESC
LIMIT 1;
```

**Resultado:** 1 fila: pedido 112, cliente 6, `2026-06-01`.

**Ojo:** si dos pedidos tienen la misma fecha, el «último» queda ambiguo. Agregar un desempate: `ORDER BY created_at DESC, id DESC`.

---

### Los últimos N registros

**QA:** revisar los 5 pedidos más recientes después de una prueba.

SQL Server:

```sql
SELECT TOP 5 id, status, created_at
FROM orders
ORDER BY created_at DESC, id DESC;
```

PostgreSQL y SQLite:

```sql
SELECT id, status, created_at
FROM orders
ORDER BY created_at DESC, id DESC
LIMIT 5;
```

**Resultado:** 5 filas: 112 paid, 111 paid, 110 pending, 109 pending, 108 cancelled.
