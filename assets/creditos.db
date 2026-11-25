-- =====================================================
-- Esquema de créditos - versión SQLite (para celular)
-- Adaptado desde PostgreSQL
-- =====================================================
PRAGMA foreign_keys = ON;

-- NOTA: los UUID se generan automáticamente con un DEFAULT.
-- Las fechas se guardan como TEXT en formato ISO-8601 (UTC).

CREATE TABLE usuarios (
    id TEXT PRIMARY KEY DEFAULT (lower(
        hex(randomblob(4)) || '-' || hex(randomblob(2)) || '-4' ||
        substr(hex(randomblob(2)),2) || '-' ||
        substr('89ab', abs(random()) % 4 + 1, 1) ||
        substr(hex(randomblob(2)),2) || '-' || hex(randomblob(6)))),
    correo TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    nombre_completo TEXT NOT NULL,
    telefono TEXT,
    rol TEXT NOT NULL CHECK (rol IN
        ('CLIENTE','AGENTE','GERENTE','DIRECTOR','ADMINISTRADOR')),
    activo INTEGER NOT NULL DEFAULT 1 CHECK (activo IN (0,1)),
    creado_en TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE zonas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    estado TEXT NOT NULL DEFAULT 'Puebla',
    municipio TEXT NOT NULL,
    activa INTEGER NOT NULL DEFAULT 1 CHECK (activa IN (0,1))
);

CREATE TABLE sucursales (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    zona_id INTEGER NOT NULL REFERENCES zonas(id),
    nombre TEXT NOT NULL,
    direccion TEXT,
    activa INTEGER NOT NULL DEFAULT 1 CHECK (activa IN (0,1))
);

CREATE TABLE empleados (
    id TEXT PRIMARY KEY DEFAULT (lower(
        hex(randomblob(4)) || '-' || hex(randomblob(2)) || '-4' ||
        substr(hex(randomblob(2)),2) || '-' ||
        substr('89ab', abs(random()) % 4 + 1, 1) ||
        substr(hex(randomblob(2)),2) || '-' || hex(randomblob(6)))),
    usuario_id TEXT UNIQUE NOT NULL REFERENCES usuarios(id),
    nombre TEXT NOT NULL,
    apellido_paterno TEXT NOT NULL,
    apellido_materno TEXT,
    puesto TEXT NOT NULL CHECK (puesto IN
        ('AGENTE','GERENTE','DIRECTOR','ADMINISTRADOR')),
    zona_id INTEGER REFERENCES zonas(id),
    sucursal_id INTEGER REFERENCES sucursales(id),
    activo INTEGER NOT NULL DEFAULT 1 CHECK (activo IN (0,1))
);

CREATE TABLE personas (
    id TEXT PRIMARY KEY DEFAULT (lower(
        hex(randomblob(4)) || '-' || hex(randomblob(2)) || '-4' ||
        substr(hex(randomblob(2)),2) || '-' ||
        substr('89ab', abs(random()) % 4 + 1, 1) ||
        substr(hex(randomblob(2)),2) || '-' || hex(randomblob(6)))),
    tipo_persona TEXT NOT NULL CHECK (tipo_persona IN ('CLIENTE','AVAL')),

    nombre TEXT NOT NULL,
    apellido_paterno TEXT NOT NULL,
    apellido_materno TEXT,
    fecha_nacimiento TEXT NOT NULL,          -- formato YYYY-MM-DD
    -- 'edad' ya no es columna: SQLite no permite 'now' en columnas
    -- generadas. Usa la vista vista_personas (más abajo).
    sexo_genero TEXT,
    estado_civil TEXT,
    curp TEXT UNIQUE,
    telefono_celular TEXT,

    calle TEXT,
    numero_exterior TEXT,
    numero_interior TEXT,
    colonia TEXT,
    poblacion TEXT,
    ciudad_municipio TEXT,
    estado TEXT,
    codigo_postal TEXT,
    entre_calle_1 TEXT,
    entre_calle_2 TEXT,
    referencia_direccion TEXT,

    nivel_estudios TEXT,
    profesion_ocupacion TEXT,
    dependientes_economicos INTEGER,
    empresa_trabajo TEXT,
    direccion_empleo TEXT,
    telefono_empleo TEXT,

    ingreso_semanal NUMERIC,
    ingreso_mensual NUMERIC,
    gasto_mensual NUMERIC,
    renta_vivienda_mensual NUMERIC,
    gasto_television NUMERIC,
    gasto_gas NUMERIC,
    gasto_luz NUMERIC,
    gasto_alimentos NUMERIC,
    gasto_pasajes NUMERIC,
    gasto_escuela NUMERIC,
    gasto_ropa_calzado NUMERIC,

    pareja_familiar_cercano TEXT,
    creado_en TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
    actualizado_en TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE referencias_familiares (
    id TEXT PRIMARY KEY DEFAULT (lower(
        hex(randomblob(4)) || '-' || hex(randomblob(2)) || '-4' ||
        substr(hex(randomblob(2)),2) || '-' ||
        substr('89ab', abs(random()) % 4 + 1, 1) ||
        substr(hex(randomblob(2)),2) || '-' || hex(randomblob(6)))),
    persona_id TEXT NOT NULL REFERENCES personas(id) ON DELETE CASCADE,
    orden INTEGER NOT NULL CHECK (orden IN (1,2)),
    nombre TEXT NOT NULL,
    telefono TEXT,
    direccion TEXT,
    parentesco TEXT
);

CREATE TABLE clientes (
    id TEXT PRIMARY KEY DEFAULT (lower(
        hex(randomblob(4)) || '-' || hex(randomblob(2)) || '-4' ||
        substr(hex(randomblob(2)),2) || '-' ||
        substr('89ab', abs(random()) % 4 + 1, 1) ||
        substr(hex(randomblob(2)),2) || '-' || hex(randomblob(6)))),
    persona_id TEXT UNIQUE NOT NULL REFERENCES personas(id),
    usuario_id TEXT UNIQUE REFERENCES usuarios(id),
    zona_id INTEGER REFERENCES zonas(id),
    agente_id TEXT REFERENCES empleados(id),
    gerente_id TEXT REFERENCES empleados(id),
    estatus TEXT NOT NULL DEFAULT 'PROSPECTO'
        CHECK (estatus IN
        ('PROSPECTO','EN_VALIDACION','APROBADO','RECHAZADO','ACTIVO','INACTIVO','MOROSO')),
    creado_en TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE avales (
    id TEXT PRIMARY KEY DEFAULT (lower(
        hex(randomblob(4)) || '-' || hex(randomblob(2)) || '-4' ||
        substr(hex(randomblob(2)),2) || '-' ||
        substr('89ab', abs(random()) % 4 + 1, 1) ||
        substr(hex(randomblob(2)),2) || '-' || hex(randomblob(6)))),
    persona_id TEXT UNIQUE NOT NULL REFERENCES personas(id),
    parentesco_cliente TEXT,
    activo INTEGER NOT NULL DEFAULT 1 CHECK (activo IN (0,1)),
    creado_en TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE solicitudes_credito (
    id TEXT PRIMARY KEY DEFAULT (lower(
        hex(randomblob(4)) || '-' || hex(randomblob(2)) || '-4' ||
        substr(hex(randomblob(2)),2) || '-' ||
        substr('89ab', abs(random()) % 4 + 1, 1) ||
        substr(hex(randomblob(2)),2) || '-' || hex(randomblob(6)))),
    folio_solicitud TEXT UNIQUE NOT NULL,
    cliente_id TEXT NOT NULL REFERENCES clientes(id),
    aval_id TEXT NOT NULL REFERENCES avales(id),
    zona_id INTEGER NOT NULL REFERENCES zonas(id),
    monto_solicitado NUMERIC NOT NULL CHECK (monto_solicitado > 0),
    plazo_semanas INTEGER NOT NULL DEFAULT 15,
    factor_recargo NUMERIC NOT NULL DEFAULT 1.4250,
    total_a_pagar NUMERIC GENERATED ALWAYS AS
        (ROUND(monto_solicitado * factor_recargo, 2)) STORED,
    pago_semanal NUMERIC GENERATED ALWAYS AS
        (ROUND((monto_solicitado * factor_recargo) / plazo_semanas, 2)) STORED,
    estatus TEXT NOT NULL DEFAULT 'CAPTURADA'
        CHECK (estatus IN
        ('CAPTURADA','EN_VERIFICACION','APROBADA','RECHAZADA','DESEMBOLSADA','CANCELADA')),
    agente_id TEXT REFERENCES empleados(id),
    gerente_id TEXT REFERENCES empleados(id),
    creado_en TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE creditos (
    id TEXT PRIMARY KEY DEFAULT (lower(
        hex(randomblob(4)) || '-' || hex(randomblob(2)) || '-4' ||
        substr(hex(randomblob(2)),2) || '-' ||
        substr('89ab', abs(random()) % 4 + 1, 1) ||
        substr(hex(randomblob(2)),2) || '-' || hex(randomblob(6)))),
    folio_contrato TEXT UNIQUE NOT NULL,
    solicitud_id TEXT UNIQUE NOT NULL REFERENCES solicitudes_credito(id),
    cliente_id TEXT NOT NULL REFERENCES clientes(id),
    aval_id TEXT NOT NULL REFERENCES avales(id),
    agente_id TEXT NOT NULL REFERENCES empleados(id),
    gerente_id TEXT NOT NULL REFERENCES empleados(id),
    monto_solicitado NUMERIC NOT NULL,
    factor_recargo NUMERIC NOT NULL,
    total_a_pagar NUMERIC NOT NULL,
    pago_semanal NUMERIC NOT NULL,
    plazo_semanas INTEGER NOT NULL,
    fecha_inicio TEXT NOT NULL,
    primer_pago TEXT NOT NULL,
    fecha_fin TEXT NOT NULL,
    saldo_pendiente NUMERIC NOT NULL,
    estatus TEXT NOT NULL DEFAULT 'ACTIVO'
        CHECK (estatus IN
        ('ACTIVO','PAGADO','VENCIDO','CANCELADO','REESTRUCTURADO')),
    desembolsado_en TEXT,
    desembolso_domicilio TEXT,
    creado_en TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE plan_pagos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    credito_id TEXT NOT NULL REFERENCES creditos(id) ON DELETE CASCADE,
    numero_pago INTEGER NOT NULL,
    fecha_vencimiento TEXT NOT NULL,
    monto_programado NUMERIC NOT NULL,
    monto_pagado NUMERIC NOT NULL DEFAULT 0,
    estatus TEXT NOT NULL DEFAULT 'PENDIENTE'
        CHECK (estatus IN ('PENDIENTE','PAGADO','PARCIAL','VENCIDO')),
    UNIQUE (credito_id, numero_pago)
);

CREATE TABLE pagos (
    id TEXT PRIMARY KEY DEFAULT (lower(
        hex(randomblob(4)) || '-' || hex(randomblob(2)) || '-4' ||
        substr(hex(randomblob(2)),2) || '-' ||
        substr('89ab', abs(random()) % 4 + 1, 1) ||
        substr(hex(randomblob(2)),2) || '-' || hex(randomblob(6)))),
    credito_id TEXT NOT NULL REFERENCES creditos(id),
    plan_pago_id INTEGER REFERENCES plan_pagos(id),
    monto NUMERIC NOT NULL CHECK (monto > 0),
    forma_pago TEXT NOT NULL DEFAULT 'EFECTIVO',
    fecha_pago TEXT NOT NULL,
    hora_pago TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
    lugar_pago TEXT,
    coordenadas_gps TEXT,
    agente_cobrador_id TEXT NOT NULL REFERENCES empleados(id),
    estatus TEXT NOT NULL DEFAULT 'PENDIENTE_CONFIRMACION'
        CHECK (estatus IN
        ('PENDIENTE_CONFIRMACION','CONFIRMADO','ANULADO','RECHAZADO')),
    creado_en TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE claves_confirmacion (
    id TEXT PRIMARY KEY DEFAULT (lower(
        hex(randomblob(4)) || '-' || hex(randomblob(2)) || '-4' ||
        substr(hex(randomblob(2)),2) || '-' ||
        substr('89ab', abs(random()) % 4 + 1, 1) ||
        substr(hex(randomblob(2)),2) || '-' || hex(randomblob(6)))),
    tipo_operacion TEXT NOT NULL CHECK (tipo_operacion IN
        ('PAGO_CLIENTE_AGENTE','EFECTIVO_AGENTE_GERENTE','EFECTIVO_GERENTE_ADMIN','DEPOSITO_BANCO')),
    referencia_id TEXT NOT NULL,
    monto NUMERIC NOT NULL,
    clave_hash TEXT NOT NULL,
    clave_visible TEXT NOT NULL,
    generado_por TEXT NOT NULL REFERENCES usuarios(id),
    confirmado_por TEXT REFERENCES usuarios(id),
    expira_en TEXT NOT NULL,
    confirmado_en TEXT,
    intentos INTEGER NOT NULL DEFAULT 0,
    usado INTEGER NOT NULL DEFAULT 0 CHECK (usado IN (0,1)),
    anulado INTEGER NOT NULL DEFAULT 0 CHECK (anulado IN (0,1)),
    creado_en TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE movimientos_efectivo (
    id TEXT PRIMARY KEY DEFAULT (lower(
        hex(randomblob(4)) || '-' || hex(randomblob(2)) || '-4' ||
        substr(hex(randomblob(2)),2) || '-' ||
        substr('89ab', abs(random()) % 4 + 1, 1) ||
        substr(hex(randomblob(2)),2) || '-' || hex(randomblob(6)))),
    tipo_movimiento TEXT NOT NULL CHECK (tipo_movimiento IN
        ('DESEMBOLSO','COBRO','ENTREGA_AGENTE_GERENTE','ENTREGA_GERENTE_ADMIN','DEPOSITO_BANCO','AJUSTE')),
    referencia_id TEXT,
    monto NUMERIC NOT NULL,
    responsable_entrega_id TEXT REFERENCES empleados(id),
    responsable_recibe_id TEXT REFERENCES empleados(id),
    clave_confirmacion_id TEXT REFERENCES claves_confirmacion(id),
    fecha_hora TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
    lugar TEXT,
    estatus TEXT NOT NULL DEFAULT 'PENDIENTE'
        CHECK (estatus IN ('PENDIENTE','CONFIRMADO','ANULADO'))
);

CREATE TABLE auditoria (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    usuario_id TEXT REFERENCES usuarios(id),
    tabla_afectada TEXT NOT NULL,
    registro_id TEXT,
    accion TEXT NOT NULL,
    datos_antes TEXT,        -- JSON como texto
    datos_despues TEXT,      -- JSON como texto
    direccion_ip TEXT,
    dispositivo TEXT,
    fecha_hora TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

-- =====================================================
-- Vista con la edad calculada (reemplaza la columna 'edad')
-- =====================================================
CREATE VIEW vista_personas AS
SELECT p.*,
       CAST((julianday('now') - julianday(fecha_nacimiento)) / 365.25 AS INTEGER) AS edad
FROM personas p;

-- =====================================================
-- Triggers: mantener actualizado 'actualizado_en'
-- =====================================================
CREATE TRIGGER trg_personas_actualizado
AFTER UPDATE ON personas
FOR EACH ROW
BEGIN
    UPDATE personas
       SET actualizado_en = strftime('%Y-%m-%dT%H:%M:%fZ','now')
     WHERE id = NEW.id;
END;

-- =====================================================
-- Índices recomendados
-- =====================================================
CREATE INDEX idx_clientes_agente     ON clientes(agente_id);
CREATE INDEX idx_clientes_zona       ON clientes(zona_id);
CREATE INDEX idx_solicitudes_cliente ON solicitudes_credito(cliente_id);
CREATE INDEX idx_creditos_cliente    ON creditos(cliente_id);
CREATE INDEX idx_creditos_agente     ON creditos(agente_id);
CREATE INDEX idx_plan_pagos_credito  ON plan_pagos(credito_id, fecha_vencimiento);
CREATE INDEX idx_pagos_credito       ON pagos(credito_id);
CREATE INDEX idx_pagos_agente        ON pagos(agente_cobrador_id, fecha_pago);
CREATE INDEX idx_claves_referencia   ON claves_confirmacion(referencia_id);
CREATE INDEX idx_mov_efectivo_ref    ON movimientos_efectivo(referencia_id);
CREATE INDEX idx_auditoria_tabla     ON auditoria(tabla_afectada, registro_id);
