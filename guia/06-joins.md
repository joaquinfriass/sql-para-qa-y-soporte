# 06 · JOINs

Los datos están repartidos en varias tablas. Un `JOIN` las une **por una columna en común**: por ejemplo, `orders.user_id` con `users.id`. La condición va en `ON`.

Para escribir menos se usan **alias de tabla** (`orders o`, `users u`).

---

### `INNER JOIN`: solo lo que tiene pareja

**Soporte:** ver los pedidos con el nombre del cliente.

```sql
SELECT o.id, u.name, o.status, o.total
FROM orders o
INNER JOIN users u ON u.id = o.user_id
ORDER BY o.id;
```

**Resultado:** 11 filas.

**Ojo:** la tabla `orders` tiene 12 pedidos. Falta el **107**, porque apunta al cliente 99, que no existe. `INNER JOIN` descarta en silencio las filas sin pareja: puede esconder datos rotos.

---

### `LEFT JOIN`: todo lo de la izquierda, tenga pareja o no

**QA:** ver todos los pedidos y, cuando existe, el nombre del cliente.

```sql
SELECT o.id, u.name, o.status, o.total
FROM orders o
LEFT JOIN users u ON u.id = o.user_id
ORDER BY o.id;
```

**Resultado:** 12 filas. El pedido 107 aparece con `name = NULL`.

**Ojo:** en `LEFT JOIN` importa cuál tabla va a la izquierda: es la que se conserva completa.

---

### Encontrar lo que no tiene pareja: `LEFT JOIN` + `IS NULL`

La técnica más útil para QA: hacer `LEFT JOIN` y quedarse con las filas donde la tabla de la derecha vino vacía.

**Soporte / QA:** clientes que nunca hicieron un pedido.

```sql
SELECT u.id, u.name
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
WHERE o.id IS NULL
ORDER BY u.id;
```

**Resultado:** 2 filas: 7 Fabián Luna y 9 Hugo Vega.

**Soporte / QA:** pedidos sin ningún pago registrado.

```sql
SELECT o.id, o.status, o.total
FROM orders o
LEFT JOIN payments p ON p.order_id = o.id
WHERE p.id IS NULL
ORDER BY o.id;
```

**Resultado:** 2 filas: 109 (`pending`, 8900.00) y 110 (`pending`, 0.00).

**Ojo:** un resultado de 0 filas también se interpreta: significa que no hay filas sin pareja. Para confirmar que la consulta funciona, probala primero con un caso que sepas que existe.

---

### Unir tres o más tablas

**Soporte:** qué productos tiene un pedido.

```sql
SELECT o.id AS pedido,
       p.name AS producto,
       oi.quantity,
       oi.unit_price
FROM orders o
INNER JOIN order_items oi ON oi.order_id = o.id
INNER JOIN products p     ON p.id = oi.product_id
WHERE o.id = 101
ORDER BY oi.id;
```

**Resultado:** 2 filas: `Remera Basic` (cantidad 2, 1500.00) y `Jean Slim` (cantidad 1, 4200.00).

**Ojo:** cada `JOIN` agrega una tabla con su propio `ON`. Si en cambio se unen las tablas con coma (`FROM orders, users`) y se olvida la condición en el `WHERE`, el motor devuelve **todas las combinaciones** posibles (producto cartesiano): miles de filas sin sentido. Escribir `JOIN ... ON` evita ese descuido.

---

### Un `JOIN` puede multiplicar filas

Si una fila de la izquierda tiene varias parejas a la derecha, aparece una vez por cada una.

```sql
SELECT o.id, o.total, p.id AS pago, p.amount
FROM orders o
INNER JOIN payments p ON p.order_id = o.id
WHERE o.id = 111;
```

**Resultado:** 2 filas: el pedido 111 aparece dos veces, porque tiene dos pagos registrados.

**Ojo:** esto distorsiona las sumas. Mirá:

```sql
SELECT SUM(o.total) AS suma_pedidos_con_pago
FROM orders o
INNER JOIN payments p ON p.order_id = o.id
WHERE o.status = 'paid';
```

**Resultado:** 70600.00. Pero la suma real de los pedidos pagados es 59600.00 (se vio en [04 · Agregaciones](04-agregaciones.md)). La diferencia, 11000.00, es el pedido 111 contado dos veces. **Regla:** antes de sumar después de un `JOIN`, verificá que cada fila quede una sola vez.

---

### `FULL JOIN`: lo que no tiene pareja de cualquier lado

`RIGHT JOIN` es un `LEFT JOIN` con las tablas al revés. `FULL JOIN` conserva las filas sin pareja de **los dos lados**: sirve para comparar dos listas.

**QA:** clientes sin pedidos **y** pedidos sin cliente, en una sola consulta.

```sql
SELECT u.id AS usuario,
       o.id AS pedido
FROM users u
FULL JOIN orders o ON o.user_id = u.id
WHERE u.id IS NULL
   OR o.id IS NULL
ORDER BY u.id, o.id;
```

**Resultado:** 3 filas: usuarios 7 y 9 (sin pedidos) y el pedido 107 (sin usuario).

**Ojo:** MySQL no tiene `FULL JOIN`; PostgreSQL y SQL Server sí.

---

### Filtrar en el `ON` o en el `WHERE`

Con `LEFT JOIN`, dónde se pone una condición sobre la tabla de la derecha cambia el resultado.

**Soporte:** todos los clientes y, si tienen, sus pedidos **pagados**.

```sql
SELECT u.id, u.name, o.id AS pedido
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
                  AND o.status = 'paid'
ORDER BY u.id, o.id;
```

**Resultado:** 11 filas: los clientes sin pedidos pagados aparecen con `pedido = NULL`.

Con la condición en el `WHERE`:

```sql
SELECT u.id, u.name, o.id AS pedido
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
WHERE o.status = 'paid'
ORDER BY u.id, o.id;
```

**Resultado:** 6 filas: desaparecieron los clientes sin pedidos pagados.

**Ojo:** el `WHERE` se aplica **después** del `JOIN` y descarta las filas con `NULL`, así que el `LEFT JOIN` se comporta como un `INNER JOIN`. Para conservar a los clientes sin pedidos, la condición va en el `ON`.
