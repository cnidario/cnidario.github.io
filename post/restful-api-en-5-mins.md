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

![Prompt interactivo al crear un proyecto con Directus](../img/restful-directus-1.png)

3. Ya está listo. Arrancamos la app.
```bash
cd tienda-directus && npx directus start
```

4. Ahora sólo queda acceder a localhost:8055

![Pantalla de login de la app de administración](../img/restful-directus-2.png)

## Creando el modelo
Será una tienda no demasiado simple. Tenemos artículos con título, descripción, precio, imagen y valoraciones asociadas a comentarios de usuarios.
Colecciones:

 - articulos titulo, descripcion, precio, imagen
 - usuarios nombre, password
 - valoraciones comentario, puntuacion
 - cada articulo tiene muchas valoraciones
 - cada usuario tiene muchas valoraciones
 - cada valoración tiene un único usuario y único articulo. Directus no tiene O2O

Despues de crear las entidades/tablas (la relación con SQL se nota bastante directa), tenemos algo así:

![Settings > Data Model](../img/restful-directus-3.png)

Y tras añadir unos productos, usuarios y valoraciones, esto:

![Content](../img/restful-directus-4.png)

## Roles & permisos
Crea un nuevo rol con acceso a las entidades. Seguidamente crea un usuario con ese rol y genera un Bearer token. Este token será con el que accederemos a la API Rest.

![Settings > Roles & Permissions > App Role](../img/restful-directus-5.png)

## Hecho.
Test simple con curl.
```{.console}
curl -H "Authorization: Bearer <TU_TOKEN_AQUI>" http://localhost:8055/items/product
curl -H "Authorization: Bearer <TU_TOKEN_AQUI>" http://localhost:8055/items/rating
curl -H "Authorization: Bearer <TU_TOKEN_AQUI>" http://localhost:8055/items/user
```

Bueno, no fueron 5 minutos. Pero menos de 30, quien podía esperarlo?

## Bonus: La app completa de regalo
Quizá ha planteado algo de dificultad la configuración del servidor (Directus + Caddy front con reverse proxy). Sobre todo por la unión de la necesidad de CORS + el modo de autorización de Directus (Bear Token). Y tras unas horas de debug tenemos una simple web store en JS puro.

![Nuestra esmerada web store](../img/restful-directus-6.png)

index.html
```{.html}
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="referrer" content="no-referrer" />
    <title>Super Low Tech Store</title>
<style>.im { width: 240px; } .app {display: flex; } </style>
</head>
<body>
    <h1>Super Low Tech Store!</h1>
    <h2>Products</h2>
    <div class="app">
        <ul id="product-list"></ul>
        <h2 id="product-title"></h2>
        <ul id="rating-list"></ul>
    </div>
    <script>
        let fetch_options = { 
            method: 'GET',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'Authorization': 'Bearer kiuf5iazcFAX_dd16LKDud7MmpEbCqh1',
            },
            mode: 'cors',
         };
        function productClick(elm) {
            let rating_list = document.getElementById('rating-list');
            rating_list.replaceChildren();
            fetch(`https://localhost:8887/items/product/${elm.getAttribute('data-pid', elm)}`, fetch_options)
            .then(res => res.text())
            .then(data => JSON.parse(data))
            .then(json => {
                let ptitle = json["data"]["title"];
                let ptitelm = document.getElementById('product-title');
                ptitelm.replaceChildren(document.createTextNode(ptitle));
                // load ratings
                let r_root = document.getElementById('rating-list');
                let r_list = json["data"]["ratings"];
                for(let r of r_list) {
                    fetch(`https://localhost:8887/items/rating/${r}`, fetch_options)
                    .then(res => res.text())
                    .then(data => JSON.parse(data))
                    .then(json => {
                        let rat = json["data"];
                        let comment = rat['comment'];
                        let user_id = rat['user_owner'];
                        let value = rat['value'];
                        fetch(`https://localhost:8887/items/user/${user_id}`, fetch_options)
                        .then(res => res.text())
                        .then(data => JSON.parse(data))
                        .then(json => {
                            let relm = createRatingElement(comment, json['data']['name'], value);
                            r_root.appendChild(relm);
                        });
                    }).then(() => console.log("Ratings loaded Ok."));
                }
            }).then(() => console.log("Products loaded OK."));
        }
        function createProductElement(title, description, img, pid) {
            let product_top = document.createElement("li");
            let ptitle = document.createElement("a");
            ptitle.href = "#";
            ptitle.setAttribute('onclick', "productClick(this)");
            ptitle.setAttribute('data-pid', pid);
            ptitle.appendChild(document.createTextNode(title));
            let pdesc = document.createElement("p");
            pdesc.appendChild(document.createTextNode(description));
            let pimg = document.createElement("img");
            pimg.src = 'https://localhost:8887/assets/' + img;
            pimg.classList.add('im');
            product_top.appendChild(ptitle);
            product_top.appendChild(pdesc);
            product_top.appendChild(pimg);
            return product_top;
        }
        function createRatingElement(title, user_name, value) {
            let rating_top = document.createElement("li");
            rating_top.appendChild(document.createTextNode(`${user_name} said: ${title}. Rating: ${value}/5`));
            return rating_top;
        }

        fetch('https://localhost:8887/items/product', fetch_options)
        .then(res => res.text())
        .then(data => JSON.parse(data))
        .then(json => {
            let p_root = document.getElementById('product-list');
            let p_list = json["data"];
            for(let p of p_list) {
                let pelm = createProductElement(p['title'], p['description'], p['image'], p['id']);
                p_root.appendChild(pelm);
            }
        }).then(() => console.log("Products loaded OK."));
    </script>
</body>
</html>
```
Caddyfile (observad la pequeña trampa para bypasear la autorización al server de directus, quizá todo hubiera sido más simple sin meternos a necesitar CORS haciendo el reverse proxy transparente, todo al https://localhost:8888 y no parte al 8887)
```{.ini}
{
        http_port 8889
        https_port 8888
}

localhost:8888 {
        root .
        file_server
}
localhost:8887 {
        @options {
            method OPTIONS
        }
        header {
            Access-Control-Allow-Origin "https://localhost:8888"
            Access-Control-Allow-Methods "GET, POST, PUT, PATCH, DELETE"
            Access-Control-Allow-Headers "Content-Type, Authorization, Accept-Ranges"
            Access-Control-Max-Age "86400"
            defer
        }
        reverse_proxy /assets/* http://localhost:8055 {
            header_up Authorization "Bearer kiuf5iazcFAX_dd16LKDud7MmpEbCqh1"
        }
        reverse_proxy http://localhost:8055 {
            header_down -Access-Control-Allow-Origin

        }
        respond @options 204
}
```
Oh, bueno, y para arrancarlo todo hago algo como
```{.bash}
#!/bin/bash

set -eu pipefail

echo "Starting postgres container"
docker start postgres_db
echo "Starting caddy, use caddy reload or caddy stop to control"
caddy start
echo "Starting directus"
(cd ../tienda-directus && npx directus start)
```
## Conclusiones
Nos hemos ventilado un backend con bastante fácil. Lo interesante es que Directus es una app no-code que otorga directamente una interfaz web bonita para backoffice (introduzco los datos en mi base de datos con una interfaz web). Además, a diferencia de Strapi (según afirman), no impone un formato sobre la base de datos, esto parece bastante cierto (bastante porque las relaciones sí que vienen precondiguradas a cierta forma). Así que lo veo genial para prototipar y para backends con stores o modelos simples (blogs, coleccionesde recursos, inventarios...).
