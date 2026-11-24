import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

import 'db.dart';

typedef Fila = Map<String, Object?>;

void toast(BuildContext c, String m) =>
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m)));

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await AppDb.instance;
    runApp(const CreditosApp());
  } catch (e, st) {
    runApp(MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Error al abrir la base')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SelectableText('$e\n\n$st'),
        ),
      ),
    ));
  }
}

class CreditosApp extends StatelessWidget {
  const CreditosApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Créditos',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
        home: const HomePage(),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _i = 0;
  final _pages = const [PersonasPage(), SolicitudesPage(), BasePage()];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: _pages[_i],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _i,
          onDestinationSelected: (v) => setState(() => _i = v),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.people), label: 'Personas'),
            NavigationDestination(
                icon: Icon(Icons.request_quote), label: 'Solicitudes'),
            NavigationDestination(
                icon: Icon(Icons.storage), label: 'Base de datos'),
          ],
        ),
      );
}

// ===================================================================
// PERSONAS (clientes y avales)
// ===================================================================
class PersonasPage extends StatefulWidget {
  const PersonasPage({super.key});

  @override
  State<PersonasPage> createState() => _PersonasPageState();
}

class _PersonasPageState extends State<PersonasPage> {
  late Future<List<Fila>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Fila>> _load() async {
    final db = await AppDb.instance;
    return db.rawQuery('''
      SELECT id, tipo_persona, nombre, apellido_paterno, apellido_materno,
             telefono_celular, curp, fecha_nacimiento,
             CAST((julianday('now') - julianday(fecha_nacimiento)) / 365.25
                  AS INTEGER) AS edad
      FROM personas
      ORDER BY creado_en DESC
    ''');
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _nueva() async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const PersonaForm(),
    );
    if (ok == true) _reload();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Clientes y avales')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _nueva,
          icon: const Icon(Icons.person_add),
          label: const Text('Nueva persona'),
        ),
        body: FutureBuilder<List<Fila>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(child: Text('Error: ${snap.error}'));
            }
            final filas = snap.data!;
            if (filas.isEmpty) {
              return const Center(child: Text('Aún no hay personas'));
            }
            return ListView.separated(
              itemCount: filas.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final f = filas[i];
                final nombre =
                    '${f['nombre']} ${f['apellido_paterno']} ${f['apellido_materno'] ?? ''}'
                        .trim();
                final esCliente = f['tipo_persona'] == 'CLIENTE';
                return ListTile(
                  leading: CircleAvatar(
                    child: Icon(esCliente ? Icons.person : Icons.shield),
                  ),
                  title: Text(nombre),
                  subtitle: Text(
                    '${f['tipo_persona']} · ${f['edad']} años'
                    '${f['telefono_celular'] != null ? ' · ${f['telefono_celular']}' : ''}',
                  ),
                );
              },
            );
          },
        ),
      );
}

class PersonaForm extends StatefulWidget {
  const PersonaForm({super.key});

  @override
  State<PersonaForm> createState() => _PersonaFormState();
}

class _PersonaFormState extends State<PersonaForm> {
  final _key = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _paterno = TextEditingController();
  final _materno = TextEditingController();
  final _tel = TextEditingController();
  final _curp = TextEditingController();
  String _tipo = 'CLIENTE';
  DateTime? _fecha;
  bool _guardando = false;

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null;

  Future<void> _elegirFecha() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _fecha ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _fecha = d);
  }

  Future<void> _guardar() async {
    if (!_key.currentState!.validate()) return;
    if (_fecha == null) {
      toast(context, 'Elige la fecha de nacimiento');
      return;
    }
    setState(() => _guardando = true);
    try {
      final db = await AppDb.instance;
      final pid = AppDb.newId();
      final curp = _curp.text.trim().toUpperCase();
      await db.transaction((tx) async {
        await tx.insert('personas', {
          'id': pid,
          'tipo_persona': _tipo,
          'nombre': _nombre.text.trim(),
          'apellido_paterno': _paterno.text.trim(),
          'apellido_materno':
              _materno.text.trim().isEmpty ? null : _materno.text.trim(),
          'fecha_nacimiento': _fecha!.toIso8601String().substring(0, 10),
          'curp': curp.isEmpty ? null : curp,
          'telefono_celular': _tel.text.trim().isEmpty ? null : _tel.text.trim(),
        });
        if (_tipo == 'CLIENTE') {
          await tx.insert(
              'clientes', {'id': AppDb.newId(), 'persona_id': pid});
        } else {
          await tx.insert('avales', {'id': AppDb.newId(), 'persona_id': pid});
        }
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      toast(context, 'No se pudo guardar: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        child: Form(
          key: _key,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'CLIENTE', label: Text('Cliente')),
                    ButtonSegment(value: 'AVAL', label: Text('Aval')),
                  ],
                  selected: {_tipo},
                  onSelectionChanged: (s) => setState(() => _tipo = s.first),
                ),
                TextFormField(
                    controller: _nombre,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: _req),
                TextFormField(
                    controller: _paterno,
                    decoration:
                        const InputDecoration(labelText: 'Apellido paterno'),
                    validator: _req),
                TextFormField(
                    controller: _materno,
                    decoration:
                        const InputDecoration(labelText: 'Apellido materno')),
                TextFormField(
                    controller: _curp,
                    maxLength: 18,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(labelText: 'CURP')),
                TextFormField(
                    controller: _tel,
                    keyboardType: TextInputType.phone,
                    decoration:
                        const InputDecoration(labelText: 'Teléfono celular')),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _elegirFecha,
                  icon: const Icon(Icons.cake),
                  label: Text(_fecha == null
                      ? 'Fecha de nacimiento'
                      : _fecha!.toIso8601String().substring(0, 10)),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _guardando ? null : _guardar,
                  child: Text(_guardando ? 'Guardando…' : 'Guardar'),
                ),
              ],
            ),
          ),
        ),
      );
}

// ===================================================================
// SOLICITUDES DE CRÉDITO
// ===================================================================
class SolicitudesPage extends StatefulWidget {
  const SolicitudesPage({super.key});

  @override
  State<SolicitudesPage> createState() => _SolicitudesPageState();
}

class _SolicitudesPageState extends State<SolicitudesPage> {
  late Future<List<Fila>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Fila>> _load() async {
    final db = await AppDb.instance;
    return db.rawQuery('''
      SELECT s.folio_solicitud, s.monto_solicitado, s.total_a_pagar,
             s.pago_semanal, s.plazo_semanas, s.estatus,
             pc.nombre || ' ' || pc.apellido_paterno AS cliente
      FROM solicitudes_credito s
      JOIN clientes c  ON c.id  = s.cliente_id
      JOIN personas pc ON pc.id = c.persona_id
      ORDER BY s.creado_en DESC
    ''');
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _nueva() async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const SolicitudForm(),
    );
    if (ok == true) _reload();
  }

  String _m(Object? v) => '\$${(v as num).toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Solicitudes de crédito')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _nueva,
          icon: const Icon(Icons.add),
          label: const Text('Nueva solicitud'),
        ),
        body: FutureBuilder<List<Fila>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(child: Text('Error: ${snap.error}'));
            }
            final filas = snap.data!;
            if (filas.isEmpty) {
              return const Center(child: Text('Aún no hay solicitudes'));
            }
            return ListView.separated(
              itemCount: filas.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final f = filas[i];
                return ListTile(
                  title: Text('${f['cliente']} · ${_m(f['monto_solicitado'])}'),
                  subtitle: Text(
                    '${f['folio_solicitud']}\n'
                    'Total ${_m(f['total_a_pagar'])} · '
                    '${f['plazo_semanas']} pagos de ${_m(f['pago_semanal'])}',
                  ),
                  isThreeLine: true,
                  trailing: Chip(label: Text('${f['estatus']}')),
                );
              },
            );
          },
        ),
      );
}

class SolicitudForm extends StatefulWidget {
  const SolicitudForm({super.key});

  @override
  State<SolicitudForm> createState() => _SolicitudFormState();
}

class _SolicitudFormState extends State<SolicitudForm> {
  final _monto = TextEditingController();
  List<Fila> _clientes = [];
  List<Fila> _avales = [];
  List<Fila> _zonas = [];
  String? _clienteId;
  String? _avalId;
  int? _zonaId;
  bool _cargando = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final db = await AppDb.instance;
    final clientes = await db.rawQuery('''
      SELECT c.id, p.nombre || ' ' || p.apellido_paterno AS nombre
      FROM clientes c JOIN personas p ON p.id = c.persona_id
      ORDER BY p.nombre
    ''');
    final avales = await db.rawQuery('''
      SELECT a.id, p.nombre || ' ' || p.apellido_paterno AS nombre
      FROM avales a JOIN personas p ON p.id = a.persona_id
      ORDER BY p.nombre
    ''');
    final zonas = await db
        .rawQuery('SELECT id, nombre FROM zonas WHERE activa = 1 ORDER BY nombre');
    if (!mounted) return;
    setState(() {
      _clientes = clientes;
      _avales = avales;
      _zonas = zonas;
      _zonaId = zonas.isNotEmpty ? zonas.first['id'] as int : null;
      _cargando = false;
    });
  }

  List<DropdownMenuItem<T>> _items<T>(List<Fila> filas) => filas
      .map((f) => DropdownMenuItem<T>(
            value: f['id'] as T,
            child: Text('${f['nombre']}'),
          ))
      .toList();

  Future<void> _guardar() async {
    final monto = double.tryParse(_monto.text.replaceAll(',', '').trim());
    if (_clienteId == null ||
        _avalId == null ||
        _zonaId == null ||
        monto == null ||
        monto <= 0) {
      toast(context, 'Completa cliente, aval, zona y un monto válido');
      return;
    }
    setState(() => _guardando = true);
    try {
      final db = await AppDb.instance;
      // total_a_pagar y pago_semanal los calcula SQLite (columnas generadas).
      await db.insert('solicitudes_credito', {
        'id': AppDb.newId(),
        'folio_solicitud': 'SOL-${DateTime.now().millisecondsSinceEpoch}',
        'cliente_id': _clienteId,
        'aval_id': _avalId,
        'zona_id': _zonaId,
        'monto_solicitado': monto,
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      toast(context, 'No se pudo guardar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const SizedBox(
          height: 200, child: Center(child: CircularProgressIndicator()));
    }
    if (_clientes.isEmpty || _avales.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text(
            'Primero registra al menos un cliente y un aval en la pestaña Personas.'),
      );
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Cliente'),
              items: _items<String>(_clientes),
              onChanged: (v) => _clienteId = v,
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Aval'),
              items: _items<String>(_avales),
              onChanged: (v) => _avalId = v,
            ),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Zona'),
              value: _zonaId,
              items: _items<int>(_zonas),
              onChanged: (v) => _zonaId = v,
            ),
            TextField(
              controller: _monto,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                  labelText: 'Monto solicitado', prefixText: '\$ '),
            ),
            const SizedBox(height: 8),
            const Text(
              'Plazo: 15 semanas · Factor: 1.425 (se calcula el total y el pago semanal).',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _guardando ? null : _guardar,
              child: Text(_guardando ? 'Guardando…' : 'Guardar solicitud'),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================================================================
// BASE DE DATOS: ruta, conteos, exportar e importar
// ===================================================================
class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  static const _tablas = [
    'usuarios', 'zonas', 'sucursales', 'empleados', 'personas',
    'referencias_familiares', 'clientes', 'avales', 'solicitudes_credito',
    'creditos', 'plan_pagos', 'pagos', 'claves_confirmacion',
    'movimientos_efectivo', 'auditoria',
  ];
  late Future<Map<String, int>> _conteos;
  late Future<String> _ruta;

  @override
  void initState() {
    super.initState();
    _refrescar();
  }

  void _refrescar() {
    _ruta = AppDb.dbPath();
    _conteos = _contar();
  }

  Future<Map<String, int>> _contar() async {
    final db = await AppDb.instance;
    final r = <String, int>{};
    for (final t in _tablas) {
      r[t] = Sqflite.firstIntValue(
              await db.rawQuery('SELECT COUNT(*) FROM $t')) ??
          0;
    }
    return r;
  }

  Future<void> _exportar() async {
    try {
      final db = await AppDb.instance;
      await db.rawQuery('PRAGMA wal_checkpoint(TRUNCATE)');
      final path = await AppDb.dbPath();
      await Share.shareXFiles([XFile(path)], text: 'creditos.db');
    } catch (e) {
      if (mounted) toast(context, 'No se pudo exportar: $e');
    }
  }

  /// Guarda una copia visible en el teléfono (Descargas, Drive, etc.)
  /// para abrirla después con la app SQLite Browser.
  Future<void> _guardarCopia() async {
    try {
      final db = await AppDb.instance;
      await db.rawQuery('PRAGMA wal_checkpoint(TRUNCATE)');
      final bytes = await File(await AppDb.dbPath()).readAsBytes();
      final destino = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar copia de la base',
        fileName: 'creditos.db',
        bytes: bytes,
      );
      if (destino != null && mounted) toast(context, 'Copia guardada');
    } catch (e) {
      if (mounted) toast(context, 'No se pudo guardar: $e');
    }
  }

  Future<void> _importar() async {
    final r = await FilePicker.platform.pickFiles();
    final path = r?.files.single.path;
    if (path == null || !mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Reemplazar base de datos'),
        content: const Text(
            'Se sustituirán TODOS los datos actuales por los del archivo elegido.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Reemplazar')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await AppDb.replaceWith(path);
      await AppDb.instance;
      if (!mounted) return;
      setState(_refrescar);
      toast(context, 'Base importada correctamente');
    } catch (e) {
      if (mounted) toast(context, 'No se pudo importar: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Base de datos')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FutureBuilder<String>(
              future: _ruta,
              builder: (_, s) => SelectableText('Archivo: ${s.data ?? '…'}'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _exportar,
              icon: const Icon(Icons.ios_share),
              label: const Text('Exportar / compartir creditos.db'),
            ),
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              onPressed: _guardarCopia,
              icon: const Icon(Icons.save_alt),
              label: const Text('Guardar copia en el teléfono'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _importar,
              icon: const Icon(Icons.file_open),
              label: const Text('Importar creditos.db'),
            ),
            const Divider(height: 32),
            const Text('Registros por tabla',
                style: TextStyle(fontWeight: FontWeight.bold)),
            FutureBuilder<Map<String, int>>(
              future: _conteos,
              builder: (_, s) {
                if (!s.hasData) {
                  return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()));
                }
                return Column(
                  children: s.data!.entries
                      .map((e) => ListTile(
                            dense: true,
                            title: Text(e.key),
                            trailing: Text('${e.value}'),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      );
}
