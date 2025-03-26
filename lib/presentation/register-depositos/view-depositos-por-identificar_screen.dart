import 'dart:async';
import 'package:billing/presentation/register-depositos/edit-deposito-identificar_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:billing/domain/register-depositos/DepositoCheque.dart';
import 'package:billing/domain/register-depositos/register-depositos_repository.dart';
import 'package:billing/application/register-depositos/register-depositvos_service.dart';
import 'package:billing/domain/register-depositos/Empresa.dart';
import 'package:billing/domain/register-depositos/SocioNegocio.dart';

import 'package:billing/domain/register-depositos/NotaRemision.dart';



// High-performance direct search client component

class ClienteSearchField extends StatefulWidget {
  final DepositoRepository repository;
  final Empresa? empresa;
  final SocioNegocio? initialValue;
  final Function(SocioNegocio) onSelect;
  final bool enabled;

  const ClienteSearchField({
    Key? key,
    required this.repository,
    required this.empresa,
    this.initialValue,
    required this.onSelect,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<ClienteSearchField> createState() => _ClienteSearchFieldState();
}

class _ClienteSearchFieldState extends State<ClienteSearchField> {
  // We'll use a debounced search timer
  Timer? _debounceTimer;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Cliente', style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        InkWell(
          onTap: !widget.enabled || widget.empresa == null ? null : () {
            _showSearchDialog(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: widget.enabled ? Colors.grey.shade400 : Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
              color: widget.enabled ? null : Colors.grey.shade50,
            ),
            child: Row(
              children: [
                const Icon(Icons.person, color: Colors.teal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.initialValue == null
                      ? 'Buscar cliente...'
                      : '${widget.initialValue!.codCliente} - ${widget.initialValue!.nombreCompleto}',
                    style: TextStyle(
                      color: widget.initialValue == null ? Colors.grey.shade600 : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.search, color: Colors.teal),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _DirectSearchDialog(
        repository: widget.repository,
        empresa: widget.empresa!,
        onSelect: (cliente) {
          widget.onSelect(cliente);
          Navigator.pop(context);
        },
      ),
    );
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

// Highly optimized direct search dialog
class _DirectSearchDialog extends StatefulWidget {
  final DepositoRepository repository;
  final Empresa empresa;
  final Function(SocioNegocio) onSelect;

  const _DirectSearchDialog({
    Key? key,
    required this.repository,
    required this.empresa,
    required this.onSelect,
  }) : super(key: key);

  @override
  State<_DirectSearchDialog> createState() => _DirectSearchDialogState();
}

class _DirectSearchDialogState extends State<_DirectSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  List<SocioNegocio> _searchResults = [];
  bool _isSearching = false;
  String _errorMessage = '';
  bool _hasSearched = false;
  
  // Track recent selections for quick access
  List<SocioNegocio> _recentSelections = [];
  bool _showRecents = true;
  
  @override
  void initState() {
    super.initState();
    // We could load recent selections from local storage here
    _searchController.addListener(_onSearchChanged);
  }
  
  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _showRecents = true;
        _searchResults = [];
        _isSearching = false;
        _hasSearched = false;
      });
      return;
    }
    
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      final query = _searchController.text;
      if (query.length >= 3) {
        _performSearch(query);
      } else {
        setState(() {
          _showRecents = true;
          _searchResults = [];
          _hasSearched = false;
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.length < 3) return;
    
    setState(() {
      _isSearching = true;
      _errorMessage = '';
      _showRecents = false;
    });
    
    try {
      // Load a small subset of clients from server based on search query
      // Since we don't have a direct API for searching clients, we'll simulate it
      final allClients = await widget.repository.getSociosNegocio(widget.empresa.codEmpresa!);
      
      // Filter locally - in a real app, this filtering would be done on the server
      final filteredClients = allClients.where((client) {
        final nombre = client.nombreCompleto?.toLowerCase() ?? '';
        final codigo = client.codCliente?.toLowerCase() ?? '';
        final searchLower = query.toLowerCase();
        return nombre.contains(searchLower) || codigo.contains(searchLower);
      }).take(20).toList(); // Only take first 20 results for performance
      
      setState(() {
        _searchResults = filteredClients;
        _isSearching = false;
        _hasSearched = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al buscar clientes: $e';
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.search, color: Colors.teal),
                const SizedBox(width: 8),
                const Text(
                  'Buscar Cliente',
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
            
            // Search box
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Ingrese al menos 3 caracteres para buscar',
                  prefixIcon: const Icon(Icons.person_search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                ),
                autofocus: true,
              ),
            ),
            
            // Status messages
            if (_isSearching)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('Buscando clientes...'),
                  ],
                ),
              ),
              
            if (_errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_errorMessage, style: const TextStyle(color: Colors.red))),
                  ],
                ),
              ),
              
            if (_hasSearched && _searchResults.isEmpty && !_isSearching)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No se encontraron clientes con "${_searchController.text}"',
                        style: const TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
              
            if (!_hasSearched && _searchController.text.length < 3 && _searchResults.isEmpty && !_isSearching && !_showRecents)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Ingrese al menos 3 caracteres para iniciar la búsqueda',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Results list
            Expanded(
              child: _hasSearched 
                ? ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final cliente = _searchResults[index];
                      return _buildClientItem(cliente);
                    },
                  )
                : _showRecents && _recentSelections.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('Selecciones recientes:', 
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _recentSelections.length,
                            itemBuilder: (context, index) {
                              final cliente = _recentSelections[index];
                              return _buildClientItem(cliente);
                            },
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'Busque un cliente por nombre o código',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildClientItem(SocioNegocio cliente) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => widget.onSelect(cliente),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.teal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cliente.nombreCompleto ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Código: ${cliente.codCliente}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }
}

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
  

  // For amount handling
  final TextEditingController _importeController = TextEditingController();
  final TextEditingController _aCuentaController = TextEditingController(text: '0.00');
  
  
  // Add date state variables
  late DateTime _startDate;
  late DateTime _endDate;
  
  Timer? _notesResetTimer;
  Timer? _bankResetTimer;

  @override
  void initState() {
    super.initState();
    // Initialize dates with default values
    _startDate = DateTime.now().subtract(const Duration(days: 30)); // Last 30 days
    _endDate = DateTime.now();
    
    // Set initial formatted values to controllers
    _startDateController.text = _formatDate(_startDate);
    _endDateController.text = _formatDate(_endDate);
    
    
  }
  
  @override
  void dispose() {
    // Clean up controllers
    _startDateController.dispose();
    _endDateController.dispose();
    _importeController.dispose();
    _aCuentaController.dispose();
    _notesResetTimer?.cancel();
    _bankResetTimer?.cancel();
    super.dispose();
  }
  
  
  // Load banks based on selected company // Helper to show error messages
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
                            ElevatedButton.icon(
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text('Editar'),
                              onPressed: () => _showEditDialog(deposito),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                textStyle: const TextStyle(fontSize: 12),
                              ),
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
    if (deposito == null) {
      _mostrarError('No se puede editar un depósito vacío');
      return;
    }
    
    // Navigate to the edit screen instead of showing a dialog
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDepositoScreen(
          deposito: deposito,
          onSaved: () {
            // Refresh the list when we return after saving
            _fetchDepositos();
            _mostrarMensajeExito('Depósito actualizado correctamente');
          },
        ),
      ),
    );
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