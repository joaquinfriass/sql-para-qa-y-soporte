# 01 · SELECT básico

`SELECT` elige **qué columnas** mostrar y `FROM` indica **de qué tabla**. Todo lo demás (filtrar, ordenar, agrupar) se agrega sobre esta base.

---

### Ver todo el contenido de una tabla

**QA:** echar un primer vistazo a los datos de una tabla nueva. **Soporte:** ver cómo es un registro antes de buscar uno puntual.

```sql
SELECT * FROM users;
```

**Resultado:** 10 filas, todas las columnas de `users`.

**Ojo:** `*` sirve para explorar. En una consulta que se va a reutilizar conviene nombrar las columnas: si la tabla cambia, el resultado cambia, y se traen datos de más.

---

### Elegir columnas

**Soporte:** mostrar solo lo que se necesita para identificar a un cliente.

```sql
SELECT id, name, email
FROM users;
```

**Resultado:** 10 filas con tres columnas. En la fila 7 el `email` aparece vacío (`NULL`).

---

### Ver los valores distintos de una columna

**QA:** descubrir qué valores existen en una columna de estados o categorías. Si aparecen `active` y `Active`, es un defecto.
**Soporte:** saber en qué países hay clientes.

```sql
SELECT DISTINCT country
FROM users;
```

**Resultado:** 4 filas: `AR`, `CL`, `UY`, `BR`.

```sql
SELECT DISTINCT status
FROM orders;
```

**Resultado:** 5 filas: `paid`, `shipped`, `delivered`, `cancelled`, `pending`.

**Ojo:** `DISTINCT` aplica a la combinación de **todas** las columnas elegidas, no solo a la primera.

---

### Ponerle nombre a una columna (alias)

**Soporte:** dejar un resultado legible para pegarlo en un reporte.

```sql
SELECT name AS producto,
       price AS precio
FROM products;
```

**Resultado:** 8 filas con las columnas `producto` y `precio`.

---

### Columnas calculadas

**QA:** comprobar un cálculo, por ejemplo el precio con IVA del 21 %.

```sql
SELECT name,
       price * 1.21 AS con_iva
FROM products;
```

**Resultado:** 8 filas. `Gorra Sport` da 0 porque su precio es 0 (un dato sospechoso; se ve en [04 · Agregaciones](04-agregaciones.md)).

**Ojo:** la columna calculada no se guarda en la tabla: existe solo en el resultado de esa consulta.
