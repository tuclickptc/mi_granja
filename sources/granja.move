module cuenta::Granja {
    use std::signer;
    use std::vector::{empty, length, borrow, borrow_mut, push_back, swap_remove };
    use std::string::{String, utf8};

    // constantes
    const E_NO_HAY_FONDOS: u64 = 1;
    const E_NO_HAY_CULTIVOS: u64 = 2;
    const E_NO_HAY_GANADO: u64 = 3;
    const E_CANTIDAD_INVALIDA: u64 = 4;
    const E_NO_ESTA_DISPONIBLE: u64 = 5;
    const E_NIVEL_NO_DISPONIBLE: u64 = 6;

    // estructura para el tipo de cultivo
    struct TipoCultivo has drop, copy {
        tipo: String,
        precio: u64,
        nivel: u64,
        num_cosechas: u64,
    }

    // estructura para el tipo de ganado
    struct TipoGanado has drop, copy {
        tipo: String,
        precio: u64,
        nivel: u64,
        producto: String,
    }

    // estructura para el tipo de recurso
    struct TipoRecurso has drop, copy {
        tipo: String,
        precio: u64,
        aumento_diario: u64,
        usos: u64,
    }

    // estructura para el tipo de riego
    struct TipoRiego has drop, copy {
        tipo: String,
        precio: u64,
        aumento_diario: u64,
        usos: u64,
    }

    // estructura para el tipo de alimento
    struct TipoAlimentoGanado has drop, copy {
        tipo: String,
        precio: u64,
        aumento_diario: u64,
        usos: u64,
    }

    // estructura del ganado
    struct Ganado has copy, store, drop, key {
        tipo: String,
        salud: u64,
        produccion: u64,
        nivel: u64,
        cantidad: u64,
        valor: u64,
    }

    // Estructura de los cultivos
    struct Cultivo has copy, store, drop, key {
        tipo: String,
        riego: u64,
        fertilidad: u64,
        estado: bool,
        valor: u64,
        nivel: u64,
        num_cosechas: u64,
    }

    // estructura para los recursos
    struct Recurso has store, copy, drop, key {
        tipo: String,
        categoria: String,
        aumento_diario: u64,
        usos: u64,
    }

    // Estado de la granja
    struct EstadoGranja has store, drop, key {
        nivel: u64,
        propietario: address,
        saldo: u64,
        energia: u64,
        cultivos: vector<Cultivo>,
        ganado: vector<Ganado>,
        recursos: vector<Recurso>,
    }

    // inicializa los tipos de cultivo
    fun Tipo_cultivo(i: u64): (String, u64, u64, u64) {
        let cultivos = empty<TipoCultivo>();
        let cultivo1 = TipoCultivo { tipo: utf8(b"Maiz"), precio: 25, nivel: 1, num_cosechas: 2};
        push_back(&mut cultivos, cultivo1);
        let cultivo2 = TipoCultivo { tipo: utf8(b"Arroz"), precio: 50, nivel: 2, num_cosechas: 3};
        push_back(&mut cultivos, cultivo2);
        let cultivo3 = TipoCultivo { tipo: utf8(b"Trigo"), precio: 75, nivel: 3, num_cosechas: 3};
        push_back(&mut cultivos, cultivo3);
        let cultivo4 = TipoCultivo { tipo: utf8(b"Avena"), precio: 100, nivel: 4, num_cosechas: 4};
        push_back(&mut cultivos, cultivo4);
        let cultivo5 = TipoCultivo { tipo: utf8(b"Cebada"), precio: 125, nivel: 5, num_cosechas: 4};
        push_back(&mut cultivos, cultivo5);
        let cultivo6 = TipoCultivo { tipo: utf8(b"Soya"), precio: 150, nivel: 6, num_cosechas: 5};
        push_back(&mut cultivos, cultivo6);
        let cultivo7 = TipoCultivo { tipo: utf8(b"Girasol"), precio: 175, nivel: 7, num_cosechas: 5};
        push_back(&mut cultivos, cultivo7);
        let cultivo8 = TipoCultivo { tipo: utf8(b"Algodon"), precio: 200, nivel: 8, num_cosechas: 6};
        push_back(&mut cultivos, cultivo8);
        let cultivo9 = TipoCultivo { tipo: utf8(b"Papa"), precio: 225, nivel: 9, num_cosechas: 6};
        push_back(&mut cultivos, cultivo9);
        let cultivo10 = TipoCultivo { tipo: utf8(b"Fresas"), precio: 250, nivel: 10, num_cosechas: 8};
        push_back(&mut cultivos, cultivo10);
        let TipoCultivo { tipo, precio, nivel, num_cosechas } = *borrow(&cultivos, i);
        (tipo, precio, nivel, num_cosechas)
    }

    // inicializa los tipos de ganado
    fun Tipo_ganado(i: u64): (String, u64, u64, String) {
        let ganados = empty<TipoGanado>();
        let ganado1 = TipoGanado { tipo: utf8(b"Gallina"), precio: 6, nivel: 1, producto: utf8(b"Huevo de gallina")};
        push_back(&mut ganados, ganado1);
        let ganado2 = TipoGanado { tipo: utf8(b"Conejo"), precio: 15, nivel: 1, producto: utf8(b"Carne de conejo")};
        push_back(&mut ganados, ganado2);
        let ganado3 = TipoGanado { tipo: utf8(b"Obeja"), precio: 40, nivel: 2, producto: utf8(b"Lana")};
        push_back(&mut ganados, ganado3);
        let ganado4 = TipoGanado { tipo: utf8(b"Cabra"), precio: 60, nivel: 2, producto: utf8(b"Leche de cabra")};
        push_back(&mut ganados, ganado4);
        let ganado5 = TipoGanado { tipo: utf8(b"Cerdo"), precio: 85, nivel: 3, producto: utf8(b"Carne de cerdo")};
        push_back(&mut ganados, ganado5);
        let ganado6 = TipoGanado { tipo: utf8(b"Pato"), precio: 135, nivel: 3, producto: utf8(b"Huevos de pato")};
        push_back(&mut ganados, ganado6);
        let ganado7 = TipoGanado { tipo: utf8(b"Pavo"), precio: 160, nivel: 5, producto: utf8(b"Carne de pavo")};
        push_back(&mut ganados, ganado7);
        let ganado8 = TipoGanado { tipo: utf8(b"Ganso"), precio: 185, nivel: 7, producto: utf8(b"Huevos de ganzo")};
        push_back(&mut ganados, ganado8);
        let ganado9 = TipoGanado { tipo: utf8(b"Vaca"), precio: 210, nivel: 10, producto: utf8(b"Leche de vaca")};
        push_back(&mut ganados, ganado9);
        let ganado10 = TipoGanado { tipo: utf8(b"Caballo"), precio: 250, nivel: 10, producto: utf8(b"Potrillos")};
        push_back(&mut ganados, ganado10);
        let TipoGanado { tipo, precio, nivel, producto } = *borrow(&ganados, i);
        (tipo, precio, nivel, producto)
    }

    // inicializa los tipos de recursos
    fun Tipo_recurso(i: u64): (String, u64, u64, u64) {
        let recursos = empty<TipoRecurso>();
        let recurso1 = TipoRecurso { tipo: utf8(b"Abono Organico"), precio: 15, aumento_diario: 5, usos: 2};
        push_back(&mut recursos, recurso1);
        let recurso2 = TipoRecurso { tipo: utf8(b"Fertilizante Quimico"), precio: 30, aumento_diario: 10, usos: 2};
        push_back(&mut recursos, recurso2);
        let recurso3 = TipoRecurso { tipo: utf8(b"Pesticidas"), precio: 45, aumento_diario: 15, usos: 2};
        push_back(&mut recursos, recurso3);
        let recurso4 = TipoRecurso { tipo: utf8(b"Herbicidas"), precio: 60, aumento_diario: 20, usos: 2};
        push_back(&mut recursos, recurso4);
        let recurso5 = TipoRecurso { tipo: utf8(b"Semillas Mejoradas"), precio: 75, aumento_diario: 25, usos: 2};
        push_back(&mut recursos, recurso5);
        let recurso6 = TipoRecurso { tipo: utf8(b"Compost"), precio: 90, aumento_diario: 30, usos: 2};
        push_back(&mut recursos, recurso6);
        let recurso7 = TipoRecurso { tipo: utf8(b"Mulch"), precio: 105, aumento_diario: 35, usos: 2};
        push_back(&mut recursos, recurso7);
        let recurso8 = TipoRecurso { tipo: utf8(b"Enmiendas del Suelo"), precio: 120, aumento_diario: 40, usos: 2};
        push_back(&mut recursos, recurso8);
        let recurso9 = TipoRecurso { tipo: utf8(b"Control Biologico"), precio: 135, aumento_diario: 45, usos: 2};
        push_back(&mut recursos, recurso9);
        let recurso10 = TipoRecurso { tipo: utf8(b"Bioestimulantes"), precio: 150, aumento_diario: 50, usos: 2};
        push_back(&mut recursos, recurso10);
        let TipoRecurso { tipo, precio, aumento_diario, usos } = *borrow(&recursos, i);
        (tipo, precio, aumento_diario, usos)
    }

    // inicializa los tipos de sistemas de riego
    fun Tipo_riego(i: u64): (String, u64, u64, u64) {
        let sistemas_riego = empty<TipoRiego>();
        let riego1 = TipoRiego { tipo: utf8(b"Riego por Gravedad"), precio: 20, aumento_diario: 5, usos: 10};
        push_back(&mut sistemas_riego, riego1);
        let riego2 = TipoRiego { tipo: utf8(b"Riego por Aspersion"), precio: 40, aumento_diario: 10, usos: 6};
        push_back(&mut sistemas_riego, riego2);
        let riego3 = TipoRiego { tipo: utf8(b"Riego por Goteo"), precio: 60, aumento_diario: 15, usos: 5};
        push_back(&mut sistemas_riego, riego3);
        let riego4 = TipoRiego { tipo: utf8(b"Riego Subterraneo"), precio: 80, aumento_diario: 20, usos: 3};
        push_back(&mut sistemas_riego, riego4);
        let riego5 = TipoRiego { tipo: utf8(b"Riego por Inundacion"), precio: 100, aumento_diario: 25, usos: 3};
        push_back(&mut sistemas_riego, riego5);
        let riego6 = TipoRiego { tipo: utf8(b"Riego por Microaspersion"), precio: 120, aumento_diario: 30, usos: 3};
        push_back(&mut sistemas_riego, riego6);
        let riego7 = TipoRiego { tipo: utf8(b"Riego por Nebulizacion"), precio: 140, aumento_diario: 35, usos: 2};
        push_back(&mut sistemas_riego, riego7);
        let riego8 = TipoRiego { tipo: utf8(b"Riego Automatico"), precio: 160, aumento_diario: 40, usos: 4};
        push_back(&mut sistemas_riego, riego8);
        let riego9 = TipoRiego { tipo: utf8(b"Riego por Capilaridad"), precio: 180, aumento_diario: 45, usos: 4};
        push_back(&mut sistemas_riego, riego9);
        let riego10 = TipoRiego { tipo: utf8(b"Riego Inteligente"), precio: 200, aumento_diario: 50, usos: 5};
        push_back(&mut sistemas_riego, riego10);
        let TipoRiego { tipo, precio, aumento_diario, usos } = *borrow(&sistemas_riego, i);
        (tipo, precio, aumento_diario, usos)
    }

    // inicializa los tipos de alimentos para el ganado
    fun Tipo_alimento_ganado(i: u64): (String, u64, u64, u64) {
        let alimentos = empty<TipoAlimentoGanado>();
        let alimento1 = TipoAlimentoGanado { tipo: utf8(b"Heno"), precio: 10, aumento_diario: 5, usos: 5};
        push_back(&mut alimentos, alimento1);
        let alimento2 = TipoAlimentoGanado { tipo: utf8(b"Pasto"), precio: 20, aumento_diario: 10, usos: 5};
        push_back(&mut alimentos, alimento2);
        let alimento3 = TipoAlimentoGanado { tipo: utf8(b"Granos"), precio: 30, aumento_diario: 15, usos: 4};
        push_back(&mut alimentos, alimento3);
        let alimento4 = TipoAlimentoGanado { tipo: utf8(b"Concentrado"), precio: 40, aumento_diario: 20, usos: 3};
        push_back(&mut alimentos, alimento4);
        let alimento5 = TipoAlimentoGanado { tipo: utf8(b"Silaje"), precio: 50, aumento_diario: 25, usos: 6};
        push_back(&mut alimentos, alimento5);
        let alimento6 = TipoAlimentoGanado { tipo: utf8(b"Alfalfa"), precio: 60, aumento_diario: 30, usos: 4};
        push_back(&mut alimentos, alimento6);
        let alimento7 = TipoAlimentoGanado { tipo: utf8(b"Subproductos"), precio: 70, aumento_diario: 35, usos: 4};
        push_back(&mut alimentos, alimento7);
        let alimento8 = TipoAlimentoGanado { tipo: utf8(b"Racion Balanceada"), precio: 80, aumento_diario: 40, usos: 5};
        push_back(&mut alimentos, alimento8);
        let alimento9 = TipoAlimentoGanado { tipo: utf8(b"Suplementos Minerales"), precio: 90, aumento_diario: 45, usos: 4};
        push_back(&mut alimentos, alimento9);
        let alimento10 = TipoAlimentoGanado { tipo: utf8(b"Suplementos Proteicos"), precio: 100, aumento_diario: 50, usos: 6};
        push_back(&mut alimentos, alimento10);
        let TipoAlimentoGanado { tipo, precio, aumento_diario, usos } = *borrow(&alimentos, i);
        (tipo, precio, aumento_diario, usos)
    }

    // Inicializa la granja
    public entry fun init_granja(s: &signer) {
        let granja = EstadoGranja {
            nivel: 1,
            propietario: signer::address_of(s),
            saldo: 100,
            energia: 100,
            cultivos: empty<Cultivo>(),
            ganado: empty<Ganado>(),
            recursos: empty<Recurso>(),
        };
        move_to(s, granja)
    }

    // Comprar un cultivo
    public entry fun comprar_cultivo(s: &signer, i: u64) acquires EstadoGranja {
        let granja = borrow_global_mut<EstadoGranja>(signer::address_of(s));
        let (tipo, precio, nivel, num_cosechas) = Tipo_cultivo(i);
        assert!(granja.saldo >= precio, E_NO_HAY_FONDOS);
        let existe = false;
        for (j in 0..length(&granja.cultivos)) {
        let cultivo = borrow_mut(&mut granja.cultivos, j);
            if (cultivo.tipo == tipo) {
                if (cultivo.num_cosechas <= num_cosechas * (cultivo.nivel - 1)) {
                    granja.saldo = granja.saldo - precio;
                    cultivo.num_cosechas = cultivo.num_cosechas + num_cosechas;
                };
                existe = true;
                break
            };
        };
        if (!existe) {
            assert!(granja.nivel >= nivel && length(&granja.cultivos) < granja.nivel, E_NIVEL_NO_DISPONIBLE);
            let cultivo = Cultivo {
                tipo,
                riego: 0,
                fertilidad: 0,
                estado: false,
                valor: precio,
                nivel: 1,
                num_cosechas,
            };
            push_back(&mut granja.cultivos, cultivo);
            granja.saldo = granja.saldo - precio;
        };
    }

    // Comprar ganado
    public entry fun comprar_ganado(s: &signer, i: u64, cantidad: u64) acquires EstadoGranja {
        let granja = borrow_global_mut<EstadoGranja>(signer::address_of(s));
        let (tipo, precio, nivel, _producto) = Tipo_ganado(i);
        assert!(granja.saldo >= precio * cantidad, E_NO_HAY_FONDOS);
        let existe: bool = false;
        for (j in 0..length(&granja.ganado)) {
        let ganado = borrow_mut(&mut granja.ganado, j);
            if (ganado.tipo == tipo) {
                ganado.cantidad = ganado.cantidad + cantidad;
                granja.saldo = granja.saldo - cantidad * precio;
                existe = true;
                break
            };
        };
        if (!existe) {
            assert!(granja.nivel >= nivel, E_NIVEL_NO_DISPONIBLE);
        let ganado = Ganado {
            tipo,
            salud: 0,
            produccion: 0,
            nivel: 1,
            cantidad,
            valor: precio,
        };
        granja.saldo = granja.saldo - cantidad * precio;
        push_back(&mut granja.ganado, ganado);
        };
    }

    // Vende un cultivo
    public entry fun vender_cultivo(s: &signer, i: u64) acquires EstadoGranja {
        let granja = borrow_global_mut<EstadoGranja>(signer::address_of(s));
        assert!(length(&granja.cultivos) > 0, E_NO_HAY_CULTIVOS);
        let cultivo = borrow_mut(&mut granja.cultivos, i);
        if (cultivo.num_cosechas > 0) {
            if (!cultivo.estado) {
                cultivo.num_cosechas = cultivo.num_cosechas -1;
                cultivo.estado = false;
                granja.saldo = granja.saldo + cultivo.valor;
            } else {
                abort 0
            };
        } else {
            swap_remove(&mut granja.cultivos, i);
        };
    }

    // Vende ganado
    public entry fun vender_ganado(s: &signer, i: u64, cantidad_v: u64) acquires EstadoGranja {
        let granja = borrow_global_mut<EstadoGranja>(signer::address_of(s));
        assert!(length(&granja.ganado) > 0, E_NO_HAY_GANADO);
        if (borrow(&granja.ganado, i).cantidad >= cantidad_v) {
            let ganado = borrow_mut(&mut granja.ganado, i);
            ganado.cantidad = ganado.cantidad - cantidad_v;
            granja.saldo = granja.saldo + ganado.valor * cantidad_v;
            if (borrow(&granja.ganado, i).cantidad == 0) {
                swap_remove(&mut granja.ganado, i);
            };
        } else {
            abort 0
        };
    }

    // Aumenta el saldo y la energia de la granja cada 24 horas
    public fun incremento_diario(s: &signer) acquires EstadoGranja {
        let granja = borrow_global_mut<EstadoGranja>(signer::address_of(s));
        granja.saldo = granja.saldo + 100;
        granja.energia = 100;
    }

    // Comprar recursos
    public entry fun comprar_recurso(s: &signer, i: u64, cant: u64) acquires EstadoGranja {
        let granja = borrow_global_mut<EstadoGranja>(signer::address_of(s));
        let (tipo, precio, aumento_diario, usos) = Tipo_recurso(i);
        assert!(granja.saldo >= precio * cant, E_NO_HAY_FONDOS);
        let existe = false;
        for (j in 0..length(&granja.recursos)) {
            let recurso = borrow_mut(&mut granja.recursos, j);
            if (recurso.tipo == tipo) {
                recurso.usos = recurso.usos + usos * cant;
                granja.saldo = granja.saldo - precio * cant;
                existe = true;
                break
            };
        };
        if (!existe) {
            let recurso = Recurso {
                tipo,
                categoria: utf8(b"cultivo"),
                aumento_diario,
                usos,
            };
            granja.saldo = granja.saldo - precio * cant;
            push_back(&mut granja.recursos, recurso);
        };
    }

    // Comprar alimento
    public entry fun comprar_alimento(s: &signer, i: u64, cant: u64) acquires EstadoGranja {
        let granja = borrow_global_mut<EstadoGranja>(signer::address_of(s));
        let (tipo, precio, aumento_diario, usos) = Tipo_alimento_ganado(i);
        assert!(granja.saldo >= precio * cant, E_NO_HAY_FONDOS);
        let existe = false;
        for (j in 0..length(&granja.recursos)) {
            let recurso = borrow_mut(&mut granja.recursos, j);
            if (recurso.tipo == tipo) {
                recurso.usos = recurso.usos + usos * cant;
                granja.saldo = granja.saldo - precio * cant;
                existe = true;
                break
            };
        };
        if (!existe) {
            let recurso = Recurso {
                tipo,
                categoria: utf8(b"ganado"),
                aumento_diario,
                usos,
            };
            granja.saldo = granja.saldo - precio * cant;
            push_back(&mut granja.recursos, recurso);
        };
    }

    // Comprar riego
    public entry fun comprar_riego(s: &signer, i: u64, cant: u64) acquires EstadoGranja {
        let granja = borrow_global_mut<EstadoGranja>(signer::address_of(s));
        let (tipo, precio, aumento_diario, usos) = Tipo_riego(i);
        assert!(granja.saldo >= precio * cant, E_NO_HAY_FONDOS);
        let existe = false;
        for (j in 0..length(&granja.recursos)) {
            let recurso = borrow_mut(&mut granja.recursos, j);
            if (recurso.tipo == tipo) {
                recurso.usos = recurso.usos + usos * cant;
                granja.saldo = granja.saldo - precio * cant;
                existe = true;
                break
            };
        };
        if (!existe) {
            let recurso = Recurso {
                tipo,
                categoria: utf8(b"riego"),
                aumento_diario,
                usos,
            };
            granja.saldo = granja.saldo - precio * cant;
            push_back(&mut granja.recursos, recurso);
        };
    }

    // Aumenta el riego o la fertilidad
    public entry fun incrementar_indicador_cultivo(s: &signer, i_recurso: u64, i: u64) acquires EstadoGranja {
        let granja = borrow_global_mut<EstadoGranja>(signer::address_of(s));
        assert!(length(&granja.recursos) > 0, E_NO_HAY_CULTIVOS);
        let recurso = borrow_mut(&mut granja.recursos, i_recurso);
        let cultivo = borrow_mut(&mut granja.cultivos, i);
        recurso.usos = recurso.usos - 1;
        if (recurso.categoria == utf8(b"riego")) {
            cultivo.riego = cultivo.riego + recurso.aumento_diario;
            if (cultivo.riego == 100) {
                cultivo.estado = true;
                cultivo.riego = 0;
                cultivo.valor = cultivo.valor * (1 + cultivo.nivel / 10);
            };
        } else {
            cultivo.fertilidad = cultivo.fertilidad + recurso.aumento_diario;
            if (cultivo.fertilidad == 100) {
                cultivo.nivel = cultivo.nivel + 1;
                cultivo.fertilidad = 0;
            };
        };
    }

    // Aumenta la salud o la produccion.
    public entry fun incrementar_indicador_ganado(s: &signer, i_recurso: u64, i: u64) acquires EstadoGranja {
        let granja = borrow_global_mut<EstadoGranja>(signer::address_of(s));
        assert!(length(&granja.recursos) > 0, E_NO_HAY_FONDOS);
        let recurso = borrow_mut(&mut granja.recursos, i_recurso);
        let ganado = borrow_mut(&mut granja.ganado, i);
        recurso.usos = recurso.usos - 1;
        if (recurso.categoria == utf8(b"riego")) {
            ganado.salud = ganado.salud + recurso.aumento_diario;
            if (ganado.salud == 100) {
                ganado.salud = 0;
                ganado.valor = ganado.valor * (1 + ganado.nivel / 10);
            };
        } else {
            ganado.produccion = ganado.produccion + recurso.aumento_diario;
            if (ganado.produccion == 100) {
                ganado.nivel = ganado.nivel + 1;
                ganado.produccion = 0;
            };
        };
    }

    // Obtiene el estado actual de los cultivos
    #[view]
    public fun estado_cultivos(s: address): vector<Cultivo> acquires EstadoGranja {
        let cultivos = borrow_global<EstadoGranja>(s).cultivos;
        (cultivos)
    }

    // Obtiene el estado actual de la granja
    #[view]
    public fun estado_granja(s: address): (u64, u64, vector<Cultivo>, vector<Ganado>, vector<Recurso>) acquires EstadoGranja {
        let granja = borrow_global<EstadoGranja>(s);
        (granja.nivel, granja.saldo, granja.cultivos, granja.ganado, granja.recursos)
    }

    // Aumenta la  salud o la produccion.
    public entry fun incrementar_indicador(s: &signer, i_recurso: u64, i: u64) acquires EstadoGranja {
        let granja = borrow_global_mut<EstadoGranja>(signer::address_of(s));
        assert!(length(&granja.recursos) > 0, E_NO_HAY_FONDOS);
        let recurso = borrow_mut(&mut granja.recursos, i_recurso);
        let cultivo = borrow_mut(&mut granja.cultivos, i);
        recurso.usos = recurso.usos - 1;
        if (recurso.tipo == utf8(b"riego")) {
            cultivo.riego = cultivo.riego + recurso.aumento_diario;
            if (cultivo.riego == 100) {
                cultivo.estado = true;
                cultivo.riego = 0;
                cultivo.valor = cultivo.valor + cultivo.valor * (1 + cultivo.nivel / 10);
            };
        } else {
            cultivo.fertilidad = cultivo.fertilidad + recurso.aumento_diario;
            if (cultivo.fertilidad == 100) {
                cultivo.nivel = cultivo.nivel + 1;
                cultivo.fertilidad = 0;
            };
        };
    }

    // Obtiene el estado actual del ganado
    #[view]
    public fun estado_ganado(s: address): vector<Ganado> acquires EstadoGranja {
        let ganado = borrow_global<EstadoGranja>(s).ganado;
        (ganado)
    }

    // Obtiene el estado actual del saldo
    #[view]
    public fun saldo_disponible(s: address): u64 acquires EstadoGranja {
        let saldo = borrow_global<EstadoGranja>(s).saldo;
        (saldo)
    }


    // Obtiene el nivel de la granja
    #[view]
    public fun nivel_actual(s: address): u64 acquires EstadoGranja {
        let nivel = borrow_global<EstadoGranja>(s).nivel;
        (nivel)
    }
}
