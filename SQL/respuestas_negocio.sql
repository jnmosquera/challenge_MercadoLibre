-- Consulta del negocio N°1

--Listar los usuarios que cumplan años el día de hoy cuya cantidad de ventas realizadas en enero 2020 sea superior a 1500. 

SELECT c.customer_id, c.nombre, c.apellido
FROM Customer c
JOIN [Item] i ON c.customer_id = i.seller_id
JOIN [Orders] o ON i.item_id = o.item_id
WHERE 
    MONTH(c.fecha_nacimiento) = MONTH(GETDATE()) -- Evaluamos que el cumpleaños sea el mes y dia de hoy.
    AND DAY(c.fecha_nacimiento) = DAY(GETDATE())
    AND YEAR(o.fecha) = 2020 -- Filtramos operaciones realizadas enero del 2020
    AND MONTH(o.fecha) = 1
GROUP BY c.customer_id, c.nombre, c.apellido, c.email
HAVING COUNT(o.order_id) > 1500; -- Filtramos aquellos que tengan más de 1500 operaciones

----------------------------------------

--Consulta del Negocio N°2

--Por cada mes del 2020, se solicita el top 5 de usuarios que más vendieron($) en la categoría Celulares. 
--Se requiere el mes y año de análisis, nombre y apellido del vendedor, cantidad de ventas realizadas, 
--cantidad de productos vendidos y el monto total transaccionado.


SELECT TOP 5
    MONTH(o.fecha) AS mes, 
    YEAR(o.fecha) AS año,
    c.nombre, 
    c.apellido, 
    COUNT(o.order_id) AS cantidad_ventas,
    SUM(o.cantidad) AS productos_vendidos,
    SUM(o.total) AS monto_total
FROM Customer c
JOIN Item i ON c.customer_id = i.seller_id
JOIN Orders o ON i.item_id = o.item_id
JOIN Category cat ON i.category_id = cat.category_id
WHERE 
    YEAR(o.fecha) = 2020 --Filtramos el año
    AND cat.nombre = 'Celulares' -- Filtramos por la categoría
GROUP BY MONTH(o.fecha), YEAR(o.fecha), c.nombre, c.apellido
ORDER BY mes, año, monto_total DESC; --Ordenamos por monto total DESC para usar el TOP 5

-----------------------------------------

--Consulta del Negocio N°3

 --Se solicita poblar una nueva tabla con el precio y estado de los Ítems a fin del día. Tener en cuenta que debe ser reprocesable. 
 --Vale resaltar que en la tabla Item, vamos a tener únicamente el último estado informado por la PK definida. 
 --(Se puede resolver a través de StoredProcedure) 


 --Consideraciones:

 --Como se el estado de items al final del día, pero no aclara si debemos guardar un historico, mi solución contempla que se guarde un historial de items por dia


CREATE PROCEDURE UpdateItemHistory
AS
BEGIN

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ItemHistory')
    BEGIN
        CREATE TABLE ItemHistory (
            item_id INT,
            fecha DATE,
            precio DECIMAL(10,2),
            estado VARCHAR(50),
            PRIMARY KEY (item_id, fecha)
        );
    END

    SET NOCOUNT ON;
    MERGE INTO ItemHistory AS target
    USING (SELECT item_id, CAST(GETDATE() AS DATE) AS fecha, precio, estado FROM Item) AS source  --Selecciono los valores de Item y agrega una columna con la fecha de proceso.
    ON target.item_id = source.item_id AND target.fecha = source.fecha  --Si el SP se corrio durante el día y lo volves a ejecutar, busca los valores del día que existan y los actualiza.
    WHEN MATCHED THEN
        UPDATE SET target.precio = source.precio, target.estado = source.estado --Si no existen valores para el día los agrega.
    WHEN NOT MATCHED THEN
        INSERT (item_id, fecha, precio, estado)
        VALUES (source.item_id, source.fecha, source.precio, source.estado);
END;
GO
