---
title: Test title
author: cnidario
date: 2020-01-07
publishDate: 2020-01-07
tags:
- arduino
- test
categories: 
- electronics
- testing
draft: true
references:
- type: article-journal
  id: WatsonCrick1953
  author:
  - family: Watson
    given: J. D.
  - family: Crick
    given: F. H. C.
  issued:
    date-parts:
    - - 1953
      - 4
      - 25
  title: 'Molecular structure of nucleic acids: a structure for deoxyribose nucleic acid'
  title-short: Molecular structure of nucleic acids
  container-title: Nature
  volume: 171
  issue: 4356
  page: 737-738
  DOI: 10.1038/171737a0
  URL: https://www.nature.com/articles/171737a0
  language: en-GB
---


Párrafo de test. Las hormigas son rojas, las que pican, como el [sol](www.test.com) del *ocaso italica*. Alguna prueba con la **negrita**.
***Y con combinaciones de ambas.***
Quiero poner un ejemplo de `<head>` inline code. Test <kbd>Ctrl+T</kbd>

Lista de prueba:

- Patatas. 1kg
- Leche, litro y medio.
- Animales, compra muchos.

> Dorothy followed her through many of the beautiful rooms in her castle.
>
>> The Witch bade her clean the pots and kettles and sweep the floor and keep the fire fed with

Test de code

``` {#codetest .haskell .numberLines startFrom="100"}
main = putStrLn "hola mundo"

test :: [Int] -> Int -> Int
test f = map f . filter (\x -> null (x ++ []) )
```

1. First item
1. Second item
1. Third item
1. Fourth item 

1. First item
2. Second item
3. Third item
    1. Indented item
    2. Indented item
4. Fourth item

- First item
- Second item
- Third item
    - Indented item
        
        Párrafo metido entre items de una lista.
        
    - Indented item
        
        <html>
           <head>
             <title>Test</title>
           </head>
        
- Fourth item

## Titulo 2

| Tables   |      Are      |  Cool |
|----------|:-------------:|------:|
| col 1 is |  left-aligned | $1600 |
| col 2 is |    centered   |   $12 |
| col 3 is | right-aligned |    $1 |

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

![A nice cat](/img/test/cat256.jpg "he is so cute") Escribir después. The cat (Felis catus) is a domestic species of a small carnivorous mammal.[1][2] It is the only domesticated species in the family Felidae and is often referred to as the domestic cat to distinguish it from the wild members of the family.[4] A cat can either be a house cat, a farm cat or a feral cat; the latter ranges freely and avoids human contact.[5] Domestic cats are valued by humans for companionship and their ability to kill rodents. About 60 cat breeds are recognized by various cat registries.

Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?

![A nice cat](/img/test/cat256.jpg "he is so cute") 

En grande
![A nice cat](/img/test/cat.jpg "he is so cute")

test etes
test

---

My favorite search engine is [Duck Duck Go](https://duckduckgo.com "The best search engine for privacy").

I love supporting the **[EFF](https://eff.org)**.
This is the *[Markdown Guide](https://www.markdownguide.org)*.
See the section on [`code`](#code).

Link de referencia [hobbit-hole][1]

[1]: https://en.wikipedia.org/wiki/Hobbit#Lifestyle "Hobbit lifestyles"



Blah blah [see @WatsonCrick1953, pp. 33-35; also @WatsonCrick1953, chap. 1].

Blah blah [@WatsonCrick1953, pp. 33-35, 38-39 and *passim*].

Blah blah [@WatsonCrick1953; @WatsonCrick1953].

### Titulo 2.1

> #### The quarterly results look great!
>
> - Revenue was off the chart.
> - Profits were higher than ever.
>
>  *Everything* is going according to **plan**.

## Titulo 3

