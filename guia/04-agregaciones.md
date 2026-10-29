# 04 · Agregaciones

Las funciones de agregación resumen muchas filas en un solo número: cuántas hay, cuánto suman, cuál es el mínimo o el máximo. Sirven para reportes y para chequeos rápidos de calidad de datos.

---

### Contar filas

**Soporte:** ¿cuántos clientes tenemos cargados?

```sql
SELECT COUNT(*) AS usuarios
FROM users;
```

**Resultado:** 1 fila: `usuarios = 10`.

---

### `COUNT(*)` contra `COUNT(columna)`

**QA:** medir cuántos registros están incompletos, con una sola consulta.

```sql
SELECT COUNT(*)     AS filas,
       COUNT(email) AS con_email
FROM users;
```

**Resultado:** 1 fila: `filas = 10`, `con_email = 9`.

**Ojo:** `COUNT(*)` cuenta filas; `COUNT(columna)` cuenta solo las filas donde esa columna **no es `NULL`**. La diferencia (10 − 9 = 1) es la cantidad de emails vacíos.

---

### Contar valores distintos

**Soporte / QA:** cuántos pedidos hay y cuántos clientes distintos los hicieron.

```sql
SELECT COUNT(*)                AS pedidos,
       COUNT(DISTINCT user_id) AS clientes_distintos
FROM orders;
```

**Resultado:** 1 fila: `pedidos = 12`, `clientes_distintos = 9`.

**Ojo:** un cliente con varios pedidos cuenta una sola vez en `clientes_distintos`.

---

### Sumar y promediar

**Soporte / QA:** ¿cuántos pedidos pagados hay, cuánto suman y cuál es el promedio?

```sql
SELECT COUNT(*)              AS cantidad,
       SUM(total)            AS suma,
       ROUND(AVG(total), 2)  AS promedio
FROM orders
WHERE status = 'paid';
```

**Resultado:** 1 fila: `cantidad = 7`, `suma = 59600.00`, `promedio = 8514.29`.

**Ojo:** el `WHERE` se aplica **antes** de agregar: solo se suman los pedidos `paid`. Y `ROUND(..., 2)` evita que el promedio salga con una cola de decimales.

---

### Mínimo y máximo

**QA:** el rango de precios del catálogo.

```sql
SELECT MIN(price) AS mas_barato,
       MAX(price) AS mas_caro
FROM products
WHERE price > 0;
```

**Resultado:** 1 fila: `mas_barato = 1500.00`, `mas_caro = 12000.00`.

**Ojo:** sin el `WHERE price > 0`, el mínimo sería `0.00`: el precio de `Gorra Sport`, un dato sospechoso. Un mínimo inesperado suele ser una pista de calidad de datos.

---

### Buscar valores imposibles o sospechosos

Chequeos de una sola tabla que un QA corre apenas recibe una base nueva:

```sql
-- Productos sin stock o con stock negativo
SELECT id, name, stock
FROM products
WHERE stock <= 0;
```

**Resultado:** 2 filas: 3 Vestido Floral (0) y 8 Campera Winter (-3).

```sql
-- Solo el stock negativo
SELECT id, name, stock
FROM products
WHERE stock < 0;
```

**Resultado:** 1 fila: 8 Campera Winter (-3). Un stock negativo es un defecto: no se pueden tener menos de cero unidades; indica una venta sin control de stock o un dato mal cargado.

```sql
-- Productos con precio cero o negativo
SELECT id, name, price
FROM products
WHERE price <= 0;
```

**Resultado:** 1 fila: 7 Gorra Sport (0.00).

```sql
-- Pedidos con total cero
SELECT id, total
FROM orders
WHERE total = 0;
```

**Resultado:** 1 fila: pedido 110 (0.00).

**Ojo:** una validación de este tipo **debería devolver 0 filas**. Si devuelve filas, esas filas son la evidencia del defecto.

---

### Un reporte simple: lo facturado en un período

**Soporte / QA:** total de pedidos pagados en mayo de 2026.

```sql
SELECT SUM(total) AS facturado
FROM orders
WHERE status = 'paid'
  AND created_at >= '2026-05-01'
  AND created_at <  '2026-06-01';
```

**Resultado:** 1 fila: `facturado = 49200.00`.
