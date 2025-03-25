import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:billing/domain/register-depositos/DepositoCheque.dart';
import 'package:billing/domain/register-depositos/register-depositos_repository.dart';
import 'package:billing/application/register-depositos/register-depositvos_service.dart';
import 'package:billing/domain/register-depositos/Empresa.dart';
import 'package:billing/domain/register-depositos/SocioNegocio.dart';
import 'package:billing/domain/register-depositos/BancoXCuenta.dart';
import 'package:billing/domain/register-depositos/NotaRemision.dart';
import 'package:billing/utils/image_picker_helper.dart';
import 'package:image_picker/image_picker.dart';

class ViewDepositosPorIdentificarScreen extends StatefulWidget {
  const ViewDepositosPorIdentificarScreen({super.key});

  @override
  State<ViewDepositosPorIdentificarScreen> createState() =>
      _ViewDepositosPorIdentificarScreenState();
}

class _ViewDepositosPorIdentificarScreenState
    extends State<ViewDepositosPorIdentificarScreen> {
  // Repository instance
  final DepositoRepository _depositoRepository = DepositoRepositoryImpl();
  
  // State variables for deposits
  List<DepositoCheque> _depositos = [];
  bool _isLoading = false;
  String _errorMessage = '';
  
  // Add text controllers for date fields
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  
  // Add state variables for the edit dialog
  List<Empresa> _empresas = [];
  List<SocioNegocio> _socios = [];
  List<BancoXCuenta> _bancos = [];
  List<NotaRemision> _notasRemision = [];
  List<NotaRemision> _notasRemisionSeleccionadas = [];
  
  Empresa? _empresaSeleccionada;
  SocioNegocio? _socioSeleccionado;
  BancoXCuenta? _bancoSeleccionado;
  bool _loadingSocios = false;
  bool _loadingNotasRemision = false;
  
  // For image handling
  Uint8List? _imageBytes;
  
  // For amount handling
  final TextEditingController _importeController = TextEditingController();
  final TextEditingController _aCuentaController = TextEditingController(text: '0.00');
  String _monedaSeleccionada = 'BS';
  
  final List<Map<String, String>> _monedas = [
    {'value': 'BS', 'label': 'Bolivianos'},
    {'value': 'USD', 'label': 'Dólares'},
  ];
  
  // Add date state variables
  late DateTime _startDate;
  late DateTime _endDate;
  
  @override
  void initState() {
    super.initState();
    // Initialize dates with default values
    _startDate = DateTime.now().subtract(const Duration(days: 30)); // Last 30 days
    _endDate = DateTime.now();
    
    // Set initial formatted values to controllers
    _startDateController.text = _formatDate(_startDate);
    _endDateController.text = _formatDate(_endDate);
    
    // Load initial data for edit dialog
    _cargarDatosIniciales();
  }
  
  @override
  void dispose() {
    // Clean up controllers
    _startDateController.dispose();
    _endDateController.dispose();
    _importeController.dispose();
    _aCuentaController.dispose();
    super.dispose();
  }
  
  // Load initial data (companies)
  Future<void> _cargarDatosIniciales() async {
    try {
      final empresasResult = await _depositoRepository.getEmpresas();
      setState(() {
        _empresas = empresasResult;
      });
    } catch (e) {
      _mostrarError('Error al cargar datos iniciales: $e');
    }
  }
  
  // Load clients based on selected company - with improved error handling
  Future<void> _cargarSocios(int codEmpresa) async {
    // Always reset loading state at the start
    setState(() {
      _loadingSocios = true;
      _socios = [];
    });
    
    try {
      // Add a timeout to prevent infinite loading
      final sociosResult = await _depositoRepository.getSociosNegocio(codEmpresa)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              _mostrarError('Tiempo de espera agotado al cargar clientes');
              return <SocioNegocio>[];
            },
          );
          
      // Force update the state regardless of mounted state
      if (mounted) {
        setState(() {
          _socios = sociosResult;
          _loadingSocios = false; // Explicitly set to false
        });
      }
    } catch (e) {
      _mostrarError('Error al cargar socios: $e');
    } finally {
      // Always ensure loading state is cleared, even on errors
      if (mounted && _loadingSocios) {
        setState(() {
          _loadingSocios = false;
        });
      }
    }
  }
  
  // Load banks based on selected company
  Future<void> _cargarBancos(int codEmpresa) async {
    setState(() => _isLoading = true);
    try {
      final bancosResult = await _depositoRepository.getBancos(codEmpresa);
      setState(() {
        _bancos = bancosResult;
        _bancoSeleccionado = null;
      });
    } catch (e) {
      _mostrarError('Error al cargar bancos: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  // Load remission notes based on selected company and client
  Future<void> _cargarNotasRemision(int codEmpresa, String codCliente) async {
    setState(() => _loadingNotasRemision = true);
    try {
      final notasResult = await _depositoRepository.getNotasRemision(
        codEmpresa,
        codCliente,
      );
      setState(() {
        _notasRemision = notasResult;
        _notasRemisionSeleccionadas = [];
      });
    } catch (e) {
      _mostrarError('Error al cargar notas de remisión: $e');
    } finally {
      setState(() => _loadingNotasRemision = false);
    }
  }
  
  // Helper to show error messages
  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }
  
  // Helper to show success messages
  void _mostrarMensajeExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  // Image picker methods
  Future<void> _pickImage() async {
    try {
      final result = await ImagePickerHelper.pickImage();
      if (result != null) {
        setState(() {
          _imageBytes = result.bytes;
        });
      }
    } catch (e) {
      _mostrarError('Error al seleccionar imagen: $e');
    }
  }
  
  Future<void> _pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      _mostrarError('Error al capturar imagen: $e');
    }
  }
  
  // Calculate total from selected notes
  double _calcularTotalNotasSeleccionadas() {
    if (_notasRemisionSeleccionadas.isEmpty) return 0.0;
    return _notasRemisionSeleccionadas.fold(
      0.0, (sum, nota) => sum + (nota.saldoPendiente ?? 0.0));
  }
  
  // Calculate total including "a cuenta"
  double _calcularTotalGeneral() {
    double totalNotas = _calcularTotalNotasSeleccionadas();
    double aCuenta = double.tryParse(_aCuentaController.text) ?? 0.0;
    return totalNotas + aCuenta;
  }
  
  // Update importe field with calculated total
  void _actualizarImporteTotal() {
    final total = _calcularTotalGeneral();
    _importeController.text = total.toStringAsFixed(2);
  }
  
  // Helper method to format dates consistently
  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Method to fetch deposits
  Future<void> _fetchDepositos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Call repository method - using 0 for idBxC and empty string for codCliente as specified
      final depositos = await _depositoRepository.lstDepositxIdentificar(
        0, // idBxC always 0
        _startDate,
        _endDate, 
        "", // codCliente empty
      );
      
      setState(() {
        _depositos = depositos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los depósitos: $e';
        _isLoading = false;
      });
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Depósitos por Identificar'),
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
              children: [
                _buildHeader(),
                _buildSearchForm(),
                _buildResultsTable(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.attach_money, size: 28, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Depósitos por Identificar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Busque y visualice los depósitos pendientes por identificar',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchForm() {
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
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: 200,
                child: TextFormField(
                  controller: _startDateController,
                  decoration: const InputDecoration(
                    labelText: 'Desde',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectStartDate(context),
                ),
              ),
              SizedBox(
                width: 200,
                child: TextFormField(
                  controller: _endDateController,
                  decoration: const InputDecoration(
                    labelText: 'Hasta',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectEndDate(context),
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.search, size: 18),
                label: const Text('Buscar'),
                onPressed: _isLoading ? null : () {
                  // Call fetch method when search button is pressed
                  _fetchDepositos();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsTable() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Results count header
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Resultados encontrados: ${_depositos.length}',
              style: const TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.w500
              ),
            ),
          ),
          
          // Loading indicator or error message
          if (_isLoading) 
            const Center(child: CircularProgressIndicator())
          else if (_errorMessage.isNotEmpty) 
            Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
          else if (_depositos.isEmpty)
            const Center(child: Text('No se encontraron depósitos')),
          
          // Results table
          if (_depositos.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Cliente')),
                  DataColumn(label: Text('Empresa')),
                  DataColumn(label: Text('Banco')),
                  DataColumn(label: Text('Importe')),
                  DataColumn(label: Text('Moneda')),
                                    DataColumn(label: Text('Estado')),
                  DataColumn(label: Text('Observaciones')),
                  DataColumn(label: Text('Acciones')),
                ],
                rows: _depositos.map((deposito) {
                  return DataRow(
                    cells: [
                      DataCell(Text('${deposito.idDeposito}')),
                      DataCell(Text(deposito.codCliente?.trim() ?? '-')),
                      DataCell(Text(deposito.nombreEmpresa ?? '-')),
                      DataCell(Text(deposito.nombreBanco ?? '-')),
                      DataCell(Text(_formatCurrency(deposito.importe))),
                      DataCell(Text(deposito.moneda ?? '-')),
                      DataCell(_buildEstadoIndicator(deposito.esPendiente)),
                      DataCell(Text(deposito.obs ?? '-')),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditDialog(deposito),
                              tooltip: 'Editar',
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
  
  // Helper to format currency values
  String _formatCurrency(double? amount) {
    if (amount == null) return '-';
    final formatter = NumberFormat.currency(
      symbol: '', // No currency symbol
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
  
  // Helper to format deposit dates
  String _formatDepositDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr; // Return the original string if parsing fails
    }
  }
  
  // Custom widget for estado indicator
  Widget _buildEstadoIndicator(String? estado) {
    Color color;
    IconData icon;
    
    if (estado == null || estado.isEmpty) {
      return const Text('-');
    }
    
    if (estado.toLowerCase().contains('pendiente')) {
      color = Colors.orange;
      icon = Icons.pending;
    } else if (estado.toLowerCase().contains('verificado')) {
      color = Colors.green;
      icon = Icons.check_circle;
    } else {
      color = Colors.grey;
      icon = Icons.help;
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(estado),
      ],
    );
  }

  // Update methods to handle specific date fields
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        _startDateController.text = _formatDate(_startDate);
      });
    }
  }
  
  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
        _endDateController.text = _formatDate(_endDate);
      });
    }
  }
  
  // Remove or comment out the original _selectDate method if not needed
  // Future<void> _selectDate(BuildContext context) async {
  //   // ...existing code...
  // }

  // Update to handle specific deposit with full functionality
  void _showEditDialog([DepositoCheque? deposito]) {
    // Reset form state first
    setState(() {
      _socioSeleccionado = null;
      _bancoSeleccionado = null;
      _notasRemisionSeleccionadas = [];
      _imageBytes = null;
      _aCuentaController.text = '0.00';
      _importeController.clear();
    });
    
    // Initialize with deposit data if editing
    if (deposito != null) {
      // Set empresa based on deposit
      if (deposito.codEmpresa != null) {
        _empresaSeleccionada = _empresas.firstWhere(
          (e) => e.codEmpresa == deposito.codEmpresa,
          orElse: () => Empresa(),
        );
        
        // Load socios and bancos for this empresa
        if (_empresaSeleccionada?.codEmpresa != null) {


          
          _cargarSocios(_empresaSeleccionada!.codEmpresa!);
          _cargarBancos(_empresaSeleccionada!.codEmpresa!);
        }
      }
      
      // Set amount values
      _importeController.text = deposito.importe?.toStringAsFixed(2) ?? '0.00';
      _aCuentaController.text = deposito.aCuenta?.toStringAsFixed(2) ?? '0.00';
      
      // Set currency
      _monedaSeleccionada = deposito.moneda ?? 'BS';
    }
    
    // Create a form key for validation
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          // Helper function to update both dialog state and widget state
          void setLocalState(Function() fn) {
            setState(fn);
            this.setState(fn);
          }
          
          return Dialog(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 800,
                maxHeight: 800,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dialog title
                      Row(
                        children: [
                          const Icon(Icons.edit_document, color: Colors.teal),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Actualización de Depósito',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      
                      // Dialog content in a scrollable container
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Deposit info section
                              _buildDepositInfoSection(deposito),
                              const SizedBox(height: 20),
                              
                              // Company selection
                              DropdownButtonFormField<Empresa>(
                                decoration: InputDecoration(
                                  labelText: 'Empresa',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(Icons.business),
                                ),
                                value: _empresaSeleccionada,
                                items: _empresas.map((empresa) {
                                  return DropdownMenuItem<Empresa>(
                                    value: empresa,
                                    child: Text(empresa.nombre ?? ''),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setLocalState(() {
                                    _empresaSeleccionada = value;
                                    _socioSeleccionado = null;
                                    _bancoSeleccionado = null;
                                    _notasRemisionSeleccionadas = [];
                                  });
                                  if (value != null && value.codEmpresa != null) {
                                    _cargarSocios(value.codEmpresa!);
                                    _cargarBancos(value.codEmpresa!);
                                  }
                                },
                                validator: (value) => value == null ? 'Seleccione una empresa' : null,
                              ),
                              const SizedBox(height: 16),
                              
                              // Client selection
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Cliente', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: _empresaSeleccionada == null || _loadingSocios ? null : () {
                                      // Force reset loader first to avoid UI getting stuck
                                      if (_loadingSocios) {
                                        setLocalState(() {
                                          _loadingSocios = false;
                                        });
                                        Future.delayed(const Duration(milliseconds: 100), () {
                                          _showClienteSearch(context, setState, setLocalState);
                                        });
                                      } else {
                                        _showClienteSearch(context, setState, setLocalState);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: _loadingSocios ? Colors.orange : Colors.grey.shade400,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.person, 
                                            color: _loadingSocios ? Colors.orange : Colors.teal),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: _loadingSocios
                                              ? Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 16, height: 16,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    const Text('Cargando clientes...'),
                                                  ],
                                                )
                                              : Text(
                                                  _socioSeleccionado == null
                                                    ? 'Seleccione un cliente'
                                                    : '${_socioSeleccionado!.codCliente} - ${_socioSeleccionado!.nombreCompleto}',
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                          ),
                                          Icon(
                                            _loadingSocios ? Icons.hourglass_top : Icons.arrow_drop_down,
                                            color: _loadingSocios ? Colors.orange : Colors.teal,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Bank selection
                              DropdownButtonFormField<BancoXCuenta>(
                                decoration: InputDecoration(
                                  labelText: 'Banco',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(Icons.account_balance),
                                ),
                                value: _bancoSeleccionado,
                                isExpanded: true,
                                items: _bancos.map((banco) {
                                  return DropdownMenuItem<BancoXCuenta>(
                                    value: banco,
                                    child: Text(
                                      banco.nombreBanco ?? '',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setLocalState(() => _bancoSeleccionado = value);
                                },
                                validator: (value) => value == null ? 'Seleccione un banco' : null,
                              ),
                              const SizedBox(height: 16),
                              
                              // Notas de remisión selector
                              if (_socioSeleccionado != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Notas de Remisión', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () => _showNotaRemisionSelector(context, setState, setLocalState),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.shade400),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.receipt_long, color: Colors.teal),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: _loadingNotasRemision
                                                ? const Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 16,
                                                        height: 16,
                                                        child: CircularProgressIndicator(strokeWidth: 2),
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text('Cargando notas...'),
                                                    ],
                                                  )
                                                : Text(
                                                    _notasRemisionSeleccionadas.isEmpty
                                                      ? 'Seleccionar notas de remisión'
                                                      : '${_notasRemisionSeleccionadas.length} notas seleccionadas',
                                                  ),
                                            ),
                                            const Icon(Icons.arrow_drop_down),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (_notasRemisionSeleccionadas.isNotEmpty)
                                      Container(
                                        margin: const EdgeInsets.only(top: 8),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Total: ${_formatCurrency(_calcularTotalNotasSeleccionadas())}'),
                                            const Divider(),
                                            for (var nota in _notasRemisionSeleccionadas.take(3))
                                              Text('Doc: ${nota.docNum} - ${_formatCurrency(nota.saldoPendiente)}'),
                                            if (_notasRemisionSeleccionadas.length > 3)
                                              Text('y ${_notasRemisionSeleccionadas.length - 3} más...'),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              const SizedBox(height: 16),
                              
                              // A cuenta field
                              TextFormField(
                                controller: _aCuentaController,
                                decoration: InputDecoration(
                                  labelText: 'A Cuenta',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(Icons.add_card),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Campo requerido';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Valor inválido';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  _actualizarImporteTotal();
                                  setState(() {}); // Update the dialog state
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Importe total (read-only)
                              TextFormField(
                                controller: _importeController,
                                decoration: InputDecoration(
                                  labelText: 'Importe Total',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(Icons.attach_money),
                                ),
                                readOnly: true,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Moneda dropdown
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Moneda',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(Icons.currency_exchange),
                                ),
                                value: _monedaSeleccionada,
                                items: _monedas.map((moneda) {
                                  return DropdownMenuItem<String>(
                                    value: moneda['value'],
                                    child: Text(moneda['label']!),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setLocalState(() => _monedaSeleccionada = value);
                                  }
                                },
                              ),
                              const SizedBox(height: 20),
                              
                              // Image selector
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Comprobante de Depósito',
                                        style: TextStyle(
                                          fontSize: 14, 
                                          fontWeight: FontWeight.bold
                                        )
                                    ),
                                    const SizedBox(height: 8),
                                    if (_imageBytes != null) ...[
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.memory(
                                              _imageBytes!,
                                              height: 200,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Material(
                                              color: Colors.white,
                                              shape: const CircleBorder(),
                                              child: InkWell(
                                                customBorder: const CircleBorder(),
                                                onTap: () => setLocalState(() {
                                                  _imageBytes = null;
                                                }),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Icon(Icons.close, size: 20),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            icon: const Icon(Icons.photo_library),
                                            label: Text(_imageBytes == null ? 'Galería' : 'Cambiar Imagen'),
                                            onPressed: () {
                                              _pickImage().then((_) => setState(() {}));
                                            },
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            icon: const Icon(Icons.camera_alt),
                                            label: const Text('Cámara'),
                                            onPressed: () {
                                              _pickImageFromCamera().then((_) => setState(() {}));
                                            },
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Dialog action buttons
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.save),
                            label: const Text('Guardar Cambios'),
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                _guardarDeposito(deposito, context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Method to save the deposit
  Future<void> _guardarDeposito(DepositoCheque? deposito, BuildContext context) async {
    if (_empresaSeleccionada == null ||
        _socioSeleccionado == null ||
        _bancoSeleccionado == null) {
      _mostrarError('Complete todos los campos requeridos');
      return;
    }
    
    // Check if either notes are selected or there's an "a cuenta" amount
    double aCuenta = double.tryParse(_aCuentaController.text) ?? 0.0;
    if (_notasRemisionSeleccionadas.isEmpty && aCuenta <= 0) {
      _mostrarError('Debe seleccionar al menos una nota de remisión o ingresar un monto a cuenta');
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      // Prepare the deposit object
      final depositoActualizado = DepositoCheque(
        idDeposito: deposito?.idDeposito ?? 0,
        codEmpresa: _empresaSeleccionada!.codEmpresa,
        codCliente: _socioSeleccionado!.codCliente,
        idBxC: _bancoSeleccionado!.idBxC,
        importe: double.parse(_importeController.text),
        moneda: _monedaSeleccionada,
        audUsuario: deposito?.audUsuario ?? 0,
        aCuenta: double.parse(_aCuentaController.text),
      );
      
      // Register or update the deposit
      final exito = await _depositoRepository.registrarDeposito(
        depositoActualizado,
        _imageBytes as File,
      );
      
      if (!exito) {
        _mostrarError('Error al guardar el depósito');
        setState(() => _isLoading = false);
        return;
      }
      
      // Save remission notes
      bool allNotesSaved = true;
      
      for (final nota in _notasRemisionSeleccionadas) {
        final success = await _depositoRepository.guardarNotaRemision(nota);
        
        if (!success) {
          _mostrarError('Error al guardar la nota de remisión #${nota.docNum}');
          allNotesSaved = false;
          break;
        }
      }
      
      if (allNotesSaved) {
        _mostrarMensajeExito('Depósito actualizado exitosamente');
        Navigator.pop(context); // Close the dialog
        _fetchDepositos(); // Refresh the deposits list
      } else {
        _mostrarError('El depósito se guardó pero hubo errores al guardar algunas notas');
      }
    } catch (e) {
      _mostrarError('Error al guardar el depósito: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Client search dialog
  void _showClienteSearch(BuildContext context, StateSetter setState, Function(Function()) setLocalState) {
    // Don't show if we're still loading clients
    if (_loadingSocios) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cargando lista de clientes...'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
    
    // Only show modal if we have clients loaded
    if (_socios.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay clientes disponibles para esta empresa'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _ClienteSearchModal(
          socios: _socios,
          onSelect: (cliente) {
            setLocalState(() {
              _socioSeleccionado = cliente;
            });
            Navigator.pop(context);
            
            if (_empresaSeleccionada != null && _socioSeleccionado != null) {
              _cargarNotasRemision(
                _empresaSeleccionada!.codEmpresa!,
                _socioSeleccionado!.codCliente!,
              );
            }
            
            setState(() {});  // Update dialog state
          },
        );
      },
    );
  }

  // Nota de remision selector dialog
  void _showNotaRemisionSelector(BuildContext context, StateSetter setState, Function(Function()) setLocalState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _NotaRemisionSelectorModal(
          notas: _notasRemision,
          selectedNotas: List.from(_notasRemisionSeleccionadas),
          onSave: (selectedItems) {
            setLocalState(() {
              _notasRemisionSeleccionadas = selectedItems;
              _actualizarImporteTotal();
            });
            setState(() {});  // Update dialog state
          },
        );
      },
    );
  }
  
  Widget _buildDepositInfoSection([DepositoCheque? deposito]) {
    // Fix GridView layout issues
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Información del Depósito',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // Replace GridView with more predictable layout
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('ID Depósito: ${deposito?.idDeposito ?? '-'}'),
                    ),
                    Expanded(
                      child: Text('Banco: ${deposito?.nombreBanco ?? '-'}'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Importe: ${deposito != null ? _formatCurrency(deposito.importe) : '-'} ${deposito?.moneda ?? ''}',
                      ),
                    ),
                    
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientFormSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Información del Cliente',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Código Cliente',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Nombre Cliente',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Empresa',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Banco',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsTable() {
    // Limit table height to prevent layout issues
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Documentos Disponibles',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 150, // Fixed height for table container
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Seleccionar')),
                    DataColumn(label: Text('Número Doc')),
                    DataColumn(label: Text('Num. Factura')),
                    DataColumn(label: Text('Fecha')),
                    DataColumn(label: Text('Total')),
                    DataColumn(label: Text('Saldo')),
                  ],
                  rows: const [],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsSection([DepositoCheque? deposito]) {
    final String importeStr = deposito != null ? _formatCurrency(deposito.importe) : '-';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Resumen de Importes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(child: Text('Total Documentos:')),
            Text('-'),
          ],
        ),
        Row(
          children: [
            const Expanded(child: Text('A Cuenta:')),
            Text(deposito != null ? _formatCurrency(deposito.aCuenta) : '-'), // Fixed property name from aCuenta to acuenta
          ],
        ),
        Row(
          children: [
            const Expanded(child: Text('Importe del Depósito:')),
            Text('$importeStr ${deposito?.moneda ?? ''}'),
          ],
        ),
      ],
    );
  }
}

// Client search modal component
class _ClienteSearchModal extends StatefulWidget {
  final List<SocioNegocio> socios;
  final Function(SocioNegocio) onSelect;

  const _ClienteSearchModal({
    Key? key,
    required this.socios,
    required this.onSelect,
  }) : super(key: key);

  @override
  _ClienteSearchModalState createState() => _ClienteSearchModalState();
}

class _ClienteSearchModalState extends State<_ClienteSearchModal> {
  final TextEditingController _searchController = TextEditingController();
  late List<SocioNegocio> _filteredSocios;

  @override
  void initState() {
    super.initState();
    _filteredSocios = widget.socios;
  }

  void _filterSocios(String query) {
    setState(() {
      _filteredSocios = widget.socios.where((socio) {
        final nombre = socio.nombreCompleto?.toLowerCase() ?? '';
        final codigo = socio.codCliente?.toLowerCase() ?? '';
        final search = query.toLowerCase();
        return nombre.contains(search) || codigo.contains(search);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            height: 4,
            width: 50,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.person_search, color: Colors.teal),
              const SizedBox(width: 8),
              const Text(
                'Seleccionar Cliente',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar cliente...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterSocios('');
                      },
                    )
                  : null,
            ),
            onChanged: _filterSocios,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _filteredSocios.isNotEmpty
                ? ListView.builder(
                    itemCount: _filteredSocios.length,
                    itemBuilder: (context, index) {
                      final socio = _filteredSocios[index];
                      return InkWell(
                        onTap: () => widget.onSelect(socio),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.person, color: Colors.teal),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      socio.nombreCompleto ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Código: ${socio.codCliente}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : const Center(child: Text('No se encontraron clientes')),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// Nota remision selector modal component
class _NotaRemisionSelectorModal extends StatefulWidget {
  final List<NotaRemision> notas;
  final List<NotaRemision> selectedNotas;
  final Function(List<NotaRemision>) onSave;

  const _NotaRemisionSelectorModal({
    Key? key, 
    required this.notas,
    required this.selectedNotas,
    required this.onSave,
  }) : super(key: key);

  @override
  _NotaRemisionSelectorModalState createState() => _NotaRemisionSelectorModalState();
}

class _NotaRemisionSelectorModalState extends State<_NotaRemisionSelectorModal> {
  late List<NotaRemision> _tempSelectedNotas;
  final TextEditingController _searchController = TextEditingController();
  List<NotaRemision> _filteredNotas = [];
  
  final formatCurrency = NumberFormat.currency(
    locale: 'es_BO',
    symbol: '',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _tempSelectedNotas = List.from(widget.selectedNotas);
    _filteredNotas = widget.notas;
  }
  
  double _calcularTotal() {
    return _tempSelectedNotas.fold(
        0.0, (sum, nota) => sum + (nota.saldoPendiente ?? 0.0));
  }
  
  void _filterNotas(String query) {
    setState(() {
      _filteredNotas = widget.notas.where((nota) {
        final docNum = nota.docNum?.toString().toLowerCase() ?? '';
        final numFact = nota.numFact?.toString().toLowerCase() ?? '';
        final search = query.toLowerCase();
        
        return docNum.contains(search) || 
               numFact.contains(search);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            height: 4,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Seleccionar notas de remisión',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por documento o factura...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterNotas('');
                      },
                    )
                  : null,
            ),
            onChanged: _filterNotas,
          ),
          const SizedBox(height: 16),
          
          // Summary section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Seleccionados: ${_tempSelectedNotas.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Total: ${formatCurrency.format(_calcularTotal())}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Select/deselect all buttons
          Row(
            children: [
              TextButton.icon(
                icon: const Icon(Icons.check_box_outlined),
                label: const Text('Seleccionar todos'),
                onPressed: () {
                  setState(() {
                    _tempSelectedNotas = List.from(_filteredNotas);
                  });
                },
              ),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.check_box_outline_blank),
                label: const Text('Desmarcar todos'),
                onPressed: () {
                  setState(() {
                    _tempSelectedNotas.clear();
                  });
                },
              ),
            ],
          ),
          
          // Remission notes list
          Expanded(
            child: ListView.builder(
              itemCount: _filteredNotas.length,
              itemBuilder: (context, index) {
                final nota = _filteredNotas[index];
                final isSelected = _tempSelectedNotas.any(
                  (selected) => selected.docNum == nota.docNum && 
                               selected.numFact == nota.numFact
                );
                
                final fecha = nota.fecha != null
                    ? DateFormat('dd/MM/yyyy').format(nota.fecha!)
                    : 'Sin fecha';
                    
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected ? Colors.teal : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _tempSelectedNotas.removeWhere(
                            (item) => item.docNum == nota.docNum && 
                                     item.numFact == nota.numFact
                          );
                        } else {
                          _tempSelectedNotas.add(nota);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _tempSelectedNotas.add(nota);
                                } else {
                                  _tempSelectedNotas.removeWhere(
                                    (item) => item.docNum == nota.docNum && 
                                             item.numFact == nota.numFact
                                  );
                                }
                              });
                            },
                            activeColor: Colors.teal,
                          ),
                          const SizedBox(width: 8),
                          
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.description, size: 16, color: Colors.teal),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Doc: ${nota.docNum ?? 'N/A'}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.receipt, size: 16, color: Colors.teal),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Fact: ${nota.numFact ?? 'N/A'}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Fecha: $fecha',
                                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                
                                Row(
                                  children: [
                                    const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Saldo: ${formatCurrency.format(nota.saldoPendiente ?? 0)}',
                                        style: TextStyle(
                                          fontSize: 13, 
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSave(_tempSelectedNotas);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.teal,
                    ),
                    child: const Text('Guardar selección'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}