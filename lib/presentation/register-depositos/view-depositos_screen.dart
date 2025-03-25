import 'package:flutter/material.dart';
import 'package:billing/domain/register-depositos/Empresa.dart';
import 'package:billing/domain/register-depositos/BancoXCuenta.dart';
import 'package:billing/domain/register-depositos/SocioNegocio.dart';
import 'package:billing/domain/register-depositos/register-depositos_repository.dart';
import 'package:billing/application/register-depositos/register-depositvos_service.dart';
import 'components/empresa_selector.dart';
import 'components/banco_selector.dart';
import 'components/cliente_selector.dart';
import 'package:intl/intl.dart';
import 'package:billing/domain/register-depositos/DepositoCheque.dart';

class ViewDepositosScreen extends StatefulWidget {
  const ViewDepositosScreen({super.key});

  @override
  State<ViewDepositosScreen> createState() => _ViewDepositosScreenState();
}

class _ViewDepositosScreenState extends State<ViewDepositosScreen> {
  // Repository
  final DepositoRepository _repository = DepositoRepositoryImpl();
  
  // Estado para los selectores
  List<Empresa> empresas = [];
  Empresa? selectedEmpresa;
  
  List<BancoXCuenta> bancos = [];
  BancoXCuenta? selectedBanco;
  
  List<SocioNegocio> clientes = [];
  SocioNegocio? selectedCliente;
  
  // Estado dropdown
  String? selectedEstado;
  final List<Map<String, String>> estadosDeposito = [
    { 'label': 'Todos', 'value': 'Todos' },
    { 'label': 'Verificado', 'value': 'Verificado' },
    { 'label': 'Pendiente', 'value': 'Pendiente' },
    { 'label': 'Rechazado', 'value': 'Rechazado' }
  ];
  
  // Estado de carga
  bool isLoadingEmpresas = false;
  bool isLoadingDependentData = false;

  // Controladores y valores para fechas
  final TextEditingController _fechaInicioController = TextEditingController();
  final TextEditingController _fechaFinController = TextEditingController();
  DateTime? fechaInicio;
  DateTime? fechaFin;

  // Variable para almacenar los resultados de la búsqueda
  List<DepositoCheque> depositos = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadEmpresas();
    
    // Inicializar fechas con valores por defecto (primer y último día del mes actual)
    final now = DateTime.now();
    fechaInicio = DateTime(now.year, now.month, 1);
    fechaFin = DateTime(now.year, now.month + 1, 0);
    
    // Formatear y mostrar las fechas en los inputs
    _fechaInicioController.text = DateFormat('dd/MM/yyyy').format(fechaInicio!);
    _fechaFinController.text = DateFormat('dd/MM/yyyy').format(fechaFin!);
  }

  @override
  void dispose() {
    _fechaInicioController.dispose();
    _fechaFinController.dispose();
    super.dispose();
  }

  Future<void> _loadEmpresas() async {
    setState(() {
      isLoadingEmpresas = true;
    });
    
    try {
      final empresasList = await _repository.getEmpresas();
      
      // Agregar opción "Todos" al inicio de la lista
      setState(() {
        empresas = [
          // Usando 0 como valor para "Todos", no id = null que puede causar errores
          Empresa(codEmpresa: 0, nombre: "Todos"),
          ...empresasList
        ];
        
        // Establecer "Todos" como selección predeterminada
        selectedEmpresa = empresas.first;
        
        // Inicializar las listas de bancos y clientes con "Todos"
        bancos = [BancoXCuenta(idBxC: 0, nombreBanco: "Todos")];
        clientes = [SocioNegocio(codCliente: "", nombreCompleto: "Todos")];
        
        selectedBanco = bancos.first;
        selectedCliente = clientes.first;
        selectedEstado = estadosDeposito.first['value'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar empresas: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoadingEmpresas = false;
      });
    }
  }

  Future<void> _loadBancosAndClientes() async {
    // Comprobar si se seleccionó "Todos" o si no hay empresa seleccionada
    if (selectedEmpresa == null || selectedEmpresa!.codEmpresa == 0) {
      // Si seleccionó "Todos", mantener solo la opción "Todos" en las listas dependientes
      setState(() {
        bancos = [BancoXCuenta(idBxC: 0, nombreBanco: "Todos")];
        clientes = [SocioNegocio(codCliente: "", nombreCompleto: "Todos")];
        selectedBanco = bancos.first;
        selectedCliente = clientes.first;
        isLoadingDependentData = false;
      });
      return;
    }
    
    setState(() {
      isLoadingDependentData = true;
      bancos = [];
      selectedBanco = null;
      clientes = [];
      selectedCliente = null;
    });
    
    try {
      // Cargar bancos y clientes en paralelo
      final results = await Future.wait([
        _repository.getBancos(selectedEmpresa!.codEmpresa!),
        _repository.getSociosNegocio(selectedEmpresa!.codEmpresa!)
      ]);
      
      final bancosList = results[0] as List<BancoXCuenta>;
      final clientesList = results[1] as List<SocioNegocio>;
      
      setState(() {
        // Agregar opción "Todos" al inicio de las listas
        bancos = [
          BancoXCuenta(idBxC: 0, nombreBanco: "Todos"),
          ...bancosList
        ];
        
        clientes = [
          SocioNegocio( codCliente: "", nombreCompleto: "Todos"),
          ...clientesList
        ];
        
        // Establecer "Todos" como selección predeterminada
        selectedBanco = bancos.first;
        selectedCliente = clientes.first;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoadingDependentData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta de Depósitos'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeaderSection(),
                
                // Search Form
                _buildSearchFormSection(),
                
                // Results Section
                _buildResultsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.attach_money, size: 28, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded( // Widget clave para evitar overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Consulta de Depósitos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  softWrap: true, // Añadir wrap para texto largo
                ),
                Text(
                  'Busque y visualice los depósitos registrados',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFormSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Criterios de Búsqueda',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildEmpresaDropdown(),
              _buildBancoDropdown(),
              _buildFechaInicioField(),
              _buildFechaFinField(),
              _buildClienteField(),
              _buildEstadoDropdown(),
              _buildSearchButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Resultados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${depositos.length} registros encontrados',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          isSearching 
              ? const Center(child: CircularProgressIndicator())
              : Container(
                  margin: const EdgeInsets.only(bottom: 40), // Add extra padding at bottom
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
                        dataRowMinHeight: 60, // Taller rows
                        dataRowMaxHeight: 80,
                        columnSpacing: 24, // More space between columns
                        horizontalMargin: 20, // Margin on the sides
                        columns: const [
                          DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Cliente', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Banco', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Empresa', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Importe', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Moneda', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Fecha Ingreso', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Num. Transaccion', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: depositos.isEmpty 
                            ? [
                                const DataRow(cells: [
                                  DataCell(Text('-')),
                                  DataCell(Text('-')),
                                  DataCell(Text('-')),
                                  DataCell(Text('-')),
                                  DataCell(Text('-')),
                                  DataCell(Text('-')),
                                  DataCell(Text('-')),
                                  DataCell(Text('-')),
                                  DataCell(Text('-')),
                                ])
                              ]
                            : depositos.map((deposito) => _buildDepositoRow(deposito)).toList(),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  DataRow _buildDepositoRow(DepositoCheque deposito) {
    // Debug the deposito object
    debugPrint('Deposito ID: ${deposito.idDeposito}');
    debugPrint('FechaI type: ${deposito.fechaI?.runtimeType}');
    debugPrint('FechaI value: ${deposito.fechaI}');
    
    // Helper function to format the date safely
    String formatDate(dynamic dateValue) {
      if (dateValue == null) return '';
      
      try {
        // Handle different possible types of the date field
        if (dateValue is DateTime) {
          return DateFormat('dd/MM/yyyy').format(dateValue);
        } else if (dateValue is String) {
          // Try to parse the date string
          try {
            return DateFormat('dd/MM/yyyy').format(DateTime.parse(dateValue));
          } catch (parseError) {
            // If standard format fails, try alternative formats
            try {
              // Try other date formats that might be used by the API
              final possibleFormats = [
                DateFormat('yyyy-MM-dd'),
                DateFormat('dd/MM/yyyy'),
                DateFormat('MM/dd/yyyy'),
              ];
              
              for (var format in possibleFormats) {
                try {
                  final date = format.parse(dateValue);
                  return DateFormat('dd/MM/yyyy').format(date);
                } catch (_) {
                  // Continue to next format
                }
              }
              
              // If all parsing attempts fail, return the original string
              return dateValue;
            } catch (_) {
              return dateValue;
            }
          }
        } else {
          return dateValue.toString();
        }
      } catch (e) {
        debugPrint('Error formatting date: $e');
        return dateValue?.toString() ?? '';
      }
    }

    return DataRow(
      cells: [
        DataCell(Text('${deposito.idDeposito ?? ''}')),
        DataCell(
          Container(
            constraints: const BoxConstraints(maxWidth: 250),
            child: Text(
              deposito.codCliente ?? '',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          Container(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Text(
              deposito.nombreBanco ?? '',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(Text(deposito.nombreEmpresa ?? '')),
        DataCell(
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${deposito.importe != null ? deposito.importe!.toStringAsFixed(2) : ''}',
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ),
        DataCell(Text(deposito.moneda ?? '')),
        DataCell(Text(formatDate(deposito.fechaI))),
        DataCell(Text(deposito.nroTransaccion ?? '')),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getEstadoColor(deposito.esPendiente),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              deposito.esPendiente ?? '',
              style: TextStyle(
                color: _getEstadoTextColor(deposito.esPendiente),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getEstadoColor(String? estado) {
    if (estado == null) return Colors.grey.shade200;
    
    switch (estado.toLowerCase()) {
      case 'verificado':
        return Colors.green.shade100;
      case 'pendiente':
        return Colors.yellow.shade100;
      case 'rechazado':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getEstadoTextColor(String? estado) {
    if (estado == null) return Colors.grey.shade700;
    
    switch (estado.toLowerCase()) {
      case 'verificado':
        return Colors.green.shade900;
      case 'pendiente':
        return Colors.orange.shade900;
      case 'rechazado':
        return Colors.red.shade900;
      default:
        return Colors.grey.shade700;
    }
  }

  Widget _buildEmpresaDropdown() {
    return SizedBox(
      width: 200,
      child: isLoadingEmpresas 
        ? const Center(child: CircularProgressIndicator())
        : EmpresaSelector(
            selectedEmpresa: selectedEmpresa,
            empresas: empresas,
            onChanged: (empresa) {
              setState(() {
                selectedEmpresa = empresa;
              });
              _loadBancosAndClientes();
            },
          ),
    );
  }

  Widget _buildBancoDropdown() {
    return SizedBox(
      width: 200,
      child: isLoadingDependentData 
        ? const Center(child: CircularProgressIndicator())
        : BancoSelector(
            selectedBanco: selectedBanco,
            bancos: bancos,
            onChanged: (banco) {
              setState(() {
                selectedBanco = banco;
              });
            },
            // Remover validación que causa errores cuando se selecciona "Todos"
            enableValidation: false,
          ),
    );
  }

  Widget _buildClienteField() {
    return SizedBox(
      width: 300,
      child: isLoadingDependentData
        ? const Center(child: CircularProgressIndicator())
        : ClienteSelector(
            selectedCliente: selectedCliente,
            clientes: clientes,
            onSelect: (cliente) {
              setState(() {
                selectedCliente = cliente;
              });
              // Modal se cierra automáticamente en cliente_search_modal.dart
            },
            // Permitir la selección incluso cuando se ha elegido "Todos" en empresa
            isEnabled: true,
            // No mostrar error cuando se selecciona "Todos"
            hasError: false,
          ),
    );
  }

  Widget _buildFechaInicioField() {
    return SizedBox(
      width: 200,
      child: TextFormField(
        controller: _fechaInicioController,
        decoration: const InputDecoration(
          labelText: 'Desde',
          suffixIcon: Icon(Icons.calendar_today),
        ),
        readOnly: true,
        onTap: () => _selectDate(context, isStartDate: true),
      ),
    );
  }

  Widget _buildFechaFinField() {
    return SizedBox(
      width: 200,
      child: TextFormField(
        controller: _fechaFinController,
        decoration: const InputDecoration(
          labelText: 'Hasta',
          suffixIcon: Icon(Icons.calendar_today),
        ),
        readOnly: true,
        onTap: () => _selectDate(context, isStartDate: false),
      ),
    );
  }

  Widget _buildEstadoDropdown() {
    return SizedBox(
      width: 200,
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(labelText: 'Estado'),
        value: selectedEstado,
        items: estadosDeposito.map((estado) {
          return DropdownMenuItem<String>(
            value: estado['value'],
            child: Text(estado['label']!),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedEstado = value;
          });
        },
      ),
    );
  }

  Widget _buildSearchButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.search, size: 18),
      label: const Text('Buscar/Actualizar'),
      onPressed: () async {
        // Obtener los valores de los filtros
        final codEmpresa = selectedEmpresa?.codEmpresa ?? 0;
        final idBxC = selectedBanco?.idBxC ?? 0;
        final codCliente = selectedCliente?.codCliente ?? "";
        final estado = selectedEstado ?? "Todos";
        
        // Imprimir los valores para depuración
        debugPrint('Filtros de búsqueda:');
        debugPrint('codEmpresa: $codEmpresa');
        debugPrint('idBxC: $idBxC');
        debugPrint('fechaInicio: ${fechaInicio?.toIso8601String()}');
        debugPrint('fechaFin: ${fechaFin?.toIso8601String()}');
        debugPrint('codCliente: $codCliente');
        debugPrint('estadoFiltro: $estado');
        
        // Iniciar búsqueda
        setState(() {
          isSearching = true;
        });
        
        try {
          final results = await _repository.obtenerDepositos(
            codEmpresa, 
            idBxC, 
            fechaInicio!, 
            fechaFin!, 
            codCliente, 
            estado
          );
          
          setState(() {
            depositos = results;
            isSearching = false;
          });
          
          debugPrint('Resultados encontrados: ${depositos.length}');
          
        } catch (e) {
          setState(() {
            isSearching = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al buscar depósitos: ${e.toString()}')),
          );
        }
      },
    );
  }

  Future<void> _selectDate(BuildContext context, {required bool isStartDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? (fechaInicio ?? DateTime.now()) : (fechaFin ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          fechaInicio = picked;
          _fechaInicioController.text = DateFormat('dd/MM/yyyy').format(picked);
        } else {
          fechaFin = picked;
          _fechaFinController.text = DateFormat('dd/MM/yyyy').format(picked);
        }
      });
    }
  }
}