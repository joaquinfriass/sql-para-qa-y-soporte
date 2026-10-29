# 08 · Validar datos

En QA, una consulta no solo responde una pregunta: **comprueba una regla**. Cada validación busca las filas que **violan** la regla:

- **0 filas:** la regla se cumple.
- **Más de 0 filas:** hay un defecto, y las filas son la evidencia.

Cada entrada sigue este formato: **regla → consulta → esperado (0 filas) → real**.

---

### VAL-01 · No debe haber usuarios duplicados

**Regla:** cada email pertenece a un solo usuario.

```sql
SELECT email, COUNT(*) AS veces
FROM users
WHERE email IS NOT NULL
GROUP BY email
HAVING COUNT(*) > 1;
```

**Esperado:** 0 filas. **Real:** 1 fila: `bruno@mail.com` aparece 2 veces.

Para ver cuáles son los registros duplicados:

```sql
SELECT id, name, email, created_at
FROM users
WHERE email IN (SELECT email
                FROM users
                GROUP BY email
                HAVING COUNT(*) > 1)
ORDER BY email, id;
```

**Real:** 2 filas: los usuarios 2 y 6, ambos «Bruno Díaz», creados el `2026-01-15` y el `2026-03-05`.

Otra forma, que deja el primero y marca solo las repeticiones, es numerar con `ROW_NUMBER`:

```sql
WITH numerados AS (
    SELECT id, name, email,
           ROW_NUMBER() OVER (PARTITION BY email ORDER BY id) AS n
    FROM users
    WHERE email IS NOT NULL
)
SELECT id, name, email
FROM numerados
WHERE n > 1;
```

**Real:** 1 fila: el usuario 6. (En SQL Server, recordá el `;` antes del `WITH` si no es la primera sentencia.)

---

### VAL-02 · Los pedidos deben pertenecer a un usuario que existe

**Regla:** todo `orders.user_id` existe en `users.id`.

```sql
SELECT o.id, o.user_id, o.status, o.total
FROM orders o
LEFT JOIN users u ON u.id = o.user_id
WHERE u.id IS NULL;
```

**Esperado:** 0 filas. **Real:** 1 fila: el pedido 107 apunta al usuario 99, que no existe (pedido huérfano, `paid`, 1500.00).

---

### VAL-03 · Las líneas deben apuntar a un producto que existe

**Regla:** todo `order_items.product_id` existe en `products.id`.

```sql
SELECT oi.id, oi.order_id, oi.product_id
FROM order_items oi
LEFT JOIN products p ON p.id = oi.product_id
WHERE p.id IS NULL;
```

**Esperado:** 0 filas. **Real:** 1 fila: la línea 16, del pedido 112, apunta al producto 99, que no existe.

---

### VAL-04 · La cantidad de una línea debe ser mayor a cero

**Regla:** `order_items.quantity > 0`.

```sql
SELECT id, order_id, quantity
FROM order_items
WHERE quantity <= 0;
```

**Esperado:** 0 filas. **Real:** 1 fila: la línea 17, del pedido 104, tiene cantidad 0.

---

### VAL-05 · Stock y precio no pueden ser negativos ni cero

**Regla:** `stock >= 0` y `price > 0`. Las consultas están en [04 · Agregaciones](04-agregaciones.md).

**Esperado:** 0 filas en cada una. **Real:** `Campera Winter` con stock −3 y `Gorra Sport` con precio 0.00.

---

### VAL-06 · El total del pedido debe coincidir con la suma de sus líneas

**Regla:** `orders.total = SUM(cantidad × precio unitario)` de sus líneas.

```sql
SELECT o.id,
       o.total,
       SUM(oi.quantity * oi.unit_price) AS suma_lineas
FROM orders o
INNER JOIN order_items oi ON oi.order_id = o.id
GROUP BY o.id, o.total
HAVING o.total <> SUM(oi.quantity * oi.unit_price)
ORDER BY o.id;
```

**Esperado:** 0 filas. **Real:** 1 fila: el pedido 106 tiene total 8000.00, pero sus líneas suman 8400.00.

**Ojo:** el `INNER JOIN` deja afuera los pedidos **sin líneas**. Para revisarlos hace falta otra consulta con `LEFT JOIN`:

```sql
SELECT o.id, o.total
FROM orders o
LEFT JOIN order_items oi ON oi.order_id = o.id
WHERE oi.id IS NULL;
```

**Real:** 1 fila: el pedido 110, con total 0.00 y sin líneas (un pedido vacío).

---

### VAL-07 · Un pedido no debe tener pagos duplicados

**Regla:** como máximo un pago aprobado por pedido.

```sql
SELECT order_id, COUNT(*) AS pagos
FROM payments
GROUP BY order_id
HAVING COUNT(*) > 1;
```

**Esperado:** 0 filas. **Real:** 1 fila: el pedido 111 tiene 2 pagos.

---

### VAL-08 · El monto pagado debe coincidir con el total del pedido

**Regla:** la suma de los pagos aprobados de un pedido es igual a su total.

```sql
SELECT o.id,
       o.total,
       SUM(p.amount) AS pagado
FROM orders o
INNER JOIN payments p ON p.order_id = o.id
WHERE p.status = 'approved'
GROUP BY o.id, o.total
HAVING SUM(p.amount) <> o.total
ORDER BY o.id;
```

**Esperado:** 0 filas. **Real:** 2 filas:

| pedido | total | pagado | qué pasa |
| --- | --- | --- | --- |
| 111 | 11000.00 | 22000.00 | cobrado dos veces (el mismo defecto de VAL-07) |
| 112 | 10400.00 | 10000.00 | se cobró menos que el total |

---

### VAL-09 · Un pedido `paid` debe tener un pago aprobado

**Regla:** todo pedido en estado `paid` tiene al menos un pago `approved`.

```sql
SELECT o.id, o.total
FROM orders o
LEFT JOIN payments p ON p.order_id = o.id
                    AND p.status = 'approved'
WHERE o.status = 'paid'
  AND p.id IS NULL;
```

**Esperado:** 0 filas. **Real:** 0 filas. **La regla se cumple.**

**Ojo:** un resultado de 0 filas también es un resultado: se informa como «pasa». Y la condición `p.status = 'approved'` va en el `ON`, no en el `WHERE` (ver [06 · JOINs](06-joins.md)).

---

### VAL-10 · El precio de una línea debe coincidir con el del catálogo

**Regla:** `order_items.unit_price = products.price`.

```sql
SELECT oi.id, oi.order_id, oi.unit_price, p.price
FROM order_items oi
INNER JOIN products p ON p.id = oi.product_id
WHERE oi.unit_price <> p.price;
```

**Esperado:** 0 filas. **Real:** 0 filas. **La regla se cumple.**

---

## Resumen de hallazgos

| Validación | Regla | Real | Hallazgo |
| --- | --- | --- | --- |
| VAL-01 | sin usuarios duplicados | 1 | usuarios 2 y 6 con el mismo email |
| VAL-02 | pedido con usuario existente | 1 | pedido 107 → usuario 99 inexistente |
| VAL-03 | línea con producto existente | 1 | línea 16 → producto 99 inexistente |
| VAL-04 | cantidad mayor a cero | 1 | línea 17 con cantidad 0 |
| VAL-05 | stock y precio válidos | 2 | stock −3 (Campera Winter) y precio 0 (Gorra Sport) |
| VAL-06 | total igual a suma de líneas | 1 | pedido 106: 8000.00 contra 8400.00 |
| VAL-07 | un pago por pedido | 1 | pedido 111 con pago duplicado |
| VAL-08 | pagado igual a total | 2 | pedidos 111 y 112 |
| VAL-09 | `paid` con pago aprobado | 0 | se cumple |
| VAL-10 | precio de línea igual al catálogo | 0 | se cumple |

---

## Cómo reportar un hallazgo

Un hallazgo sin evidencia no sirve. Un reporte corto, con lo que necesita quien lo recibe:

```
Título:      Pedido 107 apunta a un usuario que no existe
Esperado:    todo pedido pertenece a un usuario existente
Real:        el pedido 107 tiene user_id = 99 y no hay un usuario 99
Consulta:    (la de VAL-02)
Evidencia:   1 fila → 107, user_id 99, paid, 1500.00
Impacto:     un pedido pagado que no se puede asociar a ningún cliente
Derivar a:   equipo de desarrollo / datos
```

Siempre se pega la consulta y el número de filas: así cualquiera puede reproducir el hallazgo.
