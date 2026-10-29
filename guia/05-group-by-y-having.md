# 05 · GROUP BY y HAVING

`GROUP BY` junta las filas en grupos y las funciones de agregación (`COUNT`, `SUM`, `AVG`…) calculan un valor **por grupo**. `HAVING` filtra esos grupos una vez calculados.

---

### Contar filas por grupo

**Soporte:** ¿cuántos pedidos hay en cada estado? **QA:** ver la distribución de estados y detectar valores inesperados.

```sql
SELECT status,
       COUNT(*) AS pedidos
FROM orders
GROUP BY status
ORDER BY pedidos DESC, status;
```

**Resultado:** 5 filas: `paid` 7, `pending` 2, `cancelled` 1, `delivered` 1, `shipped` 1.

**Ojo:** en `ORDER BY` se puede usar el alias (`pedidos`); en `GROUP BY`, según el motor, no (ver más abajo).

---

### Sumar por grupo

**Soporte / QA:** cuánto gastó cada cliente en pedidos pagados.

```sql
SELECT user_id,
       COUNT(*)   AS pedidos,
       SUM(total) AS gastado
FROM orders
WHERE status = 'paid'
GROUP BY user_id
ORDER BY gastado DESC, user_id;
```

**Resultado:** 6 filas: cliente 1 (2 pedidos, 19200.00), 3 (11000.00), 6 (10400.00), 2 (9500.00), 8 (8000.00) y 99 (1500.00).

**Ojo:** el cliente 99 aparece en el resumen aunque no existe en `users`. Para mostrar nombres hace falta un `JOIN` (ver [06 · JOINs](06-joins.md)), y ese cliente que no existe es un defecto (ver [08 · Validar datos](08-validar-datos.md)).

---

### La regla del `GROUP BY`

Toda columna del `SELECT` que **no** es una función de agregación tiene que estar en el `GROUP BY`.

```sql
-- da error: total no está agregada ni en el GROUP BY
SELECT status, total
FROM orders
GROUP BY status;
```

**Resultado:** el motor devuelve un error. Hay que agregar la columna (`SUM(total)`) o incluirla en el `GROUP BY`.

**Ojo:** es el error más frecuente al empezar con `GROUP BY`. La pregunta para corregirlo es: «¿qué valor debería mostrar para `total` si el grupo tiene varias filas?».

---

### Filtrar grupos: `HAVING`

**Soporte:** clientes que hicieron más de un pedido.

```sql
SELECT user_id,
       COUNT(*) AS pedidos
FROM orders
GROUP BY user_id
HAVING COUNT(*) > 1
ORDER BY user_id;
```

**Resultado:** 3 filas: clientes 1, 2 y 3, con 2 pedidos cada uno.

---

### `WHERE` y `HAVING` juntos

**Soporte / QA:** clientes que gastaron más de 10000 en pedidos pagados.

```sql
SELECT user_id,
       SUM(total) AS gastado
FROM orders
WHERE status = 'paid'
GROUP BY user_id
HAVING SUM(total) > 10000
ORDER BY gastado DESC;
```

**Resultado:** 3 filas: cliente 1 (19200.00), 3 (11000.00) y 6 (10400.00).

**Ojo:** `WHERE` filtra **filas** antes de agrupar; `HAVING` filtra **grupos** después de calcular el resumen. El orden en que el motor lee la consulta es `FROM` → `WHERE` → `GROUP BY` → `HAVING` → `SELECT` → `ORDER BY`. Una condición sobre una fila (`status = 'paid'`) va en `WHERE`; una condición sobre un resultado agregado (`SUM(total) > 10000`) va en `HAVING`.

---

### Resumen por categoría

**QA / Soporte:** cuántos productos, cuántas unidades en stock y qué precio promedio tiene cada categoría.

```sql
SELECT category,
       COUNT(*)              AS productos,
       SUM(stock)            AS unidades,
       ROUND(AVG(price), 2)  AS precio_promedio
FROM products
GROUP BY category
ORDER BY category;
```

**Resultado:** 3 filas:

| category | productos | unidades | precio_promedio |
| --- | --- | --- | --- |
| Accesorios | 2 | 50 | 2600.00 |
| Calzado | 2 | 13 | 10750.00 |
| Ropa | 4 | 52 | 4600.00 |

**Ojo:** el promedio de `Accesorios` (2600.00) está bajo porque incluye la `Gorra Sport` con precio 0. Un promedio raro suele ser una pista de calidad de datos. En `Ropa`, las 52 unidades incluyen el stock negativo (−3) de la `Campera Winter`.

---

### Agrupar por mes

**Soporte / QA:** cuántos pedidos entraron cada mes. La función de fechas cambia según el motor.

PostgreSQL:

```sql
SELECT TO_CHAR(created_at, 'YYYY-MM') AS mes,
       COUNT(*)                       AS pedidos
FROM orders
GROUP BY TO_CHAR(created_at, 'YYYY-MM')
ORDER BY mes;
```

SQL Server:

```sql
SELECT FORMAT(created_at, 'yyyy-MM') AS mes,
       COUNT(*)                      AS pedidos
FROM orders
GROUP BY FORMAT(created_at, 'yyyy-MM')
ORDER BY mes;
```

**Resultado:** 2 filas: `2026-05` con 11 pedidos y `2026-06` con 1.

**Ojo:** SQL Server **no permite usar el alias del `SELECT` en el `GROUP BY`**, así que hay que repetir la expresión completa. PostgreSQL sí lo permite, pero repetirla funciona en los dos.
