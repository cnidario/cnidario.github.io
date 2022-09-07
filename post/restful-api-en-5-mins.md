---
title: RESTful API funcional en 5 minutos con Directus / Strapi
date: 2021-05-22
description: "Cómo tener disponible una API Rest sencilla rápidamente (pero lo suficientemente robusta) PASO A PASO"
draft: true
---

[Directus](https://directus.io) y [Strapi](https://strapi.io) son dos soluciones [no-code](https://en.wikipedia.org/wiki/No-code_development_platform) para la gestión de un repositorio de datos. También son llamados _headless CMS_ (porque al contrario que Wordpress no tienen incluído dentro toda la parafernalia para mostrar el contenido).

O sea, te permiten montar rápidamente un repositorio de datos, gestionarlo a través de una interfaz web y consumirlo a través de una interfaz REST o GraphQL (por ejemplo). ¿Necesitas montar una PostgreSQL, con una CRUD típica que sea consumida con REST y además con una bonita interfaz de administración (Backoffice) y las funcionalidades típicas de Autenticación, Paginación, etc, etc...? Puedes cogerte un framework en el que estés suelto como Spring, Django o Rails y tardar unas ¿horas?, ¿días? O desplegarla con Directus en 5 minutos **de reloj**.

Son realmente sencillos y útiles para tener en el toolbox y en mi opinión no incurren en demasiada deuda técnica como para suponer un riesgo frente a otras opciones que intentan abarcar mucho más. Lo que hacen, de todos modos, no es ciencia para cohetes, sólo se trata de hacer una tarea común rápida para prototipos o para servicios no demasiado exigentes.

Al ajo.

# La tienda con Directus

1. Instancia Postgres (lo hago con docker)
```bash
docker volume create tienda
docker run --name postgres_db \
    -e POSTGRES_PASSWORD=postgres \
    -e POSTGRES_USER=postgres \
    -e POSTGRES_DB=tienda \
    -p 5432:5432 \
    -v tienda:/var/lib/postgresql/data \
    -d postgres
```

2. Proyecto Directus
```bash
npx create-directus-project tienda-directus
```
Es un programa **interactivo**. Seleccionamos PostgreSQL y ponemos la password, user y nombre de base de datos con los que lanzamos el contenedor de Docker. También puede configurarse offline.

![Prompt interactivo al crear un proyecto con Directus](/blog/restful-directus-1.png)

3. Ya está listo. Arrancamos la app.
```bash
cd tienda-directus && npx directus start
```

4. Ahora sólo queda acceder a localhost:8055

![Pantalla de login de la app de administración](/blog/restful-directus-2.png)

## Creando el modelo
Será una tienda no demasiado simple. Tenemos artículos con título, descripción, precio, imagen y valoraciones asociadas a comentarios de usuarios.
Colecciones:
 - articulos titulo, descripcion, precio, imagen
 - usuarios nombre, password
 - valoraciones comentario, puntuacion
 - cada articulo tiene muchas valoraciones
 - cada usuario tiene muchas valoraciones
 - cada valoración tiene un único usuario y único articulo. Directus no tiene O2O

Roles & permisos
