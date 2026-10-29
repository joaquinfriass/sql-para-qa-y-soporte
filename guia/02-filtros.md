# 02 · Filtros

`WHERE` deja pasar solo las filas que cumplen una condición. Es la parte que más se usa en soporte (encontrar *ese* registro) y en QA (aislar los datos sospechosos).

---

### Una condición y otra a la vez (`AND`)

**Soporte:** clientes de Argentina que siguen activos.

```sql
SELECT id, name
FROM users
WHERE country = 'AR'
  AND status = 'active'
ORDER BY id;
```

**Resultado:** 4 filas: 1 Ana Pérez, 2 Bruno Díaz, 5 Elena Sosa, 6 Bruno Díaz.

**Ojo:** los textos van entre comillas simples. Y hay dos «Bruno Díaz» con el mismo email: un posible usuario duplicado para investigar.

---

### Valores vacíos: `IS NULL` e `IS NOT NULL`

**QA:** encontrar registros incompletos. **Soporte:** un cliente dice que no le llegan los mails; ¿tiene email cargado?

```sql
SELECT id, name
FROM users
WHERE email IS NULL;
```

**Resultado:** 1 fila: 7 Fabián Luna.

```sql
SELECT id, name
FROM users
WHERE email IS NOT NULL;
```

**Resultado:** 9 filas.

**Ojo:** `WHERE email = NULL` **no da error y devuelve 0 filas**. `NULL` significa «sin valor» y no es igual a nada, ni siquiera a sí mismo. Hay que usar `IS NULL`.

---

### Rango de valores: `BETWEEN`

**Soporte:** productos de precio medio para armar una promoción.

```sql
SELECT name, price
FROM products
WHERE price BETWEEN 3000 AND 9500
ORDER BY price;
```

**Resultado:** 5 filas: Vestido Floral 3800.00, Jean Slim 4200.00, Mochila Urban 5200.00, Campera Winter 8900.00, Zapatillas Run 9500.00.

**Ojo:** `BETWEEN` **incluye los dos extremos** (el 9500 aparece).

---

### Buscar por parte de un texto: `LIKE`

**Soporte:** el cliente no recuerda el nombre completo.

```sql
SELECT id, name
FROM users
WHERE name LIKE 'B%';
```

**Resultado:** 2 filas: 2 y 6, los dos «Bruno Díaz».

`%` reemplaza cualquier cantidad de caracteres. Para buscar al final o en el medio:

```sql
SELECT id, name
FROM users
WHERE email LIKE '%@mail.com';
```

**Resultado:** 9 filas (el usuario sin email no aparece, porque `NULL` no cumple ninguna comparación).

**Ojo:** si `LIKE` distingue mayúsculas de minúsculas depende del motor y de su configuración. PostgreSQL distingue; SQL Server, con la configuración habitual, no.

---

### Varios valores posibles: `IN`

**Soporte:** pedidos que todavía no se entregaron o que se cancelaron.

```sql
SELECT id, status
FROM orders
WHERE status IN ('pending', 'cancelled');
```

**Resultado:** 3 filas: 108 cancelled, 109 pending, 110 pending.

**Ojo:** `IN (...)` equivale a varios `OR`. Con `NOT IN`, si la lista (o una subconsulta) contiene un `NULL`, el resultado puede ser **0 filas** sin que haya error: es una trampa clásica.

---

### `AND` y `OR` juntos: los paréntesis importan

**QA:** pedidos pagados o enviados con un total mayor a 8000.

```sql
SELECT id, status, total
FROM orders
WHERE (status = 'paid' OR status = 'shipped')
  AND total > 8000;
```

**Resultado:** 4 filas: 102, 104, 111, 112.

Sin los paréntesis:

```sql
SELECT id, status, total
FROM orders
WHERE status = 'paid' OR status = 'shipped'
  AND total > 8000;
```

**Resultado:** 7 filas, **todos los pedidos `paid`**, incluso los de 1500.

**Ojo:** `AND` se evalúa antes que `OR`. Sin paréntesis, la segunda consulta se lee como `paid OR (shipped AND total > 8000)`. No da error: da un resultado distinto al que se quería.

---

### Filtrar por fechas

**QA / Soporte:** pedidos de mayo de 2026 con total mayor a 8000.

```sql
SELECT id, total, created_at
FROM orders
WHERE created_at >= '2026-05-01'
  AND created_at <  '2026-06-01'
  AND total > 8000
ORDER BY id;
```

**Resultado:** 5 filas: 102, 104, 105, 109, 111.

**Ojo:** conviene usar el **primer día del mes siguiente como límite superior exclusivo** (`< '2026-06-01'`) en lugar de `<= '2026-05-31'`. Si la columna tiene hora, el segundo planteo se pierde casi todo el último día.

---

### Buscar un caso concreto

Las consultas de soporte más comunes son filtros simples:

```sql
-- Pedidos de un cliente
SELECT id, status, total
FROM orders
WHERE user_id = 1
ORDER BY created_at;
```

**Resultado:** 2 filas: 101 (paid, 7200.00) y 104 (paid, 12000.00).

```sql
-- Un pedido puntual
SELECT id, user_id, status, total
FROM orders
WHERE id = 111;
```

**Resultado:** 1 fila: cliente 3, `paid`, 11000.00.

```sql
-- Clientes inactivos
SELECT id, name
FROM users
WHERE status = 'inactive';
```

**Resultado:** 2 filas: 4 Diego Ruiz y 9 Hugo Vega.

**Ojo:** si una búsqueda por `id` devuelve 0 filas, no alcanza con decir «no existe»: puede ser un error de tipeo o una consulta contra la base equivocada. Verificá antes de concluir.
