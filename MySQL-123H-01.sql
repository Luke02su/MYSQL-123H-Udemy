CREATE DATABASE clientes
DEFAULT CHARACTER SET utf8mb4 -- tipos de caracteres padrão português brasileiro
DEFAULT COLLATE utf8mb4_0900_ai_ci; -- não é sensível à acentuação e tamanho das letras

ALTER SCHEMA clientes  -- alterando database (character e collate)
DEFAULT CHARACTER SET utf8mb4 -- mantém o português
DEFAULT COLLATE utf8mb4_0900_as_cs; -- sensível à acentuação e ao tamanho das letras

SHOW CHARACTER SET; -- mostra as collations que existem