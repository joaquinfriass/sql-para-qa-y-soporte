# Equivalencias PostgreSQL ↔ SQL Server

La base de las consultas (`SELECT`, `WHERE`, `GROUP BY`, `JOIN`) es la misma en los dos motores. Lo que cambia son las funciones y algunos detalles de sintaxis. Esta tabla junta los que más molestan al pasar de uno a otro.

| Tarea | PostgreSQL | SQL Server |
| --- | --- | --- |
| Limitar filas | `... LIMIT 5` (al final) | `SELECT TOP 5 ...` (al principio), o `OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY` (requiere `ORDER BY`) |
| Concatenar texto | `a \|\| ' ' \|\| b` | `a + ' ' + b` o `CONCAT(a, ' ', b)` |
| Fecha y hora actual | `NOW()` | `GETDATE()` |
| Solo la fecha de hoy | `CURRENT_DATE` | `CAST(GETDATE() AS DATE)` |
| Últimos 7 días | `created_at >= CURRENT_DATE - INTERVAL '7 days'` | `created_at >= DATEADD(day, -7, CAST(GETDATE() AS DATE))` |
| Fecha con formato | `TO_CHAR(f, 'YYYY-MM')` | `FORMAT(f, 'yyyy-MM')` |
| Convertir de tipo | `x::numeric` o `CAST(x AS numeric)` | `CAST(x AS DECIMAL(10,2))` o `CONVERT(...)` |
| Reemplazar `NULL` | `COALESCE(x, 0)` | `COALESCE(x, 0)` o `ISNULL(x, 0)` |
| Largo de un texto | `LENGTH(x)` | `LEN(x)` |
| Buscar sin distinguir mayúsculas | `ILIKE` | no existe; con la configuración habitual `LIKE` ya no distingue |
| Texto largo | `TEXT` | `NVARCHAR(n)` o `NVARCHAR(MAX)` |
| Texto con acentos en un literal | `'Pérez'` | `N'Pérez'` (prefijo `N`) |
| Booleano | `BOOLEAN` | `BIT` (0 / 1) |
| Nombres entre comillas | `"nombre"` | `[nombre]` |

## Lo que funciona igual en los dos

`COUNT`, `SUM`, `AVG`, `MIN`, `MAX`, `ROUND`, `DISTINCT`, `GROUP BY`, `HAVING`, todos los `JOIN`, `CASE`, `COALESCE`, subconsultas, `WITH` (CTE) y `ROW_NUMBER() OVER (...)`.

## Dos diferencias que cambian resultados

- **Mayúsculas y minúsculas:** buscar `'ana'` con `=` o `LIKE` encuentra `'Ana'` en SQL Server (con la configuración habitual) y **no** en PostgreSQL.
- **`TOP` / `LIMIT` sin `ORDER BY`:** en los dos motores devuelven filas «cualquiera». Sin orden, el resultado no es reproducible.
