# 07 · Subconsultas y CTE

Una **subconsulta** es una consulta dentro de otra. Sirve cuando para responder una pregunta primero hace falta responder otra. Una **CTE** (`WITH`) es la misma idea, pero con un nombre y escrita antes, para que la consulta se lea de arriba hacia abajo.

---

### Subconsulta que devuelve un solo valor

**QA / Soporte:** productos más caros que el promedio del catálogo.

```sql
SELECT name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products)
ORDER BY price DESC;
```

**Resultado:** 3 filas: `Botas Cuero` 12000.00, `Zapatillas Run` 9500.00 y `Campera Winter` 8900.00. El promedio es 5637.50.

**Ojo:** la subconsulta del `WHERE` tiene que devolver **un solo valor** (una fila, una columna); si devuelve varios, el motor da error. Y recordá que el precio 0 de `Gorra Sport` baja el promedio.

---

### Subconsulta con `IN`

**Soporte:** clientes que tienen al menos un pedido pagado.

```sql
SELECT id, name
FROM users
WHERE id IN (SELECT user_id
             FROM orders
             WHERE status = 'paid')
ORDER BY id;
```

**Resultado:** 5 filas: 1 Ana Pérez, 2 Bruno Díaz, 3 Carla Gómez, 6 Bruno Díaz y 8 Gisela Rojas.

**Ojo:** la subconsulta devuelve una lista de `user_id` y `IN` pregunta si el `id` está en esa lista. El 99 está en la lista, pero no aparece en el resultado porque no existe en `users`.

---

### `NOT EXISTS`: lo que no tiene registros relacionados

**Soporte / QA:** clientes que nunca compraron.

```sql
SELECT u.id, u.name
FROM users u
WHERE NOT EXISTS (SELECT 1
                  FROM orders o
                  WHERE o.user_id = u.id)
ORDER BY u.id;
```

**Resultado:** 2 filas: 7 Fabián Luna y 9 Hugo Vega (las mismas que el `LEFT JOIN` + `IS NULL` de [06 · JOINs](06-joins.md)).

**Ojo:** la subconsulta usa `u.id` de la consulta de afuera. Se llama **subconsulta correlacionada** y se evalúa una vez por cada fila de `users`.

Con `NOT IN` se llega al mismo resultado hoy, pero es peligroso: si la lista contiene un `NULL`, `NOT IN` devuelve **0 filas** sin dar error. `NOT EXISTS` no tiene ese problema.

---

### El último registro de cada grupo

**Soporte:** el último pedido de cada cliente.

```sql
SELECT o.user_id, o.id, o.created_at
FROM orders o
WHERE o.created_at = (SELECT MAX(o2.created_at)
                      FROM orders o2
                      WHERE o2.user_id = o.user_id)
ORDER BY o.user_id;
```

**Resultado:** 9 filas, una por cada cliente con pedidos (incluido el 99). Por ejemplo, el cliente 1 → pedido 104 (`2026-05-10`) y el cliente 6 → pedido 112 (`2026-06-01`).

**Ojo:** si un cliente tiene dos pedidos con la misma fecha, aparecen los dos. Para desempatar hay que agregar un criterio más (por ejemplo, el `id` más alto).

---

### CTE: ponerle nombre a un paso

**Soporte:** el gasto de cada cliente con su nombre, de mayor a menor. Primero se calcula el gasto por cliente y después se une con `users`.

```sql
WITH gasto AS (
    SELECT user_id,
           SUM(total) AS gastado
    FROM orders
    WHERE status = 'paid'
    GROUP BY user_id
)
SELECT u.name, g.gastado
FROM gasto g
INNER JOIN users u ON u.id = g.user_id
ORDER BY g.gastado DESC;
```

**Resultado:** 5 filas: Ana Pérez 19200.00, Carla Gómez 11000.00, Bruno Díaz 10400.00, Bruno Díaz 9500.00 y Gisela Rojas 8000.00.

**Ojo:** el cliente 99 (1500.00) no aparece, porque el `INNER JOIN` lo descarta. Y la CTE existe **solo durante esa consulta**: no se guarda en la base.

**SQL Server:** si el `WITH` no es la primera sentencia del lote, la sentencia anterior tiene que terminar con `;`. Es un error clásico.

---

### Cuándo conviene cada una

| Situación | Herramienta |
| --- | --- |
| Comparar contra un valor calculado (promedio, máximo) | subconsulta en el `WHERE` |
| Saber si algo está en una lista | `IN` con subconsulta |
| Buscar lo que **no** tiene registros relacionados | `NOT EXISTS` o `LEFT JOIN` + `IS NULL` |
| Una consulta con varios pasos que cuesta leer | CTE (`WITH`) |
