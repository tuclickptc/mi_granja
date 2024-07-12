# Mi Granja en Move

## Descripción

El módulo Granja proporciona una serie de funciones para gestionar una granja virtual en la blockchain, permitiendo a los usuarios comprar y vender cultivos y ganado, así como consultar el estado de su granja.

## Funciones

**Tipo_cultivo(i: u64): (String, u64)**: Inicializa y devuelve un tipo de cultivo basado en el índice i.

**Tipo_ganado(i: u64): (String, u64)**: Inicializa y devuelve un tipo de ganado basado en el índice i.

**public entry fun init_granja(s: &signer)**: Inicializa una nueva granja para el usuario.

**public entry fun comprar_cultivo(s: &signer, i: u64) acquires EstadoGranja**: Compra un cultivo basado en el índice i y lo añade a la granja del usuario.

**public entry fun comprar_ganado(s: &signer, i: u64, cantidad: u64) acquires EstadoGranja**: Compra una cantidad de ganado basada en el índice i y lo añade a la granja del usuario.

**public entry fun vender_cultivo(s: &signer, i: u64) acquires EstadoGranja**: Vende un cultivo basado en el índice i desde la granja del usuario.

**public entry fun vender_ganado(s: &signer, i: u64, cantidad_v: u64) acquires EstadoGranja**: Vende una cantidad específica de ganado basado en el índice i desde la granja del usuario.

## Funciones de vista
- **public fun estado_cultivos(s: address): vector<Cultivo> acquires EstadoGranja**: Obtiene el estado actual de los cultivos en la granja del usuario.

- **public fun estado_ganado(s: address): vector<Ganado> acquires EstadoGranja**: Obtiene el estado actual del ganado en la granja del usuario.

- **public fun saldo_disponible(s: address): u64 acquires EstadoGranja**: Obtiene el saldo disponible en la granja del usuario.

- **public fun nivel_actual(s: address): u64 acquires EstadoGranja**: Obtiene el nivel actual de la granja del usuario.

## Instalación y Despliegue

### Compilación del contrato

Para compilar el contrato, utiliza el siguiente comando:

>``` sh
aptos move compile --named-addresses cuenta=default
>```

### Publicación del contrato

Para publicar el contrato en la blockchain, utiliza el siguiente comando:

>``` sh
aptos move publish --named-addresses cuenta=default
>```

### Interactuando con el paquete publicado

Para interactuar con el paquete publicado, puedes utilizar los siguientes comandos:

#### Inicializar la granja

>``` sh
aptos move run --function-id 'default::Granja::init_granja'
>```

#### Comprar un cultivo

>``` sh
aptos move run --function-id 'default::Granja::comprar_cultivo' --args u64:0
>```

#### Comprar ganado

>``` sh
aptos move run --function-id 'default::Granja::comprar_ganado' --args u64:0 u64:3
>```

#### Vender un cultivo

>``` sh
aptos move run --function-id 'default::Granja::vender_cultivo' --args u64:0
>```

#### Consultar el saldo disponible

>``` sh
aptos move view --function-id 'default::Granja::saldo_disponible' --args address:direccion_de_la_cuenta
>```

#### Consultar el estado del ganado

>``` sh
aptos move view --function-id 'default::Granja::estado_ganado' --args address:direccion_de_la_cuenta
>```

#### Obtener la dirección de la cuenta

Para obtener la dirección de la cuenta, puedes usar:

>``` sh
aptos account lookup-address
>```

