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

    // estructura para el tipo de cultivo y ganado
    struct TipoCultivo has drop, copy {
        tipo: String,
        precio: u64,
    }

    struct TipoGanado has drop, copy {
        tipo: String,
        precio: u64,
    }

    // estructura del ganado
    struct Ganado has copy, store, drop, key {
        tipo: String,
        salud: u64,
        nivel: u64,
        cantidad: u64,
        valor: u64,
    }

    // Estructura de los cultivos
    struct Cultivo has copy, store, drop, key {
        tipo: String,
        riego: u64,
        estado: bool,
        valor: u64,
    }

    // Estado de la granja
    struct EstadoGranja has store, drop, key {
        nivel: u64,
        propietario: address,
        saldo: u64,
        cultivos: vector<Cultivo>,
        ganado: vector<Ganado>,
    }

    // inicializa los tipos de cultivo
    fun Tipo_cultivo(i: u64): (String, u64) {
        let cultivos = empty<TipoCultivo>();
        let cultivo1 = TipoCultivo { tipo: utf8(b"Maiz"), precio: 25};
        push_back(&mut cultivos, cultivo1);
        cultivo1 = TipoCultivo { tipo: utf8(b"Arroz"), precio: 50};
        push_back(&mut cultivos, cultivo1);
        let TipoCultivo {tipo, precio } = *borrow(&cultivos, i);
        (tipo, precio)
    }

    // inicializa los tipos de ganado
    fun Tipo_ganado(i: u64): (String, u64) {
        let ganados = empty<TipoGanado>();
        let ganado1 = TipoGanado { tipo: utf8(b"Conejo"), precio: 10};
        push_back(&mut ganados, ganado1);
        let ganado2 = TipoGanado { tipo: utf8(b"Obeja"), precio: 35};
        push_back(&mut ganados, ganado2);
        let ganado3 = *borrow(&ganados, i);
        (ganado3.tipo, ganado3.precio)
    }

    // Inicializa la granja
    public entry fun init_granja(s: &signer) {
        let granja = EstadoGranja {
            nivel: 1,
            propietario: signer::address_of(s),
            saldo: 100,
            cultivos: empty<Cultivo>(),
            ganado: empty<Ganado>(),
        };
        move_to(s, granja)
    }

    // Comprar un cultivo
    public entry fun comprar_cultivo(s: &signer, i: u64) acquires EstadoGranja {
        let granja = borrow_global_mut<EstadoGranja>(signer::address_of(s));
        let (tipo, precio) = Tipo_cultivo(i);
        assert!(granja.saldo >= precio, E_NO_HAY_FONDOS);
        let existe: bool = false;
        for (j in 0..length(&granja.cultivos)) {
        let g = borrow_mut(&mut granja.cultivos, j);
            if (g.tipo == tipo) {
                existe = true;
                break
            };
        };
        if (!existe) {
            let cultivo = Cultivo {
                tipo,
                riego: 0,
                estado: false,
                valor: 0,
            };
            push_back(&mut granja.cultivos, cultivo);
            granja.saldo = granja.saldo - precio;
        };
    }

    // Comprar ganado
    public entry fun comprar_ganado(s: &signer, i: u64, cantidad: u64) acquires EstadoGranja {
        let granja = borrow_global_mut<EstadoGranja>(signer::address_of(s));
        let (tipo, precio) = Tipo_ganado(i);
        assert!(granja.saldo >= precio * cantidad, E_NO_HAY_FONDOS);
        granja.saldo = granja.saldo - cantidad * precio;
        let existe: bool = false;
        for (j in 0..length(&granja.ganado)) {
        let g = borrow_mut(&mut granja.ganado, j);
            if (g.tipo == tipo) {
                g.cantidad = g.cantidad + cantidad;
                existe = true;
                break
            };
        };
        if (!existe) {
        let ganado = Ganado {
            tipo,
            salud: 0,
            nivel: 0,
            cantidad,
            valor: precio,
        };
        push_back(&mut granja.ganado, ganado);
        };
    }

    // Vende un cultivo
    public entry fun vender_cultivo(s: &signer, i: u64) acquires EstadoGranja {
        let granja = borrow_global_mut<EstadoGranja>(signer::address_of(s));
        assert!(length(&granja.cultivos) > 0, E_NO_HAY_CULTIVOS);
        if (!borrow(&granja.cultivos, i).estado) {
            let g = borrow_mut(&mut granja.cultivos, i);
            granja.saldo = granja.saldo + g.valor;
            swap_remove(&mut granja.cultivos, i);
        } else {
            abort 0
        };
    }

    // Vende ganado
    public entry fun vender_ganado(s: &signer, i: u64, cantidad_v: u64) acquires EstadoGranja {
        let granja = borrow_global_mut<EstadoGranja>(signer::address_of(s));
        assert!(length(&granja.ganado) > 0, E_NO_HAY_GANADO);
        if (borrow(&granja.ganado, i).cantidad >= cantidad_v) {
            let g = borrow_mut(&mut granja.ganado, i);
            g.cantidad = g.cantidad - cantidad_v;
            granja.saldo = granja.saldo + g.valor * cantidad_v;
            if (borrow(&granja.ganado, i).cantidad == 0) {
                swap_remove(&mut granja.ganado, i);
            };
        } else {
            abort 0
        };
    }

    // Obtiene el estado actual de los cultivos
    #[view]
    public fun estado_cultivos(s: address): vector<Cultivo> acquires EstadoGranja {
        let cultivos = borrow_global<EstadoGranja>(s).cultivos;
        (cultivos)
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
